// `include "ALU.sv"
// `include "Controller.sv"
// `include "CSR.sv"
// `include "Decoder.sv"
// `include "Imm_Ext.sv"
// `include "JB_Unit.sv"
// `include "LD_Filter.sv"
// `include "Mul.sv"
// `include "Mux_3.sv"
// `include "MUX_fordelay.sv"
// `include "Mux.sv"
// `include "Reg_EXE_MEM.sv"
// `include "Reg_ID_EXE.sv"
// `include "Reg_IF_ID.sv"
// `include "Reg_MEM_WB.sv"
// `include "Reg_PC.sv"
// `include "RegFile.sv"
// // `include "SRAM_wrapper.sv"
// `include "wen_shift.sv"
// `include "Adder.sv"
// // `include "Slave_Read.sv"
// `include "Master_Read.sv"
// //`include "Bridge_Read.sv"
// `include "Master_Write.sv"
// // `include "Slave_Write.sv"
// //`include "Bridge_Write.sv"
`include "AXI_define.svh"
module CPU_wrapper (
    input clk,
    input rst,
	// input clk2,
	// input rst2,

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
	//READ ADDRESS1
	output [`AXI_ID_BITS-1:0]   ARID_M1,
	output [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output [`AXI_LEN_BITS-1:0]  ARLEN_M1,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output [1:0]                ARBURST_M1,
	output                      ARVALID_M1,
	input                       ARREADY_M1,
	//READ DATA1
	input [`AXI_ID_BITS-1:0]    RID_M1,
	input [`AXI_DATA_BITS-1:0]  RDATA_M1,
	input [1:0]                 RRESP_M1,
	input                       RLAST_M1,
	input                       RVALID_M1,
	output                      RREADY_M1,

	input interrupt_e,
	input interrupt_t,
	output wfi_signal
);

//---------------declare------------//
logic read_signal_IM, stall_IM, rvalid_out0, read_signal, stall_DM;
logic rvalid_out1, write_signal, stall_W;
logic [31:0] pc_32, inst, alu_mul_csr, ld_data, rs2_data_RegM_out, inst_RegM, alu_mul_csr_L1c,alu_mul_csr_delay;
logic [1:0] MW_nstate,MW_state, MR_state,MR_nstate;
logic [3:0] M_dm_w_en_out;
logic [3:0] id_in_W;

logic read_signal_IM_I, read_signal_L1c;
logic [31:0] pc_32_L1c, inst_L1c, rs2_data_RegM_out_L1c, ld_data_L1c;
logic stall_IM_L1c, req, write_signal_L1c;

// //M0 afifo declare
// //
// logic [`AXI_ID_BITS-1:0] ARID_M0_out;
// logic [`AXI_ADDR_BITS-1:0] ARADDR_M0_out;
// logic [`AXI_LEN_BITS-1:0] ARLEN_M0_out;
// logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0_out;
// logic [1:0] ARBURST_M0_out;
// logic ARVALID_M0_out;
// logic ARREADY_M0_out;
// // READ DATA
// logic [`AXI_ID_BITS-1:0] RID_M0_out;
// logic [`AXI_DATA_BITS-1:0] RDATA_M0_out;
// logic [1:0] RRESP_M0_out;
// logic RLAST_M0_out;
// logic RVALID_M0_out;
// logic RREADY_M0_out;

// //M1 afifo declare
// //
// logic [`AXI_ID_BITS-1:0] ARID_M1_out;
// logic [`AXI_ADDR_BITS-1:0] ARADDR_M1_out;
// logic [`AXI_LEN_BITS-1:0] ARLEN_M1_out;
// logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1_out;
// logic [1:0] ARBURST_M1_out;
// logic ARVALID_M1_out;
// logic ARREADY_M1_out;
// // READ DATA
// logic [`AXI_ID_BITS-1:0] RID_M1_out;
// logic [`AXI_DATA_BITS-1:0] RDATA_M1_out;
// logic [1:0] RRESP_M1_out;
// logic RLAST_M1_out;
// logic RVALID_M1_out;
// logic RREADY_M1_out;
// // WRITE ADDRESS
// logic [`AXI_ID_BITS-1:0] AWID_M1_out;
// logic [`AXI_ADDR_BITS-1:0] AWADDR_M1_out;
// logic [`AXI_LEN_BITS-1:0] AWLEN_M1_out;
// logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1_out;
// logic [1:0] AWBURST_M1_out;
// logic AWVALID_M1_out;
// logic AWREADY_M1_out;
// // WRITE DATA
// logic [`AXI_DATA_BITS-1:0] WDATA_M1_out;
// logic [`AXI_STRB_BITS-1:0] WSTRB_M1_out;
// logic WLAST_M1_out;
// logic WVALID_M1_out;
// logic WREADY_M1_out;
// // BBBBB
// logic [`AXI_ID_BITS-1:0] BID_M1_out;
// logic [1:0] BRESP_M1_out;
// logic BVALID_M1_out;
// logic BREADY_M1_out;




//---------------declare------------//
logic hit_data;
CPU cpu(
    .clk(clk),
    .rst(rst),
	//M0 port
	.read_signal_IM(read_signal_IM), 
	.pc_32(pc_32), 
	.inst(inst_L1c), 
	.stall_IM(stall_IM_L1c), 
	.rvalid_out0(rvalid_out0),
	//M1 read port
	.read_signal(read_signal), 
	.alu_mul_csr(alu_mul_csr), 
	.ld_data/*_in*/(ld_data_L1c), 
	.stall_DM(stall_DM_L1c), 
	.rvalid_out1(rvalid_out1),
	//M1 write port
	.M_dm_w_en_out(M_dm_w_en_out), 
	.rs2_data_RegM_out(rs2_data_RegM_out), 
	.id_in_W(id_in_W), 
	.write_signal(write_signal),
	.inst_RegM(inst_RegM),

	.stall_W(stall_W),

	.interrupt_e(interrupt_e),
	.interrupt_t(interrupt_t),
	.hit_data(hit_data),
	.wfi_signal(wfi_signal)
);

L1C_inst l1c_inst(
  .clk(clk),
  .rst(rst),
  // Core to CPU wrapper
  .core_addr(pc_32),
  .core_req(1'b1),
  // from CPU wrapper
  .I_out(inst),
  .cacheD_wait(stall_DM_L1c),
  // CPU wrapper to core
  .core_out(inst_L1c),
  .core_wait(stall_IM_L1c),
  // to CPU wrapper
  .I_req(read_signal_IM_L1c),
  .I_addr(pc_32_L1c),

  .RVALID(RVALID_M0), 
  .RLAST(RLAST_M0),
  .stall_DM(stall_DM_L1c) 
);

Master_Read MR(
	.ACLK(clk), 
	.ARESETn(~rst),
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

	.read_signal(/*(pc_32[6:0]!=7'b0000000)*//*1'b1*/read_signal_IM_L1c), 
	.address_in(pc_32_L1c), 
	.id_in(4'b1),
	.data_out(inst), 
	.stall_IF(stall_IM), 
	.rvalid_out(rvalid_out0),

	.MW_state(MW_state), 
	.MW_nstate(MW_nstate),
	.state(MR_state), 
	.nstate(MR_nstate)
);

assign req=write_signal | read_signal;

// logic [31:0] alu_mul_csr_mux;

// assign alu_mul_csr_mux=(req)?alu_mul_csr:alu_mul_csr_delay;

// always@(posedge clk )begin
//     if(rst)begin
//         alu_mul_csr_delay<=32'b0;
//     end
//     else begin
// 		if(req)	alu_mul_csr_delay<=alu_mul_csr;
// 		else alu_mul_csr_delay<=alu_mul_csr_delay;
//     end
// end
L1C_data l1c_data(
  .clk(clk),
  .rst(rst),
  // Core to CPU wrapper
  .core_addr(alu_mul_csr/*_mux*/),
  .core_req(req),
  .core_write(write_signal),
  .core_in(rs2_data_RegM_out),
  .core_type(inst_RegM[14:12]),
  // CPU wrapper to Mem
  .D_req(read_signal_L1c),
  .D_addr(alu_mul_csr_L1c),
  .D_write(write_signal_L1c),
  .D_in(rs2_data_RegM_out_L1c),
  .D_type(),
  // Mem to CPU wrapper
  .D_out(ld_data),
  .cacheI_wait(stall_IM_L1c),
  // CPU wrapper to core
  .core_out(ld_data_L1c),
  .core_wait(stall_DM_L1c),

  .BVALID(BVALID_M1), 
  .BREADY(BREADY_M1),
  .RLAST(RLAST_M1), 
  .RVALID(RVALID_M1),
  .hit_data(hit_data)
);


Master_Read MR1(
	.ACLK(clk), 
	.ARESETn(~rst),
	.ARID(ARID_M1), 
	.ARADDR(ARADDR_M1), 
	.ARLEN(ARLEN_M1), 
	.ARSIZE(ARSIZE_M1), 
	.ARBURST(ARBURST_M1), 
	.ARVALID(ARVALID_M1), 
	.ARREADY(ARREADY_M1),

	.RID(RID_M1), 
	.RDATA(RDATA_M1), 
	.RRESP(RRESP_M1),
	.RLAST(RLAST_M1), 
	.RVALID(RVALID_M1), 
	.RREADY(RREADY_M1),

	.read_signal(read_signal_L1c), 
	.address_in(alu_mul_csr_L1c), 
	.id_in(4'd2),
	.data_out(ld_data), 
	.stall_IF(stall_DM), 
	.rvalid_out(rvalid_out1),

	.MW_state(2'b0), 
	.MW_nstate(2'b0),
	.state(), 
	.nstate()
);

Master_Write MW(
	.ACLK(clk), 
	.ARESETn(~rst),
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

	.address_in(alu_mul_csr_L1c), 
	.w_en(M_dm_w_en_out), 
	.data_in(rs2_data_RegM_out_L1c), 
	.id_in(id_in_W), 
	.write_signal(write_signal_L1c),

	.stall_W(stall_W),

	.state(MW_state), 
	.nstate(MW_nstate),
	.MR_state(MR_state), 
	.MR_nstate(MR_nstate)
);

///////////////////////////////M0 afifo////////////////////
// /////AR channel
// AR_wrapper AR_M0(
//         .clock(clk),
//         .clock2(clk2),//
//         .reset(rst),
//         .reset2(rst2),//
//         .ARID   (ARID_M0_out),
//         .ARADDR (ARADDR_M0_out),
//         .ARLEN  (ARLEN_M0_out),
//         .ARSIZE (ARSIZE_M0_out),
//         .ARBURST(ARBURST_M0_out),
//         .ARVALID(ARVALID_M0_out),
//         //
//         .ARREADY_out(ARREADY_M0_out),// from slave
//         ////
//         .ARID_out   (ARID_M0),
//         .ARADDR_out (ARADDR_M0),
//         .ARLEN_out  (ARLEN_M0),
//         .ARSIZE_out (ARSIZE_M0),
//         .ARBURST_out(ARBURST_M0),
//         .ARVALID_out(ARVALID_M0),
//         //
//         .ARREADY(ARREADY_M0)// from master
// );
// /////R channel
// R_wrapper R_M0(
//         .clock(clk),
//         .clock2(clk2),//
//         .reset(rst),
//         .reset2(rst2),//
//         .RID    (RID_M0),
//         .RDATA  (RDATA_M0),
//         .RRESP  (RRESP_M0),
//         .RLAST  (RLAST_M0),
//         .RVALID (RVALID_M0),
//         //
//         .RREADY_out (RREADY_M0),
//         ////
//         .RID_out   (RID_M0_out),
//         .RDATA_out  (RDATA_M0_out),
//         .RRESP_out  (RRESP_M0_out),
//         .RLAST_out  (RLAST_M0_out),
//         .RVALID_out (RVALID_M0_out),
//         //
//         .RREADY(RREADY_M0_out)
// );

///////////////////////////////////////////////////////////

// ///////////////////////////////M1 afifo////////////////////
// /////AR channel
// AR_wrapper AR(
//         .clock(clk),
//         .clock2(clk2),//
//         .reset(rst),
//         .reset2(rst2),//
//         .ARID   (ARID_M1_out),
//         .ARADDR (ARADDR_M1_out),
//         .ARLEN  (ARLEN_M1_out),
//         .ARSIZE (ARSIZE_M1_out),
//         .ARBURST(ARBURST_M1_out),
//         .ARVALID(ARVALID_M1_out),
//         //
//         .ARREADY_out(ARREADY_M1_out),// from slave
//         ////
//         .ARID_out   (ARID_M1),
//         .ARADDR_out (ARADDR_M1),
//         .ARLEN_out  (ARLEN_M1),
//         .ARSIZE_out (ARSIZE_M1),
//         .ARBURST_out(ARBURST_M1),
//         .ARVALID_out(ARVALID_M1),
//         //
//         .ARREADY(ARREADY_M1)// from master
// );
// /////R channel
// R_wrapper R(
//         .clock(clk),
//         .clock2(clk2),//
//         .reset(rst),
//         .reset2(rst2),//
//         .RID    (RID_M1),
//         .RDATA  (RDATA_M1),
//         .RRESP  (RRESP_M1),
//         .RLAST  (RLAST_M1),
//         .RVALID (RVALID_M1),
//         //
//         .RREADY_out (RREADY_M1),
//         ////
//         .RID_out   (RID_M1_out),
//         .RDATA_out  (RDATA_M1_out),
//         .RRESP_out  (RRESP_M1_out),
//         .RLAST_out  (RLAST_M1_out),
//         .RVALID_out (RVALID_M1_out),
//         //
//         .RREADY(RREADY_M1_out)
// );

// /////AW channel
// AW_wrapper AW(
//         .clock(clk),
//         .clock2(clk2),//
//         .reset(rst),
//         .reset2(rst2),//
//         .AWID   (AWID_M1_out),
//         .AWADDR (AWADDR_M1_out),
//         .AWLEN  (AWLEN_M1_out),
//         .AWSIZE (AWSIZE_M1_out),
//         .AWBURST(AWBURST_M1_out),
//         .AWVALID(AWVALID_M1_out),
//         //
//         .AWREADY_out(AWREADY_M1_out),// from slave
//         ////
//         .AWID_out   (AWID_M1),
//         .AWADDR_out (AWADDR_M1),
//         .AWLEN_out  (AWLEN_M1),
//         .AWSIZE_out (AWSIZE_M1),
//         .AWBURST_out(AWBURST_M1),
//         .AWVALID_out(AWVALID_M1),
//         //
//         .AWREADY(AWREADY_M1)// from master
// );
// /////W channel
// W_wrapper W(
//         .clock(clk),
//         .clock2(clk2),//
//         .reset(rst),
//         .reset2(rst2),//
// 		    //
//         .WDATA  (WDATA_M1_out),
//         .WSTRB  (WSTRB_M1_out),
//         .WLAST  (WLAST_M1_out),
//         .WVALID (WVALID_M1_out),
//         .WREADY_out (WREADY_M1_out),//
// 		    ////
// 		.WDATA_out  (WDATA_M1),
//         .WSTRB_out  (WSTRB_M1),
//         .WLAST_out  (WLAST_M1),
//         .WVALID_out (WVALID_M1),
//         .WREADY (WREADY_M1)//
// );
// /////B channel
// B_wrapper B(
//         .clock(clk),
//         .clock2(clk2),//
//         .reset(rst),
//         .reset2(rst2),//
// 		    //
// 		.BID    (BID_M1),
//         .BRESP  (BRESP_M1),
//         .BVALID (BVALID_M1),
//         .BREADY_out (BREADY_M1),
// 		    ////
// 		.BID_out    (BID_M1_out),
//         .BRESP_out  (BRESP_M1_out),
//         .BVALID_out (BVALID_M1_out),
//         .BREADY (BREADY_M1_out)
// );

///////////////////////////////////////////////////////////
endmodule
