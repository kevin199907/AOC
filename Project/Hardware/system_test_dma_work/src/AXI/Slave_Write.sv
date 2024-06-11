 `include "AXI_define.svh"
module Slave_Write(
    input ACLK,
	input ARESETn,
    // WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	// WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	// WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,

    output logic [31:0] data_out, address_out,
    output logic [3:0] w_en_out,
    output logic isnot_FREE,

	input logic [1:0] select
);

localparam  FREE = 2'd0,
            SEND_DATA = 2'd1,
            SEND_B = 2'd2;

logic [1:0] state, nstate;

logic [7:0] BID_reg;
logic [31:0] AWADDR_reg;

assign isnot_FREE=state[0];

always@(posedge ACLK or posedge ARESETn)begin
    if(ARESETn) state<=FREE;
    else state<=nstate;
end

//next state logic
always@(*)begin
    case(state)
    FREE:begin
        if(AWVALID) nstate=SEND_DATA;
        else nstate=FREE;
    end
    SEND_DATA:begin
        if(WLAST && WVALID && WREADY) nstate=SEND_B;
        else nstate=SEND_DATA;
    end
    SEND_B:begin
	if(BREADY && BVALID) nstate=FREE;
	else nstate=SEND_B;
    end
    default: nstate=FREE;
    endcase
end

//output logic
always@(*)begin
    case(state)
    FREE:begin

	if(select==2'd3) AWREADY=1'b0;
	else AWREADY=1'b1;

	//AWREADY=1'b1;

        // if(nstate==SEND_DATA) WREADY=1'b1;
        // else WREADY=1'b0;

        WREADY=1'b0;

        BID=AWID;
        BRESP=2'b0;
        BVALID=1'b0;

        data_out=32'b0;
        address_out=32'b0;

        w_en_out=4'b0000;
    end
    SEND_DATA:begin
        AWREADY=1'b1;

        WREADY=1'b1;

        BID=BID_reg;
        //resp要想
        BRESP=2'b0;
        BVALID=1'b0;

        data_out=WDATA;
        address_out=AWADDR_reg;

        w_en_out=WSTRB;
    end
    SEND_B:begin

        AWREADY=1'b1;

        WREADY=1'b1;

        BID=BID_reg;
        //resp要想
        BRESP=2'b0;
        BVALID=1'b1;

        data_out=32'b0;
        address_out=32'b0;

        w_en_out=4'b0000;
    end
    default: /*BID=BID_reg;*/begin
        AWREADY=1'b0;

        WREADY=1'b0;

        BID=8'b0;
        //resp要想
        BRESP=2'b0;
        BVALID=1'b0;

        data_out=32'b0;
        address_out=32'b0;

        w_en_out=4'b0000;
    end
    endcase
end

always_ff@(posedge ACLK or posedge ARESETn  )begin
	if(ARESETn)begin
		BID_reg<=8'b0;
        AWADDR_reg<=32'b0;
	end
	else begin
		case(state)
		FREE: begin
			BID_reg<=AWID;
            AWADDR_reg<=AWADDR;
		end	
		SEND_DATA: begin
			BID_reg<=BID_reg;
            AWADDR_reg<=AWADDR_reg;
		end
		SEND_B: begin	
			BID_reg<=BID_reg;
            AWADDR_reg<=AWADDR_reg;

		end
		default: begin
			BID_reg<=BID_reg;
            AWADDR_reg<=AWADDR_reg;
		end
		endcase
	end

end



endmodule
