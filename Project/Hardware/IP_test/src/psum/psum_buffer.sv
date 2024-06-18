`define DW_SIZE 1600
`define PW_SIZE /*5408*/6272
`define OFMAP_ADDR 8192
`define OFMAP_DATA_SIZE 4
module psum_buffer (
	input 		 		clk,
	input		 		rst,
	// psum
    input        		psum_valid [15:0],
    input [15:0] 		psum_addr  [15:0],
	input [7:0]  		psum_data  [15:0],
	// mode
	input [1:0]  		mode,
	input    	 		store_is,
	output logic 		store_done,
	// output sram
	output logic [3:0]  DM_WEB,
	output logic [13:0] DM_A,
	output logic [31:0] DM_DI
);
	logic [7:0] psum_spad [8191:0];
	// ofmap memory
	logic [15:0] psum_addr_sram;

	enum logic[3:0]{
		IDLE_PSUM,
		STORE_BUF,
		STORE_SRAM
	}cs_psum, ns_psum;
	always @(posedge clk or posedge	rst) begin
		if (rst) cs_psum <= IDLE_PSUM;
		else cs_psum <= ns_psum;
	end
	always_comb begin
		case (cs_psum)
			IDLE_PSUM : ns_psum = (mode===0)? IDLE_PSUM : STORE_BUF;
			STORE_BUF : ns_psum = (store_is===1'b1)? STORE_SRAM : STORE_BUF ;
			STORE_SRAM : ns_psum = (store_done===1'b1) ? IDLE_PSUM : STORE_SRAM ;
		endcase
	end
	always_ff @(posedge clk) begin
		if (rst) begin
			for(int i=0; i<8192; i++) psum_spad[i] <= 0;
		end else if (cs_psum == STORE_BUF) begin
			for (int i=0; i<16; i++) begin
				if (psum_valid[i]) psum_spad[(psum_addr[i])] <= psum_data[i];
				else ;
			end			
		end else ;
	end
	// =============== psum ===================
	always_comb begin
		if ((psum_addr_sram+`OFMAP_DATA_SIZE)>=`PW_SIZE) store_done = 1;
		else store_done = 0;
	end
	always_ff @(posedge clk or posedge rst) begin
		if(rst) psum_addr_sram <= 0;
		else if (cs_psum==STORE_SRAM) psum_addr_sram <= psum_addr_sram+4;
		else psum_addr_sram <= 0;
	end
	// write to output sram
	always_comb begin
		if (cs_psum==STORE_SRAM) DM_WEB = 0;
		else DM_WEB = 4'b1111;
	end
	always_comb begin
		DM_DI = {psum_spad[psum_addr_sram],
						psum_spad[psum_addr_sram+1],
						psum_spad[psum_addr_sram+2],
						psum_spad[psum_addr_sram+3]};
	end
	always_ff @(posedge clk or posedge rst) begin
		if(rst) DM_A <= `OFMAP_ADDR;
		else if (cs_psum==STORE_SRAM) DM_A <= DM_A+1;
		else ;
	end
endmodule