`include "AXI_define.svh"
`include "def.svh"
`include "./AXI/AXI.sv"
`include "AXI/Master/Master_Read.sv"
`include "AXI/Master/Master_Read1.sv"
`include "AXI/Master/Master_Write.sv"
`include "AXI/Master/Master_Write1.sv"
`include "AXI/Slave_Write.sv"
// `include "./CPU/CPU_wrapper.sv"
`include "./SRAM_wrapper.sv"
`include "./DRAM_Wrapper.sv"
//`include "./sensor_ctrl.sv"
`include "./Sensor_Wrapper.sv"
`include "./WDT_Wrapper.sv"
`include "./WDT.sv"
`include "./AFIFO_Rx.sv"
`include "./AFIFO_Tx.sv"
`include "./Vector_SYNC.sv"
// `include "./data_array_wrapper.sv"
// `include "./tag_array_wrapper.sv"
`include "CPU/CPU_wrapper.sv"
`include "CPU/CPU.sv"
`include "CPU/ALU.sv"
`include "CPU/Controller.sv"
`include "CPU/CSR.sv"
`include "CPU/Decoder.sv"
`include "CPU/Imm_Ext.sv"
`include "CPU/JB_Unit.sv"
`include "CPU/LD_Filter.sv"
`include "CPU/Mul.sv"
`include "CPU/Mux_3.sv"
`include "CPU/MUX_fordelay.sv"
`include "CPU/Mux.sv"
`include "CPU/Reg_EXE_MEM.sv"
`include "CPU/Reg_ID_EXE.sv"
`include "CPU/Reg_IF_ID.sv"
`include "CPU/Reg_MEM_WB.sv"
`include "CPU/Reg_PC.sv"
`include "CPU/RegFile.sv"
`include "CPU/wen_shift.sv"
`include "CPU/INTR_CONTROLLER.sv"
`include "CPU/Cache/data_array_wrapper.sv"
`include "CPU/Cache/tag_array_wrapper.sv"
`include "CPU/Cache/L1C_data.sv"
`include "CPU/Cache/L1C_inst.sv"
`include "CPU/Div.sv"
`include "CPU/div_rill.sv"
`include "CPU/BPU.sv"
`include "DMA/DMA_controller.sv"
`include "DMA/DMA_wrapper.sv"
`include "DMA/sync_fifo.sv"
`include "EPU/out_SRAM_Wrapper_epu.sv"
`include "EPU/in_SRAM_Wrapper_epu.sv"
`include "EPU/Master_Monitor_epu.sv"
`include "EPU/EPU.sv"
`include "EPU/EPU_Wrapper.sv"
`include "EPU/Hoff/H_color_table.sv"
`include "EPU/Hoff/H_light_table.sv"
`include "EPU/Hoff/H_table.sv"
`include "EPU/Hoff/FIFO_shift.sv"
`include "EPU/Hoff/H_encoder.sv"
`include "EPU/Hoff/H_FF.sv"
`include "EPU/Hoff/FF_SRAM.sv"
`include "EPU/EPU_ALG/toYCrCb.sv"
`include "EPU/EPU_ALG/ycrcb_mem.sv"
`include "EPU/EPU_ALG/DCT.sv"
`include "EPU/EPU_ALG/mul_matrix.sv"
`include "EPU/EPU_ALG/zigzag.sv"
`include "EPU/EPU_ALG/RLE.sv"
`include "EPU/EPU_ALG/DPCM_Y.sv"
`include "EPU/EPU_ALG/DPCM_Cr.sv"
`include "EPU/EPU_ALG/DPCM_Cb.sv"
`include "EPU/EPU_ALG/EPU_ALG.sv"


module top(
    input  logic           cpu_clk,
    input  logic           axi_clk,
    input  logic           rom_clk,
    input  logic           dram_clk,
    input  logic           sram_clk,
    input  logic           cpu_rst,
    input  logic           axi_rst,
    input  logic           rom_rst,
    input  logic           dram_rst,
    input  logic           sram_rst,
    // input  logic           sensor_ready,
    // input  logic [   31:0] sensor_out,
    // output logic           sensor_en,
    input  logic [   31:0] ROM_out,
    input  logic [   31:0] DRAM_Q,
    output logic           ROM_read,
    output logic           ROM_enable,
    output logic [   11:0] ROM_address,
    output logic           DRAM_CSn,
    output logic [    3:0] DRAM_WEn,
    output logic           DRAM_RASn,
    output logic           DRAM_CASn,
    output logic [   10:0] DRAM_A,
    output logic [   31:0] DRAM_D,
    input  logic           DRAM_valid,
    input  logic [10:0]    data_counter,


    // Core inputs
    output logic sctrl_en,
    output logic sctrl_clear,
    output logic [11:0] sctrl_addr,
    // Sensor inputs
    //.sensor_ready     (sensor_ready),
    //.sensor_out       (sensor_out),
    // Core outputs
    input logic sctrl_interrupt,
    input logic [31:0] sctrl_out
    // Sensor outputs
    //.sensor_en        (sensor_en)
);

logic CPU_RSTn, CPU_RSTn_1;	// CPU_RSTn  is sync rst
always_ff @( posedge cpu_clk or posedge cpu_rst) begin : CPU_RST_SYNC
    unique if (cpu_rst) begin
        CPU_RSTn_1  <= 1'b0;
        CPU_RSTn    <= 1'b0;
    end
    else begin
        CPU_RSTn_1  <= 1'b1;
        CPU_RSTn    <= CPU_RSTn_1;
    end
end

logic AXI_RSTn, AXI_RSTn_1;	// AXI_RSTn  is sync rst
always_ff @( posedge axi_clk or posedge axi_rst) begin : AXI_RST_SYNC
    unique if (axi_rst) begin
        AXI_RSTn_1  <= 1'b0;
        AXI_RSTn    <= 1'b0;
    end
    else begin
        AXI_RSTn_1  <= 1'b1;
        AXI_RSTn    <= AXI_RSTn_1;
    end
end

logic ROM_RSTn, ROM_RSTn_1;	// ROM_RSTn  is sync rst
always_ff @( posedge rom_clk or posedge rom_rst) begin : ROM_RST_SYNC
    unique if (rom_rst) begin
        ROM_RSTn_1  <= 1'b0;
        ROM_RSTn    <= 1'b0;
    end
    else begin
        ROM_RSTn_1  <= 1'b1;
        ROM_RSTn    <= ROM_RSTn_1;
    end
end

logic DRAM_RSTn, DRAM_RSTn_1;	// DRAM_RSTn  is sync rst
always_ff @( posedge dram_clk or posedge dram_rst) begin : DRAM_RST_SYNC
    unique if (dram_rst) begin
        DRAM_RSTn_1  <= 1'b0;
        DRAM_RSTn    <= 1'b0;
    end
    else begin
        DRAM_RSTn_1  <= 1'b1;
        DRAM_RSTn    <= DRAM_RSTn_1;
    end
end

logic SRAM_RSTn, SRAM_RSTn_1;	// SRAM_RSTn  is sync rst
always_ff @( posedge sram_clk or posedge sram_rst) begin : SRAM_RST_SYNC
    unique if (sram_rst) begin
        SRAM_RSTn_1  <= 1'b0;
        SRAM_RSTn    <= 1'b0;
    end
    else begin
        SRAM_RSTn_1  <= 1'b1;
        SRAM_RSTn    <= SRAM_RSTn_1;
    end
end

assign ROM_enable = 1'b1;
assign ROM_read = 1'b1;

logic [13:0] ROM_A;
assign ROM_address = {20'b0, ROM_A[11:0]};

logic [`AXI_ID_BITS-1:0]    ARID_M0,	ARID_M1 	, ARID_M1_axi       , ARID_M0_axi   ;
logic [`AXI_ADDR_BITS-1:0]  ARADDR_M0,	ARADDR_M1   , ARADDR_M1_axi     , ARADDR_M0_axi ;
logic [`AXI_LEN_BITS-1:0]   ARLEN_M0,	ARLEN_M1    , ARLEN_M1_axi      , ARLEN_M0_axi  ;
logic [`AXI_SIZE_BITS-1:0]  ARSIZE_M0,	ARSIZE_M1   , ARSIZE_M1_axi     , ARSIZE_M0_axi ;
logic [1:0]                 ARBURST_M0, ARBURST_M1  , ARBURST_M1_axi    , ARBURST_M0_axi;
logic                       ARVALID_M0, ARVALID_M1  , ARVALID_M1_axi    , ARVALID_M0_axi;
logic                       ARREADY_M0, ARREADY_M1  , ARREADY_M1_axi    , ARREADY_M0_axi;

logic [`AXI_IDS_BITS-1:0]   ARID_S0,	ARID_S1,	ARID_S2,	ARID_S3,	ARID_S4,	ARID_S5     , ARID_S7   , ARID_S8    ;
logic [`AXI_ADDR_BITS-1:0]  ARADDR_S0,	ARADDR_S1,	ARADDR_S2,	ARADDR_S3,	ARADDR_S4,	ARADDR_S5   , ARADDR_S7 , ARADDR_S8  ;
logic [`AXI_SIZE_BITS-1:0]  ARSIZE_S0,	ARSIZE_S1,	ARSIZE_S2,	ARSIZE_S3,	ARSIZE_S4,	ARSIZE_S5   , ARSIZE_S7 , ARSIZE_S8  ;
logic [`AXI_LEN_BITS-1:0]   ARLEN_S0,	ARLEN_S1,	ARLEN_S2,	ARLEN_S3,	ARLEN_S4,	ARLEN_S5    , ARLEN_S7  , ARLEN_S8   ;	
logic [1:0]                 ARBURST_S0,	ARBURST_S1,	ARBURST_S2,	ARBURST_S3,	ARBURST_S4,	ARBURST_S5  , ARBURST_S7, ARBURST_S8 ;
logic                       ARVALID_S0,	ARVALID_S1,	ARVALID_S2,	ARVALID_S3,	ARVALID_S4,	ARVALID_S5  , ARVALID_S7, ARVALID_S8 ;
logic                       ARREADY_S0,	ARREADY_S1,	ARREADY_S2,	ARREADY_S3,	ARREADY_S4,	ARREADY_S5  , ARREADY_S7, ARREADY_S8 ;

logic [`AXI_IDS_BITS-1:0]   ARID_S0_axi     , ARID_S1_axi   , ARID_S2_axi   , ARID_S3_axi   , ARID_S4_axi   , ARID_S5_axi    , ARID_S7_axi    , ARID_S8_axi   ;
logic [`AXI_ADDR_BITS-1:0]  ARADDR_S0_axi   , ARADDR_S1_axi , ARADDR_S2_axi , ARADDR_S3_axi , ARADDR_S4_axi , ARADDR_S5_axi  , ARADDR_S7_axi  , ARADDR_S8_axi ;
logic [`AXI_SIZE_BITS-1:0]  ARSIZE_S0_axi   , ARSIZE_S1_axi , ARSIZE_S2_axi , ARSIZE_S3_axi , ARSIZE_S4_axi , ARSIZE_S5_axi  , ARSIZE_S7_axi  , ARSIZE_S8_axi ;
logic [`AXI_LEN_BITS-1:0]   ARLEN_S0_axi    , ARLEN_S1_axi  , ARLEN_S2_axi  , ARLEN_S3_axi  , ARLEN_S4_axi  , ARLEN_S5_axi   , ARLEN_S7_axi   , ARLEN_S8_axi  ;
logic [1:0]                 ARBURST_S0_axi  , ARBURST_S1_axi, ARBURST_S2_axi, ARBURST_S3_axi, ARBURST_S4_axi, ARBURST_S5_axi , ARBURST_S7_axi , ARBURST_S8_axi;
logic                       ARVALID_S0_axi  , ARVALID_S1_axi, ARVALID_S2_axi, ARVALID_S3_axi, ARVALID_S4_axi, ARVALID_S5_axi , ARVALID_S7_axi , ARVALID_S8_axi;
logic                       ARREADY_S0_axi  , ARREADY_S1_axi, ARREADY_S2_axi, ARREADY_S3_axi, ARREADY_S4_axi, ARREADY_S5_axi , ARREADY_S7_axi , ARREADY_S8_axi;

logic [`AXI_ID_BITS-1:0]    AWID_M1     , AWID_M1_axi;
logic [`AXI_ADDR_BITS-1:0]  AWADDR_M1   , AWADDR_M1_axi;
logic [`AXI_LEN_BITS-1:0]   AWLEN_M1    , AWLEN_M1_axi;
logic [`AXI_SIZE_BITS-1:0]  AWSIZE_M1   , AWSIZE_M1_axi;
logic [1:0]                 AWBURST_M1  , AWBURST_M1_axi;
logic                       AWVALID_M1  , AWVALID_M1_axi;
logic                       AWREADY_M1  , AWREADY_M1_axi;

logic [`AXI_IDS_BITS-1:0]   AWID_S1,	AWID_S2,	AWID_S3,	AWID_S4,	AWID_S5    , AWID_S7    , AWID_S8    ;
logic [`AXI_ADDR_BITS-1:0]  AWADDR_S1,	AWADDR_S2,	AWADDR_S3,	AWADDR_S4,	AWADDR_S5  , AWADDR_S7  , AWADDR_S8  ;
logic [`AXI_LEN_BITS-1:0]   AWLEN_S1,	AWLEN_S2,	AWLEN_S3,	AWLEN_S4,	AWLEN_S5   , AWLEN_S7   , AWLEN_S8   ;
logic [`AXI_SIZE_BITS-1:0]  AWSIZE_S1,	AWSIZE_S2,	AWSIZE_S3,	AWSIZE_S4,	AWSIZE_S5  , AWSIZE_S7  , AWSIZE_S8  ;
logic [1:0]                 AWBURST_S1,	AWBURST_S2,	AWBURST_S3,	AWBURST_S4,	AWBURST_S5 , AWBURST_S7 , AWBURST_S8 ;
logic                       AWVALID_S1,	AWVALID_S2,	AWVALID_S3,	AWVALID_S4,	AWVALID_S5 , AWVALID_S7 , AWVALID_S8 ;
logic                       AWREADY_S1,	AWREADY_S2,	AWREADY_S3,	AWREADY_S4,	AWREADY_S5 , AWREADY_S7 , AWREADY_S8 ;

logic [`AXI_IDS_BITS-1:0]   AWID_S1_axi     , AWID_S2_axi   , AWID_S3_axi   , AWID_S4_axi   , AWID_S5_axi    , AWID_S7_axi    , AWID_S8_axi   ;
logic [`AXI_ADDR_BITS-1:0]  AWADDR_S1_axi   , AWADDR_S2_axi , AWADDR_S3_axi , AWADDR_S4_axi , AWADDR_S5_axi  , AWADDR_S7_axi  , AWADDR_S8_axi ;
logic [`AXI_LEN_BITS-1:0]   AWLEN_S1_axi    , AWLEN_S2_axi  , AWLEN_S3_axi  , AWLEN_S4_axi  , AWLEN_S5_axi   , AWLEN_S7_axi   , AWLEN_S8_axi  ;
logic [`AXI_SIZE_BITS-1:0]  AWSIZE_S1_axi   , AWSIZE_S2_axi , AWSIZE_S3_axi , AWSIZE_S4_axi , AWSIZE_S5_axi  , AWSIZE_S7_axi  , AWSIZE_S8_axi ;
logic [1:0]                 AWBURST_S1_axi  , AWBURST_S2_axi, AWBURST_S3_axi, AWBURST_S4_axi, AWBURST_S5_axi , AWBURST_S7_axi , AWBURST_S8_axi;
logic                       AWVALID_S1_axi  , AWVALID_S2_axi, AWVALID_S3_axi, AWVALID_S4_axi, AWVALID_S5_axi , AWVALID_S7_axi , AWVALID_S8_axi;
logic                       AWREADY_S1_axi  , AWREADY_S2_axi, AWREADY_S3_axi, AWREADY_S4_axi, AWREADY_S5_axi , AWREADY_S7_axi , AWREADY_S8_axi;

logic [`AXI_DATA_BITS-1:0]  WDATA_M1    , WDATA_M1_axi;
logic [`AXI_STRB_BITS-1:0]  WSTRB_M1    , WSTRB_M1_axi;
logic                       WLAST_M1    , WLAST_M1_axi;
logic                       WVALID_M1   , WVALID_M1_axi;
logic                       WREADY_M1   , WREADY_M1_axi;

logic [`AXI_DATA_BITS-1:0]  WDATA_S1,	WDATA_S2,	WDATA_S3,	WDATA_S4,	WDATA_S5  ,WDATA_S7  , WDATA_S8   ;
logic [`AXI_STRB_BITS-1:0]  WSTRB_S1,	WSTRB_S2,	WSTRB_S3,	WSTRB_S4,	WSTRB_S5  ,WSTRB_S7  , WSTRB_S8   ;
logic                       WLAST_S1,	WLAST_S2,	WLAST_S3,	WLAST_S4,	WLAST_S5  ,WLAST_S7  , WLAST_S8   ;
logic                       WVALID_S1,	WVALID_S2,	WVALID_S3,	WVALID_S4,	WVALID_S5 ,WVALID_S7 , WVALID_S8  ;
logic                       WREADY_S1,	WREADY_S2,	WREADY_S3,	WREADY_S4,	WREADY_S5 ,WREADY_S7 , WREADY_S8  ;

logic [`AXI_DATA_BITS-1:0]  WDATA_S1_axi    , WDATA_S2_axi  , WDATA_S3_axi  , WDATA_S4_axi  , WDATA_S5_axi  , WDATA_S7_axi  , WDATA_S8_axi ;
logic [`AXI_STRB_BITS-1:0]  WSTRB_S1_axi    , WSTRB_S2_axi  , WSTRB_S3_axi  , WSTRB_S4_axi  , WSTRB_S5_axi  , WSTRB_S7_axi  , WSTRB_S8_axi ;
logic                       WLAST_S1_axi    , WLAST_S2_axi  , WLAST_S3_axi  , WLAST_S4_axi  , WLAST_S5_axi  , WLAST_S7_axi  , WLAST_S8_axi ;
logic                       WVALID_S1_axi   , WVALID_S2_axi , WVALID_S3_axi , WVALID_S4_axi , WVALID_S5_axi , WVALID_S7_axi , WVALID_S8_axi;
logic                       WREADY_S1_axi   , WREADY_S2_axi , WREADY_S3_axi , WREADY_S4_axi , WREADY_S5_axi , WREADY_S7_axi , WREADY_S8_axi;

logic [`AXI_ID_BITS-1:0]    BID_M1      , BID_M1_axi;
logic [1:0]                 BRESP_M1    , BRESP_M1_axi;
logic                       BVALID_M1   , BVALID_M1_axi;
logic                       BREADY_M1   , BREADY_M1_axi;

