`include "./../../include/AXI_define.svh"
module DMA_wrapper(
	input clk,
	input rst,
	
	//Slave
	input [`AXI_IDS_BITS-1:0] 	AWID,
	input [`AXI_ADDR_BITS-1:0] 	AWADDR,
	input [`AXI_LEN_BITS-1:0] 	AWLEN,
	input [`AXI_SIZE_BITS-1:0] 	AWSIZE,
	input [1:0] 				AWBURST,
	input 						AWVALID,
	output 						AWREADY,
	// WRITE DATA
	input [`AXI_DATA_BITS-1:0] 	WDATA,
	input [`AXI_STRB_BITS-1:0] 	WSTRB,
	input 						WLAST,
	input					 	WVALID,
	output 						WREADY,
	// WRITE RESPONSE
	output [`AXI_IDS_BITS-1:0] 	BID,
	output [1:0] 				BRESP,
	output 						BVALID,
	input 						BREADY,

	//Master0
	//READ ADDRESS0
	output [`AXI_ID_BITS-1:0]   ARID_M0,
	output [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output [`AXI_LEN_BITS-1:0]  ARLEN_M0,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	output [1:0]                ARBURST_M0,
	output                      ARVALID_M0,
	input                       ARREADY_M0,
	//READ DATA0
	input [`AXI_ID_BITS-1:0]    RID_M0,
	input [`AXI_DATA_BITS-1:0]  RDATA_M0,
	input [1:0]                 RRESP_M0,
	input                       RLAST_M0,
	input                       RVALID_M0,
	output                      RREADY_M0,

	//Master1
	output [`AXI_ID_BITS-1:0]   AWID_M1,
	output [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output [`AXI_LEN_BITS-1:0]  AWLEN_M1,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output [1:0]                AWBURST_M1,
	output                      AWVALID_M1,
	input                       AWREADY_M1,
	//WRITE DATA
	output [`AXI_DATA_BITS-1:0] WDATA_M1,
	output [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output                      WLAST_M1,
	output                      WVALID_M1,
	input                       WREADY_M1,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0]    BID_M1, 
	input [1:0]                 BRESP_M1,
	input                       BVALID_M1,
	output                      BREADY_M1,

    input 						wfi_signal,
    output logic 				interrupt_dma_done
);

logic [3:0] dmareg_wen;
logic [31:0] dmareg_addr;
logic [31:0] dmareg_data;
logic [31:0] current_addr_read;
logic [31:0] current_addr_write;
logic read_signal;


logic [31:0] data_into_fifo, data_from_fifo;
logic rvalid_out;

logic full, empty;
logic wr_en, rd_en, rd_en_delay;

logic [3:0] w_en;

always_ff@(posedge clk or negedge rst)begin
	if(~rst) rd_en_delay<=1'b0;
	else rd_en_delay<=rd_en;
end

DMA_controller DMA_controller(
    .clk(clk),
    .rst(~rst),
    .wfi_signal(wfi_signal),
    .dmareg_wen(dmareg_wen),
    .dmareg_addr(dmareg_addr),
    .dmareg_data(dmareg_data),
    .read_signal(read_signal),
    .current_addr_read(current_addr_read),
	.current_addr_write(current_addr_write),
    .done(interrupt_dma_done),
	.BVALID(BVALID_M1),
	.BREADY(BREADY_M1),
	.RLAST(RLAST_M0)
);

Slave_Write SW(
    .ACLK(clk),
    .ARESETn(~rst),
    .AWID(AWID),
    .AWADDR(AWADDR), 
    .AWLEN(AWLEN), 
    .AWSIZE(AWSIZE), 
    .AWBURST(AWBURST),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WLAST(WLAST),
    .WVALID(WVALID),
    .WREADY(WREADY),

    .BID(BID),
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),

    .data_out(dmareg_data),
    .address_out(dmareg_addr),
    .w_en_out(dmareg_wen), 
    .isnot_FREE(), 
    .select(2'b0)
);


Master_Read1 MR(
	.ACLK(clk), 
	.ARESETn(rst),
	.ARID(ARID_M0), 
	.ARADDR(ARADDR_M0), 
	.ARLEN(ARLEN_M0), 
	.ARSIZE(ARSIZE_M0), 
	.ARBURST(ARBURST_M0), 
	.ARVALID(ARVALID_M0), 
	.ARREADY(ARREADY_M0),

	.RID(RID_M0), 
	.RDATA(RDATA_M0), 
	.RRESP(RRESP_M0),
	.RLAST(RLAST_M0), 
	.RVALID(RVALID_M0), 
	.RREADY(RREADY_M0),

	.read_signal(read_signal), 
	.address_in(current_addr_read), 
	.id_in(4'b1),

	.data_out(data_into_fifo), 
	.stall_IF(), 
	.rvalid_out(),

	.MW_state(2'b0), 
	.MW_nstate(2'b0),
	.state(), 
	.nstate()
);

assign wr_en=(RVALID_M0 && ~full)?1'b1:1'b0;
assign rd_en=(~empty)?1'b1:1'b0;


////fifo////
sync_fifo#(32,16) fifo
(
    .clk(clk),
    .rst(~rst),
    .wr_en(wr_en),
    .wdata(data_into_fifo),
    .rd_en(rd_en),
    .rdata(data_from_fifo),
    .full(full),
    .empty(empty)
);

assign w_en=(rd_en)?4'b1111:4'b0000;

Master_Write1 MW(
	.ACLK(clk), 
	.ARESETn(rst),
	.AWID(AWID_M1), 
	.AWADDR(AWADDR_M1), 
	.AWLEN(AWLEN_M1), 
	.AWSIZE(AWSIZE_M1),
	.AWBURST(AWBURST_M1), 
	.AWVALID(AWVALID_M1), 
	.AWREADY(AWREADY_M1),
	
	.WDATA(WDATA_M1), 
	.WSTRB(WSTRB_M1), 
	.WLAST(WLAST_M1), 
	.WVALID(WVALID_M1), 
	.WREADY(WREADY_M1),

	.BID(BID_M1), 
	.BRESP(BRESP_M1), 
	.BVALID(BVALID_M1), 
	.BREADY(BREADY_M1), 

	.address_in(current_addr_write), 
	.w_en(w_en), //
	.data_in(data_from_fifo), 
	.id_in(4'b1), 
	.write_signal(rd_en), //

	.stall_W(),

	.state(), 
	.nstate(),
	.MR_state(2'b0), 
	.MR_nstate(2'b0),
	.rd_en(rd_en_delay)
);


endmodule