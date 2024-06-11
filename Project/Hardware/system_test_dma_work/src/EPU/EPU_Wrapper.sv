`ifndef AXI_DEFINITION
`define AXI_DEFINITION
`include "AXI_define.svh"
`endif
module EPU_Wrapper(
    input   CLK,
    input   RSTn,

    //for S7 port
    input   [`AXI_IDS_BITS-1:0]           ARID_S7,
    input   [`AXI_ADDR_BITS-1:0]          ARADDR_S7,
    input   [`AXI_LEN_BITS-1:0]           ARLEN_S7,
    input   [`AXI_SIZE_BITS-1:0]          ARSIZE_S7,
    input   [1:0]                         ARBURST_S7,
    input                                 ARVALID_S7,
    output  logic                         ARREADY_S7,

    output  logic   [`AXI_IDS_BITS-1:0]   RID_S7,
    output  logic   [`AXI_DATA_BITS-1:0]  RDATA_S7,
    output  logic   [1:0]                 RRESP_S7,
    output  logic                         RLAST_S7,
    output  logic                         RVALID_S7,
    input                                 RREADY_S7,

    input   [`AXI_IDS_BITS-1:0]           AWID_S7,
    input   [`AXI_ADDR_BITS-1:0]          AWADDR_S7,
    input   [`AXI_LEN_BITS-1:0]           AWLEN_S7,
    input   [`AXI_SIZE_BITS-1:0]          AWSIZE_S7,
    input   [1:0]                         AWBURST_S7,
    input                                 AWVALID_S7,
    output  logic                         AWREADY_S7,

    input   [`AXI_DATA_BITS-1:0]          WDATA_S7,
    input   [`AXI_STRB_BITS-1:0]          WSTRB_S7,
    input                                 WLAST_S7,
    input                                 WVALID_S7,
    output  logic                         WREADY_S7,

    output  logic   [`AXI_IDS_BITS-1:0]   BID_S7,
    output  logic   [1:0]                 BRESP_S7,
    output  logic                         BVALID_S7,
    input                                 BREADY_S7,

    //for S8 port
    input   [`AXI_IDS_BITS-1:0]           ARID_S8,
    input   [`AXI_ADDR_BITS-1:0]          ARADDR_S8,
    input   [`AXI_LEN_BITS-1:0]           ARLEN_S8,
    input   [`AXI_SIZE_BITS-1:0]          ARSIZE_S8,
    input   [1:0]                         ARBURST_S8,
    input                                 ARVALID_S8,
    output  logic                         ARREADY_S8,

    output  logic   [`AXI_IDS_BITS-1:0]   RID_S8,
    output  logic   [`AXI_DATA_BITS-1:0]  RDATA_S8,
    output  logic   [1:0]                 RRESP_S8,
    output  logic                         RLAST_S8,
    output  logic                         RVALID_S8,
    input                                 RREADY_S8,

    input   [`AXI_IDS_BITS-1:0]           AWID_S8,
    input   [`AXI_ADDR_BITS-1:0]          AWADDR_S8,
    input   [`AXI_LEN_BITS-1:0]           AWLEN_S8,
    input   [`AXI_SIZE_BITS-1:0]          AWSIZE_S8,
    input   [1:0]                         AWBURST_S8,
    input                                 AWVALID_S8,
    output  logic                         AWREADY_S8,

    input   [`AXI_DATA_BITS-1:0]          WDATA_S8,
    input   [`AXI_STRB_BITS-1:0]          WSTRB_S8,
    input                                 WLAST_S8,
    input                                 WVALID_S8,
    output  logic                         WREADY_S8,

    output  logic   [`AXI_IDS_BITS-1:0]   BID_S8,
    output  logic   [1:0]                 BRESP_S8,
    output  logic                         BVALID_S8,
    input                                 BREADY_S8

);

logic [11:0] A_s7;
logic end_signal, start_signal_s7, start_signal_s8;
logic [127:0] DO_s7;
logic [11:0] A_s8;
logic [31:0] DI_s8;
logic [3:0] WEB_s8;

in_SRAM_Wrapper_epu input_sram(
    .CLK        (CLK),
    .RSTn       (RSTn),

    .ARID       (ARID_S7),
    .ARADDR     (ARADDR_S7),
    .ARLEN      (ARLEN_S7),
    .ARSIZE     (ARSIZE_S7),
    .ARBURST    (ARBURST_S7),
    .ARVALID    (ARVALID_S7),
    .ARREADY    (ARREADY_S7),

    .RID        (RID_S7),
    .RDATA      (RDATA_S7),
    .RRESP      (RRESP_S7),
    .RLAST      (RLAST_S7),
    .RVALID     (RVALID_S7),
    .RREADY     (RREADY_S7),

    .AWID       (AWID_S7),
    .AWADDR     (AWADDR_S7),
    .AWLEN      (AWLEN_S7),
    .AWSIZE     (AWSIZE_S7),
    .AWBURST    (AWBURST_S7),
    .AWVALID    (AWVALID_S7),
    .AWREADY    (AWREADY_S7),

    .WDATA      (WDATA_S7),
    .WSTRB      (WSTRB_S7),
    .WLAST      (WLAST_S7),
    .WVALID     (WVALID_S7),
    .WREADY     (WREADY_S7),

    .BID        (BID_S7),
    .BRESP      (BRESP_S7),
    .BVALID     (BVALID_S7),
    .BREADY     (BREADY_S7),

  //for EPU port
    .A_epu      (A_s7),
    .end_signal (end_signal), 
    .start_signal(start_signal_s7),
    .DO_epu     (DO_s7)
);

EPU epu(
    .clk(CLK),
    .rst(~RSTn),
    .A_s7               (A_s7),
    .start_signal_s7    (start_signal_s7),
    .DO_s7              (DO_s7),
    .A_s8               (A_s8),
    .WEB_s8             (WEB_s8),
    .DI_s8              (DI_s8),
    .start_signal_s8    (start_signal_s8),
    .end_signal         (end_signal) 
);

out_SRAM_Wrapper_epu output_sram(
    .CLK        (CLK),
    .RSTn       (RSTn),

    .ARID       (ARID_S8),
    .ARADDR     (ARADDR_S8),
    .ARLEN      (ARLEN_S8),
    .ARSIZE     (ARSIZE_S8),
    .ARBURST    (ARBURST_S8),
    .ARVALID    (ARVALID_S8),
    .ARREADY    (ARREADY_S8),

    .RID        (RID_S8),
    .RDATA      (RDATA_S8),
    .RRESP      (RRESP_S8),
    .RLAST      (RLAST_S8),
    .RVALID     (RVALID_S8),
    .RREADY     (RREADY_S8),

    .AWID       (AWID_S8),
    .AWADDR     (AWADDR_S8),
    .AWLEN      (AWLEN_S8),
    .AWSIZE     (AWSIZE_S8),
    .AWBURST    (AWBURST_S8),
    .AWVALID    (AWVALID_S8),
    .AWREADY    (AWREADY_S8),

    .WDATA      (WDATA_S8),
    .WSTRB      (WSTRB_S8),
    .WLAST      (WLAST_S8),
    .WVALID     (WVALID_S8),
    .WREADY     (WREADY_S8),

    .BID        (BID_S8),
    .BRESP      (BRESP_S8),
    .BVALID     (BVALID_S8),
    .BREADY     (BREADY_S8),

      //for EPU port
    .A_epu          (A_s8),
    .WEB_epu        (WEB_s8),
    .DI_epu         (DI_s8),
    .end_signal     (end_signal),
    .start_signal   (start_signal_s8)
);


endmodule