logic [`AXI_IDS_BITS-1:0]   BID_S1, 	BID_S2, 	BID_S3, 	BID_S4, 	BID_S5    , BID_S7    , BID_S8   ;
logic [1:0]                 BRESP_S1, 	BRESP_S2, 	BRESP_S3, 	BRESP_S4, 	BRESP_S5  , BRESP_S7  , BRESP_S8 ;
logic                       BVALID_S1, 	BVALID_S2, 	BVALID_S3, 	BVALID_S4, 	BVALID_S5 , BVALID_S7 , BVALID_S8;
logic                       BREADY_S1, 	BREADY_S2, 	BREADY_S3, 	BREADY_S4, 	BREADY_S5 , BREADY_S7 , BREADY_S8;

logic [`AXI_IDS_BITS-1:0]   BID_S1_axi      , BID_S2_axi    , BID_S3_axi    , BID_S4_axi    , BID_S5_axi    , BID_S7_axi    , BID_S8_axi   ;
logic [1:0]                 BRESP_S1_axi    , BRESP_S2_axi  , BRESP_S3_axi  , BRESP_S4_axi  , BRESP_S5_axi  , BRESP_S7_axi  , BRESP_S8_axi ;
logic                       BVALID_S1_axi   , BVALID_S2_axi , BVALID_S3_axi , BVALID_S4_axi , BVALID_S5_axi , BVALID_S7_axi , BVALID_S8_axi;
logic                       BREADY_S1_axi   , BREADY_S2_axi , BREADY_S3_axi , BREADY_S4_axi , BREADY_S5_axi , BREADY_S7_axi , BREADY_S8_axi;

logic [`AXI_ID_BITS-1:0]    RID_M1   , RID_M0   , RID_M0_axi    , RID_M1_axi;
logic [`AXI_DATA_BITS-1:0]  RDATA_M1 , RDATA_M0 , RDATA_M0_axi  , RDATA_M1_axi;
logic [1:0]                 RRESP_M1 , RRESP_M0 , RRESP_M0_axi  , RRESP_M1_axi;
logic                       RLAST_M1 , RLAST_M0 , RLAST_M0_axi  , RLAST_M1_axi;
logic                       RVALID_M1, RVALID_M0, RVALID_M0_axi , RVALID_M1_axi;
logic                       RREADY_M1, RREADY_M0, RREADY_M0_axi , RREADY_M1_axi;

logic [`AXI_IDS_BITS-1:0]   RID_S0,		RID_S1, 	RID_S2, 	RID_S3, 	RID_S4, 	RID_S5    , RID_S7    , RID_S8   ;
logic [`AXI_DATA_BITS-1:0]  RDATA_S0,	RDATA_S1, 	RDATA_S2, 	RDATA_S3, 	RDATA_S4, 	RDATA_S5  , RDATA_S7  , RDATA_S8 ;
logic [1:0]                 RRESP_S0,	RRESP_S1, 	RRESP_S2, 	RRESP_S3, 	RRESP_S4, 	RRESP_S5  , RRESP_S7  , RRESP_S8 ;
logic                       RLAST_S0,	RLAST_S1, 	RLAST_S2, 	RLAST_S3, 	RLAST_S4, 	RLAST_S5  , RLAST_S7  , RLAST_S8 ;
logic                       RVALID_S0,	RVALID_S1, 	RVALID_S2, 	RVALID_S3, 	RVALID_S4, 	RVALID_S5 , RVALID_S7 , RVALID_S8;
logic                       RREADY_S0,	RREADY_S1, 	RREADY_S2, 	RREADY_S3, 	RREADY_S4, 	RREADY_S5 , RREADY_S7 , RREADY_S8;

logic [`AXI_IDS_BITS-1:0]   RID_S0_axi      , RID_S1_axi    , RID_S2_axi    , RID_S3_axi    , RID_S4_axi    , RID_S5_axi    , RID_S7_axi    , RID_S8_axi   ;
logic [`AXI_DATA_BITS-1:0]  RDATA_S0_axi    , RDATA_S1_axi  , RDATA_S2_axi  , RDATA_S3_axi  , RDATA_S4_axi  , RDATA_S5_axi  , RDATA_S7_axi  , RDATA_S8_axi ;
logic [1:0]                 RRESP_S0_axi    , RRESP_S1_axi  , RRESP_S2_axi  , RRESP_S3_axi  , RRESP_S4_axi  , RRESP_S5_axi  , RRESP_S7_axi  , RRESP_S8_axi ;
logic                       RLAST_S0_axi    , RLAST_S1_axi  , RLAST_S2_axi  , RLAST_S3_axi  , RLAST_S4_axi  , RLAST_S5_axi  , RLAST_S7_axi  , RLAST_S8_axi ;
logic                       RVALID_S0_axi   , RVALID_S1_axi , RVALID_S2_axi , RVALID_S3_axi , RVALID_S4_axi , RVALID_S5_axi , RVALID_S7_axi , RVALID_S8_axi;
logic                       RREADY_S0_axi   , RREADY_S1_axi , RREADY_S2_axi , RREADY_S3_axi , RREADY_S4_axi , RREADY_S5_axi , RREADY_S7_axi , RREADY_S8_axi;

//logic	sctrl_interrupt, 
logic WTO;

logic [`AXI_ID_BITS-1:0]   ARID_M0_dma     ;
logic [`AXI_ADDR_BITS-1:0]  ARADDR_M0_dma   ;
logic [`AXI_SIZE_BITS-1:0]  ARSIZE_M0_dma   ;
logic [`AXI_LEN_BITS-1:0]   ARLEN_M0_dma    ;
logic [1:0]                 ARBURST_M0_dma  ;
logic                       ARVALID_M0_dma  ;
logic                       ARREADY_M0_dma  ;

logic [`AXI_ID_BITS-1:0]   RID_M0_dma      ;
logic [`AXI_DATA_BITS-1:0]  RDATA_M0_dma    ;
logic [1:0]                 RRESP_M0_dma    ;
logic                       RLAST_M0_dma    ;
logic                       RVALID_M0_dma   ;
logic                       RREADY_M0_dma   ;



logic [`AXI_ID_BITS-1:0]    AWID_M1_dma;
logic [`AXI_IDS_BITS-1:0]   AWID_S_dma   ;
logic [`AXI_ADDR_BITS-1:0]  AWADDR_M1_dma   , AWADDR_S_dma ;
logic [`AXI_LEN_BITS-1:0]   AWLEN_M1_dma    , AWLEN_S_dma  ;
logic [`AXI_SIZE_BITS-1:0]  AWSIZE_M1_dma   , AWSIZE_S_dma ;
logic [1:0]                 AWBURST_M1_dma  , AWBURST_S_dma;
logic                       AWVALID_M1_dma  , AWVALID_S_dma;
logic                       AWREADY_M1_dma  , AWREADY_S_dma;


logic [`AXI_DATA_BITS-1:0]  WDATA_M1_dma    , WDATA_S_dma  ;
logic [`AXI_STRB_BITS-1:0]  WSTRB_M1_dma    , WSTRB_S_dma  ;
logic                       WLAST_M1_dma    , WLAST_S_dma  ;
logic                       WVALID_M1_dma   , WVALID_S_dma ;
logic                       WREADY_M1_dma   , WREADY_S_dma ;


logic [`AXI_ID_BITS-1:0]    BID_M1_dma ;
logic [`AXI_IDS_BITS-1:0]   BID_S_dma    ;
logic [1:0]                 BRESP_M1_dma    , BRESP_S_dma  ;
logic                       BVALID_M1_dma   , BVALID_S_dma ;
logic                       BREADY_M1_dma   , BREADY_S_dma ;

logic wfi_signal, interrupt_dma_done;




//====================================== MASTER ======================================//

//====================== M0 AR ======================//
logic   [44:0]  AFIFO_WDATA_AR_M0   , AFIFO_RDATA_AR_M0     , AFIFO_RDATA_T_AR_M0;
logic   [3:0]   R_PTR_GRAY_AR_M0    , R_PTR_Binary_AR_M0    , W_PTR_GRAY_AR_M0;
logic           W_FULL_AR_M0        , R_EMPTY_AR_M0;
assign AFIFO_WDATA_AR_M0 = {ARID_M0, ARADDR_M0, ARLEN_M0, ARSIZE_M0, ARBURST_M0};
assign {ARID_M0_axi, ARADDR_M0_axi, ARLEN_M0_axi, ARSIZE_M0_axi, ARBURST_M0_axi} = AFIFO_RDATA_T_AR_M0;
assign ARREADY_M0 = ~W_FULL_AR_M0;
assign ARVALID_M0_axi = ~R_EMPTY_AR_M0;
AFIFO_Tx#(
    .DATA_WIDTH(45),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_M0
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_AR_M0),
    .WEN(ARVALID_M0),
    .W_FULL(W_FULL_AR_M0),
    .R_PTR_GRAY(R_PTR_GRAY_AR_M0),
    .R_PTR_Binary(R_PTR_Binary_AR_M0),
    .W_PTR_GRAY(W_PTR_GRAY_AR_M0),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_M0)
);
AFIFO_Rx#(
    .DATA_WIDTH(45),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_M0
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_AR_M0),
    .REN(ARREADY_M0_axi),
    .R_EMPTY(R_EMPTY_AR_M0),
    .W_PTR_GRAY(W_PTR_GRAY_AR_M0),
    .R_PTR_GRAY(R_PTR_GRAY_AR_M0),
    .R_PTR_Binary(R_PTR_Binary_AR_M0),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_M0)
);
//====================== M0 AR ======================//
//====================== M0  R ======================//
logic   [42:0]  AFIFO_WDATA_R_M0    , AFIFO_RDATA_R_M0      , AFIFO_RDATA_T_R_M0;
logic   [3:0]   R_PTR_GRAY_R_M0     , R_PTR_Binary_R_M0     , W_PTR_GRAY_R_M0;
logic           W_FULL_R_M0         , R_EMPTY_R_M0;
assign AFIFO_WDATA_R_M0 = {RID_M0_axi, RDATA_M0_axi, RRESP_M0_axi, RLAST_M0_axi};
assign {RID_M0, RDATA_M0, RRESP_M0, RLAST_M0} = AFIFO_RDATA_T_R_M0;
assign RREADY_M0_axi = ~W_FULL_R_M0;
assign RVALID_M0 = ~R_EMPTY_R_M0;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_M0
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_R_M0),
    .WEN(RVALID_M0_axi),
    .W_FULL(W_FULL_R_M0),
    .R_PTR_GRAY(R_PTR_GRAY_R_M0),
    .R_PTR_Binary(R_PTR_Binary_R_M0),
    .W_PTR_GRAY(W_PTR_GRAY_R_M0),
    .R_DATA_Tx(AFIFO_RDATA_T_R_M0)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_M0
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_R_M0),
    .REN(RREADY_M0),
    .R_EMPTY(R_EMPTY_R_M0),
    .W_PTR_GRAY(W_PTR_GRAY_R_M0),
    .R_PTR_GRAY(R_PTR_GRAY_R_M0),
    .R_PTR_Binary(R_PTR_Binary_R_M0),
    .R_DATA_Tx(AFIFO_RDATA_T_R_M0)
);
//====================== M0  R ======================//


//====================== M1 AW ======================//
logic   [44:0]  AFIFO_WDATA_AW_M1   , AFIFO_RDATA_AW_M1     , AFIFO_RDATA_T_AW_M1;
logic   [3:0]   R_PTR_GRAY_AW_M1    , R_PTR_Binary_AW_M1    , W_PTR_GRAY_AW_M1;
logic           W_FULL_AW_M1        , R_EMPTY_AW_M1;
assign AFIFO_WDATA_AW_M1 = {AWID_M1, AWADDR_M1, AWLEN_M1, AWSIZE_M1, AWBURST_M1};
assign {AWID_M1_axi, AWADDR_M1_axi, AWLEN_M1_axi, AWSIZE_M1_axi, AWBURST_M1_axi} = AFIFO_RDATA_T_AW_M1;
assign AWREADY_M1 = ~W_FULL_AW_M1;
assign AWVALID_M1_axi = ~R_EMPTY_AW_M1;
AFIFO_Tx#(
    .DATA_WIDTH(45),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AW_M1
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_AW_M1),
    .WEN(AWVALID_M1),
    .W_FULL(W_FULL_AW_M1),
    .R_PTR_GRAY(R_PTR_GRAY_AW_M1),
    .R_PTR_Binary(R_PTR_Binary_AW_M1),
    .W_PTR_GRAY(W_PTR_GRAY_AW_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_M1)
);
AFIFO_Rx#(
    .DATA_WIDTH(45),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AW_M1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_AW_M1),
    .REN(AWREADY_M1_axi),
    .R_EMPTY(R_EMPTY_AW_M1),
    .W_PTR_GRAY(W_PTR_GRAY_AW_M1),
    .R_PTR_GRAY(R_PTR_GRAY_AW_M1),
    .R_PTR_Binary(R_PTR_Binary_AW_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_M1)
);
//====================== M1 AW ======================//
//====================== M1  W ======================//
logic   [36:0]  AFIFO_WDATA_W_M1    , AFIFO_RDATA_W_M1      , AFIFO_RDATA_T_W_M1;
logic   [3:0]   R_PTR_GRAY_W_M1     , R_PTR_Binary_W_M1     , W_PTR_GRAY_W_M1;
logic           W_FULL_W_M1         , R_EMPTY_W_M1;
assign AFIFO_WDATA_W_M1 = {WDATA_M1, WSTRB_M1, WLAST_M1};
assign {WDATA_M1_axi, WSTRB_M1_axi, WLAST_M1_axi} = AFIFO_RDATA_T_W_M1;
assign WREADY_M1 = ~W_FULL_W_M1;
assign WVALID_M1_axi = ~R_EMPTY_W_M1;
AFIFO_Tx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Tx_W_M1
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_W_M1),
    .WEN(WVALID_M1),
    .W_FULL(W_FULL_W_M1),
    .R_PTR_GRAY(R_PTR_GRAY_W_M1),
    .R_PTR_Binary(R_PTR_Binary_W_M1),
    .W_PTR_GRAY(W_PTR_GRAY_W_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_W_M1)
);
AFIFO_Rx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Rx_W_M1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_W_M1),
    .REN(WREADY_M1_axi),
    .R_EMPTY(R_EMPTY_W_M1),
    .W_PTR_GRAY(W_PTR_GRAY_W_M1),
    .R_PTR_GRAY(R_PTR_GRAY_W_M1),
    .R_PTR_Binary(R_PTR_Binary_W_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_W_M1)
);
//====================== M1  W ======================//
//====================== M1  B ======================//
logic   [5:0]   AFIFO_WDATA_B_M1    , AFIFO_RDATA_B_M1      , AFIFO_RDATA_T_B_M1;
logic   [3:0]   R_PTR_GRAY_B_M1     , R_PTR_Binary_B_M1     , W_PTR_GRAY_B_M1;
logic           W_FULL_B_M1         , R_EMPTY_B_M1;
assign AFIFO_WDATA_B_M1 = {BID_M1_axi, BRESP_M1_axi};
assign {BID_M1, BRESP_M1} = AFIFO_RDATA_T_B_M1;
assign BREADY_M1_axi = ~W_FULL_B_M1;
assign BVALID_M1 = ~R_EMPTY_B_M1;
AFIFO_Tx#(
    .DATA_WIDTH(6),
    .ADDR_WIDTH(4)
) AFIFO_Tx_B_M1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_B_M1),
    .WEN(BVALID_M1_axi),
    .W_FULL(W_FULL_B_M1),
    .R_PTR_GRAY(R_PTR_GRAY_B_M1),
    .R_PTR_Binary(R_PTR_Binary_B_M1),
    .W_PTR_GRAY(W_PTR_GRAY_B_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_B_M1)
);
AFIFO_Rx#(
    .DATA_WIDTH(6),
    .ADDR_WIDTH(4)
) AFIFO_Rx_B_M1
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_B_M1),
    .REN(BREADY_M1),
    .R_EMPTY(R_EMPTY_B_M1),
    .W_PTR_GRAY(W_PTR_GRAY_B_M1),
    .R_PTR_GRAY(R_PTR_GRAY_B_M1),
    .R_PTR_Binary(R_PTR_Binary_B_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_B_M1)
);
//====================== M1  B ======================//
//====================== M1 AR ======================//
logic   [44:0]  AFIFO_WDATA_AR_M1   , AFIFO_RDATA_AR_M1     , AFIFO_RDATA_T_AR_M1;
logic   [3:0]   R_PTR_GRAY_AR_M1    , R_PTR_Binary_AR_M1    , W_PTR_GRAY_AR_M1;
logic           W_FULL_AR_M1        , R_EMPTY_AR_M1;
assign AFIFO_WDATA_AR_M1 = {ARID_M1, ARADDR_M1, ARLEN_M1, ARSIZE_M1, ARBURST_M1};
assign {ARID_M1_axi, ARADDR_M1_axi, ARLEN_M1_axi, ARSIZE_M1_axi, ARBURST_M1_axi} = AFIFO_RDATA_T_AR_M1;
assign ARREADY_M1 = ~W_FULL_AR_M1;
assign ARVALID_M1_axi = ~R_EMPTY_AR_M1;
AFIFO_Tx#(
    .DATA_WIDTH(45),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_M1
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_AR_M1),
    .WEN(ARVALID_M1),
    .W_FULL(W_FULL_AR_M1),
    .R_PTR_GRAY(R_PTR_GRAY_AR_M1),
    .R_PTR_Binary(R_PTR_Binary_AR_M1),
    .W_PTR_GRAY(W_PTR_GRAY_AR_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_M1)
);
AFIFO_Rx#(
    .DATA_WIDTH(45),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_M1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_AR_M1),
    .REN(ARREADY_M1_axi),
    .R_EMPTY(R_EMPTY_AR_M1),
    .W_PTR_GRAY(W_PTR_GRAY_AR_M1),
    .R_PTR_GRAY(R_PTR_GRAY_AR_M1),
    .R_PTR_Binary(R_PTR_Binary_AR_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_M1)
);
//====================== M1 AR ======================//
//====================== M1  R ======================//
logic   [38:0]  AFIFO_WDATA_R_M1    , AFIFO_RDATA_R_M1      , AFIFO_RDATA_T_R_M1;
logic   [3:0]   R_PTR_GRAY_R_M1     , R_PTR_Binary_R_M1     , W_PTR_GRAY_R_M1;
logic           W_FULL_R_M1         , R_EMPTY_R_M1;
assign AFIFO_WDATA_R_M1 = {RID_M1_axi, RDATA_M1_axi, RRESP_M1_axi, RLAST_M1_axi};
assign {RID_M1, RDATA_M1, RRESP_M1, RLAST_M1} = AFIFO_RDATA_T_R_M1;
assign RREADY_M1_axi = ~W_FULL_R_M1;
assign RVALID_M1 = ~R_EMPTY_R_M1;
AFIFO_Tx#(
    .DATA_WIDTH(39),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_M1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_R_M1),
    .WEN(RVALID_M1_axi),
    .W_FULL(W_FULL_R_M1),
    .R_PTR_GRAY(R_PTR_GRAY_R_M1),
    .R_PTR_Binary(R_PTR_Binary_R_M1),
    .W_PTR_GRAY(W_PTR_GRAY_R_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_R_M1)
);
AFIFO_Rx#(
    .DATA_WIDTH(39),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_M1
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_R_M1),
    .REN(RREADY_M1),
    .R_EMPTY(R_EMPTY_R_M1),
    .W_PTR_GRAY(W_PTR_GRAY_R_M1),
    .R_PTR_GRAY(R_PTR_GRAY_R_M1),
    .R_PTR_Binary(R_PTR_Binary_R_M1),
    .R_DATA_Tx(AFIFO_RDATA_T_R_M1)
);
//====================== M1  R ======================//




















//====================================== SLAVE0  ======================================//

// //====================== S0 AW ======================//
// logic   [48:0]  AFIFO_WDATA_AW_S0   , AFIFO_RDATA_AW_S0     , AFIFO_RDATA_T_AW_S0;
// logic   [3:0]   R_PTR_GRAY_AW_S0    , R_PTR_Binary_AW_S0    , W_PTR_GRAY_AW_S0;
// logic           W_FULL_AW_S0        , R_EMPTY_AW_S0;
// assign AFIFO_WDATA_AW_S0 = {AWID_S0_axi, AWADDR_S0_axi, AWLEN_S0_axi, AWSIZE_S0_axi, AWBURST_S0_axi};
// assign {AWID_S0, AWADDR_S0, AWLEN_S0, AWSIZE_S0, AWBURST_S0} = AFIFO_RDATA_AW_S0;
// assign AWREADY_S0_axi = ~W_FULL_AW_S0;
// assign AWVALID_S0 = ~R_EMPTY_AW_S0;
// AFIFO_Tx#(
//     .DATA_WIDTH(49),
//     .ADDR_WIDTH(4)
// ) AFIFO_Tx_AW_S0
// (
//     .CLK(axi_clk),
//     .RSTn(AXI_RSTn),
//     .W_DATA(AFIFO_WDATA_AW_S0),
//     .WEN(AWVALID_S0_axi),
//     .W_FULL(W_FULL_AW_S0),
//     .R_PTR_GRAY(R_PTR_GRAY_AW_S0),
//     .R_PTR_Binary(R_PTR_Binary_AW_S0),
//     .W_PTR_GRAY(W_PTR_GRAY_AW_S0),
//     .R_DATA_Tx(AFIFO_RDATA_T_AW_S0)
// );
// AFIFO_Rx#(
//     .DATA_WIDTH(49),
//     .ADDR_WIDTH(4)
// ) AFIFO_Rx_AW_S0
// (
//     .CLK(sram_clk),
//     .RSTn(SRAM_RSTn),
//     .R_DATA(AFIFO_RDATA_AW_S0),
//     .REN(AWREADY_S0),
//     .R_EMPTY(R_EMPTY_AW_S0),
//     .W_PTR_GRAY(W_PTR_GRAY_AW_S0),
//     .R_PTR_GRAY(R_PTR_GRAY_AW_S0),
//     .R_PTR_Binary(R_PTR_Binary_AW_S0),
//     .R_DATA_Tx(AFIFO_RDATA_T_AW_S0)
// );
// //====================== S0 AW ======================//
// //====================== S0  W ======================//
// logic   [36:0]  AFIFO_WDATA_W_S0    , AFIFO_RDATA_W_S0      , AFIFO_RDATA_T_W_S0;
// logic   [3:0]   R_PTR_GRAY_W_S0     , R_PTR_Binary_W_S0     , W_PTR_GRAY_W_S0;
// logic           W_FULL_W_S0         , R_EMPTY_W_S0;
// assign AFIFO_WDATA_W_S0 = {WDATA_S0_axi, WSTRB_S0_axi, WLAST_S0_axi};
// assign {WDATA_S0, WSTRB_S0, WLAST_S0} = AFIFO_RDATA_W_S0;
// assign WREADY_S0_axi = ~W_FULL_W_S0;
// assign WVALID_S0 = ~R_EMPTY_W_S0;
// AFIFO_Tx#(
//     .DATA_WIDTH(37),
//     .ADDR_WIDTH(4)
// ) AFIFO_Tx_W_S0
// (
//     .CLK(axi_clk),
//     .RSTn(AXI_RSTn),
//     .W_DATA(AFIFO_WDATA_W_S0),
//     .WEN(WVALID_S0_axi),
//     .W_FULL(W_FULL_W_S0),
//     .R_PTR_GRAY(R_PTR_GRAY_W_S0),
//     .R_PTR_Binary(R_PTR_Binary_W_S0),
//     .W_PTR_GRAY(W_PTR_GRAY_W_S0),
//     .R_DATA_Tx(AFIFO_RDATA_T_W_S0)
// );
// AFIFO_Rx#(
//     .DATA_WIDTH(37),
//     .ADDR_WIDTH(4)
// ) AFIFO_Rx_W_S0
// (
//     .CLK(sram_clk),
//     .RSTn(SRAM_RSTn),
//     .R_DATA(AFIFO_RDATA_W_S0),
//     .REN(WREADY_S0),
//     .R_EMPTY(R_EMPTY_W_S0),
//     .W_PTR_GRAY(W_PTR_GRAY_W_S0),
//     .R_PTR_GRAY(R_PTR_GRAY_W_S0),
//     .R_PTR_Binary(R_PTR_Binary_W_S0),
//     .R_DATA_Tx(AFIFO_RDATA_T_W_S0)
// );
// //====================== S0  W ======================//
// //====================== S0  B ======================//
// logic   [9:0]   AFIFO_WDATA_B_S0    , AFIFO_RDATA_B_S0      , AFIFO_RDATA_T_B_S0;
// logic   [3:0]   R_PTR_GRAY_B_S0     , R_PTR_Binary_B_S0     , W_PTR_GRAY_B_S0;
// logic           W_FULL_B_S0         , R_EMPTY_B_S0;
// assign AFIFO_WDATA_B_S0 = {BID_S0, BRESP_S0};
// assign {BID_S0_axi, BRESP_S0_axi} = AFIFO_RDATA_B_S0;
// assign BREADY_S0 = ~W_FULL_B_S0;
// assign BVALID_S0_axi = ~R_EMPTY_B_S0;
// AFIFO_Tx#(
//     .DATA_WIDTH(10),
//     .ADDR_WIDTH(4)
// ) AFIFO_Tx_B_S0
// (
//     .CLK(sram_clk),
//     .RSTn(SRAM_RSTn),
//     .W_DATA(AFIFO_WDATA_B_S0),
//     .WEN(BVALID_S0),
//     .W_FULL(W_FULL_B_S0),
//     .R_PTR_GRAY(R_PTR_GRAY_B_S0),
//     .R_PTR_Binary(R_PTR_Binary_B_S0),
//     .W_PTR_GRAY(W_PTR_GRAY_B_S0),
//     .R_DATA_Tx(AFIFO_RDATA_T_B_S0)
// );
// AFIFO_Rx#(
//     .DATA_WIDTH(10),
//     .ADDR_WIDTH(4)
// ) AFIFO_Rx_B_S0
// (
//     .CLK(axi_clk),
//     .RSTn(AXI_RSTn),
//     .R_DATA(AFIFO_RDATA_B_S0),
//     .REN(BREADY_S0_axi),
//     .R_EMPTY(R_EMPTY_B_S0),
//     .W_PTR_GRAY(W_PTR_GRAY_B_S0),
//     .R_PTR_GRAY(R_PTR_GRAY_B_S0),
//     .R_PTR_Binary(R_PTR_Binary_B_S0),
//     .R_DATA_Tx(AFIFO_RDATA_T_B_S0)
// );
// //====================== S0  B ======================//
//====================== S0 AR ======================//
logic   [48:0]  AFIFO_WDATA_AR_S0   , AFIFO_RDATA_AR_S0     , AFIFO_RDATA_T_AR_S0;
logic   [3:0]   R_PTR_GRAY_AR_S0    , R_PTR_Binary_AR_S0    , W_PTR_GRAY_AR_S0;
logic           W_FULL_AR_S0        , R_EMPTY_AR_S0;
assign AFIFO_WDATA_AR_S0 = {ARID_S0_axi, ARADDR_S0_axi, ARLEN_S0_axi, ARSIZE_S0_axi, ARBURST_S0_axi};
assign {ARID_S0, ARADDR_S0, ARLEN_S0, ARSIZE_S0, ARBURST_S0} = AFIFO_RDATA_T_AR_S0;
assign ARREADY_S0_axi = ~W_FULL_AR_S0;
assign ARVALID_S0 = ~R_EMPTY_AR_S0;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_S0
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AR_S0),
    .WEN(ARVALID_S0_axi),
    .W_FULL(W_FULL_AR_S0),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S0),
    .R_PTR_Binary(R_PTR_Binary_AR_S0),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S0),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S0)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_S0
(
    .CLK(rom_clk),
    .RSTn(ROM_RSTn),
    .R_DATA(AFIFO_RDATA_AR_S0),
    .REN(ARREADY_S0),
    .R_EMPTY(R_EMPTY_AR_S0),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S0),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S0),
    .R_PTR_Binary(R_PTR_Binary_AR_S0),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S0)
);
//====================== S0 AR ======================//
//====================== S0  R ======================//
logic   [42:0]  AFIFO_WDATA_R_S0    , AFIFO_RDATA_R_S0      , AFIFO_RDATA_T_R_S0;
logic   [3:0]   R_PTR_GRAY_R_S0     , R_PTR_Binary_R_S0     , W_PTR_GRAY_R_S0;
logic           W_FULL_R_S0         , R_EMPTY_R_S0;
assign AFIFO_WDATA_R_S0 = {RID_S0, RDATA_S0, RRESP_S0, RLAST_S0};
assign {RID_S0_axi, RDATA_S0_axi, RRESP_S0_axi, RLAST_S0_axi} = AFIFO_RDATA_T_R_S0;
assign RREADY_S0 = ~W_FULL_R_S0;
assign RVALID_S0_axi = ~R_EMPTY_R_S0;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_S0
(
    .CLK(rom_clk),
    .RSTn(ROM_RSTn),
    .W_DATA(AFIFO_WDATA_R_S0),
    .WEN(RVALID_S0),
    .W_FULL(W_FULL_R_S0),
    .R_PTR_GRAY(R_PTR_GRAY_R_S0),
    .R_PTR_Binary(R_PTR_Binary_R_S0),
    .W_PTR_GRAY(W_PTR_GRAY_R_S0),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S0)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_S0
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_R_S0),
    .REN(RREADY_S0_axi),
    .R_EMPTY(R_EMPTY_R_S0),
    .W_PTR_GRAY(W_PTR_GRAY_R_S0),
    .R_PTR_GRAY(R_PTR_GRAY_R_S0),
    .R_PTR_Binary(R_PTR_Binary_R_S0),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S0)
);
//====================== S0 R ======================//

//====================================== SLAVE1  ======================================//

//====================== S1 AW ======================//
logic   [48:0]  AFIFO_WDATA_AW_S1   , AFIFO_RDATA_AW_S1     , AFIFO_RDATA_T_AW_S1;
logic   [3:0]   R_PTR_GRAY_AW_S1    , R_PTR_Binary_AW_S1    , W_PTR_GRAY_AW_S1;
logic           W_FULL_AW_S1        , R_EMPTY_AW_S1;
assign AFIFO_WDATA_AW_S1 = {AWID_S1_axi, AWADDR_S1_axi, AWLEN_S1_axi, AWSIZE_S1_axi, AWBURST_S1_axi};
assign {AWID_S1, AWADDR_S1, AWLEN_S1, AWSIZE_S1, AWBURST_S1} = AFIFO_RDATA_T_AW_S1;
assign AWREADY_S1_axi = ~W_FULL_AW_S1;
assign AWVALID_S1 = ~R_EMPTY_AW_S1;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AW_S1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AW_S1),
    .WEN(AWVALID_S1_axi),
    .W_FULL(W_FULL_AW_S1),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S1),
    .R_PTR_Binary(R_PTR_Binary_AW_S1),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S1)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AW_S1
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .R_DATA(AFIFO_RDATA_AW_S1),
    .REN(AWREADY_S1),
    .R_EMPTY(R_EMPTY_AW_S1),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S1),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S1),
    .R_PTR_Binary(R_PTR_Binary_AW_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S1)
);
//====================== S1 AW ======================//
//====================== S1  W ======================//
logic   [36:0]  AFIFO_WDATA_W_S1    , AFIFO_RDATA_W_S1      , AFIFO_RDATA_T_W_S1;
logic   [3:0]   R_PTR_GRAY_W_S1     , R_PTR_Binary_W_S1     , W_PTR_GRAY_W_S1;
logic           W_FULL_W_S1         , R_EMPTY_W_S1;
assign AFIFO_WDATA_W_S1 = {WDATA_S1_axi, WSTRB_S1_axi, WLAST_S1_axi};
assign {WDATA_S1, WSTRB_S1, WLAST_S1} = AFIFO_RDATA_T_W_S1;
assign WREADY_S1_axi = ~W_FULL_W_S1;
assign WVALID_S1 = ~R_EMPTY_W_S1;
AFIFO_Tx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Tx_W_S1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_W_S1),
    .WEN(WVALID_S1_axi),
    .W_FULL(W_FULL_W_S1),
    .R_PTR_GRAY(R_PTR_GRAY_W_S1),
    .R_PTR_Binary(R_PTR_Binary_W_S1),
    .W_PTR_GRAY(W_PTR_GRAY_W_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S1)
);
AFIFO_Rx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Rx_W_S1
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .R_DATA(AFIFO_RDATA_W_S1),
    .REN(WREADY_S1),
    .R_EMPTY(R_EMPTY_W_S1),
    .W_PTR_GRAY(W_PTR_GRAY_W_S1),
    .R_PTR_GRAY(R_PTR_GRAY_W_S1),
    .R_PTR_Binary(R_PTR_Binary_W_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S1)
);
//====================== S1  W ======================//
//====================== S1  B ======================//
logic   [9:0]   AFIFO_WDATA_B_S1    , AFIFO_RDATA_B_S1      , AFIFO_RDATA_T_B_S1;
logic   [3:0]   R_PTR_GRAY_B_S1     , R_PTR_Binary_B_S1     , W_PTR_GRAY_B_S1;
logic           W_FULL_B_S1         , R_EMPTY_B_S1;
assign AFIFO_WDATA_B_S1 = {BID_S1, BRESP_S1};
assign {BID_S1_axi, BRESP_S1_axi} = AFIFO_RDATA_T_B_S1;
assign BREADY_S1 = ~W_FULL_B_S1;
assign BVALID_S1_axi = ~R_EMPTY_B_S1;
AFIFO_Tx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Tx_B_S1
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .W_DATA(AFIFO_WDATA_B_S1),
    .WEN(BVALID_S1),
    .W_FULL(W_FULL_B_S1),
    .R_PTR_GRAY(R_PTR_GRAY_B_S1),
    .R_PTR_Binary(R_PTR_Binary_B_S1),
    .W_PTR_GRAY(W_PTR_GRAY_B_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S1)
);
AFIFO_Rx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Rx_B_S1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_B_S1),
    .REN(BREADY_S1_axi),
    .R_EMPTY(R_EMPTY_B_S1),
    .W_PTR_GRAY(W_PTR_GRAY_B_S1),
    .R_PTR_GRAY(R_PTR_GRAY_B_S1),
    .R_PTR_Binary(R_PTR_Binary_B_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S1)
);
//====================== S1  B ======================//
//====================== S1 AR ======================//
logic   [48:0]  AFIFO_WDATA_AR_S1   , AFIFO_RDATA_AR_S1     , AFIFO_RDATA_T_AR_S1;
logic   [3:0]   R_PTR_GRAY_AR_S1    , R_PTR_Binary_AR_S1    , W_PTR_GRAY_AR_S1;
logic           W_FULL_AR_S1        , R_EMPTY_AR_S1;
assign AFIFO_WDATA_AR_S1 = {ARID_S1_axi, ARADDR_S1_axi, ARLEN_S1_axi, ARSIZE_S1_axi, ARBURST_S1_axi};
assign {ARID_S1, ARADDR_S1, ARLEN_S1, ARSIZE_S1, ARBURST_S1} = AFIFO_RDATA_T_AR_S1;
assign ARREADY_S1_axi = ~W_FULL_AR_S1;
assign ARVALID_S1 = ~R_EMPTY_AR_S1;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_S1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AR_S1),
    .WEN(ARVALID_S1_axi),
    .W_FULL(W_FULL_AR_S1),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S1),
    .R_PTR_Binary(R_PTR_Binary_AR_S1),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S1)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_S1
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .R_DATA(AFIFO_RDATA_AR_S1),
    .REN(ARREADY_S1),
    .R_EMPTY(R_EMPTY_AR_S1),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S1),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S1),
    .R_PTR_Binary(R_PTR_Binary_AR_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S1)
);
//====================== S1 AR ======================//
//====================== S1  R ======================//
logic   [42:0]  AFIFO_WDATA_R_S1    , AFIFO_RDATA_R_S1      , AFIFO_RDATA_T_R_S1;
logic   [3:0]   R_PTR_GRAY_R_S1     , R_PTR_Binary_R_S1     , W_PTR_GRAY_R_S1;
logic           W_FULL_R_S1         , R_EMPTY_R_S1;
assign AFIFO_WDATA_R_S1 = {RID_S1, RDATA_S1, RRESP_S1, RLAST_S1};
assign {RID_S1_axi, RDATA_S1_axi, RRESP_S1_axi, RLAST_S1_axi} = AFIFO_RDATA_T_R_S1;
assign RREADY_S1 = ~W_FULL_R_S1;
assign RVALID_S1_axi = ~R_EMPTY_R_S1;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_S1
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .W_DATA(AFIFO_WDATA_R_S1),
    .WEN(RVALID_S1),
    .W_FULL(W_FULL_R_S1),
    .R_PTR_GRAY(R_PTR_GRAY_R_S1),
    .R_PTR_Binary(R_PTR_Binary_R_S1),
    .W_PTR_GRAY(W_PTR_GRAY_R_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S1)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_S1
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_R_S1),
    .REN(RREADY_S1_axi),
    .R_EMPTY(R_EMPTY_R_S1),
    .W_PTR_GRAY(W_PTR_GRAY_R_S1),
    .R_PTR_GRAY(R_PTR_GRAY_R_S1),
    .R_PTR_Binary(R_PTR_Binary_R_S1),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S1)
);
//====================== S1  R ======================//

//====================================== SLAVE2  ======================================//

//====================== S2 AW ======================//
logic   [48:0]  AFIFO_WDATA_AW_S2   , AFIFO_RDATA_AW_S2     , AFIFO_RDATA_T_AW_S2;
logic   [3:0]   R_PTR_GRAY_AW_S2    , R_PTR_Binary_AW_S2    , W_PTR_GRAY_AW_S2;
logic           W_FULL_AW_S2        , R_EMPTY_AW_S2;
assign AFIFO_WDATA_AW_S2 = {AWID_S2_axi, AWADDR_S2_axi, AWLEN_S2_axi, AWSIZE_S2_axi, AWBURST_S2_axi};
assign {AWID_S2, AWADDR_S2, AWLEN_S2, AWSIZE_S2, AWBURST_S2} = AFIFO_RDATA_T_AW_S2;
assign AWREADY_S2_axi = ~W_FULL_AW_S2;
assign AWVALID_S2 = ~R_EMPTY_AW_S2;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AW_S2
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AW_S2),
    .WEN(AWVALID_S2_axi),
    .W_FULL(W_FULL_AW_S2),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S2),
    .R_PTR_Binary(R_PTR_Binary_AW_S2),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S2)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AW_S2
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .R_DATA(AFIFO_RDATA_AW_S2),
    .REN(AWREADY_S2),
    .R_EMPTY(R_EMPTY_AW_S2),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S2),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S2),
    .R_PTR_Binary(R_PTR_Binary_AW_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S2)
);
//====================== S2 AW ======================//
//====================== S2  W ======================//
logic   [36:0]  AFIFO_WDATA_W_S2    , AFIFO_RDATA_W_S2      , AFIFO_RDATA_T_W_S2;
logic   [3:0]   R_PTR_GRAY_W_S2     , R_PTR_Binary_W_S2     , W_PTR_GRAY_W_S2;
logic           W_FULL_W_S2         , R_EMPTY_W_S2;
assign AFIFO_WDATA_W_S2 = {WDATA_S2_axi, WSTRB_S2_axi, WLAST_S2_axi};
assign {WDATA_S2, WSTRB_S2, WLAST_S2} = AFIFO_RDATA_T_W_S2;
assign WREADY_S2_axi = ~W_FULL_W_S2;
assign WVALID_S2 = ~R_EMPTY_W_S2;
AFIFO_Tx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Tx_W_S2
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_W_S2),
    .WEN(WVALID_S2_axi),
    .W_FULL(W_FULL_W_S2),
    .R_PTR_GRAY(R_PTR_GRAY_W_S2),
    .R_PTR_Binary(R_PTR_Binary_W_S2),
    .W_PTR_GRAY(W_PTR_GRAY_W_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S2)
);
AFIFO_Rx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Rx_W_S2
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .R_DATA(AFIFO_RDATA_W_S2),
    .REN(WREADY_S2),
    .R_EMPTY(R_EMPTY_W_S2),
    .W_PTR_GRAY(W_PTR_GRAY_W_S2),
    .R_PTR_GRAY(R_PTR_GRAY_W_S2),
    .R_PTR_Binary(R_PTR_Binary_W_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S2)
);
//====================== S2  W ======================//
//====================== S2  B ======================//
logic   [9:0]   AFIFO_WDATA_B_S2    , AFIFO_RDATA_B_S2      , AFIFO_RDATA_T_B_S2;
logic   [3:0]   R_PTR_GRAY_B_S2     , R_PTR_Binary_B_S2     , W_PTR_GRAY_B_S2;
logic           W_FULL_B_S2         , R_EMPTY_B_S2;
assign AFIFO_WDATA_B_S2 = {BID_S2, BRESP_S2};
assign {BID_S2_axi, BRESP_S2_axi} = AFIFO_RDATA_T_B_S2;
assign BREADY_S2 = ~W_FULL_B_S2;
assign BVALID_S2_axi = ~R_EMPTY_B_S2;
AFIFO_Tx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Tx_B_S2
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .W_DATA(AFIFO_WDATA_B_S2),
    .WEN(BVALID_S2),
    .W_FULL(W_FULL_B_S2),
    .R_PTR_GRAY(R_PTR_GRAY_B_S2),
    .R_PTR_Binary(R_PTR_Binary_B_S2),
    .W_PTR_GRAY(W_PTR_GRAY_B_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S2)
);
AFIFO_Rx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Rx_B_S2
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_B_S2),
    .REN(BREADY_S2_axi),
    .R_EMPTY(R_EMPTY_B_S2),
    .W_PTR_GRAY(W_PTR_GRAY_B_S2),
    .R_PTR_GRAY(R_PTR_GRAY_B_S2),
    .R_PTR_Binary(R_PTR_Binary_B_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S2)
);
//====================== S2  B ======================//
//====================== S2 AR ======================//
logic   [48:0]  AFIFO_WDATA_AR_S2   , AFIFO_RDATA_AR_S2     , AFIFO_RDATA_T_AR_S2;
logic   [3:0]   R_PTR_GRAY_AR_S2    , R_PTR_Binary_AR_S2    , W_PTR_GRAY_AR_S2;
logic           W_FULL_AR_S2        , R_EMPTY_AR_S2;
assign AFIFO_WDATA_AR_S2 = {ARID_S2_axi, ARADDR_S2_axi, ARLEN_S2_axi, ARSIZE_S2_axi, ARBURST_S2_axi};
assign {ARID_S2, ARADDR_S2, ARLEN_S2, ARSIZE_S2, ARBURST_S2} = AFIFO_RDATA_T_AR_S2;
assign ARREADY_S2_axi = ~W_FULL_AR_S2;
assign ARVALID_S2 = ~R_EMPTY_AR_S2;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_S2
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AR_S2),
    .WEN(ARVALID_S2_axi),
    .W_FULL(W_FULL_AR_S2),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S2),
    .R_PTR_Binary(R_PTR_Binary_AR_S2),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S2)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_S2
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .R_DATA(AFIFO_RDATA_AR_S2),
    .REN(ARREADY_S2),
    .R_EMPTY(R_EMPTY_AR_S2),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S2),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S2),
    .R_PTR_Binary(R_PTR_Binary_AR_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S2)
);
//====================== S2 AR ======================//
//====================== S2  R ======================//
logic   [42:0]  AFIFO_WDATA_R_S2    , AFIFO_RDATA_R_S2      , AFIFO_RDATA_T_R_S2;
logic   [3:0]   R_PTR_GRAY_R_S2     , R_PTR_Binary_R_S2     , W_PTR_GRAY_R_S2;
logic           W_FULL_R_S2         , R_EMPTY_R_S2;
assign AFIFO_WDATA_R_S2 = {RID_S2, RDATA_S2, RRESP_S2, RLAST_S2};
assign {RID_S2_axi, RDATA_S2_axi, RRESP_S2_axi, RLAST_S2_axi} = AFIFO_RDATA_T_R_S2;
assign RREADY_S2 = ~W_FULL_R_S2;
assign RVALID_S2_axi = ~R_EMPTY_R_S2;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_S2
(
    .CLK(sram_clk),
    .RSTn(SRAM_RSTn),
    .W_DATA(AFIFO_WDATA_R_S2),
    .WEN(RVALID_S2),
    .W_FULL(W_FULL_R_S2),
    .R_PTR_GRAY(R_PTR_GRAY_R_S2),
    .R_PTR_Binary(R_PTR_Binary_R_S2),
    .W_PTR_GRAY(W_PTR_GRAY_R_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S2)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_S2
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_R_S2),
    .REN(RREADY_S2_axi),
    .R_EMPTY(R_EMPTY_R_S2),
    .W_PTR_GRAY(W_PTR_GRAY_R_S2),
    .R_PTR_GRAY(R_PTR_GRAY_R_S2),
    .R_PTR_Binary(R_PTR_Binary_R_S2),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S2)
);
//====================== S2  R ======================//

//====================================== SLAVE3  ======================================//

//====================== S3 AW ======================//
logic   [48:0]  AFIFO_WDATA_AW_S3   , AFIFO_RDATA_AW_S3     , AFIFO_RDATA_T_AW_S3;
logic   [3:0]   R_PTR_GRAY_AW_S3    , R_PTR_Binary_AW_S3    , W_PTR_GRAY_AW_S3;
logic           W_FULL_AW_S3        , R_EMPTY_AW_S3;
assign AFIFO_WDATA_AW_S3 = {AWID_S3_axi, AWADDR_S3_axi, AWLEN_S3_axi, AWSIZE_S3_axi, AWBURST_S3_axi};
assign {AWID_S3, AWADDR_S3, AWLEN_S3, AWSIZE_S3, AWBURST_S3} = AFIFO_RDATA_T_AW_S3;
assign AWREADY_S3_axi = ~W_FULL_AW_S3;
assign AWVALID_S3 = ~R_EMPTY_AW_S3;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AW_S3
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AW_S3),
    .WEN(AWVALID_S3_axi),
    .W_FULL(W_FULL_AW_S3),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S3),
    .R_PTR_Binary(R_PTR_Binary_AW_S3),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S3)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AW_S3
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .R_DATA(AFIFO_RDATA_AW_S3),
    .REN(AWREADY_S3),
    .R_EMPTY(R_EMPTY_AW_S3),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S3),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S3),
    .R_PTR_Binary(R_PTR_Binary_AW_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S3)
);
//====================== S3 AW ======================//
//====================== S3  W ======================//
logic   [36:0]  AFIFO_WDATA_W_S3    , AFIFO_RDATA_W_S3      , AFIFO_RDATA_T_W_S3;
logic   [3:0]   R_PTR_GRAY_W_S3     , R_PTR_Binary_W_S3     , W_PTR_GRAY_W_S3;
logic           W_FULL_W_S3         , R_EMPTY_W_S3;
assign AFIFO_WDATA_W_S3 = {WDATA_S3_axi, WSTRB_S3_axi, WLAST_S3_axi};
assign {WDATA_S3, WSTRB_S3, WLAST_S3} = AFIFO_RDATA_T_W_S3;
assign WREADY_S3_axi = ~W_FULL_W_S3;
assign WVALID_S3 = ~R_EMPTY_W_S3;
AFIFO_Tx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Tx_W_S3
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_W_S3),
    .WEN(WVALID_S3_axi),
    .W_FULL(W_FULL_W_S3),
    .R_PTR_GRAY(R_PTR_GRAY_W_S3),
    .R_PTR_Binary(R_PTR_Binary_W_S3),
    .W_PTR_GRAY(W_PTR_GRAY_W_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S3)
);
AFIFO_Rx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Rx_W_S3
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .R_DATA(AFIFO_RDATA_W_S3),
    .REN(WREADY_S3),
    .R_EMPTY(R_EMPTY_W_S3),
    .W_PTR_GRAY(W_PTR_GRAY_W_S3),
    .R_PTR_GRAY(R_PTR_GRAY_W_S3),
    .R_PTR_Binary(R_PTR_Binary_W_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S3)
);
//====================== S3  W ======================//
//====================== S3  B ======================//
logic   [9:0]   AFIFO_WDATA_B_S3    , AFIFO_RDATA_B_S3      , AFIFO_RDATA_T_B_S3;
logic   [3:0]   R_PTR_GRAY_B_S3     , R_PTR_Binary_B_S3     , W_PTR_GRAY_B_S3;
logic           W_FULL_B_S3         , R_EMPTY_B_S3;
assign AFIFO_WDATA_B_S3 = {BID_S3, BRESP_S3};
assign {BID_S3_axi, BRESP_S3_axi} = AFIFO_RDATA_T_B_S3;
assign BREADY_S3 = ~W_FULL_B_S3;
assign BVALID_S3_axi = ~R_EMPTY_B_S3;
AFIFO_Tx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Tx_B_S3
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .W_DATA(AFIFO_WDATA_B_S3),
    .WEN(BVALID_S3),
    .W_FULL(W_FULL_B_S3),
    .R_PTR_GRAY(R_PTR_GRAY_B_S3),
    .R_PTR_Binary(R_PTR_Binary_B_S3),
    .W_PTR_GRAY(W_PTR_GRAY_B_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S3)
);
AFIFO_Rx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Rx_B_S3
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_B_S3),
    .REN(BREADY_S3_axi),
    .R_EMPTY(R_EMPTY_B_S3),
    .W_PTR_GRAY(W_PTR_GRAY_B_S3),
    .R_PTR_GRAY(R_PTR_GRAY_B_S3),
    .R_PTR_Binary(R_PTR_Binary_B_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S3)
);
//====================== S3  B ======================//
//====================== S3 AR ======================//
logic   [48:0]  AFIFO_WDATA_AR_S3   , AFIFO_RDATA_AR_S3     , AFIFO_RDATA_T_AR_S3;
logic   [3:0]   R_PTR_GRAY_AR_S3    , R_PTR_Binary_AR_S3    , W_PTR_GRAY_AR_S3;
logic           W_FULL_AR_S3        , R_EMPTY_AR_S3;
assign AFIFO_WDATA_AR_S3 = {ARID_S3_axi, ARADDR_S3_axi, ARLEN_S3_axi, ARSIZE_S3_axi, ARBURST_S3_axi};
assign {ARID_S3, ARADDR_S3, ARLEN_S3, ARSIZE_S3, ARBURST_S3} = AFIFO_RDATA_T_AR_S3;
assign ARREADY_S3_axi = ~W_FULL_AR_S3;
assign ARVALID_S3 = ~R_EMPTY_AR_S3;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_S3
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AR_S3),
    .WEN(ARVALID_S3_axi),
    .W_FULL(W_FULL_AR_S3),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S3),
    .R_PTR_Binary(R_PTR_Binary_AR_S3),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S3)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_S3
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .R_DATA(AFIFO_RDATA_AR_S3),
    .REN(ARREADY_S3),
    .R_EMPTY(R_EMPTY_AR_S3),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S3),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S3),
    .R_PTR_Binary(R_PTR_Binary_AR_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S3)
);
//====================== S3 AR ======================//
//====================== S3  R ======================//
logic   [42:0]  AFIFO_WDATA_R_S3    , AFIFO_RDATA_R_S3      , AFIFO_RDATA_T_R_S3;
logic   [3:0]   R_PTR_GRAY_R_S3     , R_PTR_Binary_R_S3     , W_PTR_GRAY_R_S3;
logic           W_FULL_R_S3         , R_EMPTY_R_S3;
assign AFIFO_WDATA_R_S3 = {RID_S3, RDATA_S3, RRESP_S3, RLAST_S3};
assign {RID_S3_axi, RDATA_S3_axi, RRESP_S3_axi, RLAST_S3_axi} = AFIFO_RDATA_T_R_S3;
assign RREADY_S3 = ~W_FULL_R_S3;
assign RVALID_S3_axi = ~R_EMPTY_R_S3;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_S3
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .W_DATA(AFIFO_WDATA_R_S3),
    .WEN(RVALID_S3),
    .W_FULL(W_FULL_R_S3),
    .R_PTR_GRAY(R_PTR_GRAY_R_S3),
    .R_PTR_Binary(R_PTR_Binary_R_S3),
    .W_PTR_GRAY(W_PTR_GRAY_R_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S3)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_S3
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_R_S3),
    .REN(RREADY_S3_axi),
    .R_EMPTY(R_EMPTY_R_S3),
    .W_PTR_GRAY(W_PTR_GRAY_R_S3),
    .R_PTR_GRAY(R_PTR_GRAY_R_S3),
    .R_PTR_Binary(R_PTR_Binary_R_S3),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S3)
);
//====================== S3  R ======================//

//====================================== SLAVE4  ======================================//

//====================== S4 AW ======================//
logic   [48:0]  AFIFO_WDATA_AW_S4   , AFIFO_RDATA_AW_S4     , AFIFO_RDATA_T_AW_S4;
logic   [3:0]   R_PTR_GRAY_AW_S4    , R_PTR_Binary_AW_S4    , W_PTR_GRAY_AW_S4;
logic           W_FULL_AW_S4        , R_EMPTY_AW_S4;
assign AFIFO_WDATA_AW_S4 = {AWID_S4_axi, AWADDR_S4_axi, AWLEN_S4_axi, AWSIZE_S4_axi, AWBURST_S4_axi};
assign {AWID_S4, AWADDR_S4, AWLEN_S4, AWSIZE_S4, AWBURST_S4} = AFIFO_RDATA_T_AW_S4;
assign AWREADY_S4_axi = ~W_FULL_AW_S4;
assign AWVALID_S4 = ~R_EMPTY_AW_S4;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AW_S4
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AW_S4),
    .WEN(AWVALID_S4_axi),
    .W_FULL(W_FULL_AW_S4),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S4),
    .R_PTR_Binary(R_PTR_Binary_AW_S4),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S4)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AW_S4
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_AW_S4),
    .REN(AWREADY_S4),
    .R_EMPTY(R_EMPTY_AW_S4),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S4),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S4),
    .R_PTR_Binary(R_PTR_Binary_AW_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S4)
);
//====================== S4 AW ======================//
//====================== S4  W ======================//
logic   [36:0]  AFIFO_WDATA_W_S4    , AFIFO_RDATA_W_S4      , AFIFO_RDATA_T_W_S4;
logic   [3:0]   R_PTR_GRAY_W_S4     , R_PTR_Binary_W_S4     , W_PTR_GRAY_W_S4;
logic           W_FULL_W_S4         , R_EMPTY_W_S4;
assign AFIFO_WDATA_W_S4 = {WDATA_S4_axi, WSTRB_S4_axi, WLAST_S4_axi};
assign {WDATA_S4, WSTRB_S4, WLAST_S4} = AFIFO_RDATA_T_W_S4;
assign WREADY_S4_axi = ~W_FULL_W_S4;
assign WVALID_S4 = ~R_EMPTY_W_S4;
AFIFO_Tx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Tx_W_S4
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_W_S4),
    .WEN(WVALID_S4_axi),
    .W_FULL(W_FULL_W_S4),
    .R_PTR_GRAY(R_PTR_GRAY_W_S4),
    .R_PTR_Binary(R_PTR_Binary_W_S4),
    .W_PTR_GRAY(W_PTR_GRAY_W_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S4)
);
AFIFO_Rx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Rx_W_S4
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_W_S4),
    .REN(WREADY_S4),
    .R_EMPTY(R_EMPTY_W_S4),
    .W_PTR_GRAY(W_PTR_GRAY_W_S4),
    .R_PTR_GRAY(R_PTR_GRAY_W_S4),
    .R_PTR_Binary(R_PTR_Binary_W_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S4)
);
//====================== S4  W ======================//
//====================== S4  B ======================//
logic   [9:0]   AFIFO_WDATA_B_S4    , AFIFO_RDATA_B_S4      , AFIFO_RDATA_T_B_S4;
logic   [3:0]   R_PTR_GRAY_B_S4     , R_PTR_Binary_B_S4     , W_PTR_GRAY_B_S4;
logic           W_FULL_B_S4         , R_EMPTY_B_S4;
assign AFIFO_WDATA_B_S4 = {BID_S4, BRESP_S4};
assign {BID_S4_axi, BRESP_S4_axi} = AFIFO_RDATA_T_B_S4;
assign BREADY_S4 = ~W_FULL_B_S4;
assign BVALID_S4_axi = ~R_EMPTY_B_S4;
AFIFO_Tx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Tx_B_S4
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_B_S4),
    .WEN(BVALID_S4),
    .W_FULL(W_FULL_B_S4),
    .R_PTR_GRAY(R_PTR_GRAY_B_S4),
    .R_PTR_Binary(R_PTR_Binary_B_S4),
    .W_PTR_GRAY(W_PTR_GRAY_B_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S4)
);
AFIFO_Rx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Rx_B_S4
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_B_S4),
    .REN(BREADY_S4_axi),
    .R_EMPTY(R_EMPTY_B_S4),
    .W_PTR_GRAY(W_PTR_GRAY_B_S4),
    .R_PTR_GRAY(R_PTR_GRAY_B_S4),
    .R_PTR_Binary(R_PTR_Binary_B_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S4)
);
//====================== S4  B ======================//
//====================== S4 AR ======================//
logic   [48:0]  AFIFO_WDATA_AR_S4   , AFIFO_RDATA_AR_S4     , AFIFO_RDATA_T_AR_S4;
logic   [3:0]   R_PTR_GRAY_AR_S4    , R_PTR_Binary_AR_S4    , W_PTR_GRAY_AR_S4;
logic           W_FULL_AR_S4        , R_EMPTY_AR_S4;
assign AFIFO_WDATA_AR_S4 = {ARID_S4_axi, ARADDR_S4_axi, ARLEN_S4_axi, ARSIZE_S4_axi, ARBURST_S4_axi};
assign {ARID_S4, ARADDR_S4, ARLEN_S4, ARSIZE_S4, ARBURST_S4} = AFIFO_RDATA_T_AR_S4;
assign ARREADY_S4_axi = ~W_FULL_AR_S4;
assign ARVALID_S4 = ~R_EMPTY_AR_S4;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_S4
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AR_S4),
    .WEN(ARVALID_S4_axi),
    .W_FULL(W_FULL_AR_S4),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S4),
    .R_PTR_Binary(R_PTR_Binary_AR_S4),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S4)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_S4
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_AR_S4),
    .REN(ARREADY_S4),
    .R_EMPTY(R_EMPTY_AR_S4),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S4),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S4),
    .R_PTR_Binary(R_PTR_Binary_AR_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S4)
);
//====================== S4 AR ======================//
//====================== S4  R ======================//
logic   [42:0]  AFIFO_WDATA_R_S4    , AFIFO_RDATA_R_S4      , AFIFO_RDATA_T_R_S4;
logic   [3:0]   R_PTR_GRAY_R_S4     , R_PTR_Binary_R_S4     , W_PTR_GRAY_R_S4;
logic           W_FULL_R_S4         , R_EMPTY_R_S4;
assign AFIFO_WDATA_R_S4 = {RID_S4, RDATA_S4, RRESP_S4, RLAST_S4};
assign {RID_S4_axi, RDATA_S4_axi, RRESP_S4_axi, RLAST_S4_axi} = AFIFO_RDATA_T_R_S4;
assign RREADY_S4 = ~W_FULL_R_S4;
assign RVALID_S4_axi = ~R_EMPTY_R_S4;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_S4
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_R_S4),
    .WEN(RVALID_S4),
    .W_FULL(W_FULL_R_S4),
    .R_PTR_GRAY(R_PTR_GRAY_R_S4),
    .R_PTR_Binary(R_PTR_Binary_R_S4),
    .W_PTR_GRAY(W_PTR_GRAY_R_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S4)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_S4
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_R_S4),
    .REN(RREADY_S4_axi),
    .R_EMPTY(R_EMPTY_R_S4),
    .W_PTR_GRAY(W_PTR_GRAY_R_S4),
    .R_PTR_GRAY(R_PTR_GRAY_R_S4),
    .R_PTR_Binary(R_PTR_Binary_R_S4),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S4)
);
//====================== S4  R ======================//

//====================================== SLAVE5  ======================================//

//====================== S5 AW ======================//
logic   [48:0]  AFIFO_WDATA_AW_S5   , AFIFO_RDATA_AW_S5     , AFIFO_RDATA_T_AW_S5;
logic   [3:0]   R_PTR_GRAY_AW_S5    , R_PTR_Binary_AW_S5    , W_PTR_GRAY_AW_S5;
logic           W_FULL_AW_S5        , R_EMPTY_AW_S5;
assign AFIFO_WDATA_AW_S5 = {AWID_S5_axi, AWADDR_S5_axi, AWLEN_S5_axi, AWSIZE_S5_axi, AWBURST_S5_axi};
assign {AWID_S5, AWADDR_S5, AWLEN_S5, AWSIZE_S5, AWBURST_S5} = AFIFO_RDATA_T_AW_S5;
assign AWREADY_S5_axi = ~W_FULL_AW_S5;
assign AWVALID_S5 = ~R_EMPTY_AW_S5;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AW_S5
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AW_S5),
    .WEN(AWVALID_S5_axi),
    .W_FULL(W_FULL_AW_S5),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S5),
    .R_PTR_Binary(R_PTR_Binary_AW_S5),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S5)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AW_S5
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .R_DATA(AFIFO_RDATA_AW_S5),
    .REN(AWREADY_S5),
    .R_EMPTY(R_EMPTY_AW_S5),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S5),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S5),
    .R_PTR_Binary(R_PTR_Binary_AW_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S5)
);
//====================== S5 AW ======================//
//====================== S5  W ======================//
logic   [36:0]  AFIFO_WDATA_W_S5    , AFIFO_RDATA_W_S5      , AFIFO_RDATA_T_W_S5;
logic   [4:0]   R_PTR_GRAY_W_S5     , R_PTR_Binary_W_S5     , W_PTR_GRAY_W_S5;
logic           W_FULL_W_S5         , R_EMPTY_W_S5;
assign AFIFO_WDATA_W_S5 = {WDATA_S5_axi, WSTRB_S5_axi, WLAST_S5_axi};
assign {WDATA_S5, WSTRB_S5, WLAST_S5} = AFIFO_RDATA_T_W_S5;
assign WREADY_S5_axi = ~W_FULL_W_S5;
assign WVALID_S5 = ~R_EMPTY_W_S5;
AFIFO_Tx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(5)
) AFIFO_Tx_W_S5
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_W_S5),
    .WEN(WVALID_S5_axi),
    .W_FULL(W_FULL_W_S5),
    .R_PTR_GRAY(R_PTR_GRAY_W_S5),
    .R_PTR_Binary(R_PTR_Binary_W_S5),
    .W_PTR_GRAY(W_PTR_GRAY_W_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S5)
);
AFIFO_Rx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(5)
) AFIFO_Rx_W_S5
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .R_DATA(AFIFO_RDATA_W_S5),
    .REN(WREADY_S5),
    .R_EMPTY(R_EMPTY_W_S5),
    .W_PTR_GRAY(W_PTR_GRAY_W_S5),
    .R_PTR_GRAY(R_PTR_GRAY_W_S5),
    .R_PTR_Binary(R_PTR_Binary_W_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S5)
);
//====================== S5  W ======================//
//====================== S5  B ======================//
logic   [9:0]   AFIFO_WDATA_B_S5    , AFIFO_RDATA_B_S5      , AFIFO_RDATA_T_B_S5;
logic   [3:0]   R_PTR_GRAY_B_S5     , R_PTR_Binary_B_S5     , W_PTR_GRAY_B_S5;
logic           W_FULL_B_S5         , R_EMPTY_B_S5;
assign AFIFO_WDATA_B_S5 = {BID_S5, BRESP_S5};
assign {BID_S5_axi, BRESP_S5_axi} = AFIFO_RDATA_T_B_S5;
assign BREADY_S5 = ~W_FULL_B_S5;
assign BVALID_S5_axi = ~R_EMPTY_B_S5;
AFIFO_Tx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Tx_B_S5
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .W_DATA(AFIFO_WDATA_B_S5),
    .WEN(BVALID_S5),
    .W_FULL(W_FULL_B_S5),
    .R_PTR_GRAY(R_PTR_GRAY_B_S5),
    .R_PTR_Binary(R_PTR_Binary_B_S5),
    .W_PTR_GRAY(W_PTR_GRAY_B_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S5)
);
AFIFO_Rx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Rx_B_S5
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_B_S5),
    .REN(BREADY_S5_axi),
    .R_EMPTY(R_EMPTY_B_S5),
    .W_PTR_GRAY(W_PTR_GRAY_B_S5),
    .R_PTR_GRAY(R_PTR_GRAY_B_S5),
    .R_PTR_Binary(R_PTR_Binary_B_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S5)
);
//====================== S5  B ======================//
//====================== S5 AR ======================//
logic   [48:0]  AFIFO_WDATA_AR_S5   , AFIFO_RDATA_AR_S5     , AFIFO_RDATA_T_AR_S5;
logic   [3:0]   R_PTR_GRAY_AR_S5    , R_PTR_Binary_AR_S5    , W_PTR_GRAY_AR_S5;
logic           W_FULL_AR_S5        , R_EMPTY_AR_S5;
assign AFIFO_WDATA_AR_S5 = {ARID_S5_axi, ARADDR_S5_axi, ARLEN_S5_axi, ARSIZE_S5_axi, ARBURST_S5_axi};
assign {ARID_S5, ARADDR_S5, ARLEN_S5, ARSIZE_S5, ARBURST_S5} = AFIFO_RDATA_T_AR_S5;
assign ARREADY_S5_axi = ~W_FULL_AR_S5;
assign ARVALID_S5 = ~R_EMPTY_AR_S5;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_S5
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AR_S5),
    .WEN(ARVALID_S5_axi),
    .W_FULL(W_FULL_AR_S5),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S5),
    .R_PTR_Binary(R_PTR_Binary_AR_S5),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S5)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_S5
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .R_DATA(AFIFO_RDATA_AR_S5),
    .REN(ARREADY_S5),
    .R_EMPTY(R_EMPTY_AR_S5),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S5),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S5),
    .R_PTR_Binary(R_PTR_Binary_AR_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S5)
);
//====================== S5 AR ======================//
//====================== S5  R ======================//
logic   [42:0]  AFIFO_WDATA_R_S5    , AFIFO_RDATA_R_S5      , AFIFO_RDATA_T_R_S5;
logic   [3:0]   R_PTR_GRAY_R_S5     , R_PTR_Binary_R_S5     , W_PTR_GRAY_R_S5;
logic           W_FULL_R_S5         , R_EMPTY_R_S5;
assign AFIFO_WDATA_R_S5 = {RID_S5, RDATA_S5, RRESP_S5, RLAST_S5};
assign {RID_S5_axi, RDATA_S5_axi, RRESP_S5_axi, RLAST_S5_axi} = AFIFO_RDATA_T_R_S5;
assign RREADY_S5 = ~W_FULL_R_S5;
assign RVALID_S5_axi = ~R_EMPTY_R_S5;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_S5
(
    .CLK(dram_clk),
    .RSTn(DRAM_RSTn),
    .W_DATA(AFIFO_WDATA_R_S5),
    .WEN(RVALID_S5),
    .W_FULL(W_FULL_R_S5),
    .R_PTR_GRAY(R_PTR_GRAY_R_S5),
    .R_PTR_Binary(R_PTR_Binary_R_S5),
    .W_PTR_GRAY(W_PTR_GRAY_R_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S5)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_S5
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_R_S5),
    .REN(RREADY_S5_axi),
    .R_EMPTY(R_EMPTY_R_S5),
    .W_PTR_GRAY(W_PTR_GRAY_R_S5),
    .R_PTR_GRAY(R_PTR_GRAY_R_S5),
    .R_PTR_Binary(R_PTR_Binary_R_S5),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S5)
);
//====================== S5  R ======================//

//====================================== SLAVE7  ======================================//

//====================== S7 AW ======================//
logic   [48:0]  AFIFO_WDATA_AW_S7   , AFIFO_RDATA_AW_S7     , AFIFO_RDATA_T_AW_S7;
logic   [3:0]   R_PTR_GRAY_AW_S7    , R_PTR_Binary_AW_S7    , W_PTR_GRAY_AW_S7;
logic           W_FULL_AW_S7        , R_EMPTY_AW_S7;
assign AFIFO_WDATA_AW_S7 = {AWID_S7_axi, AWADDR_S7_axi, AWLEN_S7_axi, AWSIZE_S7_axi, AWBURST_S7_axi};
assign {AWID_S7, AWADDR_S7, AWLEN_S7, AWSIZE_S7, AWBURST_S7} = AFIFO_RDATA_T_AW_S7;
assign AWREADY_S7_axi = ~W_FULL_AW_S7;
assign AWVALID_S7 = ~R_EMPTY_AW_S7;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AW_S7
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AW_S7),
    .WEN(AWVALID_S7_axi),
    .W_FULL(W_FULL_AW_S7),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S7),
    .R_PTR_Binary(R_PTR_Binary_AW_S7),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S7)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AW_S7
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_AW_S7),
    .REN(AWREADY_S7),
    .R_EMPTY(R_EMPTY_AW_S7),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S7),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S7),
    .R_PTR_Binary(R_PTR_Binary_AW_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S7)
);
//====================== S7 AW ======================//
//====================== S7  W ======================//
logic   [36:0]  AFIFO_WDATA_W_S7    , AFIFO_RDATA_W_S7      , AFIFO_RDATA_T_W_S7;
logic   [3:0]   R_PTR_GRAY_W_S7     , R_PTR_Binary_W_S7     , W_PTR_GRAY_W_S7;
logic           W_FULL_W_S7         , R_EMPTY_W_S7;
assign AFIFO_WDATA_W_S7 = {WDATA_S7_axi, WSTRB_S7_axi, WLAST_S7_axi};
assign {WDATA_S7, WSTRB_S7, WLAST_S7} = AFIFO_RDATA_T_W_S7;
assign WREADY_S7_axi = ~W_FULL_W_S7;
assign WVALID_S7 = ~R_EMPTY_W_S7;
AFIFO_Tx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Tx_W_S7
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_W_S7),
    .WEN(WVALID_S7_axi),
    .W_FULL(W_FULL_W_S7),
    .R_PTR_GRAY(R_PTR_GRAY_W_S7),
    .R_PTR_Binary(R_PTR_Binary_W_S7),
    .W_PTR_GRAY(W_PTR_GRAY_W_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S7)
);
AFIFO_Rx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Rx_W_S7
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_W_S7),
    .REN(WREADY_S7),
    .R_EMPTY(R_EMPTY_W_S7),
    .W_PTR_GRAY(W_PTR_GRAY_W_S7),
    .R_PTR_GRAY(R_PTR_GRAY_W_S7),
    .R_PTR_Binary(R_PTR_Binary_W_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S7)
);
//====================== S7  W ======================//
//====================== S7  B ======================//
logic   [9:0]   AFIFO_WDATA_B_S7    , AFIFO_RDATA_B_S7      , AFIFO_RDATA_T_B_S7;
logic   [3:0]   R_PTR_GRAY_B_S7     , R_PTR_Binary_B_S7     , W_PTR_GRAY_B_S7;
logic           W_FULL_B_S7         , R_EMPTY_B_S7;
assign AFIFO_WDATA_B_S7 = {BID_S7, BRESP_S7};
assign {BID_S7_axi, BRESP_S7_axi} = AFIFO_RDATA_T_B_S7;
assign BREADY_S7 = ~W_FULL_B_S7;
assign BVALID_S7_axi = ~R_EMPTY_B_S7;
AFIFO_Tx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Tx_B_S7
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_B_S7),
    .WEN(BVALID_S7),
    .W_FULL(W_FULL_B_S7),
    .R_PTR_GRAY(R_PTR_GRAY_B_S7),
    .R_PTR_Binary(R_PTR_Binary_B_S7),
    .W_PTR_GRAY(W_PTR_GRAY_B_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S7)
);
AFIFO_Rx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Rx_B_S7
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_B_S7),
    .REN(BREADY_S7_axi),
    .R_EMPTY(R_EMPTY_B_S7),
    .W_PTR_GRAY(W_PTR_GRAY_B_S7),
    .R_PTR_GRAY(R_PTR_GRAY_B_S7),
    .R_PTR_Binary(R_PTR_Binary_B_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S7)
);
//====================== S7  B ======================//
//====================== S7 AR ======================//
logic   [48:0]  AFIFO_WDATA_AR_S7   , AFIFO_RDATA_AR_S7     , AFIFO_RDATA_T_AR_S7;
logic   [3:0]   R_PTR_GRAY_AR_S7    , R_PTR_Binary_AR_S7    , W_PTR_GRAY_AR_S7;
logic           W_FULL_AR_S7        , R_EMPTY_AR_S7;
assign AFIFO_WDATA_AR_S7 = {ARID_S7_axi, ARADDR_S7_axi, ARLEN_S7_axi, ARSIZE_S7_axi, ARBURST_S7_axi};
assign {ARID_S7, ARADDR_S7, ARLEN_S7, ARSIZE_S7, ARBURST_S7} = AFIFO_RDATA_T_AR_S7;
assign ARREADY_S7_axi = ~W_FULL_AR_S7;
assign ARVALID_S7 = ~R_EMPTY_AR_S7;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_S7
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AR_S7),
    .WEN(ARVALID_S7_axi),
    .W_FULL(W_FULL_AR_S7),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S7),
    .R_PTR_Binary(R_PTR_Binary_AR_S7),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S7)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_S7
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_AR_S7),
    .REN(ARREADY_S7),
    .R_EMPTY(R_EMPTY_AR_S7),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S7),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S7),
    .R_PTR_Binary(R_PTR_Binary_AR_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S7)
);
//====================== S7 AR ======================//
//====================== S7  R ======================//
logic   [42:0]  AFIFO_WDATA_R_S7    , AFIFO_RDATA_R_S7      , AFIFO_RDATA_T_R_S7;
logic   [3:0]   R_PTR_GRAY_R_S7     , R_PTR_Binary_R_S7     , W_PTR_GRAY_R_S7;
logic           W_FULL_R_S7         , R_EMPTY_R_S7;
assign AFIFO_WDATA_R_S7 = {RID_S7, RDATA_S7, RRESP_S7, RLAST_S7};
assign {RID_S7_axi, RDATA_S7_axi, RRESP_S7_axi, RLAST_S7_axi} = AFIFO_RDATA_T_R_S7;
assign RREADY_S7 = ~W_FULL_R_S7;
assign RVALID_S7_axi = ~R_EMPTY_R_S7;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_S7
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_R_S7),
    .WEN(RVALID_S7),
    .W_FULL(W_FULL_R_S7),
    .R_PTR_GRAY(R_PTR_GRAY_R_S7),
    .R_PTR_Binary(R_PTR_Binary_R_S7),
    .W_PTR_GRAY(W_PTR_GRAY_R_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S7)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_S7
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_R_S7),
    .REN(RREADY_S7_axi),
    .R_EMPTY(R_EMPTY_R_S7),
    .W_PTR_GRAY(W_PTR_GRAY_R_S7),
    .R_PTR_GRAY(R_PTR_GRAY_R_S7),
    .R_PTR_Binary(R_PTR_Binary_R_S7),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S7)
);
//====================== S7  R ======================//



//====================================== SLAVE8  ======================================//
//====================== S8 AW ======================//
logic   [48:0]  AFIFO_WDATA_AW_S8   , AFIFO_RDATA_AW_S8     , AFIFO_RDATA_T_AW_S8;
logic   [3:0]   R_PTR_GRAY_AW_S8    , R_PTR_Binary_AW_S8    , W_PTR_GRAY_AW_S8;
logic           W_FULL_AW_S8        , R_EMPTY_AW_S8;
assign AFIFO_WDATA_AW_S8 = {AWID_S8_axi, AWADDR_S8_axi, AWLEN_S8_axi, AWSIZE_S8_axi, AWBURST_S8_axi};
assign {AWID_S8, AWADDR_S8, AWLEN_S8, AWSIZE_S8, AWBURST_S8} = AFIFO_RDATA_T_AW_S8;
assign AWREADY_S8_axi = ~W_FULL_AW_S8;
assign AWVALID_S8 = ~R_EMPTY_AW_S8;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AW_S8
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AW_S8),
    .WEN(AWVALID_S8_axi),
    .W_FULL(W_FULL_AW_S8),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S8),
    .R_PTR_Binary(R_PTR_Binary_AW_S8),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S8)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AW_S8
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_AW_S8),
    .REN(AWREADY_S8),
    .R_EMPTY(R_EMPTY_AW_S8),
    .W_PTR_GRAY(W_PTR_GRAY_AW_S8),
    .R_PTR_GRAY(R_PTR_GRAY_AW_S8),
    .R_PTR_Binary(R_PTR_Binary_AW_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_AW_S8)
);
//====================== S8 AW ======================//
//====================== S8  W ======================//
logic   [36:0]  AFIFO_WDATA_W_S8    , AFIFO_RDATA_W_S8      , AFIFO_RDATA_T_W_S8;
logic   [3:0]   R_PTR_GRAY_W_S8     , R_PTR_Binary_W_S8     , W_PTR_GRAY_W_S8;
logic           W_FULL_W_S8         , R_EMPTY_W_S8;
assign AFIFO_WDATA_W_S8 = {WDATA_S8_axi, WSTRB_S8_axi, WLAST_S8_axi};
assign {WDATA_S8, WSTRB_S8, WLAST_S8} = AFIFO_RDATA_T_W_S8;
assign WREADY_S8_axi = ~W_FULL_W_S8;
assign WVALID_S8 = ~R_EMPTY_W_S8;
AFIFO_Tx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Tx_W_S8
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_W_S8),
    .WEN(WVALID_S8_axi),
    .W_FULL(W_FULL_W_S8),
    .R_PTR_GRAY(R_PTR_GRAY_W_S8),
    .R_PTR_Binary(R_PTR_Binary_W_S8),
    .W_PTR_GRAY(W_PTR_GRAY_W_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S8)
);
AFIFO_Rx#(
    .DATA_WIDTH(37),
    .ADDR_WIDTH(4)
) AFIFO_Rx_W_S8
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_W_S8),
    .REN(WREADY_S8),
    .R_EMPTY(R_EMPTY_W_S8),
    .W_PTR_GRAY(W_PTR_GRAY_W_S8),
    .R_PTR_GRAY(R_PTR_GRAY_W_S8),
    .R_PTR_Binary(R_PTR_Binary_W_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_W_S8)
);
//====================== S8  W ======================//
//====================== S8  B ======================//
logic   [9:0]   AFIFO_WDATA_B_S8    , AFIFO_RDATA_B_S8      , AFIFO_RDATA_T_B_S8;
logic   [3:0]   R_PTR_GRAY_B_S8     , R_PTR_Binary_B_S8     , W_PTR_GRAY_B_S8;
logic           W_FULL_B_S8         , R_EMPTY_B_S8;
assign AFIFO_WDATA_B_S8 = {BID_S8, BRESP_S8};
assign {BID_S8_axi, BRESP_S8_axi} = AFIFO_RDATA_T_B_S8;
assign BREADY_S8 = ~W_FULL_B_S8;
assign BVALID_S8_axi = ~R_EMPTY_B_S8;
AFIFO_Tx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Tx_B_S8
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_B_S8),
    .WEN(BVALID_S8),
    .W_FULL(W_FULL_B_S8),
    .R_PTR_GRAY(R_PTR_GRAY_B_S8),
    .R_PTR_Binary(R_PTR_Binary_B_S8),
    .W_PTR_GRAY(W_PTR_GRAY_B_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S8)
);
AFIFO_Rx#(
    .DATA_WIDTH(10),
    .ADDR_WIDTH(4)
) AFIFO_Rx_B_S8
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_B_S8),
    .REN(BREADY_S8_axi),
    .R_EMPTY(R_EMPTY_B_S8),
    .W_PTR_GRAY(W_PTR_GRAY_B_S8),
    .R_PTR_GRAY(R_PTR_GRAY_B_S8),
    .R_PTR_Binary(R_PTR_Binary_B_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_B_S8)
);
//====================== S8  B ======================//
//====================== S8 AR ======================//
logic   [48:0]  AFIFO_WDATA_AR_S8   , AFIFO_RDATA_AR_S8     , AFIFO_RDATA_T_AR_S8;
logic   [3:0]   R_PTR_GRAY_AR_S8    , R_PTR_Binary_AR_S8    , W_PTR_GRAY_AR_S8;
logic           W_FULL_AR_S8        , R_EMPTY_AR_S8;
assign AFIFO_WDATA_AR_S8 = {ARID_S8_axi, ARADDR_S8_axi, ARLEN_S8_axi, ARSIZE_S8_axi, ARBURST_S8_axi};
assign {ARID_S8, ARADDR_S8, ARLEN_S8, ARSIZE_S8, ARBURST_S8} = AFIFO_RDATA_T_AR_S8;
assign ARREADY_S8_axi = ~W_FULL_AR_S8;
assign ARVALID_S8 = ~R_EMPTY_AR_S8;
AFIFO_Tx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Tx_AR_S8
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .W_DATA(AFIFO_WDATA_AR_S8),
    .WEN(ARVALID_S8_axi),
    .W_FULL(W_FULL_AR_S8),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S8),
    .R_PTR_Binary(R_PTR_Binary_AR_S8),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S8)
);
AFIFO_Rx#(
    .DATA_WIDTH(49),
    .ADDR_WIDTH(4)
) AFIFO_Rx_AR_S8
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .R_DATA(AFIFO_RDATA_AR_S8),
    .REN(ARREADY_S8),
    .R_EMPTY(R_EMPTY_AR_S8),
    .W_PTR_GRAY(W_PTR_GRAY_AR_S8),
    .R_PTR_GRAY(R_PTR_GRAY_AR_S8),
    .R_PTR_Binary(R_PTR_Binary_AR_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_AR_S8)
);
//====================== S8 AR ======================//
//====================== S8  R ======================//
logic   [42:0]  AFIFO_WDATA_R_S8    , AFIFO_RDATA_R_S8      , AFIFO_RDATA_T_R_S8;
logic   [3:0]   R_PTR_GRAY_R_S8     , R_PTR_Binary_R_S8     , W_PTR_GRAY_R_S8;
logic           W_FULL_R_S8         , R_EMPTY_R_S8;
assign AFIFO_WDATA_R_S8 = {RID_S8, RDATA_S8, RRESP_S8, RLAST_S8};
assign {RID_S8_axi, RDATA_S8_axi, RRESP_S8_axi, RLAST_S8_axi} = AFIFO_RDATA_T_R_S8;
assign RREADY_S8 = ~W_FULL_R_S8;
assign RVALID_S8_axi = ~R_EMPTY_R_S8;
AFIFO_Tx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Tx_R_S8
(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),
    .W_DATA(AFIFO_WDATA_R_S8),
    .WEN(RVALID_S8),
    .W_FULL(W_FULL_R_S8),
    .R_PTR_GRAY(R_PTR_GRAY_R_S8),
    .R_PTR_Binary(R_PTR_Binary_R_S8),
    .W_PTR_GRAY(W_PTR_GRAY_R_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S8)
);
AFIFO_Rx#(
    .DATA_WIDTH(43),
    .ADDR_WIDTH(4)
) AFIFO_Rx_R_S8
(
    .CLK(axi_clk),
    .RSTn(AXI_RSTn),
    .R_DATA(AFIFO_RDATA_R_S8),
    .REN(RREADY_S8_axi),
    .R_EMPTY(R_EMPTY_R_S8),
    .W_PTR_GRAY(W_PTR_GRAY_R_S8),
    .R_PTR_GRAY(R_PTR_GRAY_R_S8),
    .R_PTR_Binary(R_PTR_Binary_R_S8),
    .R_DATA_Tx(AFIFO_RDATA_T_R_S8)
);
//====================== S8  R ======================//
logic interrupt_dma_done_1, interrupt_dma_done_2;
CPU_wrapper cpu(
        .clk(cpu_clk),
        .rst(~CPU_RSTn),
        // .clk2(axi_clk),
        // .rst2(axi_rst),

        .AWID_M1    (AWID_M1),
        .AWADDR_M1  (AWADDR_M1),
        .AWLEN_M1   (AWLEN_M1),
        .AWSIZE_M1  (AWSIZE_M1),
        .AWBURST_M1 (AWBURST_M1),
        .AWVALID_M1 (AWVALID_M1),
        .AWREADY_M1 (AWREADY_M1),

        .WDATA_M1(WDATA_M1),
        .WSTRB_M1(WSTRB_M1),
        .WLAST_M1(WLAST_M1),
        .WVALID_M1(WVALID_M1),
        .WREADY_M1(WREADY_M1),

        .BID_M1(BID_M1),
        .BRESP_M1(BRESP_M1),
        .BVALID_M1(BVALID_M1),
        .BREADY_M1(BREADY_M1),

        .ARID_M0(ARID_M0),
        .ARADDR_M0(ARADDR_M0),
        .ARLEN_M0(ARLEN_M0),
        .ARSIZE_M0(ARSIZE_M0),
        .ARBURST_M0(ARBURST_M0),
        .ARVALID_M0(ARVALID_M0),
        .ARREADY_M0(ARREADY_M0),

        .RID_M0(RID_M0),
        .RDATA_M0(RDATA_M0),
        .RRESP_M0(RRESP_M0),
        .RLAST_M0(RLAST_M0),
        .RVALID_M0(RVALID_M0),
        .RREADY_M0(RREADY_M0),

        .ARID_M1(ARID_M1),
        .ARADDR_M1(ARADDR_M1),
        .ARLEN_M1(ARLEN_M1),
        .ARSIZE_M1(ARSIZE_M1),
        .ARBURST_M1(ARBURST_M1),
        .ARVALID_M1(ARVALID_M1),
        .ARREADY_M1(ARREADY_M1),

        .RID_M1(RID_M1),
        .RDATA_M1(RDATA_M1),
        .RRESP_M1(RRESP_M1),
        .RLAST_M1(RLAST_M1),
        .RVALID_M1(RVALID_M1),
        .RREADY_M1(RREADY_M1),

        .interrupt_e(interrupt_dma_done_2/*sctrl_interrupt*/),
        .interrupt_t(WTO),
        .wfi_signal(wfi_signal)
    );

always_ff@(posedge cpu_clk or negedge CPU_RSTn)begin
    if(~CPU_RSTn)begin
        interrupt_dma_done_1<=1'b0;
        interrupt_dma_done_2<=1'b0;
    end
    else begin
        interrupt_dma_done_1<=interrupt_dma_done;
        interrupt_dma_done_2<=interrupt_dma_done_1;
    end
end

DMA_wrapper DMA(
	.clk(axi_clk),
	.rst(AXI_RSTn),

	.AWID       (AWID_S_dma   ),
	.AWADDR     (AWADDR_S_dma ),
	.AWLEN      (AWLEN_S_dma  ),
	.AWSIZE     (AWSIZE_S_dma ),
	.AWBURST    (AWBURST_S_dma),
	.AWVALID    (AWVALID_S_dma),
	.AWREADY    (AWREADY_S_dma),

	.WDATA      (WDATA_S_dma ),
	.WSTRB      (WSTRB_S_dma ),
	.WLAST      (WLAST_S_dma ),
	.WVALID     (WVALID_S_dma),
	.WREADY     (WREADY_S_dma),
    
	.BID        (BID_S_dma   ),
	.BRESP      (BRESP_S_dma ),
	.BVALID     (BVALID_S_dma),
	.BREADY     (BREADY_S_dma),

	.ARID_M0    (ARID_M0_dma   ),
	.ARADDR_M0  (ARADDR_M0_dma ),
	.ARLEN_M0   (ARLEN_M0_dma ),
	.ARSIZE_M0  (ARSIZE_M0_dma  ),
	.ARBURST_M0 (ARBURST_M0_dma),
	.ARVALID_M0 (ARVALID_M0_dma),
	.ARREADY_M0 (ARREADY_M0_dma),
	
	.RID_M0     (RID_M0_dma   ),
	.RDATA_M0   (RDATA_M0_dma ),
	.RRESP_M0   (RRESP_M0_dma ),
	.RLAST_M0   (RLAST_M0_dma ),
	.RVALID_M0  (RVALID_M0_dma),
	.RREADY_M0  (RREADY_M0_dma),

	.AWID_M1    (AWID_M1_dma   ),
	.AWADDR_M1  (AWADDR_M1_dma ),
	.AWLEN_M1   (AWLEN_M1_dma  ),
	.AWSIZE_M1  (AWSIZE_M1_dma ),
	.AWBURST_M1 (AWBURST_M1_dma),
	.AWVALID_M1 (AWVALID_M1_dma),
	.AWREADY_M1 (AWREADY_M1_dma),
	
	.WDATA_M1   (WDATA_M1_dma ),
	.WSTRB_M1   (WSTRB_M1_dma ),
	.WLAST_M1   (WLAST_M1_dma ),
	.WVALID_M1  (WVALID_M1_dma),
	.WREADY_M1  (WREADY_M1_dma),
	
	.BID_M1     (BID_M1_dma   ), 
	.BRESP_M1   (BRESP_M1_dma ),
	.BVALID_M1  (BVALID_M1_dma),
	.BREADY_M1  (BREADY_M1_dma),

    .wfi_signal(wfi_signal),
    .interrupt_dma_done(interrupt_dma_done)
);

Master_Monitor ROM_Monitor(
	.CLK        (rom_clk),
    .RSTn       (ROM_RSTn),

    .ARID       (ARID_S0),
    .ARADDR     (ARADDR_S0),
    .ARLEN      (ARLEN_S0),
    .ARSIZE     (ARSIZE_S0),
    .ARBURST    (ARBURST_S0),
    .ARVALID    (ARVALID_S0),
    .ARREADY    (ARREADY_S0),

    .RID        (RID_S0),
    .RDATA      (RDATA_S0),
    .RRESP      (RRESP_S0),
    .RLAST      (RLAST_S0),
    .RVALID     (RVALID_S0),
    .RREADY     (RREADY_S0),

    .AWID       (8'b0),
    .AWADDR     (32'b0),
    .AWLEN      (4'b0),
    .AWSIZE     (`AXI_SIZE_BITS'b0),
    .AWBURST    (2'b0),
    .AWVALID    (1'b0),
    .AWREADY    (),

    .WDATA      (32'b0),
    .WSTRB      (4'b0),
    .WLAST      (1'b0),
    .WVALID     (1'b0),
    .WREADY     (),

    .BID        (),
    .BRESP      (),
    .BVALID     (),
    .BREADY     (1'b0),

    .SRAM_WEB   (),
    .SRAM_A     (ROM_A),
    .SRAM_DI    (),
    .SRAM_DO    (ROM_out)
); 

SRAM_wrapper IM1(
    .CLK        (sram_clk),
    .RSTn       (SRAM_RSTn),

    .ARID       (ARID_S1),
    .ARADDR     (ARADDR_S1),
    .ARLEN      (ARLEN_S1),
    .ARSIZE     (ARSIZE_S1),
    .ARBURST    (ARBURST_S1),
    .ARVALID    (ARVALID_S1),
    .ARREADY    (ARREADY_S1),

    .RID        (RID_S1),
    .RDATA      (RDATA_S1),
    .RRESP      (RRESP_S1),
    .RLAST      (RLAST_S1),
    .RVALID     (RVALID_S1),
    .RREADY     (RREADY_S1),

    .AWID       (AWID_S1),
    .AWADDR     (AWADDR_S1),
    .AWLEN      (AWLEN_S1),
    .AWSIZE     (AWSIZE_S1),
    .AWBURST    (AWBURST_S1),
    .AWVALID    (AWVALID_S1),
    .AWREADY    (AWREADY_S1),

    .WDATA      (WDATA_S1),
    .WSTRB      (WSTRB_S1),
    .WLAST      (WLAST_S1),
    .WVALID     (WVALID_S1),
    .WREADY     (WREADY_S1),

    .BID        (BID_S1),
    .BRESP      (BRESP_S1),
    .BVALID     (BVALID_S1),
    .BREADY     (BREADY_S1)
);

SRAM_wrapper DM1(
    .CLK        (sram_clk),
    .RSTn       (SRAM_RSTn),

    .ARID       (ARID_S2),
    .ARADDR     (ARADDR_S2),
    .ARLEN      (ARLEN_S2),
    .ARSIZE     (ARSIZE_S2),
    .ARBURST    (ARBURST_S2),
    .ARVALID    (ARVALID_S2),
    .ARREADY    (ARREADY_S2),

    .RID        (RID_S2),
    .RDATA      (RDATA_S2),
    .RRESP      (RRESP_S2),
    .RLAST      (RLAST_S2),
    .RVALID     (RVALID_S2),
    .RREADY     (RREADY_S2),

    .AWID       (AWID_S2),
    .AWADDR     (AWADDR_S2),
    .AWLEN      (AWLEN_S2),
    .AWSIZE     (AWSIZE_S2),
    .AWBURST    (AWBURST_S2),
    .AWVALID    (AWVALID_S2),
    .AWREADY    (AWREADY_S2),

    .WDATA      (WDATA_S2),
    .WSTRB      (WSTRB_S2),
    .WLAST      (WLAST_S2),
    .WVALID     (WVALID_S2),
    .WREADY     (WREADY_S2),

    .BID        (BID_S2),
    .BRESP      (BRESP_S2),
    .BVALID     (BVALID_S2),
    .BREADY     (BREADY_S2)
);



// logic	[31:0]	sctrl_out;
// logic	sctrl_en, sctrl_clear;
// logic   [11:0]	sctrl_addr;
Sensor_Wrapper Sensor_Slave (
    .CLK        (dram_clk),
    .RSTn       (DRAM_RSTn),

    // CPU inputs
    .sctrl_en   (sctrl_en),
    .sctrl_clear(sctrl_clear),
    .sctrl_addr (sctrl_addr),
    // CPU outputs
    .sctrl_out  (sctrl_out),
    .sctrl_interrupt(sctrl_interrupt),

    // Belows are ports connect to AXI
    // AW channel
    .AWID       (AWID_S3),
    .AWADDR     (AWADDR_S3),
    .AWLEN      (AWLEN_S3),
    .AWSIZE     (AWSIZE_S3),
    .AWBURST    (AWBURST_S3),
    .AWVALID    (AWVALID_S3),
    .AWREADY    (AWREADY_S3),
    // W channel
    .WDATA      (WDATA_S3),
    .WSTRB      (WSTRB_S3),
    .WLAST      (WLAST_S3),
    .WVALID     (WVALID_S3),
    .WREADY     (WREADY_S3),
    // B channel
    .BID        (BID_S3),
    .BRESP      (BRESP_S3),
    .BVALID     (BVALID_S3),
    .BREADY     (BREADY_S3),
    // AR channel
    .ARID       (ARID_S3),
    .ARADDR     (ARADDR_S3),
    .ARLEN      (ARLEN_S3),
    .ARSIZE     (ARSIZE_S3),
    .ARBURST    (ARBURST_S3),
    .ARVALID    (ARVALID_S3),
    .ARREADY    (ARREADY_S3),
    // R channel
    .RID        (RID_S3),
    .RDATA      (RDATA_S3),
    .RRESP      (RRESP_S3),
    .RLAST      (RLAST_S3),
    .RVALID     (RVALID_S3),
    .RREADY     (RREADY_S3)
    // Aboves are ports connect to AXI
);

// sensor_ctrl Sensor_Controller(
//   .clk              (cpu_clk),
//   .rstn             (CPU_RSTn),
//   // Core inputs
//   .sctrl_en         (sctrl_en),
//   .sctrl_clear      (sctrl_clear),
//   .sctrl_addr       (sctrl_addr),
//   // Sensor inputs
//   .sensor_ready     (sensor_ready),
//   .sensor_out       (sensor_out),
//   // Core outputs
//   .sctrl_interrupt  (sctrl_interrupt),
//   .sctrl_out        (sctrl_out),
//   // Sensor outputs
//   .sensor_en        (sensor_en)
// );

logic	WDEN, WDLIVE;
logic	[31:0]	WTOCNT;

WDT_Wrapper Timer_Slave(
    .CLK        (cpu_clk),
    .RSTn       (CPU_RSTn),

    // Belows are ports connect to AXI
    // AW channel
    .AWID       (AWID_S4),
    .AWADDR     (AWADDR_S4),
    .AWLEN      (AWLEN_S4),
    .AWSIZE     (AWSIZE_S4),
    .AWBURST    (AWBURST_S4),
    .AWVALID    (AWVALID_S4),
    .AWREADY    (AWREADY_S4),
    // W channel
    .WDATA      (WDATA_S4),
    .WSTRB      (WSTRB_S4),
    .WLAST      (WLAST_S4),
    .WVALID     (WVALID_S4),
    .WREADY     (WREADY_S4),
    // B channel
    .BID        (BID_S4),
    .BRESP      (BRESP_S4),
    .BVALID     (BVALID_S4),
    .BREADY     (BREADY_S4),
    // AR channel
    .ARID       (ARID_S4),
    .ARADDR     (ARADDR_S4),
    .ARLEN      (ARLEN_S4),
    .ARSIZE     (ARSIZE_S4),
    .ARBURST    (ARBURST_S4),
    .ARVALID    (ARVALID_S4),
    .ARREADY    (ARREADY_S4),
    // R channel
    .RID        (RID_S4),
    .RDATA      (RDATA_S4),
    .RRESP      (RRESP_S4),
    .RLAST      (RLAST_S4),
    .RVALID     (RVALID_S4),
    .RREADY     (RREADY_S4),
    // Aboves are ports connect to AXI

    .WDEN       (WDEN),
    .WDLIVE     (WDLIVE),
    .WTOCNT     (WTOCNT),
    .WTO        (WTO)
);

WDT WDT (
    .CLK    (cpu_clk),
    .RSTn   (CPU_RSTn),
    .WDEN   (WDEN),
    .WDLIVE (WDLIVE),
    .WTOCNT (WTOCNT),
    .WTO    (WTO)
);

DRAM_Wrapper DRAM_1 (
    .CLK    (dram_clk),
    .RSTn   (DRAM_RSTn),

    // Belows are ports connect to DRAM
    .CSn    (DRAM_CSn),
    .WEn    (DRAM_WEn),
    .RASn   (DRAM_RASn),
    .CASn   (DRAM_CASn),
    .A      (DRAM_A),
    .D      (DRAM_D),
    .VALID  (DRAM_valid),
    .Q      (DRAM_Q),
    // Aboves are ports connect to DRAM

    // Belows are ports connect to AXI
    // AW channel
    .AWID   (AWID_S5),
    .AWADDR (AWADDR_S5),
    .AWLEN  (AWLEN_S5),
    .AWSIZE (AWSIZE_S5),
    .AWBURST(AWBURST_S5),
    .AWVALID(AWVALID_S5),
    .AWREADY(AWREADY_S5),
    // W channel
    .WDATA  (WDATA_S5),
    .WSTRB  (WSTRB_S5),
    .WLAST  (WLAST_S5),
    .WVALID (WVALID_S5),
    .WREADY (WREADY_S5),
    // B channel
    .BID    (BID_S5),
    .BRESP  (BRESP_S5),
    .BVALID (BVALID_S5),
    .BREADY (BREADY_S5),
    // AR channel
    .ARID   (ARID_S5),
    .ARADDR (ARADDR_S5),
    .ARLEN  (ARLEN_S5),
    .ARSIZE (ARSIZE_S5),
    .ARBURST(ARBURST_S5),
    .ARVALID(ARVALID_S5),
    .ARREADY(ARREADY_S5),
    // R channel
    .RID    (RID_S5),
    .RDATA  (RDATA_S5),
    .RRESP  (RRESP_S5),
    .RLAST  (RLAST_S5),
    .RVALID (RVALID_S5),
    .RREADY (RREADY_S5)
    // Aboves are ports connect to AXI
);

EPU_Wrapper EPU(
    .CLK(cpu_clk),
    .RSTn(CPU_RSTn),

    //for S7 port
    .ARID_S7(ARID_S7),
    .ARADDR_S7(ARADDR_S7),
    .ARLEN_S7(ARLEN_S7),
    .ARSIZE_S7(ARSIZE_S7),
    .ARBURST_S7(ARBURST_S7),
    .ARVALID_S7(ARVALID_S7),
    .ARREADY_S7(ARREADY_S7),

    .RID_S7(RID_S7),
    .RDATA_S7(RDATA_S7),
    .RRESP_S7(RRESP_S7),
    .RLAST_S7(RLAST_S7),
    .RVALID_S7(RVALID_S7),
    .RREADY_S7(RREADY_S7),

    .AWID_S7(AWID_S7),
    .AWADDR_S7(AWADDR_S7),
    .AWLEN_S7(AWLEN_S7),
    .AWSIZE_S7(AWSIZE_S7),
    .AWBURST_S7(AWBURST_S7),
    .AWVALID_S7(AWVALID_S7),
    .AWREADY_S7(AWREADY_S7),

    .WDATA_S7(WDATA_S7),
    .WSTRB_S7(WSTRB_S7),
    .WLAST_S7(WLAST_S7),
    .WVALID_S7(WVALID_S7),
    .WREADY_S7(WREADY_S7),

    .BID_S7(BID_S7),
    .BRESP_S7(BRESP_S7),
    .BVALID_S7(BVALID_S7),
    .BREADY_S7(BREADY_S7),

    .ARID_S8(ARID_S8),
    .ARADDR_S8(ARADDR_S8),
    .ARLEN_S8(ARLEN_S8),
    .ARSIZE_S8(ARSIZE_S8),
    .ARBURST_S8(ARBURST_S8),
    .ARVALID_S8(ARVALID_S8),
    .ARREADY_S8(ARREADY_S8),

    .RID_S8(RID_S8),
    .RDATA_S8(RDATA_S8),
    .RRESP_S8(RRESP_S8),
    .RLAST_S8(RLAST_S8),
    .RVALID_S8(RVALID_S8),
    .RREADY_S8(RREADY_S8),

    .AWID_S8(AWID_S8),
    .AWADDR_S8(AWADDR_S8),
    .AWLEN_S8(AWLEN_S8),
    .AWSIZE_S8(AWSIZE_S8),
    .AWBURST_S8(AWBURST_S8),
    .AWVALID_S8(AWVALID_S8),
    .AWREADY_S8(AWREADY_S8),

    .WDATA_S8(WDATA_S8),
    .WSTRB_S8(WSTRB_S8),
    .WLAST_S8(WLAST_S8),
    .WVALID_S8(WVALID_S8),
    .WREADY_S8(WREADY_S8),

    .BID_S8(BID_S8),
    .BRESP_S8(BRESP_S8),
    .BVALID_S8(BVALID_S8),
    .BREADY_S8(BREADY_S8)

);

AXI AXI_Bridge(
    .ACLK   	(axi_clk),
	.ARESETn   	(AXI_RSTn),

	//==============================//
	//	SLAVE INTERFACE FOR MASTERS	//
	//==============================//

	//======Master 0 interface======//

	//READ ADDRESS0
	.ARID_M0 	(ARID_M0_axi),
	.ARADDR_M0 	(ARADDR_M0_axi),
	.ARLEN_M0 	(ARLEN_M0_axi),
	.ARSIZE_M0 	(ARSIZE_M0_axi),
	.ARBURST_M0 (ARBURST_M0_axi),
	.ARVALID_M0 (ARVALID_M0_axi),
	.ARREADY_M0 (ARREADY_M0_axi),
	
	//READ DATA0
	.RID_M0 	(RID_M0_axi),
	.RDATA_M0 	(RDATA_M0_axi),
	.RRESP_M0 	(RRESP_M0_axi),
	.RLAST_M0 	(RLAST_M0_axi),
	.RVALID_M0 	(RVALID_M0_axi),
	.RREADY_M0 	(RREADY_M0_axi),

	//======Master 1 interface======//
	
	//WRITE ADDRESS
	.AWID_M1	(AWID_M1_axi),
	.AWADDR_M1	(AWADDR_M1_axi),
	.AWLEN_M1	(AWLEN_M1_axi),
	.AWSIZE_M1	(AWSIZE_M1_axi),
	.AWBURST_M1	(AWBURST_M1_axi),
	.AWVALID_M1	(AWVALID_M1_axi),
	.AWREADY_M1	(AWREADY_M1_axi),
	
	//WRITE DATA
	.WDATA_M1	(WDATA_M1_axi),
	.WSTRB_M1	(WSTRB_M1_axi),
	.WLAST_M1	(WLAST_M1_axi),
	.WVALID_M1	(WVALID_M1_axi),
	.WREADY_M1	(WREADY_M1_axi),
	
	//WRITE RESPONSE
	.BID_M1 	(BID_M1_axi),
	.BRESP_M1 	(BRESP_M1_axi),
	.BVALID_M1 	(BVALID_M1_axi),
	.BREADY_M1 	(BREADY_M1_axi),

	//READ ADDRESS1
	.ARID_M1	(ARID_M1_axi),
	.ARADDR_M1	(ARADDR_M1_axi),
	.ARLEN_M1	(ARLEN_M1_axi),
	.ARSIZE_M1	(ARSIZE_M1_axi),
	.ARBURST_M1	(ARBURST_M1_axi),
	.ARVALID_M1	(ARVALID_M1_axi),
	.ARREADY_M1	(ARREADY_M1_axi),
	
	//READ DATA1
	.RID_M1 	(RID_M1_axi),
	.RDATA_M1 	(RDATA_M1_axi),
	.RRESP_M1 	(RRESP_M1_axi),
	.RLAST_M1 	(RLAST_M1_axi),
	.RVALID_M1 	(RVALID_M1_axi),
	.RREADY_M1 	(RREADY_M1_axi),

    //======DMA Master 0 interface======//
    
	//READ ADDRESS1
	.ARID_M0_dma	(ARID_M0_dma),
	.ARADDR_M0_dma	(ARADDR_M0_dma),
	.ARLEN_M0_dma	(ARLEN_M0_dma),
	.ARSIZE_M0_dma	(ARSIZE_M0_dma),
	.ARBURST_M0_dma	(ARBURST_M0_dma),
	.ARVALID_M0_dma	(ARVALID_M0_dma),
	.ARREADY_M0_dma	(ARREADY_M0_dma),
	
	//READ DATA1
	.RID_M0_dma 	(RID_M0_dma),
	.RDATA_M0_dma 	(RDATA_M0_dma),
	.RRESP_M0_dma 	(RRESP_M0_dma),
	.RLAST_M0_dma 	(RLAST_M0_dma),
	.RVALID_M0_dma 	(RVALID_M0_dma),
	.RREADY_M0_dma 	(RREADY_M0_dma),

	//======DMA Master 1 interface======//
	//WRITE ADDRESS
	.AWID_M1_dma	(AWID_M1_dma),
	.AWADDR_M1_dma	(AWADDR_M1_dma),
	.AWLEN_M1_dma	(AWLEN_M1_dma),
	.AWSIZE_M1_dma	(AWSIZE_M1_dma),
	.AWBURST_M1_dma	(AWBURST_M1_dma),
	.AWVALID_M1_dma	(AWVALID_M1_dma),
	.AWREADY_M1_dma	(AWREADY_M1_dma),
	
	//WRITE DATA
	.WDATA_M1_dma	(WDATA_M1_dma),
	.WSTRB_M1_dma	(WSTRB_M1_dma),
	.WLAST_M1_dma	(WLAST_M1_dma),
	.WVALID_M1_dma	(WVALID_M1_dma),
	.WREADY_M1_dma	(WREADY_M1_dma),
	
	//WRITE RESPONSE
	.BID_M1_dma 	(BID_M1_dma),
	.BRESP_M1_dma 	(BRESP_M1_dma),
	.BVALID_M1_dma 	(BVALID_M1_dma),
	.BREADY_M1_dma 	(BREADY_M1_dma),


	//==================================//
	//	 MASTER INTERFACE FOR SLAVES	//
	//==================================//

	//========Slave 0 interface========//
	//WRITE ADDRESS0
	// .AWID_S0	(AWID_S0),
	// .AWADDR_S0	(AWADDR_S0),
	// .AWLEN_S0	(AWLEN_S0),
	// .AWSIZE_S0	(AWSIZE_S0),
	// .AWBURST_S0	(AWBURST_S0),
	// .AWVALID_S0	(AWVALID_S0),
	// .AWREADY_S0	(AWREADY_S0),
	
	//WRITE DATA0
	// .WDATA_S0	(WDATA_S0),
	// .WSTRB_S0	(WSTRB_S0),
	// .WLAST_S0	(WLAST_S0),
	// .WVALID_S0	(WVALID_S0),
	// .WREADY_S0	(WREADY_S0),

	//WRITE RESPONSE0
	// .BID_S0 	(BID_S0),
	// .BRESP_S0 	(BRESP_S0),
	// .BVALID_S0 	(BVALID_S0),
	// .BREADY_S0 	(BREADY_S0),

	//READ ADDRESS0
	.ARID_S0	(ARID_S0_axi),
	.ARADDR_S0	(ARADDR_S0_axi),
	.ARLEN_S0	(ARLEN_S0_axi),
	.ARSIZE_S0	(ARSIZE_S0_axi),
	.ARBURST_S0	(ARBURST_S0_axi),
	.ARVALID_S0	(ARVALID_S0_axi),
	.ARREADY_S0	(ARREADY_S0_axi),
	
	//READ DATA0
	.RID_S0 	(RID_S0_axi),
	.RDATA_S0 	(RDATA_S0_axi),
	.RRESP_S0 	(RRESP_S0_axi),
	.RLAST_S0 	(RLAST_S0_axi),
	.RVALID_S0 	(RVALID_S0_axi),
	.RREADY_S0 	(RREADY_S0_axi),


	//========Slave 1 interface========//
	//WRITE ADDRESS1
	.AWID_S1	(AWID_S1_axi),
	.AWADDR_S1	(AWADDR_S1_axi),
	.AWLEN_S1	(AWLEN_S1_axi),
	.AWSIZE_S1	(AWSIZE_S1_axi),
	.AWBURST_S1	(AWBURST_S1_axi),
	.AWVALID_S1	(AWVALID_S1_axi),
	.AWREADY_S1	(AWREADY_S1_axi),
	
	//WRITE DATA1
	.WDATA_S1	(WDATA_S1_axi),
	.WSTRB_S1	(WSTRB_S1_axi),
	.WLAST_S1	(WLAST_S1_axi),
	.WVALID_S1	(WVALID_S1_axi),
	.WREADY_S1	(WREADY_S1_axi),
	
	//WRITE RESPONSE1
	.BID_S1 	(BID_S1_axi),
	.BRESP_S1 	(BRESP_S1_axi),
	.BVALID_S1 	(BVALID_S1_axi),
	.BREADY_S1 	(BREADY_S1_axi),

	//READ DATA1
	.RID_S1 	(RID_S1_axi),
	.RDATA_S1 	(RDATA_S1_axi),
	.RRESP_S1 	(RRESP_S1_axi),
	.RLAST_S1 	(RLAST_S1_axi),
	.RVALID_S1 	(RVALID_S1_axi),
	.RREADY_S1 	(RREADY_S1_axi),
	
	//READ ADDRESS1
	.ARID_S1	(ARID_S1_axi),
	.ARADDR_S1	(ARADDR_S1_axi),
	.ARLEN_S1	(ARLEN_S1_axi),
	.ARSIZE_S1	(ARSIZE_S1_axi),
	.ARBURST_S1	(ARBURST_S1_axi),
	.ARVALID_S1	(ARVALID_S1_axi),
	.ARREADY_S1	(ARREADY_S1_axi),

	//========Slave 2 interface========//
	//WRITE ADDRESS2
	.AWID_S2	(AWID_S2_axi),
	.AWADDR_S2	(AWADDR_S2_axi),
	.AWLEN_S2	(AWLEN_S2_axi),
	.AWSIZE_S2	(AWSIZE_S2_axi),
	.AWBURST_S2	(AWBURST_S2_axi),
	.AWVALID_S2	(AWVALID_S2_axi),
	.AWREADY_S2	(AWREADY_S2_axi),
	
	//WRITE DATA2
	.WDATA_S2	(WDATA_S2_axi),
	.WSTRB_S2	(WSTRB_S2_axi),
	.WLAST_S2	(WLAST_S2_axi),
	.WVALID_S2	(WVALID_S2_axi),
	.WREADY_S2	(WREADY_S2_axi),
	
	//WRITE RESPONSE2
	.BID_S2 	(BID_S2_axi),
	.BRESP_S2 	(BRESP_S2_axi),
	.BVALID_S2 	(BVALID_S2_axi),
	.BREADY_S2 	(BREADY_S2_axi),

	//READ ADDRESS2
	.ARID_S2	(ARID_S2_axi),
	.ARADDR_S2	(ARADDR_S2_axi),
	.ARLEN_S2	(ARLEN_S2_axi),
	.ARSIZE_S2	(ARSIZE_S2_axi),
	.ARBURST_S2	(ARBURST_S2_axi),
	.ARVALID_S2	(ARVALID_S2_axi),
	.ARREADY_S2	(ARREADY_S2_axi),
	
	//READ DATA2
	.RID_S2 	(RID_S2_axi),
	.RDATA_S2 	(RDATA_S2_axi),
	.RRESP_S2 	(RRESP_S2_axi),
	.RLAST_S2 	(RLAST_S2_axi),
	.RVALID_S2 	(RVALID_S2_axi),
	.RREADY_S2 	(RREADY_S2_axi),

	//========Slave 3 interface========//
	//WRITE ADDRESS3
	.AWID_S3	(AWID_S3_axi),
	.AWADDR_S3	(AWADDR_S3_axi),
	.AWLEN_S3	(AWLEN_S3_axi),
	.AWSIZE_S3	(AWSIZE_S3_axi),
	.AWBURST_S3	(AWBURST_S3_axi),
	.AWVALID_S3	(AWVALID_S3_axi),
	.AWREADY_S3	(AWREADY_S3_axi),
	
	//WRITE DATA3
	.WDATA_S3	(WDATA_S3_axi),
	.WSTRB_S3	(WSTRB_S3_axi),
	.WLAST_S3	(WLAST_S3_axi),
	.WVALID_S3	(WVALID_S3_axi),
	.WREADY_S3	(WREADY_S3_axi),
	
	//WRITE RESPONSE3
	.BID_S3 	(BID_S3_axi),
	.BRESP_S3 	(BRESP_S3_axi),
	.BVALID_S3 	(BVALID_S3_axi),
	.BREADY_S3 	(BREADY_S3_axi),

	//READ ADDRESS3
	.ARID_S3	(ARID_S3_axi),
	.ARADDR_S3	(ARADDR_S3_axi),
	.ARLEN_S3	(ARLEN_S3_axi),
	.ARSIZE_S3	(ARSIZE_S3_axi),
	.ARBURST_S3	(ARBURST_S3_axi),
	.ARVALID_S3	(ARVALID_S3_axi),
	.ARREADY_S3	(ARREADY_S3_axi),
	
	//READ DATA3
	.RID_S3 	(RID_S3_axi),
	.RDATA_S3 	(RDATA_S3_axi),
	.RRESP_S3 	(RRESP_S3_axi),
	.RLAST_S3 	(RLAST_S3_axi),
	.RVALID_S3 	(RVALID_S3_axi),
	.RREADY_S3 	(RREADY_S3_axi),

	//========Slave 4 interface========//
	//WRITE ADDRESS4
	.AWID_S4	(AWID_S4_axi),
	.AWADDR_S4	(AWADDR_S4_axi),
	.AWLEN_S4	(AWLEN_S4_axi),
	.AWSIZE_S4	(AWSIZE_S4_axi),
	.AWBURST_S4	(AWBURST_S4_axi),
	.AWVALID_S4	(AWVALID_S4_axi),
	.AWREADY_S4	(AWREADY_S4_axi),
	
	//WRITE DATA4
	.WDATA_S4	(WDATA_S4_axi),
	.WSTRB_S4	(WSTRB_S4_axi),
	.WLAST_S4	(WLAST_S4_axi),
	.WVALID_S4	(WVALID_S4_axi),
	.WREADY_S4	(WREADY_S4_axi),
	
	//WRITE RESPONSE4
	.BID_S4 	(BID_S4_axi),
	.BRESP_S4 	(BRESP_S4_axi),
	.BVALID_S4 	(BVALID_S4_axi),
	.BREADY_S4 	(BREADY_S4_axi),

	//READ ADDRESS4
	.ARID_S4	(ARID_S4_axi),
	.ARADDR_S4	(ARADDR_S4_axi),
	.ARLEN_S4	(ARLEN_S4_axi),
	.ARSIZE_S4	(ARSIZE_S4_axi),
	.ARBURST_S4	(ARBURST_S4_axi),
	.ARVALID_S4	(ARVALID_S4_axi),
	.ARREADY_S4	(ARREADY_S4_axi),
		//READ DATA4
	.RID_S4 	(RID_S4_axi),
	.RDATA_S4 	(RDATA_S4_axi),
	.RRESP_S4 	(RRESP_S4_axi),
	.RLAST_S4 	(RLAST_S4_axi),
	.RVALID_S4 	(RVALID_S4_axi),
	.RREADY_S4 	(RREADY_S4_axi),

	//========Slave 5 interface========//
	//WRITE ADDRESS5
	.AWID_S5	(AWID_S5_axi),
	.AWADDR_S5	(AWADDR_S5_axi),
	.AWLEN_S5	(AWLEN_S5_axi),
	.AWSIZE_S5	(AWSIZE_S5_axi),
	.AWBURST_S5	(AWBURST_S5_axi),
	.AWVALID_S5	(AWVALID_S5_axi),
	.AWREADY_S5	(AWREADY_S5_axi),
	
	//WRITE DATA5
	.WDATA_S5	(WDATA_S5_axi),
	.WSTRB_S5	(WSTRB_S5_axi),
	.WLAST_S5	(WLAST_S5_axi),
	.WVALID_S5	(WVALID_S5_axi),
	.WREADY_S5	(WREADY_S5_axi),

	//WRITE RESPONSE5
	.BID_S5 	(BID_S5_axi),
	.BRESP_S5 	(BRESP_S5_axi),
	.BVALID_S5 	(BVALID_S5_axi),
	.BREADY_S5 	(BREADY_S5_axi),

	//READ ADDRESS5
	.ARID_S5	(ARID_S5_axi),
	.ARADDR_S5	(ARADDR_S5_axi),
	.ARLEN_S5	(ARLEN_S5_axi),
	.ARSIZE_S5	(ARSIZE_S5_axi),
	.ARBURST_S5	(ARBURST_S5_axi),
	.ARVALID_S5	(ARVALID_S5_axi),
	.ARREADY_S5	(ARREADY_S5_axi),

	//READ DATA5
	.RID_S5 	(RID_S5_axi),
	.RDATA_S5 	(RDATA_S5_axi),
	.RRESP_S5 	(RRESP_S5_axi),
	.RLAST_S5 	(RLAST_S5_axi),
	.RVALID_S5 	(RVALID_S5_axi),
	.RREADY_S5 	(RREADY_S5_axi),

    //========Slave 6 interface========//
	//WRITE ADDRESS6
	.AWID_S6	(AWID_S_dma),
	.AWADDR_S6	(AWADDR_S_dma),
	.AWLEN_S6	(AWLEN_S_dma),
	.AWSIZE_S6	(AWSIZE_S_dma),
	.AWBURST_S6	(AWBURST_S_dma),
	.AWVALID_S6	(AWVALID_S_dma),
	.AWREADY_S6	(AWREADY_S_dma),
	
	//WRITE DATA6
	.WDATA_S6	(WDATA_S_dma),
	.WSTRB_S6	(WSTRB_S_dma),
	.WLAST_S6	(WLAST_S_dma),
	.WVALID_S6	(WVALID_S_dma),
	.WREADY_S6	(WREADY_S_dma),

	//WRITE RESPONSE6
	.BID_S6 	(BID_S_dma),
	.BRESP_S6 	(BRESP_S_dma),
	.BVALID_S6 	(BVALID_S_dma),
	.BREADY_S6 	(BREADY_S_dma),

	//========Slave 7 interface========//
	//WRITE ADDRESS7
	.AWID_S7	(AWID_S7_axi),
	.AWADDR_S7	(AWADDR_S7_axi),
	.AWLEN_S7	(AWLEN_S7_axi),
	.AWSIZE_S7	(AWSIZE_S7_axi),
	.AWBURST_S7	(AWBURST_S7_axi),
	.AWVALID_S7	(AWVALID_S7_axi),
	.AWREADY_S7	(AWREADY_S7_axi),
	
	//WRITE DATA7
	.WDATA_S7	(WDATA_S7_axi),
	.WSTRB_S7	(WSTRB_S7_axi),
	.WLAST_S7	(WLAST_S7_axi),
	.WVALID_S7	(WVALID_S7_axi),
	.WREADY_S7	(WREADY_S7_axi),
	
	//WRITE RESPONSE7
	.BID_S7 	(BID_S7_axi),
	.BRESP_S7 	(BRESP_S7_axi),
	.BVALID_S7 	(BVALID_S7_axi),
	.BREADY_S7 	(BREADY_S7_axi),

	//READ ADDRESS7
	.ARID_S7	(ARID_S7_axi),
	.ARADDR_S7	(ARADDR_S7_axi),
	.ARLEN_S7	(ARLEN_S7_axi),
	.ARSIZE_S7	(ARSIZE_S7_axi),
	.ARBURST_S7	(ARBURST_S7_axi),
	.ARVALID_S7	(ARVALID_S7_axi),
	.ARREADY_S7	(ARREADY_S7_axi),
	
	//READ DATA7
	.RID_S7 	(RID_S7_axi),
	.RDATA_S7 	(RDATA_S7_axi),
	.RRESP_S7 	(RRESP_S7_axi),
	.RLAST_S7 	(RLAST_S7_axi),
	.RVALID_S7 	(RVALID_S7_axi),
	.RREADY_S7 	(RREADY_S7_axi),

	//========Slave 8 interface========//
	//WRITE ADDRESS8
	.AWID_S8	(AWID_S8_axi),
	.AWADDR_S8	(AWADDR_S8_axi),
	.AWLEN_S8	(AWLEN_S8_axi),
	.AWSIZE_S8	(AWSIZE_S8_axi),
	.AWBURST_S8	(AWBURST_S8_axi),
	.AWVALID_S8	(AWVALID_S8_axi),
	.AWREADY_S8	(AWREADY_S8_axi),
	
	//WRITE DATA8
	.WDATA_S8	(WDATA_S8_axi),
	.WSTRB_S8	(WSTRB_S8_axi),
	.WLAST_S8	(WLAST_S8_axi),
	.WVALID_S8	(WVALID_S8_axi),
	.WREADY_S8	(WREADY_S8_axi),
	
	//WRITE RESPONSE8
	.BID_S8 	(BID_S8_axi),
	.BRESP_S8 	(BRESP_S8_axi),
	.BVALID_S8 	(BVALID_S8_axi),
	.BREADY_S8 	(BREADY_S8_axi),

	//READ ADDRESS8
	.ARID_S8	(ARID_S8_axi),
	.ARADDR_S8	(ARADDR_S8_axi),
	.ARLEN_S8	(ARLEN_S8_axi),
	.ARSIZE_S8	(ARSIZE_S8_axi),
	.ARBURST_S8	(ARBURST_S8_axi),
	.ARVALID_S8	(ARVALID_S8_axi),
	.ARREADY_S8	(ARREADY_S8_axi),
	
	//READ DATA8
	.RID_S8 	(RID_S8_axi),
	.RDATA_S8 	(RDATA_S8_axi),
	.RRESP_S8 	(RRESP_S8_axi),
	.RLAST_S8 	(RLAST_S8_axi),
	.RVALID_S8 	(RVALID_S8_axi),
	.RREADY_S8 	(RREADY_S8_axi)
);

endmodule


