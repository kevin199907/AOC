//================================================
// Auther:      Chen Zhi-Yu (Willy)           
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`ifndef AXI_DEFINITION
`define AXI_DEFINITION
`include "./../../include/AXI_define.svh"
`endif

module AXI(

	input ACLK,
	input ARESETn,

	//==============================//
	//	SLAVE INTERFACE FOR MASTERS	//
	//==============================//

	//======Master 0 interface======//

	//READ ADDRESS0
	input	[`AXI_ID_BITS-1:0]			ARID_M0,
	input	[`AXI_ADDR_BITS-1:0]		ARADDR_M0,
	input	[`AXI_LEN_BITS-1:0]			ARLEN_M0,
	input	[`AXI_SIZE_BITS-1:0]		ARSIZE_M0,
	input	[1:0] 						ARBURST_M0,
	input								ARVALID_M0,
	output	logic 						ARREADY_M0,
	
	//READ DATA0
	output	logic [`AXI_ID_BITS-1:0]	RID_M0,
	output	logic [`AXI_DATA_BITS-1:0]	RDATA_M0,
	output	logic [1:0]					RRESP_M0,
	output	logic						RLAST_M0,
	output	logic						RVALID_M0,
	input								RREADY_M0,

	//======Master 1 interface======//
	
	//WRITE ADDRESS
	input	[`AXI_ID_BITS-1:0]			AWID_M1,
	input	[`AXI_ADDR_BITS-1:0]		AWADDR_M1,
	input	[`AXI_LEN_BITS-1:0]			AWLEN_M1,
	input	[`AXI_SIZE_BITS-1:0]		AWSIZE_M1,
	input	[1:0]						AWBURST_M1,
	input								AWVALID_M1,
	output	logic						AWREADY_M1,
	
	//WRITE DATA
	input	[`AXI_DATA_BITS-1:0]		WDATA_M1,
	input	[`AXI_STRB_BITS-1:0]		WSTRB_M1,
	input								WLAST_M1,
	input								WVALID_M1,
	output	logic						WREADY_M1,
	
	//WRITE RESPONSE
	output	logic [`AXI_ID_BITS-1:0]	BID_M1,
	output	logic [1:0]					BRESP_M1,
	output	logic						BVALID_M1,
	input								BREADY_M1,

	//READ ADDRESS1
	input	[`AXI_ID_BITS-1:0]			ARID_M1,
	input	[`AXI_ADDR_BITS-1:0]		ARADDR_M1,
	input	[`AXI_LEN_BITS-1:0]			ARLEN_M1,
	input	[`AXI_SIZE_BITS-1:0]		ARSIZE_M1,
	input	[1:0]						ARBURST_M1,
	input								ARVALID_M1,
	output	logic						ARREADY_M1,
	
	//READ DATA1
	output	logic [`AXI_ID_BITS-1:0]	RID_M1,
	output	logic [`AXI_DATA_BITS-1:0]	RDATA_M1,
	output	logic [1:0]					RRESP_M1,
	output	logic						RLAST_M1,
	output	logic						RVALID_M1,
	input								RREADY_M1,

	
	//======DMA Master 0 interface======//
	//READ ADDRESS1
	input	[`AXI_ID_BITS-1:0]			ARID_M0_dma,
	input	[`AXI_ADDR_BITS-1:0]		ARADDR_M0_dma,
	input	[`AXI_LEN_BITS-1:0]			ARLEN_M0_dma,
	input	[`AXI_SIZE_BITS-1:0]		ARSIZE_M0_dma,
	input	[1:0]						ARBURST_M0_dma,
	input								ARVALID_M0_dma,
	output	logic						ARREADY_M0_dma,
	
	//READ DATA1
	output	logic [`AXI_ID_BITS-1:0]	RID_M0_dma,
	output	logic [`AXI_DATA_BITS-1:0]	RDATA_M0_dma,
	output	logic [1:0]					RRESP_M0_dma,
	output	logic						RLAST_M0_dma,
	output	logic						RVALID_M0_dma,
	input								RREADY_M0_dma,
	
	//======DMA Master 1 interface======//
	//WRITE ADDRESS
	input	[`AXI_ID_BITS-1:0]			AWID_M1_dma,
	input	[`AXI_ADDR_BITS-1:0]		AWADDR_M1_dma,
	input	[`AXI_LEN_BITS-1:0]			AWLEN_M1_dma,
	input	[`AXI_SIZE_BITS-1:0]		AWSIZE_M1_dma,
	input	[1:0]						AWBURST_M1_dma,
	input								AWVALID_M1_dma,
	output	logic						AWREADY_M1_dma,
	
	//WRITE DATA
	input	[`AXI_DATA_BITS-1:0]		WDATA_M1_dma,
	input	[`AXI_STRB_BITS-1:0]		WSTRB_M1_dma,
	input								WLAST_M1_dma,
	input								WVALID_M1_dma,
	output	logic						WREADY_M1_dma,
	
	//WRITE RESPONSE
	output	logic [`AXI_ID_BITS-1:0]	BID_M1_dma,
	output	logic [1:0]					BRESP_M1_dma,
	output	logic						BVALID_M1_dma,
	input								BREADY_M1_dma,

	//==================================//
	//	 MASTER INTERFACE FOR SLAVES	//
	//==================================//

	//========Slave 0 interface========//
	//WRITE ADDRESS0
	// output	logic [`AXI_IDS_BITS-1:0]	AWID_S0,
	// output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S0,
	// output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S0,
	// output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S0,
	// output	logic [1:0]					AWBURST_S0,
	// output	logic						AWVALID_S0,
	// input								AWREADY_S0,
	
	// //WRITE DATA0
	// output	logic [`AXI_DATA_BITS-1:0]	WDATA_S0,
	// output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S0,
	// output	logic						WLAST_S0,
	// output	logic						WVALID_S0,
	// input								WREADY_S0,
	
	// //WRITE RESPONSE0
	// input	[`AXI_IDS_BITS-1:0]			BID_S0,
	// input	[1:0]						BRESP_S0,
	// input								BVALID_S0,
	// output	logic						BREADY_S0,

	//READ ADDRESS0
	output	logic [`AXI_IDS_BITS-1:0]	ARID_S0,
	output	logic [`AXI_ADDR_BITS-1:0]	ARADDR_S0,
	output 	logic [`AXI_LEN_BITS-1:0]	ARLEN_S0,
	output	logic [`AXI_SIZE_BITS-1:0]	ARSIZE_S0,
	output	logic [1:0]					ARBURST_S0,
	output	logic						ARVALID_S0,
	input								ARREADY_S0,
	
	//READ DATA0
	input	[`AXI_IDS_BITS-1:0]			RID_S0,
	input	[`AXI_DATA_BITS-1:0]		RDATA_S0,
	input	[1:0]						RRESP_S0,
	input								RLAST_S0,
	input								RVALID_S0,
	output	logic						RREADY_S0,


	//========Slave 1 interface========//
	//WRITE ADDRESS1
	output	logic [`AXI_IDS_BITS-1:0]	AWID_S1,
	output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S1,
	output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S1,
	output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S1,
	output	logic [1:0]					AWBURST_S1,
	output	logic						AWVALID_S1,
	input								AWREADY_S1,
	
	//WRITE DATA1
	output	logic [`AXI_DATA_BITS-1:0]	WDATA_S1,
	output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S1,
	output	logic						WLAST_S1,
	output	logic						WVALID_S1,
	input								WREADY_S1,
	
	//WRITE RESPONSE1
	input	[`AXI_IDS_BITS-1:0]			BID_S1,
	input	[1:0]						BRESP_S1,
	input								BVALID_S1,
	output	logic						BREADY_S1,

	//READ DATA1
	input	[`AXI_IDS_BITS-1:0]			RID_S1,
	input	[`AXI_DATA_BITS-1:0]		RDATA_S1,
	input	[1:0]						RRESP_S1,
	input								RLAST_S1,
	input								RVALID_S1,
	output	logic						RREADY_S1,
	
	//READ ADDRESS1
	output	logic [`AXI_IDS_BITS-1:0]	ARID_S1,
	output	logic [`AXI_ADDR_BITS-1:0]	ARADDR_S1,
	output	logic [`AXI_LEN_BITS-1:0]	ARLEN_S1,
	output	logic [`AXI_SIZE_BITS-1:0]	ARSIZE_S1,
	output	logic [1:0]					ARBURST_S1,
	output	logic						ARVALID_S1,
	input								ARREADY_S1,

	//========Slave 2 interface========//
	//WRITE ADDRESS2
	output	logic [`AXI_IDS_BITS-1:0]	AWID_S2,
	output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S2,
	output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S2,
	output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S2,
	output	logic [1:0]					AWBURST_S2,
	output	logic						AWVALID_S2,
	input								AWREADY_S2,
	
	//WRITE DATA2
	output	logic [`AXI_DATA_BITS-1:0]	WDATA_S2,
	output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S2,
	output	logic						WLAST_S2,
	output	logic						WVALID_S2,
	input								WREADY_S2,
	
	//WRITE RESPONSE2
	input	[`AXI_IDS_BITS-1:0]			BID_S2,
	input	[1:0]						BRESP_S2,
	input								BVALID_S2,
	output	logic						BREADY_S2,

	//READ ADDRESS2
	output	logic [`AXI_IDS_BITS-1:0]	ARID_S2,
	output	logic [`AXI_ADDR_BITS-1:0]	ARADDR_S2,
	output 	logic [`AXI_LEN_BITS-1:0]	ARLEN_S2,
	output	logic [`AXI_SIZE_BITS-1:0]	ARSIZE_S2,
	output	logic [1:0]					ARBURST_S2,
	output	logic						ARVALID_S2,
	input								ARREADY_S2,
	
	//READ DATA2
	input	[`AXI_IDS_BITS-1:0]			RID_S2,
	input	[`AXI_DATA_BITS-1:0]		RDATA_S2,
	input	[1:0]						RRESP_S2,
	input								RLAST_S2,
	input								RVALID_S2,
	output	logic						RREADY_S2,

	//========Slave 3 interface========//
	//WRITE ADDRESS3
	output	logic [`AXI_IDS_BITS-1:0]	AWID_S3,
	output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S3,
	output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S3,
	output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S3,
	output	logic [1:0]					AWBURST_S3,
	output	logic						AWVALID_S3,
	input								AWREADY_S3,
	
	//WRITE DATA3
	output	logic [`AXI_DATA_BITS-1:0]	WDATA_S3,
	output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S3,
	output	logic						WLAST_S3,
	output	logic						WVALID_S3,
	input								WREADY_S3,
	
	//WRITE RESPONSE3
	input	[`AXI_IDS_BITS-1:0]			BID_S3,
	input	[1:0]						BRESP_S3,
	input								BVALID_S3,
	output	logic						BREADY_S3,

	//READ ADDRESS3
	output	logic [`AXI_IDS_BITS-1:0]	ARID_S3,
	output	logic [`AXI_ADDR_BITS-1:0]	ARADDR_S3,
	output 	logic [`AXI_LEN_BITS-1:0]	ARLEN_S3,
	output	logic [`AXI_SIZE_BITS-1:0]	ARSIZE_S3,
	output	logic [1:0]					ARBURST_S3,
	output	logic						ARVALID_S3,
	input								ARREADY_S3,
	
	//READ DATA3
	input	[`AXI_IDS_BITS-1:0]			RID_S3,
	input	[`AXI_DATA_BITS-1:0]		RDATA_S3,
	input	[1:0]						RRESP_S3,
	input								RLAST_S3,
	input								RVALID_S3,
	output	logic						RREADY_S3,

	//========Slave 4 interface========//
	//WRITE ADDRESS4
	output	logic [`AXI_IDS_BITS-1:0]	AWID_S4,
	output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S4,
	output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S4,
	output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S4,
	output	logic [1:0]					AWBURST_S4,
	output	logic						AWVALID_S4,
	input								AWREADY_S4,
	
	//WRITE DATA4
	output	logic [`AXI_DATA_BITS-1:0]	WDATA_S4,
	output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S4,
	output	logic						WLAST_S4,
	output	logic						WVALID_S4,
	input								WREADY_S4,
	
	//WRITE RESPONSE4
	input	[`AXI_IDS_BITS-1:0]			BID_S4,
	input	[1:0]						BRESP_S4,
	input								BVALID_S4,
	output	logic						BREADY_S4,

	//READ ADDRESS4
	output	logic [`AXI_IDS_BITS-1:0]	ARID_S4,
	output	logic [`AXI_ADDR_BITS-1:0]	ARADDR_S4,
	output 	logic [`AXI_LEN_BITS-1:0]	ARLEN_S4,
	output	logic [`AXI_SIZE_BITS-1:0]	ARSIZE_S4,
	output	logic [1:0]					ARBURST_S4,
	output	logic						ARVALID_S4,
	input								ARREADY_S4,
	
	//READ DATA4
	input	[`AXI_IDS_BITS-1:0]			RID_S4,
	input	[`AXI_DATA_BITS-1:0]		RDATA_S4,
	input	[1:0]						RRESP_S4,
	input								RLAST_S4,
	input								RVALID_S4,
	output	logic						RREADY_S4,

	//========Slave 5 interface========//
	//WRITE ADDRESS5
	output	logic [`AXI_IDS_BITS-1:0]	AWID_S5,
	output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S5,
	output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S5,
	output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S5,
	output	logic [1:0]					AWBURST_S5,
	output	logic						AWVALID_S5,
	input								AWREADY_S5,
	
	//WRITE DATA5
	output	logic [`AXI_DATA_BITS-1:0]	WDATA_S5,
	output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S5,
	output	logic						WLAST_S5,
	output	logic						WVALID_S5,
	input								WREADY_S5,

	//WRITE RESPONSE5
	input	[`AXI_IDS_BITS-1:0]			BID_S5,
	input	[1:0]						BRESP_S5,
	input								BVALID_S5,
	output	logic						BREADY_S5,

	//READ ADDRESS5
	output	logic [`AXI_IDS_BITS-1:0]	ARID_S5,
	output	logic [`AXI_ADDR_BITS-1:0]	ARADDR_S5,
	output 	logic [`AXI_LEN_BITS-1:0]	ARLEN_S5,
	output	logic [`AXI_SIZE_BITS-1:0]	ARSIZE_S5,
	output	logic [1:0]					ARBURST_S5,
	output	logic						ARVALID_S5,
	input								ARREADY_S5,
	
	//READ DATA5
	input	[`AXI_IDS_BITS-1:0]			RID_S5,
	input	[`AXI_DATA_BITS-1:0]		RDATA_S5,
	input	[1:0]						RRESP_S5,
	input								RLAST_S5,
	input								RVALID_S5,
	output	logic						RREADY_S5,

	//========Slave 6 interface========//
	//WRITE ADDRESS5
	output	logic [`AXI_IDS_BITS-1:0]	AWID_S6,
	output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S6,
	output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S6,
	output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S6,
	output	logic [1:0]					AWBURST_S6,
	output	logic						AWVALID_S6,
	input								AWREADY_S6,
	
	//WRITE DATA5
	output	logic [`AXI_DATA_BITS-1:0]	WDATA_S6,
	output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S6,
	output	logic						WLAST_S6,
	output	logic						WVALID_S6,
	input								WREADY_S6,

	//WRITE RESPONSE5
	input	[`AXI_IDS_BITS-1:0]			BID_S6,
	input	[1:0]						BRESP_S6,
	input								BVALID_S6,
	output	logic						BREADY_S6,

	//========Slave 7 interface========//
	//WRITE ADDRESS7
	output	logic [`AXI_IDS_BITS-1:0]	AWID_S7,
	output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S7,
	output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S7,
	output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S7,
	output	logic [1:0]					AWBURST_S7,
	output	logic						AWVALID_S7,
	input								AWREADY_S7,
	
	//WRITE DATA7
	output	logic [`AXI_DATA_BITS-1:0]	WDATA_S7,
	output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S7,
	output	logic						WLAST_S7,
	output	logic						WVALID_S7,
	input								WREADY_S7,
	
	//WRITE RESPONSE7
	input	[`AXI_IDS_BITS-1:0]			BID_S7,
	input	[1:0]						BRESP_S7,
	input								BVALID_S7,
	output	logic						BREADY_S7,

	//READ ADDRESS7
	output	logic [`AXI_IDS_BITS-1:0]	ARID_S7,
	output	logic [`AXI_ADDR_BITS-1:0]	ARADDR_S7,
	output 	logic [`AXI_LEN_BITS-1:0]	ARLEN_S7,
	output	logic [`AXI_SIZE_BITS-1:0]	ARSIZE_S7,
	output	logic [1:0]					ARBURST_S7,
	output	logic						ARVALID_S7,
	input								ARREADY_S7,
	
	//READ DATA7
	input	[`AXI_IDS_BITS-1:0]			RID_S7,
	input	[`AXI_DATA_BITS-1:0]		RDATA_S7,
	input	[1:0]						RRESP_S7,
	input								RLAST_S7,
	input								RVALID_S7,
	output	logic						RREADY_S7,

	//========Slave 8 interface========//
	//WRITE ADDRESS8
	output	logic [`AXI_IDS_BITS-1:0]	AWID_S8,
	output	logic [`AXI_ADDR_BITS-1:0]	AWADDR_S8,
	output	logic [`AXI_LEN_BITS-1:0]	AWLEN_S8,
	output	logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S8,
	output	logic [1:0]					AWBURST_S8,
	output	logic						AWVALID_S8,
	input								AWREADY_S8,
	
	//WRITE DATA8
	output	logic [`AXI_DATA_BITS-1:0]	WDATA_S8,
	output	logic [`AXI_STRB_BITS-1:0]	WSTRB_S8,
	output	logic						WLAST_S8,
	output	logic						WVALID_S8,
	input								WREADY_S8,
	
	//WRITE RESPONSE8
	input	[`AXI_IDS_BITS-1:0]			BID_S8,
	input	[1:0]						BRESP_S8,
	input								BVALID_S8,
	output	logic						BREADY_S8,

	//READ ADDRESS8
	output	logic [`AXI_IDS_BITS-1:0]	ARID_S8,
	output	logic [`AXI_ADDR_BITS-1:0]	ARADDR_S8,
	output 	logic [`AXI_LEN_BITS-1:0]	ARLEN_S8,
	output	logic [`AXI_SIZE_BITS-1:0]	ARSIZE_S8,
	output	logic [1:0]					ARBURST_S8,
	output	logic						ARVALID_S8,
	input								ARREADY_S8,
	
	//READ DATA/
	input	[`AXI_IDS_BITS-1:0]			RID_S8,
	input	[`AXI_DATA_BITS-1:0]		RDATA_S8,
	input	[1:0]						RRESP_S8,
	input								RLAST_S8,
	input								RVALID_S8,
	output	logic						RREADY_S8
);

logic [`AXI_IDS_BITS-1:0]	AWID_S1_dma;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S1_dma;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S1_dma;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S1_dma;
logic [1:0]					AWBURST_S1_dma;
logic						AWVALID_S1_dma;
logic [`AXI_DATA_BITS-1:0]	WDATA_S1_dma;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S1_dma;
logic						WLAST_S1_dma;
logic						WVALID_S1_dma;
logic						BREADY_S1_dma;

logic [`AXI_IDS_BITS-1:0]	AWID_S2_dma;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S2_dma;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S2_dma;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S2_dma;
logic [1:0]					AWBURST_S2_dma;
logic						AWVALID_S2_dma;
logic [`AXI_DATA_BITS-1:0]	WDATA_S2_dma;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S2_dma;
logic						WLAST_S2_dma;
logic						WVALID_S2_dma;
logic						BREADY_S2_dma;

logic [`AXI_IDS_BITS-1:0]	AWID_S3_dma;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S3_dma;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S3_dma;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S3_dma;
logic [1:0]					AWBURST_S3_dma;
logic						AWVALID_S3_dma;
logic [`AXI_DATA_BITS-1:0]	WDATA_S3_dma;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S3_dma;
logic						WLAST_S3_dma;
logic						WVALID_S3_dma;
logic						BREADY_S3_dma;

logic [`AXI_IDS_BITS-1:0]	AWID_S4_dma;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S4_dma;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S4_dma;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S4_dma;
logic [1:0]					AWBURST_S4_dma;
logic						AWVALID_S4_dma;
logic [`AXI_DATA_BITS-1:0]	WDATA_S4_dma;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S4_dma;
logic						WLAST_S4_dma;
logic						WVALID_S4_dma;
logic						BREADY_S4_dma;

logic [`AXI_IDS_BITS-1:0]	AWID_S5_dma;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S5_dma;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S5_dma;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S5_dma;
logic [1:0]					AWBURST_S5_dma;
logic						AWVALID_S5_dma;
logic [`AXI_DATA_BITS-1:0]	WDATA_S5_dma;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S5_dma;
logic						WLAST_S5_dma;
logic						WVALID_S5_dma;
logic						BREADY_S5_dma;

logic [`AXI_IDS_BITS-1:0]	AWID_S6_dma;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S6_dma;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S6_dma;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S6_dma;
logic [1:0]					AWBURST_S6_dma;
logic						AWVALID_S6_dma;
logic [`AXI_DATA_BITS-1:0]	WDATA_S6_dma;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S6_dma;
logic						WLAST_S6_dma;
logic						WVALID_S6_dma;
logic						BREADY_S6_dma;

logic [`AXI_IDS_BITS-1:0]	AWID_S7_dma;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S7_dma;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S7_dma;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S7_dma;
logic [1:0]					AWBURST_S7_dma;
logic						AWVALID_S7_dma;
logic [`AXI_DATA_BITS-1:0]	WDATA_S7_dma;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S7_dma;
logic						WLAST_S7_dma;
logic						WVALID_S7_dma;
logic						BREADY_S7_dma;

logic [`AXI_IDS_BITS-1:0]	AWID_S8_dma;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S8_dma;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S8_dma;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S8_dma;
logic [1:0]					AWBURST_S8_dma;
logic						AWVALID_S8_dma;
logic [`AXI_DATA_BITS-1:0]	WDATA_S8_dma;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S8_dma;
logic						WLAST_S8_dma;
logic						WVALID_S8_dma;
logic						BREADY_S8_dma;


logic [`AXI_IDS_BITS-1:0]	AWID_S1_original;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S1_original;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S1_original;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S1_original;
logic [1:0]					AWBURST_S1_original;
logic						AWVALID_S1_original;
logic [`AXI_DATA_BITS-1:0]	WDATA_S1_original;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S1_original;
logic						WLAST_S1_original;
logic						WVALID_S1_original;
logic						BREADY_S1_original;

logic [`AXI_IDS_BITS-1:0]	AWID_S2_original;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S2_original;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S2_original;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S2_original;
logic [1:0]					AWBURST_S2_original;
logic						AWVALID_S2_original;
logic [`AXI_DATA_BITS-1:0]	WDATA_S2_original;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S2_original;
logic						WLAST_S2_original;
logic						WVALID_S2_original;
logic						BREADY_S2_original;

logic [`AXI_IDS_BITS-1:0]	AWID_S3_original;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S3_original;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S3_original;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S3_original;
logic [1:0]					AWBURST_S3_original;
logic						AWVALID_S3_original;
logic [`AXI_DATA_BITS-1:0]	WDATA_S3_original;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S3_original;
logic						WLAST_S3_original;
logic						WVALID_S3_original;
logic						BREADY_S3_original;

logic [`AXI_IDS_BITS-1:0]	AWID_S4_original;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S4_original;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S4_original;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S4_original;
logic [1:0]					AWBURST_S4_original;
logic						AWVALID_S4_original;
logic [`AXI_DATA_BITS-1:0]	WDATA_S4_original;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S4_original;
logic						WLAST_S4_original;
logic						WVALID_S4_original;
logic						BREADY_S4_original;

logic [`AXI_IDS_BITS-1:0]	AWID_S5_original;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S5_original;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S5_original;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S5_original;
logic [1:0]					AWBURST_S5_original;
logic						AWVALID_S5_original;
logic [`AXI_DATA_BITS-1:0]	WDATA_S5_original;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S5_original;
logic						WLAST_S5_original;
logic						WVALID_S5_original;
logic						BREADY_S5_original;

logic [`AXI_IDS_BITS-1:0]	AWID_S6_original;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S6_original;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S6_original;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S6_original;
logic [1:0]					AWBURST_S6_original;
logic						AWVALID_S6_original;
logic [`AXI_DATA_BITS-1:0]	WDATA_S6_original;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S6_original;
logic						WLAST_S6_original;
logic						WVALID_S6_original;
logic						BREADY_S6_original;

logic [`AXI_IDS_BITS-1:0]	AWID_S7_original;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S7_original;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S7_original;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S7_original;
logic [1:0]					AWBURST_S7_original;
logic						AWVALID_S7_original;
logic [`AXI_DATA_BITS-1:0]	WDATA_S7_original;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S7_original;
logic						WLAST_S7_original;
logic						WVALID_S7_original;
logic						BREADY_S7_original;

logic [`AXI_IDS_BITS-1:0]	AWID_S8_original;
logic [`AXI_ADDR_BITS-1:0]	AWADDR_S8_original;
logic [`AXI_LEN_BITS-1:0]	AWLEN_S8_original;
logic [`AXI_SIZE_BITS-1:0]	AWSIZE_S8_original;
logic [1:0]					AWBURST_S8_original;
logic						AWVALID_S8_original;
logic [`AXI_DATA_BITS-1:0]	WDATA_S8_original;
logic [`AXI_STRB_BITS-1:0]	WSTRB_S8_original;
logic						WLAST_S8_original;
logic						WVALID_S8_original;
logic						BREADY_S8_original;


//==============================//
//	AXI write Busrt controller	//
//==============================//

// write state controller and write slave controller
parameter RESET_IDLE= 2'b00;
parameter AW_IDLE	= 2'b01;
parameter W_IDLE	= 2'b11;
parameter B_IDLE	= 2'b10;
logic [1:0]	WRITE_CS, WRITE_NS;
logic [`AXI_ADDR_BITS/2-1:0]WRITE_SLAVE_ID;	// record which slave is going to write
logic [`AXI_ID_BITS-1:0] WRITE_BURST_ID;	// record which BURST ID is this burst be
always_comb begin : WRITE_state_prediction
	case(WRITE_CS)
	RESET_IDLE	:begin// RESET_IDLE
		WRITE_NS = AW_IDLE;
	end
	AW_IDLE		:begin// AW_IDLE
		WRITE_NS = (AWVALID_M1 & AWREADY_M1)? ((WVALID_M1 & WREADY_M1 & WLAST_M1)? B_IDLE : W_IDLE) : AW_IDLE;
	end
	W_IDLE		:begin// W_IDLE
		WRITE_NS = (WVALID_M1 & WREADY_M1 & WLAST_M1)? B_IDLE : W_IDLE;
	end
	B_IDLE		:begin// B_IDLE
		WRITE_NS = (BVALID_M1 & BREADY_M1)? AW_IDLE : B_IDLE;
	end
	endcase
end
always_ff @( posedge ACLK or negedge ARESETn ) begin : WRITE_State_transfer
	if (~ARESETn) begin
		WRITE_CS <= RESET_IDLE;
	end
	else begin
		WRITE_CS <= WRITE_NS;
	end
end
always_ff @( posedge ACLK or negedge ARESETn ) begin : WRITE_Control_recorder
	if (~ARESETn) begin
		WRITE_SLAVE_ID <= 16'b0;
		WRITE_BURST_ID <= `AXI_ID_BITS'b0;
	end
	else begin// only record SLAVE ID when AW mode and handshake
		WRITE_SLAVE_ID <= (AWVALID_M1 & AWREADY_M1 & (WRITE_CS == AW_IDLE))? AWADDR_M1[`AXI_ADDR_BITS-1:`AXI_ADDR_BITS/2] : WRITE_SLAVE_ID;
		WRITE_BURST_ID <= (AWVALID_M1 & AWREADY_M1 & (WRITE_CS == AW_IDLE))? AWID_M1 : WRITE_BURST_ID;
	end
end


// ------------------  ADDR ------------------ //

// Write adress handshake signal transaction
// add more case here for expanding slave numbers
logic	AWREADY_FAKE;
always_ff @( posedge ACLK or negedge ARESETn ) begin : AWREADY_FAKE_Control
	unique if (~ARESETn) begin
		AWREADY_FAKE	<= 1'b0;
	end
	else begin
		AWREADY_FAKE	<= AWVALID_M1;
	end
end
always_comb begin : AWREADY_AWVALID_decoder// do not need arbitration because this is single master case
	unique if (WRITE_CS == AW_IDLE)begin// only transaction valid ready at AW state
		unique casez(AWADDR_M1[`AXI_ADDR_BITS-1:`AXI_ADDR_BITS/2])
		16'h1:begin
			AWREADY_M1 = AWREADY_S1;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = AWVALID_M1;
			AWVALID_S2_original = 1'b0;
			AWVALID_S3_original = 1'b0;
			AWVALID_S4_original = 1'b0;
			AWVALID_S5_original = 1'b0;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = {4'b1, AWID_M1};
			AWADDR_S1_original  = AWADDR_M1;
			AWLEN_S1_original   = AWLEN_M1;
			AWSIZE_S1_original  = AWSIZE_M1;
			AWBURST_S1_original = AWBURST_M1;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_original   = `AXI_LEN_ONE;
			AWSIZE_S5_original  = `AXI_SIZE_WORD;
			AWBURST_S5_original = `AXI_BURST_INC;

			AWID_S6_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC;

			AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		16'h2:begin
			AWREADY_M1 = AWREADY_S2;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = AWVALID_M1;
			AWVALID_S3_original = 1'b0;
			AWVALID_S4_original = 1'b0;
			AWVALID_S5_original = 1'b0;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = {4'b1, AWID_M1};
			AWADDR_S2_original  = AWADDR_M1;
			AWLEN_S2_original   = AWLEN_M1;
			AWSIZE_S2_original  = AWSIZE_M1;
			AWBURST_S2_original = AWBURST_M1;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_original   = `AXI_LEN_ONE;
			AWSIZE_S5_original  = `AXI_SIZE_WORD;
			AWBURST_S5_original = `AXI_BURST_INC;

			AWID_S6_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC;

			AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		16'h1000:begin
			AWREADY_M1 = AWREADY_S3;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = 1'b0;
			AWVALID_S3_original = AWVALID_M1;
			AWVALID_S4_original = 1'b0;
			AWVALID_S5_original = 1'b0;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = {4'b1, AWID_M1};
			AWADDR_S3_original  = AWADDR_M1;
			AWLEN_S3_original   = AWLEN_M1;
			AWSIZE_S3_original  = AWSIZE_M1;
			AWBURST_S3_original = AWBURST_M1;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_original   = `AXI_LEN_ONE;
			AWSIZE_S5_original  = `AXI_SIZE_WORD;
			AWBURST_S5_original = `AXI_BURST_INC;

			AWID_S6_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC;

			AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		16'h1001:begin
			AWREADY_M1 = AWREADY_S4;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = 1'b0;
			AWVALID_S3_original = 1'b0;
			AWVALID_S4_original = AWVALID_M1;
			AWVALID_S5_original = 1'b0;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = {4'b1, AWID_M1};
			AWADDR_S4_original  = AWADDR_M1;
			AWLEN_S4_original   = AWLEN_M1;
			AWSIZE_S4_original  = AWSIZE_M1;
			AWBURST_S4_original = AWBURST_M1;

			AWID_S5_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_original   = `AXI_LEN_ONE;
			AWSIZE_S5_original  = `AXI_SIZE_WORD;
			AWBURST_S5_original = `AXI_BURST_INC;

			AWID_S6_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC;

			AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		16'h200?:begin
			AWREADY_M1 = AWREADY_S5;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = 1'b0;
			AWVALID_S3_original = 1'b0;
			AWVALID_S4_original = 1'b0;
			AWVALID_S5_original = AWVALID_M1;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	   = {4'b1, AWID_M1};
			AWADDR_S5_original  = AWADDR_M1;
			AWLEN_S5_original   = AWLEN_M1;
			AWSIZE_S5_original  = AWSIZE_M1;
			AWBURST_S5_original = AWBURST_M1;

			AWID_S6_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC;

			AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		16'h201?:begin
			AWREADY_M1 = AWREADY_S5;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = 1'b0;
			AWVALID_S3_original = 1'b0;
			AWVALID_S4_original = 1'b0;
			AWVALID_S5_original = AWVALID_M1;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	   = {4'b1, AWID_M1};
			AWADDR_S5_original  = AWADDR_M1;
			AWLEN_S5_original   = AWLEN_M1;
			AWSIZE_S5_original  = AWSIZE_M1;
			AWBURST_S5_original = AWBURST_M1;

			AWID_S6_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC;

			AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		16'h5000:begin
			AWREADY_M1 = AWREADY_S6;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = 1'b0;
			AWVALID_S3_original = 1'b0;
			AWVALID_S4_original = 1'b0;
			AWVALID_S5_original = 1'b0;
			AWVALID_S6_original = AWVALID_M1;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_original   = `AXI_LEN_ONE;
			AWSIZE_S5_original  = `AXI_SIZE_WORD;
			AWBURST_S5_original = `AXI_BURST_INC;

			AWID_S6_original	   = {4'b1, AWID_M1};
			AWADDR_S6_original  = AWADDR_M1;
			AWLEN_S6_original   = AWLEN_M1;
			AWSIZE_S6_original  = AWSIZE_M1;
			AWBURST_S6_original = AWBURST_M1;

			AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		16'h6000:begin
			AWREADY_M1 = AWREADY_S7;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = 1'b0;
			AWVALID_S3_original = 1'b0;
			AWVALID_S4_original = 1'b0;
			AWVALID_S5_original = 1'b0;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = AWVALID_M1;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	= 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_original   = `AXI_LEN_ONE;
			AWSIZE_S5_original  = `AXI_SIZE_WORD;
			AWBURST_S5_original = `AXI_BURST_INC;

			AWID_S6_original	= 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC;

			AWID_S7_original	= {4'b1, AWID_M1};
			AWADDR_S7_original  = AWADDR_M1;
			AWLEN_S7_original   = AWLEN_M1;
			AWSIZE_S7_original  = AWSIZE_M1;
			AWBURST_S7_original = AWBURST_M1;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		16'h7000:begin
			AWREADY_M1 = AWREADY_S8;
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = 1'b0;
			AWVALID_S3_original = 1'b0;
			AWVALID_S4_original = 1'b0;
			AWVALID_S5_original = 1'b0;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = AWVALID_M1;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_original   = `AXI_LEN_ONE;
			AWSIZE_S5_original  = `AXI_SIZE_WORD;
			AWBURST_S5_original = `AXI_BURST_INC;

			AWID_S6_original	= 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC;

			AWID_S7_original 	= 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	= {4'b1, AWID_M1};
			AWADDR_S8_original  = AWADDR_M1;
			AWLEN_S8_original   = AWLEN_M1;
			AWSIZE_S8_original  = AWSIZE_M1;
			AWBURST_S8_original = AWBURST_M1;
		end
		default:begin
			AWREADY_M1 = AWREADY_FAKE;// here pull up is needed or master may stucked
			//AWVALID_S0_original = 1'b0;
			AWVALID_S1_original = 1'b0;
			AWVALID_S2_original = 1'b0; 
			AWVALID_S3_original = 1'b0; 
			AWVALID_S4_original = 1'b0; 
			AWVALID_S5_original = 1'b0;
			AWVALID_S6_original = 1'b0;
			AWVALID_S7_original = 1'b0;
			AWVALID_S8_original = 1'b0;

			// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_original   = `AXI_LEN_ONE;
			// AWSIZE_S0_original  = `AXI_SIZE_WORD;
			// AWBURST_S0_original = `AXI_BURST_INC;

			AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_original   = `AXI_LEN_ONE;
			AWSIZE_S1_original  = `AXI_SIZE_WORD;
			AWBURST_S1_original = `AXI_BURST_INC;

			AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_original   = `AXI_LEN_ONE;
			AWSIZE_S2_original  = `AXI_SIZE_WORD;
			AWBURST_S2_original = `AXI_BURST_INC;

			AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_original   = `AXI_LEN_ONE;
			AWSIZE_S3_original  = `AXI_SIZE_WORD;
			AWBURST_S3_original = `AXI_BURST_INC;

			AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_original   = `AXI_LEN_ONE;
			AWSIZE_S4_original  = `AXI_SIZE_WORD;
			AWBURST_S4_original = `AXI_BURST_INC;

			AWID_S5_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_original   = `AXI_LEN_ONE;
			AWSIZE_S5_original  = `AXI_SIZE_WORD;
			AWBURST_S5_original = `AXI_BURST_INC; 

			AWID_S6_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort;
			AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_original   = `AXI_LEN_ONE;
			AWSIZE_S6_original  = `AXI_SIZE_WORD;
			AWBURST_S6_original = `AXI_BURST_INC; 

			AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_original   = `AXI_LEN_ONE;
			AWSIZE_S7_original  = `AXI_SIZE_WORD;
			AWBURST_S7_original = `AXI_BURST_INC;

			AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_original   = `AXI_LEN_ONE;
			AWSIZE_S8_original  = `AXI_SIZE_WORD;
			AWBURST_S8_original = `AXI_BURST_INC;
		end
		endcase	
	end
	else begin// if not at AW state, then do not transaction, keep IDLE
		AWREADY_M1 = 1'b0;
		//AWVALID_S0_original = 1'b0;
		AWVALID_S1_original = 1'b0;
		AWVALID_S2_original = 1'b0;
		AWVALID_S3_original = 1'b0;
		AWVALID_S4_original = 1'b0;
		AWVALID_S5_original = 1'b0;
		AWVALID_S6_original = 1'b0;
		AWVALID_S7_original = 1'b0;
		AWVALID_S8_original = 1'b0;

		// AWID_S0_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		// AWADDR_S0_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		// AWLEN_S0_original   = `AXI_LEN_BITS'b0;
		// AWSIZE_S0_original  = `AXI_SIZE_BITS'b0;
		// AWBURST_S0_original = `AXI_BURST_INC;// default INCR mode

		AWID_S1_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S1_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S1_original   = `AXI_LEN_BITS'b0;
		AWSIZE_S1_original  = `AXI_SIZE_BITS'b0;
		AWBURST_S1_original = `AXI_BURST_INC;// default INCR mode

		AWID_S2_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S2_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S2_original   = `AXI_LEN_BITS'b0;
		AWSIZE_S2_original  = `AXI_SIZE_BITS'b0;
		AWBURST_S2_original = `AXI_BURST_INC;// default INCR mode

		AWID_S3_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S3_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S3_original   = `AXI_LEN_BITS'b0;
		AWSIZE_S3_original  = `AXI_SIZE_BITS'b0;
		AWBURST_S3_original = `AXI_BURST_INC;// default INCR mode

		AWID_S4_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S4_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S4_original   = `AXI_LEN_BITS'b0;
		AWSIZE_S4_original  = `AXI_SIZE_BITS'b0;
		AWBURST_S4_original = `AXI_BURST_INC;// default INCR mode

		AWID_S5_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S5_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S5_original   = `AXI_LEN_BITS'b0;
		AWSIZE_S5_original  = `AXI_SIZE_BITS'b0;
		AWBURST_S5_original = `AXI_BURST_INC;// default INCR mode

		AWID_S6_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S6_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S6_original   = `AXI_LEN_ONE;
		AWSIZE_S6_original  = `AXI_SIZE_WORD;
		AWBURST_S6_original = `AXI_BURST_INC;

		AWID_S7_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S7_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S7_original   = `AXI_LEN_ONE;
		AWSIZE_S7_original  = `AXI_SIZE_WORD;
		AWBURST_S7_original = `AXI_BURST_INC;

		AWID_S8_original	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S8_original  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S8_original   = `AXI_LEN_ONE;
		AWSIZE_S8_original  = `AXI_SIZE_WORD;
		AWBURST_S8_original = `AXI_BURST_INC;
	end
end

// ------------------  DATA ------------------ //

// WREADY_WVALID_decoder finished
// Write handshake signal transaction
// add more case here for expanding slave numbers
logic	WREADY_FAKE;
always_ff @( posedge ACLK or negedge ARESETn ) begin : WREADY_FAKE_Control
	unique if (~ARESETn) begin
		WREADY_FAKE	<= 1'b0;
	end
	else begin
		WREADY_FAKE	<= WVALID_M1;
	end
end
always_comb begin : WREADY_WVALID_decoder
	unique if (WRITE_CS == W_IDLE)begin
		unique casez(WRITE_SLAVE_ID)
		// add more case here for expanding slave numbers
		16'h1:	begin
			WREADY_M1 = WREADY_S1;
			//WVALID_S0_original = 1'b0;
			WVALID_S1_original = WVALID_M1;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = WDATA_M1;
			WSTRB_S1_original  = WSTRB_M1;
			WLAST_S1_original  = WLAST_M1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;
			
			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h2:begin
			WREADY_M1 = WREADY_S2;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = WVALID_M1;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = WDATA_M1;
			WSTRB_S2_original  = WSTRB_M1;
			WLAST_S2_original  = WLAST_M1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;
			
			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h1000:begin
			WREADY_M1 = WREADY_S3;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = WVALID_M1;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = WDATA_M1;
			WSTRB_S3_original  = WSTRB_M1;
			WLAST_S3_original  = WLAST_M1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;
			
			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h1001:begin
			WREADY_M1 = WREADY_S4;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = WVALID_M1;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = WDATA_M1;
			WSTRB_S4_original  = WSTRB_M1;
			WLAST_S4_original  = WLAST_M1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;
			
			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h200?:begin
			WREADY_M1 = WREADY_S5;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = WVALID_M1;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = `AXI_DATA_BITS'b0;
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = `AXI_DATA_BITS'b0;
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = `AXI_DATA_BITS'b0;
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = `AXI_DATA_BITS'b0;
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = `AXI_DATA_BITS'b0;
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = WDATA_M1;
			WSTRB_S5_original  = WSTRB_M1;
			WLAST_S5_original  = WLAST_M1;
			
			WDATA_S6_original  = `AXI_DATA_BITS'b0;
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h201?:begin
			WREADY_M1 = WREADY_S5;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = WVALID_M1;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = WDATA_M1;
			WSTRB_S5_original  = WSTRB_M1;
			WLAST_S5_original  = WLAST_M1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h5000:begin
			WREADY_M1 = WREADY_S6;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = WVALID_M1;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = WDATA_M1;
			WSTRB_S6_original  = WSTRB_M1;
			WLAST_S6_original  = WLAST_M1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h6000:begin
			WREADY_M1 = WREADY_S7;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = WVALID_M1;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = WDATA_M1;
			WSTRB_S7_original  = WSTRB_M1;
			WLAST_S7_original  = WLAST_M1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h7000:begin
			WREADY_M1 = WREADY_S8;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = WVALID_M1;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = WDATA_M1;
			WSTRB_S8_original  = WSTRB_M1;
			WLAST_S8_original  = WLAST_M1;
		end
		default:begin
			WREADY_M1 = WREADY_FAKE;// here always pull up to speed up uneffective transaction
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		endcase
	end
	else if (WRITE_CS == AW_IDLE) begin
		unique casez(AWADDR_M1[`AXI_ADDR_BITS-1:`AXI_ADDR_BITS/2])
		// add more case here for expanding slave numbers
		16'h1:	begin
			WREADY_M1 = WREADY_S1;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = WVALID_M1;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = WDATA_M1;
			WSTRB_S1_original  = WSTRB_M1;
			WLAST_S1_original  = WLAST_M1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h2:begin
			WREADY_M1 = WREADY_S2;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = WVALID_M1;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = WDATA_M1;
			WSTRB_S2_original  = WSTRB_M1;
			WLAST_S2_original  = WLAST_M1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h1000:begin
			WREADY_M1 = WREADY_S3;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = WVALID_M1;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = WDATA_M1;
			WSTRB_S3_original  = WSTRB_M1;
			WLAST_S3_original  = WLAST_M1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h1001:begin
			WREADY_M1 = WREADY_S4;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = WVALID_M1;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = WDATA_M1;
			WSTRB_S4_original  = WSTRB_M1;
			WLAST_S4_original  = WLAST_M1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h200?:begin
			WREADY_M1 = WREADY_S5;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = WVALID_M1;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = WDATA_M1;
			WSTRB_S5_original  = WSTRB_M1;
			WLAST_S5_original  = WLAST_M1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h201?:begin
			WREADY_M1 = WREADY_S5;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = WVALID_M1;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = WDATA_M1;
			WSTRB_S5_original  = WSTRB_M1;
			WLAST_S5_original  = WLAST_M1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h5000:begin
			WREADY_M1 = WREADY_S6;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = WVALID_M1;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = WDATA_M1;
			WSTRB_S6_original  = WSTRB_M1;
			WLAST_S6_original  = WLAST_M1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h6000:begin
			WREADY_M1 = WREADY_S7;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = WVALID_M1;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = WDATA_M1;
			WSTRB_S7_original  = WSTRB_M1;
			WLAST_S7_original  = WLAST_M1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		16'h7000:begin
			WREADY_M1 = WREADY_S8;
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = WVALID_M1;

			// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = WDATA_M1;
			WSTRB_S8_original  = WSTRB_M1;
			WLAST_S8_original  = WLAST_M1;
		end
		default:begin
			WREADY_M1 = WREADY_FAKE;// here always pull up to speed up uneffective transaction
			// WVALID_S0_original = 1'b0;
			WVALID_S1_original = 1'b0;
			WVALID_S2_original = 1'b0;
			WVALID_S3_original = 1'b0;
			WVALID_S4_original = 1'b0;
			WVALID_S5_original = 1'b0;
			WVALID_S6_original = 1'b0;
			WVALID_S7_original = 1'b0;
			WVALID_S8_original = 1'b0;

			// WDATA_S0_original  = `AXI_DATA_BITS'b0;
			// WSTRB_S0_original  = `AXI_STRB_WORD;
			// WLAST_S0_original  = 1'b1;

			WDATA_S1_original  = `AXI_DATA_BITS'b0;
			WSTRB_S1_original  = `AXI_STRB_WORD;
			WLAST_S1_original  = 1'b1;

			WDATA_S2_original  = `AXI_DATA_BITS'b0;
			WSTRB_S2_original  = `AXI_STRB_WORD;
			WLAST_S2_original  = 1'b1;

			WDATA_S3_original  = `AXI_DATA_BITS'b0;
			WSTRB_S3_original  = `AXI_STRB_WORD;
			WLAST_S3_original  = 1'b1;

			WDATA_S4_original  = `AXI_DATA_BITS'b0;
			WSTRB_S4_original  = `AXI_STRB_WORD;
			WLAST_S4_original  = 1'b1;

			WDATA_S5_original  = `AXI_DATA_BITS'b0;
			WSTRB_S5_original  = `AXI_STRB_WORD;
			WLAST_S5_original  = 1'b1;

			WDATA_S6_original  = `AXI_DATA_BITS'b0;
			WSTRB_S6_original  = `AXI_STRB_WORD;
			WLAST_S6_original  = 1'b1;
			
			WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_original  = `AXI_STRB_WORD;
			WLAST_S7_original  = 1'b1;
			
			WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_original  = `AXI_STRB_WORD;
			WLAST_S8_original  = 1'b1;
		end
		endcase
	end
	else begin// if not at W state, then do not transaction, keep IDLE
		WREADY_M1 = 1'b0;// here always pull up to speed up uneffective transaction
		// WVALID_S0_original = 1'b0;
		WVALID_S1_original = 1'b0;
		WVALID_S2_original = 1'b0;
		WVALID_S3_original = 1'b0;
		WVALID_S4_original = 1'b0;
		WVALID_S5_original = 1'b0;
		WVALID_S6_original = 1'b0;
		WVALID_S7_original = 1'b0;
		WVALID_S8_original = 1'b0;

		// WDATA_S0_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// WSTRB_S0_original  = `AXI_STRB_WORD;
		// WLAST_S0_original  = 1'b1;

		WDATA_S1_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S1_original  = `AXI_STRB_WORD;
		WLAST_S1_original  = 1'b1;

		WDATA_S2_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S2_original  = `AXI_STRB_WORD;
		WLAST_S2_original  = 1'b1;

		WDATA_S3_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S3_original  = `AXI_STRB_WORD;
		WLAST_S3_original  = 1'b1;

		WDATA_S4_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S4_original  = `AXI_STRB_WORD;
		WLAST_S4_original  = 1'b1;

		WDATA_S5_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S5_original  = `AXI_STRB_WORD;
		WLAST_S5_original  = 1'b1;

		WDATA_S6_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S6_original  = `AXI_STRB_WORD;
		WLAST_S6_original  = 1'b1;
			
		WDATA_S7_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S7_original  = `AXI_STRB_WORD;
		WLAST_S7_original  = 1'b1;
		
		WDATA_S8_original  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S8_original  = `AXI_STRB_WORD;
		WLAST_S8_original  = 1'b1;
	end
end

// ------------------  RESPONSE ------------------ //

// Write response handshake transaction
// add more case here for expanding slave numbers
logic	BVALID_FAKE;
always_ff @( posedge ACLK or negedge ARESETn ) begin : BVALID_FAKE_Control
	unique if (~ARESETn) begin
		BVALID_FAKE <= 1'b0;
	end
	else begin
		BVALID_FAKE	<= (BVALID_M1 & BREADY_M1)? 1'b0 : (WRITE_CS == B_IDLE);
	end
end
always_comb begin : BREADY_BVALID_decoder
	unique if (WRITE_CS == B_IDLE)begin
		unique casez(WRITE_SLAVE_ID)
		// add more case here for expanding slave numbers
		// 16'h0:	begin
		// 	BVALID_M1 = BVALID_S0;
		// 	BREADY_S0_original = BREADY_M1;
		// 	BREADY_S1_original = 1'b0;
		// 	BREADY_S2_original = 1'b0;
		// 	BREADY_S3_original = 1'b0;
		// 	BREADY_S4_original = 1'b0;
		// 	BREADY_S5_original = 1'b0;

		// 	BID_M1   = BID_S0[`AXI_ID_BITS-1:0];
		// 	BRESP_M1 = BRESP_S0;
		// end
		16'h1:	begin
			BVALID_M1 = BVALID_S1;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = BREADY_M1;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = 1'b0;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = 1'b0;

			BID_M1   = BID_S1[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S1;
		end
		16'h2:	begin
			BVALID_M1 = BVALID_S2;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = BREADY_M1;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = 1'b0;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = 1'b0;

			BID_M1   = BID_S2[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S2;
		end
		16'h1000:	begin
			BVALID_M1 = BVALID_S3;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = BREADY_M1;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = 1'b0;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = 1'b0;

			BID_M1   = BID_S3[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S3;
		end
		16'h1001:	begin
			BVALID_M1 = BVALID_S4;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = BREADY_M1;
			BREADY_S5_original = 1'b0;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = 1'b0;

			BID_M1   = BID_S4[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S4;
		end
		16'h200?:	begin
			BVALID_M1 = BVALID_S5;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = BREADY_M1;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = 1'b0;

			BID_M1   = BID_S5[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S5;
		end
		16'h201?:	begin
			BVALID_M1 = BVALID_S5;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = BREADY_M1;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = 1'b0;

			BID_M1   = BID_S5[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S5;
		end
		16'h5000:	begin
			BVALID_M1 = BVALID_S6;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = 1'b0;
			BREADY_S6_original = BREADY_M1;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = 1'b0;

			BID_M1   = BID_S6[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S6;
		end	
		16'h6000:	begin
			BVALID_M1 = BVALID_S7;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = 1'b0;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = BREADY_M1;
			BREADY_S8_original = 1'b0;

			BID_M1   = BID_S7[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S7;
		end		
		16'h7000:	begin
			BVALID_M1 = BVALID_S8;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = 1'b0;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = BREADY_M1;

			BID_M1   = BID_S8[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S8;
		end		
		default:begin
			BVALID_M1 = 1'b1;
			// BREADY_S0_original = 1'b0;
			BREADY_S1_original = 1'b0;
			BREADY_S2_original = 1'b0;
			BREADY_S3_original = 1'b0;
			BREADY_S4_original = 1'b0;
			BREADY_S5_original = 1'b0;
			BREADY_S6_original = 1'b0;
			BREADY_S7_original = 1'b0;
			BREADY_S8_original = 1'b0;

			BID_M1   = WRITE_BURST_ID;
			BRESP_M1 = `AXI_RESP_DECERR;
		end
		endcase
	end
	else begin
		BVALID_M1 = 1'b0;
		// BREADY_S0_original = 1'b0;
		BREADY_S1_original = 1'b0;
		BREADY_S2_original = 1'b0;
		BREADY_S3_original = 1'b0;
		BREADY_S4_original = 1'b0;
		BREADY_S5_original = 1'b0;
		BREADY_S6_original = 1'b0;
		BREADY_S7_original = 1'b0;
		BREADY_S8_original = 1'b0;

		BID_M1   = 4'h0;
		BRESP_M1 = `AXI_RESP_DECERR;
	end
end


//==============================//
//	AXI Read Busrt controller	//
//==============================//

// ------------------  ADDR ------------------ //

// READ state control state machine
logic [1:0] READ_CS, READ_NS;
parameter AR_IDLE = 2'b01;
parameter R_IDLE = 2'b11;
logic [`AXI_IDS_BITS-1:0]		READ_ARID;		// record ID in this burst
logic [`AXI_ADDR_BITS/2-1:0]	READ_SLAVE_ID;	// record which slave in this burst
logic [`AXI_LEN_BITS-1:0]		READ_ARLEN;		// record LEN in this burst
logic [1:0]						READ_ARBURST;	// record BURST in this burst

// AR Arbitrator state machine
parameter ARB_IDLE	= 3'b000;
parameter ARB_0STA	= 3'b010;
parameter ARB_1STA	= 3'b100;
parameter ARB_dmaSTA =3'b001;
logic [2:0] ARB_READ_CS, ARB_READ_NS;

logic [`AXI_IDS_BITS-1:0]	BUS_ARID;
logic [`AXI_ADDR_BITS-1:0]	BUS_ARADDR;
logic [`AXI_LEN_BITS-1:0]	BUS_ARLEN;
logic [`AXI_SIZE_BITS-1:0]	BUS_ARSIZE;
logic [1:0]					BUS_ARBURST;
logic 						BUS_ARVALID;
logic						BUS_ARREADY;

logic [`AXI_IDS_BITS-1:0]	BUS_RID;
logic [`AXI_DATA_BITS-1:0]	BUS_RDATA;
logic [1:0] 				BUS_RRESP;
logic 						BUS_RLAST;
logic 						BUS_RVALID;
logic 						BUS_RREADY;

// READ_State_Transfer finish
// READ_State_Transfer control the state of READ burst
always_ff @( posedge ACLK or negedge ARESETn ) begin : READ_State_Transfer
	unique if (~ARESETn) begin
		READ_CS <= RESET_IDLE;
	end
	else begin
		READ_CS <= READ_NS;
	end
end

always_ff @( posedge ACLK or negedge ARESETn ) begin : blockName
	unique if (~ARESETn) begin
		READ_ARID		<= 8'b0;
		READ_ARLEN		<= 4'b0;
		READ_ARBURST	<= 2'b0;
		READ_SLAVE_ID	<= 16'b0;
	end
	else begin
		unique if (BUS_ARREADY & BUS_ARVALID & READ_CS == AR_IDLE) begin
			READ_ARID		<= BUS_ARID;
			READ_ARLEN		<= BUS_ARLEN;
			READ_ARBURST	<= BUS_ARBURST;
			READ_SLAVE_ID	<= BUS_ARADDR[31:16];
		end
		else begin
			READ_ARID		<= READ_ARID;
			READ_ARLEN		<= READ_ARLEN;
			READ_ARBURST	<= READ_ARBURST;
			READ_SLAVE_ID	<= READ_SLAVE_ID;
		end
	end
end
always_comb begin : READ_State_Predicor
	unique case(READ_CS)// RIDLE, if handshake then transaction and if RLAST then go back ARIDLE
	RESET_IDLE:begin
		READ_NS = AR_IDLE;
	end
	AR_IDLE:begin
		READ_NS = (BUS_ARVALID & BUS_ARREADY)? R_IDLE : AR_IDLE;
	end
	R_IDLE:begin
		READ_NS = (BUS_RVALID & BUS_RREADY & BUS_RLAST)? AR_IDLE : R_IDLE;
	end
	default:READ_NS = RESET_IDLE;
	endcase
end


// READ_ARB_State_Transfer finish
// READ_ARB_State_Transfer control the priority transfer of arbitrator
// add more state here for expanding master numbers
always_ff @( posedge ACLK or negedge ARESETn ) begin : READ_ARB_State_Transfer
	unique if (~ARESETn)begin
		ARB_READ_CS <= ARB_IDLE;
	end
	else begin
		ARB_READ_CS <= ARB_READ_NS;
	end
end
always_comb begin : READ_ARB_state_predictor
	unique case(ARB_READ_CS)
	ARB_IDLE:begin
		unique case({ARVALID_M0, ARVALID_M1, ARVALID_M0_dma})
		3'b110: ARB_READ_NS = ARB_0STA;
		3'b100: ARB_READ_NS = ARB_0STA;
		3'b010: ARB_READ_NS = ARB_1STA;
		3'b001: ARB_READ_NS = ARB_dmaSTA;
		default: ARB_READ_NS = ARB_IDLE;
		endcase
	end
	ARB_0STA:begin
		unique if (ARVALID_M1)begin
			ARB_READ_NS = (BUS_ARREADY)? ARB_1STA : ARB_0STA;
		end
		else begin
			ARB_READ_NS = (BUS_ARREADY)? ARB_IDLE : ARB_0STA;
		end
	end
	ARB_1STA:begin
		unique if (ARVALID_M1)begin
			ARB_READ_NS = (BUS_ARREADY)? ARB_1STA : ARB_1STA;
		end
		else begin
			ARB_READ_NS = (BUS_ARREADY)? ARB_IDLE : ARB_1STA;
		end
	end
	ARB_dmaSTA:begin
		unique if (ARVALID_M0_dma)begin
			ARB_READ_NS = (BUS_ARREADY)? ARB_dmaSTA : ARB_dmaSTA;
		end
		else begin
			ARB_READ_NS = (BUS_ARREADY)? ARB_IDLE : ARB_dmaSTA;
		end
	end
	default:begin
		ARB_READ_NS = ARB_IDLE;
	end
	endcase
end

// ARREADY_ARVALID_Arbitration_MUX finish
// ARREADY_ARVALID_Arbitration_MUX arbitrate and connect master to bus
// add more case here for expanding master numbers
always_comb begin : ARREADY_ARVALID_Arbitration_MUX
	unique if (READ_CS == AR_IDLE)begin
		unique case(ARB_READ_CS)
		ARB_IDLE:begin
			BUS_ARID	= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			BUS_ARADDR	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			BUS_ARLEN	= 4'h0;
			BUS_ARSIZE	= 3'h0;
			BUS_ARBURST	= 2'h0;
			BUS_ARVALID	= 1'b0;

			ARREADY_M0 = 1'b0;
			ARREADY_M1 = 1'b0;
			ARREADY_M0_dma = 1'b0;
		end
		ARB_0STA:begin
			BUS_ARID	= {4'b0, ARID_M0};
			BUS_ARADDR	= ARADDR_M0;
			BUS_ARLEN	= ARLEN_M0;
			BUS_ARSIZE	= ARSIZE_M0;
			BUS_ARBURST	= ARBURST_M0;
			BUS_ARVALID	= ARVALID_M0;

			ARREADY_M0 = BUS_ARREADY;
			ARREADY_M1 = 1'b0;
			ARREADY_M0_dma = 1'b0;
		end
		ARB_1STA:begin
			BUS_ARID	= {4'b1, ARID_M1};
			BUS_ARADDR	= ARADDR_M1;
			BUS_ARLEN	= ARLEN_M1;
			BUS_ARSIZE	= ARSIZE_M1;
			BUS_ARBURST	= ARBURST_M1;
			BUS_ARVALID	= ARVALID_M1;

			ARREADY_M0 = 1'b0;
			ARREADY_M1 = BUS_ARREADY;
			ARREADY_M0_dma = 1'b0;
		end
		ARB_dmaSTA:begin
			BUS_ARID	= {4'd2, ARID_M0_dma};
			BUS_ARADDR	= ARADDR_M0_dma;
			BUS_ARLEN	= ARLEN_M0_dma;
			BUS_ARSIZE	= ARSIZE_M0_dma;
			BUS_ARBURST	= ARBURST_M0_dma;
			BUS_ARVALID	= ARVALID_M0_dma;

			ARREADY_M0 = 1'b0;
			ARREADY_M1 = 1'b0;
			ARREADY_M0_dma = BUS_ARREADY;
		end
		default:begin
			BUS_ARID	= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			BUS_ARADDR	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			BUS_ARLEN	= 4'h0;
			BUS_ARSIZE	= 3'h0;
			BUS_ARBURST	= 2'h0;
			BUS_ARVALID	= 1'b0;

			ARREADY_M0 = 1'b0;
			ARREADY_M1 = 1'b0;
			ARREADY_M0_dma = 1'b0;
		end
		endcase
	end
	else begin
		BUS_ARID	= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		BUS_ARADDR	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		BUS_ARLEN	= 4'h0;
		BUS_ARSIZE	= 3'h0;
		BUS_ARBURST	= 2'h0;
		BUS_ARVALID	= 1'b0;

		ARREADY_M0 = 1'b0;
		ARREADY_M1 = 1'b0;
		ARREADY_M0_dma = 1'b0;
	end
end

// ARREADY_ARVALID_Decoder finish
// ARREADY_ARVALID_Decoder decode the information and connect bus to slave
// by upper 16-bits of ARADDR
// add more case here for expanding slave numbers
always_comb begin : ARREADY_ARVALID_Decoder
	unique if (READ_CS == AR_IDLE)begin
		unique casez(BUS_ARADDR[31:16])
		16'h0:begin
			ARVALID_S0	= BUS_ARVALID;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= 1'b0;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = ARREADY_S0;

			ARID_S0		= BUS_ARID;
			ARADDR_S0	= BUS_ARADDR;
			ARLEN_S0	= BUS_ARLEN;
			ARSIZE_S0	= BUS_ARSIZE;
			ARBURST_S0	= BUS_ARBURST;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S5	= 4'h0;
			ARSIZE_S5	= 3'h0;
			ARBURST_S5	= 2'h0;	

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;	
		end
		16'h1:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= BUS_ARVALID;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= 1'b0;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = ARREADY_S1;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= BUS_ARID;
			ARADDR_S1	= BUS_ARADDR;
			ARLEN_S1	= BUS_ARLEN;
			ARSIZE_S1	= BUS_ARSIZE;
			ARBURST_S1	= BUS_ARBURST;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S5	= 4'h0;
			ARSIZE_S5	= 3'h0;
			ARBURST_S5	= 2'h0;		

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;	
		end
		16'h2:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= BUS_ARVALID;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= 1'b0;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = ARREADY_S2;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= BUS_ARID;
			ARADDR_S2	= BUS_ARADDR;
			ARLEN_S2	= BUS_ARLEN;
			ARSIZE_S2	= BUS_ARSIZE;
			ARBURST_S2	= BUS_ARBURST;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S5	= 4'h0;
			ARSIZE_S5	= 3'h0;
			ARBURST_S5	= 2'h0;		

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;	
		end
		16'h1000:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= BUS_ARVALID;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= 1'b0;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = ARREADY_S3;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= BUS_ARID;
			ARADDR_S3	= BUS_ARADDR;
			ARLEN_S3	= BUS_ARLEN;
			ARSIZE_S3	= BUS_ARSIZE;
			ARBURST_S3	= BUS_ARBURST;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S5	= 4'h0;
			ARSIZE_S5	= 3'h0;
			ARBURST_S5	= 2'h0;		

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;	
		end
		16'h1001:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= BUS_ARVALID;
			ARVALID_S5	= 1'b0;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = ARREADY_S4;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= BUS_ARID;
			ARADDR_S4	= BUS_ARADDR;
			ARLEN_S4	= BUS_ARLEN;
			ARSIZE_S4	= BUS_ARSIZE;
			ARBURST_S4	= BUS_ARBURST;

			ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S5	= 4'h0;
			ARSIZE_S5	= 3'h0;
			ARBURST_S5	= 2'h0;		

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;	
		end
		16'h200?:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= BUS_ARVALID;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = ARREADY_S5;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= BUS_ARID;
			ARADDR_S5	= BUS_ARADDR;
			ARLEN_S5	= BUS_ARLEN;
			ARSIZE_S5	= BUS_ARSIZE;
			ARBURST_S5	= BUS_ARBURST;	

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;		
		end
		16'h201?:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= BUS_ARVALID;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = ARREADY_S5;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= BUS_ARID;
			ARADDR_S5	= BUS_ARADDR;
			ARLEN_S5	= BUS_ARLEN;
			ARSIZE_S5	= BUS_ARSIZE;
			ARBURST_S5	= BUS_ARBURST;	

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;	
		end
		16'h6000:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= 1'b0;
			ARVALID_S7	= BUS_ARVALID;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = ARREADY_S7;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S5	= 4'h0;
			ARSIZE_S5	= 3'h0;
			ARBURST_S5	= 2'h0;	

			ARID_S7		= BUS_ARID;
			ARADDR_S7	= BUS_ARADDR;
			ARLEN_S7	= BUS_ARLEN;
			ARSIZE_S7	= BUS_ARSIZE;
			ARBURST_S7	= BUS_ARBURST;

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;	
		end
		16'h7000:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= 1'b0;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= BUS_ARVALID;

			BUS_ARREADY = ARREADY_S8;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S5	= 4'h0;
			ARSIZE_S5	= 3'h0;
			ARBURST_S5	= 2'h0;	

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= BUS_ARID;
			ARADDR_S8	= BUS_ARADDR;
			ARLEN_S8	= BUS_ARLEN;
			ARSIZE_S8	= BUS_ARSIZE;
			ARBURST_S8	= BUS_ARBURST;	
		end
		default:begin
			ARVALID_S0	= 1'b0;
			ARVALID_S1	= 1'b0;
			ARVALID_S2	= 1'b0;
			ARVALID_S3	= 1'b0;
			ARVALID_S4	= 1'b0;
			ARVALID_S5	= 1'b0;
			ARVALID_S7	= 1'b0;
			ARVALID_S8	= 1'b0;

			BUS_ARREADY = 1'b1;

			ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S0	= 4'h0;
			ARSIZE_S0	= 3'h0;
			ARBURST_S0	= 2'h0;

			ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S1	= 4'h0;
			ARSIZE_S1	= 3'h0;
			ARBURST_S1	= 2'h0;

			ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S2	= 4'h0;
			ARSIZE_S2	= 3'h0;
			ARBURST_S2	= 2'h0;

			ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S3	= 4'h0;
			ARSIZE_S3	= 3'h0;
			ARBURST_S3	= 2'h0;

			ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S4	= 4'h0;
			ARSIZE_S4	= 3'h0;
			ARBURST_S4	= 2'h0;

			ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S5	= 4'h0;
			ARSIZE_S5	= 3'h0;
			ARBURST_S5	= 2'h0;		

			ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S7	= 4'h0;
			ARSIZE_S7	= 3'h0;
			ARBURST_S7	= 2'h0;	

			ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
			ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
			ARLEN_S8	= 4'h0;
			ARSIZE_S8	= 3'h0;
			ARBURST_S8	= 2'h0;	
		end
		endcase
	end
	else begin
		ARVALID_S0	= 1'b0;
		ARVALID_S1	= 1'b0;
		ARVALID_S2	= 1'b0;
		ARVALID_S3	= 1'b0;
		ARVALID_S4	= 1'b0;
		ARVALID_S5	= 1'b0;
		ARVALID_S7	= 1'b0;
		ARVALID_S8	= 1'b0;

		BUS_ARREADY = 1'b1;

		ARID_S0		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		ARADDR_S0	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		ARLEN_S0	= 4'h0;
		ARSIZE_S0	= 3'h0;
		ARBURST_S0	= 2'h0;

		ARID_S1		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		ARADDR_S1	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		ARLEN_S1	= 4'h0;
		ARSIZE_S1	= 3'h0;
		ARBURST_S1	= 2'h0;

		ARID_S2		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		ARADDR_S2	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		ARLEN_S2	= 4'h0;
		ARSIZE_S2	= 3'h0;
		ARBURST_S2	= 2'h0;

		ARID_S3		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		ARADDR_S3	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		ARLEN_S3	= 4'h0;
		ARSIZE_S3	= 3'h0;
		ARBURST_S3	= 2'h0;

		ARID_S4		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		ARADDR_S4	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		ARLEN_S4	= 4'h0;
		ARSIZE_S4	= 3'h0;
		ARBURST_S4	= 2'h0;

		ARID_S5		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		ARADDR_S5	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		ARLEN_S5	= 4'h0;
		ARSIZE_S5	= 3'h0;
		ARBURST_S5	= 2'h0;

		ARID_S7		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		ARADDR_S7	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		ARLEN_S7	= 4'h0;
		ARSIZE_S7	= 3'h0;
		ARBURST_S7	= 2'h0;	

		ARID_S8		= 8'h0;// ARID have 8 bits, using don't care value to lower capacitance effort
		ARADDR_S8	= 32'h0;// ARADDDR have 32 bits, using don't care value to lower capacitance effort
		ARLEN_S8	= 4'h0;
		ARSIZE_S8	= 3'h0;
		ARBURST_S8	= 2'h0;	
	end
end

// ------------------  DATA ------------------ //

logic [`AXI_LEN_BITS-1:0] READ_BURST_COUNTER;
always_ff @( posedge ACLK or negedge ARESETn ) begin : READ_Bound_Recorder
	unique if (~ARESETn)begin
		READ_BURST_COUNTER <= `AXI_LEN_ONE;
	end
	else begin
		case (READ_CS)
		RESET_IDLE:begin
			READ_BURST_COUNTER <= `AXI_LEN_ONE;
		end
		AR_IDLE:begin
			READ_BURST_COUNTER <= (BUS_ARVALID & BUS_ARREADY)? BUS_ARLEN : `AXI_LEN_ONE;
		end
		R_IDLE:begin
			READ_BURST_COUNTER <= (BUS_RVALID & BUS_RREADY)? (READ_BURST_COUNTER - 4'b1) : READ_BURST_COUNTER;
		end
		default:begin
			READ_BURST_COUNTER <= `AXI_LEN_ONE;
		end
		endcase
	end
end
logic FAKE_SLAVE_RLAST;
assign FAKE_SLAVE_RLAST = ~(READ_BURST_COUNTER[3]|READ_BURST_COUNTER[2]|READ_BURST_COUNTER[1]|READ_BURST_COUNTER[0]);

// RREADY_RVALID_Arbitration_MUX finish
// RREADY_RVALID_Arbitration_MUX arbitrate and connect slave to bus
// for read, we connect slave to arbitrator because slave provide data to master
// add more case here for expanding slave numbers
logic	BUS_RVALID_FAKE;
always_ff @( posedge ACLK or negedge ARESETn ) begin : FAKE_VALID_Control
	unique if (~ARESETn)begin
		BUS_RVALID_FAKE <= 1'b1;
	end
	else begin
		BUS_RVALID_FAKE <= ~(BUS_RVALID & BUS_RREADY);
	end
end
always_comb begin : RREADY_RVALID_Arbitration_MUX
	unique if (READ_CS == R_IDLE)begin
		unique casez(READ_SLAVE_ID)
		16'h0:begin
			BUS_RID		= RID_S0;
			BUS_RDATA	= RDATA_S0;
			BUS_RRESP	= RRESP_S0;
			BUS_RLAST	= RLAST_S0;
			BUS_RVALID	= RVALID_S0;

			RREADY_S0	= BUS_RREADY;
			RREADY_S1	= 1'b0;
			RREADY_S2	= 1'b0;
			RREADY_S3	= 1'b0;
			RREADY_S4	= 1'b0;
			RREADY_S5	= 1'b0;
			RREADY_S7	= 1'b0;
			RREADY_S8	= 1'b0;
		end
		16'h1:begin
			BUS_RID		= RID_S1;
			BUS_RDATA	= RDATA_S1;
			BUS_RRESP	= RRESP_S1;
			BUS_RLAST	= RLAST_S1;
			BUS_RVALID	= RVALID_S1;

			RREADY_S0	= 1'b0;
			RREADY_S1	= BUS_RREADY;
			RREADY_S2	= 1'b0;
			RREADY_S3	= 1'b0;
			RREADY_S4	= 1'b0;
			RREADY_S5	= 1'b0;
			RREADY_S7	= 1'b0;
			RREADY_S8	= 1'b0;
		end
		16'h2:begin
			BUS_RID		= RID_S2;
			BUS_RDATA	= RDATA_S2;
			BUS_RRESP	= RRESP_S2;
			BUS_RLAST	= RLAST_S2;
			BUS_RVALID	= RVALID_S2;

			RREADY_S0	= 1'b0;
			RREADY_S1	= 1'b0;
			RREADY_S2	= BUS_RREADY;
			RREADY_S3	= 1'b0;
			RREADY_S4	= 1'b0;
			RREADY_S5	= 1'b0;
			RREADY_S7	= 1'b0;
			RREADY_S8	= 1'b0;
		end
		16'h1000:begin
			BUS_RID		= RID_S3;
			BUS_RDATA	= RDATA_S3;
			BUS_RRESP	= RRESP_S3;
			BUS_RLAST	= RLAST_S3;
			BUS_RVALID	= RVALID_S3;

			RREADY_S0	= 1'b0;
			RREADY_S1	= 1'b0;
			RREADY_S2	= 1'b0;
			RREADY_S3	= BUS_RREADY;
			RREADY_S4	= 1'b0;
			RREADY_S5	= 1'b0;
			RREADY_S7	= 1'b0;
			RREADY_S8	= 1'b0;
		end
		16'h1001:begin
			BUS_RID		= RID_S4;
			BUS_RDATA	= RDATA_S4;
			BUS_RRESP	= RRESP_S4;
			BUS_RLAST	= RLAST_S4;
			BUS_RVALID	= RVALID_S4;

			RREADY_S0	= 1'b0;
			RREADY_S1	= 1'b0;
			RREADY_S2	= 1'b0;
			RREADY_S3	= 1'b0;
			RREADY_S4	= BUS_RREADY;
			RREADY_S5	= 1'b0;
			RREADY_S7	= 1'b0;
			RREADY_S8	= 1'b0;
		end
		16'h200?:begin
			BUS_RID		= RID_S5;
			BUS_RDATA	= RDATA_S5;
			BUS_RRESP	= RRESP_S5;
			BUS_RLAST	= RLAST_S5;
			BUS_RVALID	= RVALID_S5;

			RREADY_S0	= 1'b0;
			RREADY_S1	= 1'b0;
			RREADY_S2	= 1'b0;
			RREADY_S3	= 1'b0;
			RREADY_S4	= 1'b0;
			RREADY_S5	= BUS_RREADY;
			RREADY_S7	= 1'b0;
			RREADY_S8	= 1'b0;
		end
		16'h201?:begin
			BUS_RID		= RID_S5;
			BUS_RDATA	= RDATA_S5;
			BUS_RRESP	= RRESP_S5;
			BUS_RLAST	= RLAST_S5;
			BUS_RVALID	= RVALID_S5;

			RREADY_S0	= 1'b0;
			RREADY_S1	= 1'b0;
			RREADY_S2	= 1'b0;
			RREADY_S3	= 1'b0;
			RREADY_S4	= 1'b0;
			RREADY_S5	= BUS_RREADY;
			RREADY_S7	= 1'b0;
			RREADY_S8	= 1'b0;
		end
		16'h6000:begin
			BUS_RID		= RID_S7;
			BUS_RDATA	= RDATA_S7;
			BUS_RRESP	= RRESP_S7;
			BUS_RLAST	= RLAST_S7;
			BUS_RVALID	= RVALID_S7;

			RREADY_S0	= 1'b0;
			RREADY_S1	= 1'b0;
			RREADY_S2	= 1'b0;
			RREADY_S3	= 1'b0;
			RREADY_S4	= 1'b0;
			RREADY_S5	= 1'b0;
			RREADY_S7	= BUS_RREADY;
			RREADY_S8	= 1'b0;
		end
		16'h7000:begin
			BUS_RID		= RID_S8;
			BUS_RDATA	= RDATA_S8;
			BUS_RRESP	= RRESP_S8;
			BUS_RLAST	= RLAST_S8;
			BUS_RVALID	= RVALID_S8;

			RREADY_S0	= 1'b0;
			RREADY_S1	= 1'b0;
			RREADY_S2	= 1'b0;
			RREADY_S3	= 1'b0;
			RREADY_S4	= 1'b0;
			RREADY_S5	= 1'b0;
			RREADY_S7	= 1'b0;
			RREADY_S8	= BUS_RREADY;
		end
		default:begin
			BUS_RID		= READ_ARID;
			BUS_RDATA	= 32'b0;
			BUS_RRESP	= `AXI_RESP_DECERR;
			BUS_RLAST	= FAKE_SLAVE_RLAST;
			BUS_RVALID	= BUS_RVALID_FAKE;
			
			RREADY_S0	= 1'b0;
			RREADY_S1	= 1'b0;
			RREADY_S2	= 1'b0;
			RREADY_S3	= 1'b0;
			RREADY_S4	= 1'b0;
			RREADY_S5	= 1'b0;
			RREADY_S7	= 1'b0;
			RREADY_S8	= 1'b0;
		end
		endcase
	end
	else begin
		BUS_RID		= 8'h0;
		BUS_RDATA	= 32'h0;
		BUS_RRESP	= `AXI_RESP_DECERR;
		BUS_RLAST	= 1'b0;
		BUS_RVALID	= 1'b0;
		
		RREADY_S0	= 1'b0;
		RREADY_S1	= 1'b0;
		RREADY_S2	= 1'b0;
		RREADY_S3	= 1'b0;
		RREADY_S4	= 1'b0;
		RREADY_S5	= 1'b0;
		RREADY_S7	= 1'b0;
		RREADY_S8	= 1'b0;
	end
end

// ARREADY_ARVALID_Decoder finish
// ARREADY_ARVALID_Decoder decode the information and connect bus to master
// by upper 4-bits of BUS_RID
// add more case here for expanding master numbers
always_comb begin : RREADY_RVALID_Decoder
	unique if (READ_CS == R_IDLE)begin
		unique case(BUS_RID[7:4])
		4'h0:begin
			RID_M0		= BUS_RID[3:0];
			RDATA_M0	= BUS_RDATA;
			RRESP_M0	= BUS_RRESP;
			RLAST_M0	= BUS_RLAST;
			RVALID_M0	= BUS_RVALID;

			RID_M1		= 4'h0;
			RDATA_M1	= 32'h0;
			RRESP_M1	= 2'b0;
			RLAST_M1	= 1'b0;
			RVALID_M1	= 1'b0;

			RID_M0_dma		= 4'h0;
			RDATA_M0_dma	= 32'h0;
			RRESP_M0_dma	= 2'b0;
			RLAST_M0_dma	= 1'b0;
			RVALID_M0_dma	= 1'b0;

			BUS_RREADY	= RREADY_M0;
		end
		4'h1:begin
			RID_M0		= 4'h0;
			RDATA_M0	= 32'h0;
			RRESP_M0	= 2'h0;
			RLAST_M0	= 1'h0;
			RVALID_M0	= 1'h0;

			RID_M1		= BUS_RID[3:0];
			RDATA_M1	= BUS_RDATA;
			RRESP_M1	= BUS_RRESP;
			RLAST_M1	= BUS_RLAST;
			RVALID_M1	= BUS_RVALID;

			RID_M0_dma		= 4'h0;
			RDATA_M0_dma	= 32'h0;
			RRESP_M0_dma	= 2'h0;
			RLAST_M0_dma	= 1'h0;
			RVALID_M0_dma	= 1'h0;

			BUS_RREADY	= RREADY_M1;
		end
		4'h2:begin
			RID_M0		= 4'h0;
			RDATA_M0	= 32'h0;
			RRESP_M0	= 2'h0;
			RLAST_M0	= 1'h0;
			RVALID_M0	= 1'b0;

			RID_M1		= 4'h0;
			RDATA_M1	= 32'h0;
			RRESP_M1	= 2'h0;
			RLAST_M1	= 1'h0;
			RVALID_M1	= 1'b0;

			RID_M0_dma		= BUS_RID[3:0];
			RDATA_M0_dma	= BUS_RDATA;
			RRESP_M0_dma	= BUS_RRESP;
			RLAST_M0_dma	= BUS_RLAST;
			RVALID_M0_dma	= BUS_RVALID;

			BUS_RREADY	= RREADY_M0_dma;
		end
		default:begin
			RID_M0		= 4'h0;
			RDATA_M0	= 32'h0;
			RRESP_M0	= `AXI_RESP_DECERR;
			RLAST_M0	= 1'h0;
			RVALID_M0	= 1'b0;

			RID_M1		= 4'h0;
			RDATA_M1	= 32'h0;
			RRESP_M1	= `AXI_RESP_DECERR;
			RLAST_M1	= 1'h0;
			RVALID_M1	= 1'b0;

			RID_M0_dma		= 4'h0;
			RDATA_M0_dma	= 32'h0;
			RRESP_M0_dma	= `AXI_RESP_DECERR;
			RLAST_M0_dma	= 1'h0;
			RVALID_M0_dma	= 1'b0;

			BUS_RREADY	= 1'b0;
		end
		endcase
	end
	else begin
		RID_M0		= 4'h0;
		RDATA_M0	= 32'h0;
		RRESP_M0	= 2'h0;
		RLAST_M0	= 1'b0;
		RVALID_M0	= 1'b0;

		RID_M1		= 4'h0;
		RDATA_M1	= 32'h0;
		RRESP_M1	= 2'h0;
		RLAST_M1	= 1'b0;
		RVALID_M1	= 1'b0;

		RID_M0_dma		= 4'h0;
		RDATA_M0_dma	= 32'h0;
		RRESP_M0_dma	= 2'h0;
		RLAST_M0_dma	= 1'b0;
		RVALID_M0_dma	= 1'b0;

		BUS_RREADY	= 1'b0;
	end
end





////////////////////////////DMA////////////////////////////

// write state controller and write slave controller
parameter RESET_IDLE_dma= 2'b00;
parameter AW_IDLE_dma	= 2'b01;
parameter W_IDLE_dma	= 2'b11;
parameter B_IDLE_dma	= 2'b10;
logic [1:0]	WRITE_CS_dma, WRITE_NS_dma;
logic [`AXI_ADDR_BITS/2-1:0]WRITE_SLAVE_ID_dma;	// record which slave is going to write
logic [`AXI_ID_BITS-1:0] WRITE_BURST_ID_dma;	// record which BURST ID is this burst be
always_comb begin : WRITE_state_prediction_dma
	case(WRITE_CS_dma)
	RESET_IDLE_dma	:begin// RESET_IDLE_dma
		WRITE_NS_dma = AW_IDLE_dma;
	end
	AW_IDLE_dma		:begin// AW_IDLE_dma
		WRITE_NS_dma = (AWVALID_M1_dma & AWREADY_M1_dma)? ((WVALID_M1_dma & WREADY_M1_dma & WLAST_M1_dma)? B_IDLE_dma : W_IDLE_dma) : AW_IDLE_dma;
	end
	W_IDLE_dma		:begin// W_IDLE_dma
		WRITE_NS_dma = (WVALID_M1_dma & WREADY_M1_dma & WLAST_M1_dma)? B_IDLE_dma : W_IDLE_dma;
	end
	B_IDLE_dma		:begin// B_IDLE_dma
		WRITE_NS_dma = (BVALID_M1_dma & BREADY_M1_dma)? AW_IDLE_dma : B_IDLE_dma;
	end
	endcase
end
always_ff @( posedge ACLK or negedge ARESETn ) begin : WRITE_State_transfer_dma
	if (~ARESETn) begin
		WRITE_CS_dma <= RESET_IDLE_dma;
	end
	else begin
		WRITE_CS_dma <= WRITE_NS_dma;
	end
end
always_ff @( posedge ACLK or negedge ARESETn ) begin : WRITE_Control_recorder_dma
	if (~ARESETn) begin
		WRITE_SLAVE_ID_dma <= 16'b0;
		WRITE_BURST_ID_dma <= `AXI_ID_BITS'b0;
	end
	else begin// only record SLAVE ID when AW mode and handshake
		WRITE_SLAVE_ID_dma <= (AWVALID_M1_dma & AWREADY_M1_dma & (WRITE_CS_dma == AW_IDLE_dma))? AWADDR_M1_dma[`AXI_ADDR_BITS-1:`AXI_ADDR_BITS/2] : WRITE_SLAVE_ID_dma;
		WRITE_BURST_ID_dma <= (AWVALID_M1_dma & AWREADY_M1_dma & (WRITE_CS_dma == AW_IDLE_dma))? AWID_M1_dma : WRITE_BURST_ID_dma;
	end
end


// ------------------  ADDR ------------------ //

// Write adress handshake signal transaction
// add more case here for expanding slave numbers
logic	AWREADY_FAKE_dma_dma;
always_ff @( posedge ACLK or negedge ARESETn ) begin : AWREADY_FAKE_dma_dma_Control
	unique if (~ARESETn) begin
		AWREADY_FAKE_dma_dma	<= 1'b0;
	end
	else begin
		AWREADY_FAKE_dma_dma	<= AWVALID_M1_dma;
	end
end
always_comb begin : AWREADY_AWVALID_decoder_dma// do not need arbitration because this is single master case
	unique if (WRITE_CS_dma == AW_IDLE_dma)begin// only transaction valid ready at AW state
		unique casez(AWADDR_M1_dma[`AXI_ADDR_BITS-1:`AXI_ADDR_BITS/2])
		16'h1:begin
			AWREADY_M1_dma = AWREADY_S1;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = AWVALID_M1_dma;
			AWVALID_S2_dma = 1'b0;
			AWVALID_S3_dma = 1'b0;
			AWVALID_S4_dma = 1'b0;
			AWVALID_S5_dma = 1'b0;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S1_dma  = AWADDR_M1_dma;
			AWLEN_S1_dma   = AWLEN_M1_dma;
			AWSIZE_S1_dma  = AWSIZE_M1_dma;
			AWBURST_S1_dma = AWBURST_M1_dma;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_dma   = `AXI_LEN_ONE;
			AWSIZE_S5_dma  = `AXI_SIZE_WORD;
			AWBURST_S5_dma = `AXI_BURST_INC;

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC;

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		16'h2:begin
			AWREADY_M1_dma = AWREADY_S2;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = AWVALID_M1_dma;
			AWVALID_S3_dma = 1'b0;
			AWVALID_S4_dma = 1'b0;
			AWVALID_S5_dma = 1'b0;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S2_dma  = AWADDR_M1_dma;
			AWLEN_S2_dma   = AWLEN_M1_dma;
			AWSIZE_S2_dma  = AWSIZE_M1_dma;
			AWBURST_S2_dma = AWBURST_M1_dma;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_dma   = `AXI_LEN_ONE;
			AWSIZE_S5_dma  = `AXI_SIZE_WORD;
			AWBURST_S5_dma = `AXI_BURST_INC;

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC;

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		16'h1000:begin
			AWREADY_M1_dma = AWREADY_S3;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = 1'b0;
			AWVALID_S3_dma = AWVALID_M1_dma;
			AWVALID_S4_dma = 1'b0;
			AWVALID_S5_dma = 1'b0;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S3_dma  = AWADDR_M1_dma;
			AWLEN_S3_dma   = AWLEN_M1_dma;
			AWSIZE_S3_dma  = AWSIZE_M1_dma;
			AWBURST_S3_dma = AWBURST_M1_dma;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_dma   = `AXI_LEN_ONE;
			AWSIZE_S5_dma  = `AXI_SIZE_WORD;
			AWBURST_S5_dma = `AXI_BURST_INC;

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC;

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		16'h1001:begin
			AWREADY_M1_dma = AWREADY_S4;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = 1'b0;
			AWVALID_S3_dma = 1'b0;
			AWVALID_S4_dma = AWVALID_M1_dma;
			AWVALID_S5_dma = 1'b0;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S4_dma  = AWADDR_M1_dma;
			AWLEN_S4_dma   = AWLEN_M1_dma;
			AWSIZE_S4_dma  = AWSIZE_M1_dma;
			AWBURST_S4_dma = AWBURST_M1_dma;

			AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_dma   = `AXI_LEN_ONE;
			AWSIZE_S5_dma  = `AXI_SIZE_WORD;
			AWBURST_S5_dma = `AXI_BURST_INC;

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC;

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		16'h200?:begin
			AWREADY_M1_dma = AWREADY_S5;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = 1'b0;
			AWVALID_S3_dma = 1'b0;
			AWVALID_S4_dma = 1'b0;
			AWVALID_S5_dma = AWVALID_M1_dma;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S5_dma  = AWADDR_M1_dma;
			AWLEN_S5_dma   = AWLEN_M1_dma;
			AWSIZE_S5_dma  = AWSIZE_M1_dma;
			AWBURST_S5_dma = AWBURST_M1_dma;

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC;

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		16'h201?:begin
			AWREADY_M1_dma = AWREADY_S5;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = 1'b0;
			AWVALID_S3_dma = 1'b0;
			AWVALID_S4_dma = 1'b0;
			AWVALID_S5_dma = AWVALID_M1_dma;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S5_dma  = AWADDR_M1_dma;
			AWLEN_S5_dma   = AWLEN_M1_dma;
			AWSIZE_S5_dma  = AWSIZE_M1_dma;
			AWBURST_S5_dma = AWBURST_M1_dma;

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC;

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		16'h5000:begin
			AWREADY_M1_dma = AWREADY_S6;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = 1'b0;
			AWVALID_S3_dma = 1'b0;
			AWVALID_S4_dma = 1'b0;
			AWVALID_S5_dma = 1'b0;
			AWVALID_S6_dma = AWVALID_M1_dma;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_dma   = `AXI_LEN_ONE;
			AWSIZE_S5_dma  = `AXI_SIZE_WORD;
			AWBURST_S5_dma = `AXI_BURST_INC;

			AWID_S6_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S6_dma  = AWADDR_M1_dma;
			AWLEN_S6_dma   = AWLEN_M1_dma;
			AWSIZE_S6_dma  = AWSIZE_M1_dma;
			AWBURST_S6_dma = AWBURST_M1_dma;

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		16'h6000:begin
			AWREADY_M1_dma = AWREADY_S7;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = 1'b0;
			AWVALID_S3_dma = 1'b0;
			AWVALID_S4_dma = 1'b0;
			AWVALID_S5_dma = 1'b0;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = AWVALID_M1_dma;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_dma   = `AXI_LEN_ONE;
			AWSIZE_S5_dma  = `AXI_SIZE_WORD;
			AWBURST_S5_dma = `AXI_BURST_INC;

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC;

			AWID_S7_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S7_dma  = AWADDR_M1_dma;
			AWLEN_S7_dma   = AWLEN_M1_dma;
			AWSIZE_S7_dma  = AWSIZE_M1_dma;
			AWBURST_S7_dma = AWBURST_M1_dma;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		16'h7000:begin
			AWREADY_M1_dma = AWREADY_S8;
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = 1'b0;
			AWVALID_S3_dma = 1'b0;
			AWVALID_S4_dma = 1'b0;
			AWVALID_S5_dma = 1'b0;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = AWVALID_M1_dma;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_dma   = `AXI_LEN_ONE;
			AWSIZE_S5_dma  = `AXI_SIZE_WORD;
			AWBURST_S5_dma = `AXI_BURST_INC;

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC;

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = {4'd2, AWID_M1_dma};
			AWADDR_S8_dma  = AWADDR_M1_dma;
			AWLEN_S8_dma   = AWLEN_M1_dma;
			AWSIZE_S8_dma  = AWSIZE_M1_dma;
			AWBURST_S8_dma = AWBURST_M1_dma;
		end
		default:begin
			AWREADY_M1_dma = AWREADY_FAKE_dma_dma;// here pull up is needed or master may stucked
			//AWVALID_S0_dma = 1'b0;
			AWVALID_S1_dma = 1'b0;
			AWVALID_S2_dma = 1'b0; 
			AWVALID_S3_dma = 1'b0; 
			AWVALID_S4_dma = 1'b0; 
			AWVALID_S5_dma = 1'b0;
			AWVALID_S6_dma = 1'b0;
			AWVALID_S7_dma = 1'b0;
			AWVALID_S8_dma = 1'b0;

			// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			// AWLEN_S0_dma   = `AXI_LEN_ONE;
			// AWSIZE_S0_dma  = `AXI_SIZE_WORD;
			// AWBURST_S0_dma = `AXI_BURST_INC;

			AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S1_dma   = `AXI_LEN_ONE;
			AWSIZE_S1_dma  = `AXI_SIZE_WORD;
			AWBURST_S1_dma = `AXI_BURST_INC;

			AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S2_dma   = `AXI_LEN_ONE;
			AWSIZE_S2_dma  = `AXI_SIZE_WORD;
			AWBURST_S2_dma = `AXI_BURST_INC;

			AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S3_dma   = `AXI_LEN_ONE;
			AWSIZE_S3_dma  = `AXI_SIZE_WORD;
			AWBURST_S3_dma = `AXI_BURST_INC;

			AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S4_dma   = `AXI_LEN_ONE;
			AWSIZE_S4_dma  = `AXI_SIZE_WORD;
			AWBURST_S4_dma = `AXI_BURST_INC;

			AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S5_dma   = `AXI_LEN_ONE;
			AWSIZE_S5_dma  = `AXI_SIZE_WORD;
			AWBURST_S5_dma = `AXI_BURST_INC; 

			AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort;
			AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S6_dma   = `AXI_LEN_ONE;
			AWSIZE_S6_dma  = `AXI_SIZE_WORD;
			AWBURST_S6_dma = `AXI_BURST_INC; 

			AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S7_dma   = `AXI_LEN_ONE;
			AWSIZE_S7_dma  = `AXI_SIZE_WORD;
			AWBURST_S7_dma = `AXI_BURST_INC;

			AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
			AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
			AWLEN_S8_dma   = `AXI_LEN_ONE;
			AWSIZE_S8_dma  = `AXI_SIZE_WORD;
			AWBURST_S8_dma = `AXI_BURST_INC;
		end
		endcase	
	end
	else begin// if not at AW state, then do not transaction, keep IDLE
		AWREADY_M1_dma = 1'b0;
		//AWVALID_S0_dma = 1'b0;
		AWVALID_S1_dma = 1'b0;
		AWVALID_S2_dma = 1'b0;
		AWVALID_S3_dma = 1'b0;
		AWVALID_S4_dma = 1'b0;
		AWVALID_S5_dma = 1'b0;
		AWVALID_S6_dma = 1'b0;
		AWVALID_S7_dma = 1'b0;
		AWVALID_S8_dma = 1'b0;

		// AWID_S0_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		// AWADDR_S0_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		// AWLEN_S0_dma   = `AXI_LEN_BITS'b0;
		// AWSIZE_S0_dma  = `AXI_SIZE_BITS'b0;
		// AWBURST_S0_dma = `AXI_BURST_INC;// default INCR mode

		AWID_S1_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S1_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S1_dma   = `AXI_LEN_BITS'b0;
		AWSIZE_S1_dma  = `AXI_SIZE_BITS'b0;
		AWBURST_S1_dma = `AXI_BURST_INC;// default INCR mode

		AWID_S2_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S2_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S2_dma   = `AXI_LEN_BITS'b0;
		AWSIZE_S2_dma  = `AXI_SIZE_BITS'b0;
		AWBURST_S2_dma = `AXI_BURST_INC;// default INCR mode

		AWID_S3_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S3_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S3_dma   = `AXI_LEN_BITS'b0;
		AWSIZE_S3_dma  = `AXI_SIZE_BITS'b0;
		AWBURST_S3_dma = `AXI_BURST_INC;// default INCR mode

		AWID_S4_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S4_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S4_dma   = `AXI_LEN_BITS'b0;
		AWSIZE_S4_dma  = `AXI_SIZE_BITS'b0;
		AWBURST_S4_dma = `AXI_BURST_INC;// default INCR mode

		AWID_S5_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S5_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S5_dma   = `AXI_LEN_BITS'b0;
		AWSIZE_S5_dma  = `AXI_SIZE_BITS'b0;
		AWBURST_S5_dma = `AXI_BURST_INC;// default INCR mode

		AWID_S6_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S6_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S6_dma   = `AXI_LEN_ONE;
		AWSIZE_S6_dma  = `AXI_SIZE_WORD;
		AWBURST_S6_dma = `AXI_BURST_INC;

		AWID_S7_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S7_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S7_dma   = `AXI_LEN_ONE;
		AWSIZE_S7_dma  = `AXI_SIZE_WORD;
		AWBURST_S7_dma = `AXI_BURST_INC;

		AWID_S8_dma	   = 8'h0;// IDslave have 8 bits, using don't care value to lower capacitance effort
		AWADDR_S8_dma  = 32'h0;// AWADDDR have 32 bits, using don't care value to lower capacitance effort
		AWLEN_S8_dma   = `AXI_LEN_ONE;
		AWSIZE_S8_dma  = `AXI_SIZE_WORD;
		AWBURST_S8_dma = `AXI_BURST_INC;
	end
end

// ------------------  DATA ------------------ //

// WREADY_WVALID_decoder finished
// Write handshake signal transaction
// add more case here for expanding slave numbers
logic	WREADY_FAKE_dma;
always_ff @( posedge ACLK or negedge ARESETn ) begin : WREADY_FAKE_dma_Control
	unique if (~ARESETn) begin
		WREADY_FAKE_dma	<= 1'b0;
	end
	else begin
		WREADY_FAKE_dma	<= WVALID_M1_dma;
	end
end
always_comb begin : WREADY_WVALID_decoder_dma
	unique if (WRITE_CS_dma == W_IDLE_dma)begin
		unique casez(WRITE_SLAVE_ID_dma)
		// add more case here for expanding slave numbers
		// 16'h0:	begin
		// 	WREADY_M1_dma = WREADY_S0_dma;
		// 	WVALID_S0_dma = WVALID_M1_dma;
		// 	WVALID_S1_dma = 1'b0;
		// 	WVALID_S2_dma = 1'b0;
		// 	WVALID_S3_dma = 1'b0;
		// 	WVALID_S4_dma = 1'b0;
		// 	WVALID_S5_dma = 1'b0;

		// 	WDATA_S0_dma  = WDATA_M1_dma;
		// 	WSTRB_S0_dma  = WSTRB_M1_dma;
		// 	WLAST_S0_dma  = WLAST_M1_dma;

		// 	WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S1_dma  = `AXI_STRB_WORD;
		// 	WLAST_S1_dma  = 1'b1;

		// 	WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S2_dma  = `AXI_STRB_WORD;
		// 	WLAST_S2_dma  = 1'b1;

		// 	WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S3_dma  = `AXI_STRB_WORD;
		// 	WLAST_S3_dma  = 1'b1;

		// 	WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S4_dma  = `AXI_STRB_WORD;
		// 	WLAST_S4_dma  = 1'b1;

		// 	WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S5_dma  = `AXI_STRB_WORD;
		// 	WLAST_S5_dma  = 1'b1;
		// end
		16'h1:	begin
			WREADY_M1_dma = WREADY_S1;
			//WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = WVALID_M1_dma;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = WDATA_M1_dma;
			WSTRB_S1_dma  = WSTRB_M1_dma;
			WLAST_S1_dma  = WLAST_M1_dma;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;
			
			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;
			
			WDATA_S7_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;
			
			WDATA_S8_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h2:begin
			WREADY_M1_dma = WREADY_S2;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = WVALID_M1_dma;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = WDATA_M1_dma;
			WSTRB_S2_dma  = WSTRB_M1_dma;
			WLAST_S2_dma  = WLAST_M1_dma;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;
			
			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;
			
			WDATA_S7_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;
			
			WDATA_S8_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h1000:begin
			WREADY_M1_dma = WREADY_S3;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = WVALID_M1_dma;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = WDATA_M1_dma;
			WSTRB_S3_dma  = WSTRB_M1_dma;
			WLAST_S3_dma  = WLAST_M1_dma;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;
			
			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;
			
			WDATA_S7_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;
			
			WDATA_S8_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h1001:begin
			WREADY_M1_dma = WREADY_S4;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = WVALID_M1_dma;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = WDATA_M1_dma;
			WSTRB_S4_dma  = WSTRB_M1_dma;
			WLAST_S4_dma  = WLAST_M1_dma;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;
			
			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;
			
			WDATA_S7_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;
			
			WDATA_S8_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h200?:begin
			WREADY_M1_dma = WREADY_S5;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = WVALID_M1_dma;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = `AXI_DATA_BITS'b0;
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = WDATA_M1_dma;
			WSTRB_S5_dma  = WSTRB_M1_dma;
			WLAST_S5_dma  = WLAST_M1_dma;
			
			WDATA_S6_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;
			
			WDATA_S7_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;
			
			WDATA_S8_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h201?:begin
			WREADY_M1_dma = WREADY_S5;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = WVALID_M1_dma;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = WDATA_M1_dma;
			WSTRB_S5_dma  = WSTRB_M1_dma;
			WLAST_S5_dma  = WLAST_M1_dma;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;
			
			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;
			
			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h5000:begin
			WREADY_M1_dma = WREADY_S6;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = WVALID_M1_dma;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = WDATA_M1_dma;
			WSTRB_S6_dma  = WSTRB_M1_dma;
			WLAST_S6_dma  = WLAST_M1_dma;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h6000:begin
			WREADY_M1_dma = WREADY_S7;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = WVALID_M1_dma;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = WDATA_M1_dma;
			WSTRB_S7_dma  = WSTRB_M1_dma;
			WLAST_S7_dma  = WLAST_M1_dma;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h7000:begin
			WREADY_M1_dma = WREADY_S8;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = WVALID_M1_dma;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = WDATA_M1_dma;
			WSTRB_S8_dma  = WSTRB_M1_dma;
			WLAST_S8_dma  = WLAST_M1_dma;
		end
		default:begin
			WREADY_M1_dma = WREADY_FAKE_dma;// here always pull up to speed up uneffective transaction
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		endcase
	end
	else if (WRITE_CS_dma == AW_IDLE_dma) begin
		unique casez(AWADDR_M1_dma[`AXI_ADDR_BITS-1:`AXI_ADDR_BITS/2])
		// add more case here for expanding slave numbers
		// 16'h0:	begin
		// 	WREADY_M1_dma = WREADY_S0_dma;
		// 	WVALID_S0_dma = WVALID_M1_dma;
		// 	WVALID_S1_dma = 1'b0;
		// 	WVALID_S2_dma = 1'b0;
		// 	WVALID_S3_dma = 1'b0;
		// 	WVALID_S4_dma = 1'b0;
		// 	WVALID_S5_dma = 1'b0;

		// 	WDATA_S0_dma  = WDATA_M1_dma;
		// 	WSTRB_S0_dma  = WSTRB_M1_dma;
		// 	WLAST_S0_dma  = WLAST_M1_dma;

		// 	WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S1_dma  = `AXI_STRB_WORD;
		// 	WLAST_S1_dma  = 1'b1;

		// 	WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S2_dma  = `AXI_STRB_WORD;
		// 	WLAST_S2_dma  = 1'b1;

		// 	WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S3_dma  = `AXI_STRB_WORD;
		// 	WLAST_S3_dma  = 1'b1;

		// 	WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S4_dma  = `AXI_STRB_WORD;
		// 	WLAST_S4_dma  = 1'b1;

		// 	WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// 	WSTRB_S5_dma  = `AXI_STRB_WORD;
		// 	WLAST_S5_dma  = 1'b1;
		// end
		16'h1:	begin
			WREADY_M1_dma = WREADY_S1;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = WVALID_M1_dma;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = WDATA_M1_dma;
			WSTRB_S1_dma  = WSTRB_M1_dma;
			WLAST_S1_dma  = WLAST_M1_dma;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h2:begin
			WREADY_M1_dma = WREADY_S2;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = WVALID_M1_dma;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = WDATA_M1_dma;
			WSTRB_S2_dma  = WSTRB_M1_dma;
			WLAST_S2_dma  = WLAST_M1_dma;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h1000:begin
			WREADY_M1_dma = WREADY_S3;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = WVALID_M1_dma;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = WDATA_M1_dma;
			WSTRB_S3_dma  = WSTRB_M1_dma;
			WLAST_S3_dma  = WLAST_M1_dma;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h1001:begin
			WREADY_M1_dma = WREADY_S4;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = WVALID_M1_dma;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = WDATA_M1_dma;
			WSTRB_S4_dma  = WSTRB_M1_dma;
			WLAST_S4_dma  = WLAST_M1_dma;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h200?:begin
			WREADY_M1_dma = WREADY_S5;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = WVALID_M1_dma;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = WDATA_M1_dma;
			WSTRB_S5_dma  = WSTRB_M1_dma;
			WLAST_S5_dma  = WLAST_M1_dma;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h201?:begin
			WREADY_M1_dma = WREADY_S5;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = WVALID_M1_dma;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = WDATA_M1_dma;
			WSTRB_S5_dma  = WSTRB_M1_dma;
			WLAST_S5_dma  = WLAST_M1_dma;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h5000:begin
			WREADY_M1_dma = WREADY_S6;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = WVALID_M1_dma;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = WDATA_M1_dma;
			WSTRB_S6_dma  = WSTRB_M1_dma;
			WLAST_S6_dma  = WLAST_M1_dma;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h6000:begin
			WREADY_M1_dma = WREADY_S7;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = WVALID_M1_dma;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = WDATA_M1_dma;
			WSTRB_S7_dma  = WSTRB_M1_dma;
			WLAST_S7_dma  = WLAST_M1_dma;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		16'h7000:begin
			WREADY_M1_dma = WREADY_S8;
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = WVALID_M1_dma;

			// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = WDATA_M1_dma;
			WSTRB_S8_dma  = WSTRB_M1_dma;
			WLAST_S8_dma  = WLAST_M1_dma;
		end
		default:begin
			WREADY_M1_dma = WREADY_FAKE_dma;// here always pull up to speed up uneffective transaction
			// WVALID_S0_dma = 1'b0;
			WVALID_S1_dma = 1'b0;
			WVALID_S2_dma = 1'b0;
			WVALID_S3_dma = 1'b0;
			WVALID_S4_dma = 1'b0;
			WVALID_S5_dma = 1'b0;
			WVALID_S6_dma = 1'b0;
			WVALID_S7_dma = 1'b0;
			WVALID_S8_dma = 1'b0;

			// WDATA_S0_dma  = `AXI_DATA_BITS'b0;
			// WSTRB_S0_dma  = `AXI_STRB_WORD;
			// WLAST_S0_dma  = 1'b1;

			WDATA_S1_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S1_dma  = `AXI_STRB_WORD;
			WLAST_S1_dma  = 1'b1;

			WDATA_S2_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S2_dma  = `AXI_STRB_WORD;
			WLAST_S2_dma  = 1'b1;

			WDATA_S3_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S3_dma  = `AXI_STRB_WORD;
			WLAST_S3_dma  = 1'b1;

			WDATA_S4_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S4_dma  = `AXI_STRB_WORD;
			WLAST_S4_dma  = 1'b1;

			WDATA_S5_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S5_dma  = `AXI_STRB_WORD;
			WLAST_S5_dma  = 1'b1;

			WDATA_S6_dma  = `AXI_DATA_BITS'b0;
			WSTRB_S6_dma  = `AXI_STRB_WORD;
			WLAST_S6_dma  = 1'b1;

			WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S7_dma  = `AXI_STRB_WORD;
			WLAST_S7_dma  = 1'b1;

			WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
			WSTRB_S8_dma  = `AXI_STRB_WORD;
			WLAST_S8_dma  = 1'b1;
		end
		endcase
	end
	else begin// if not at W state, then do not transaction, keep IDLE
		WREADY_M1_dma = 1'b0;// here always pull up to speed up uneffective transaction
		// WVALID_S0_dma = 1'b0;
		WVALID_S1_dma = 1'b0;
		WVALID_S2_dma = 1'b0;
		WVALID_S3_dma = 1'b0;
		WVALID_S4_dma = 1'b0;
		WVALID_S5_dma = 1'b0;
		WVALID_S6_dma = 1'b0;
		WVALID_S7_dma = 1'b0;
		WVALID_S8_dma = 1'b0;

		// WDATA_S0_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		// WSTRB_S0_dma  = `AXI_STRB_WORD;
		// WLAST_S0_dma  = 1'b1;

		WDATA_S1_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S1_dma  = `AXI_STRB_WORD;
		WLAST_S1_dma  = 1'b1;

		WDATA_S2_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S2_dma  = `AXI_STRB_WORD;
		WLAST_S2_dma  = 1'b1;

		WDATA_S3_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S3_dma  = `AXI_STRB_WORD;
		WLAST_S3_dma  = 1'b1;

		WDATA_S4_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S4_dma  = `AXI_STRB_WORD;
		WLAST_S4_dma  = 1'b1;

		WDATA_S5_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S5_dma  = `AXI_STRB_WORD;
		WLAST_S5_dma  = 1'b1;

		WDATA_S6_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S6_dma  = `AXI_STRB_WORD;
		WLAST_S6_dma  = 1'b1;

		WDATA_S7_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S7_dma  = `AXI_STRB_WORD;
		WLAST_S7_dma  = 1'b1;

		WDATA_S8_dma  = 32'h0;// WDATA have 32 bits, using don't care value to lower capacitance effort
		WSTRB_S8_dma  = `AXI_STRB_WORD;
		WLAST_S8_dma  = 1'b1;
	end
end

// ------------------  RESPONSE ------------------ //

// Write response handshake transaction
// add more case here for expanding slave numbers
logic	BVALID_FAKE_dma;
always_ff @( posedge ACLK or negedge ARESETn ) begin : BVALID_FAKE_dma_Control
	unique if (~ARESETn) begin
		BVALID_FAKE_dma <= 1'b0;
	end
	else begin
		BVALID_FAKE_dma	<= (BVALID_M1_dma & BREADY_M1_dma)? 1'b0 : (WRITE_CS_dma == B_IDLE_dma);
	end
end
always_comb begin : BREADY_BVALID_decoder_dma
	unique if (WRITE_CS_dma == B_IDLE_dma)begin
		unique casez(WRITE_SLAVE_ID_dma)
		// add more case here for expanding slave numbers
		// 16'h0:	begin
		// 	BVALID_M1_dma = BVALID_S0_dma;
		// 	BREADY_S0_dma = BREADY_M1_dma;
		// 	BREADY_S1_dma = 1'b0;
		// 	BREADY_S2_dma = 1'b0;
		// 	BREADY_S3_dma = 1'b0;
		// 	BREADY_S4_dma = 1'b0;
		// 	BREADY_S5_dma = 1'b0;

		// 	BID_M1_dma   = BID_S0_dma[`AXI_ID_BITS-1:0];
		// 	BRESP_M1_dma = BRESP_S0_dma;
		// end
		16'h1:	begin
			BVALID_M1_dma = BVALID_S1;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = BREADY_M1_dma;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = 1'b0;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = BID_S1[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BID_S1;
		end
		16'h2:	begin
			BVALID_M1_dma = BVALID_S2;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = BREADY_M1_dma;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = 1'b0;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = BID_S2[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BID_S2;
		end
		16'h1000:	begin
			BVALID_M1_dma = BVALID_S3;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = BREADY_M1_dma;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = 1'b0;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = BID_S3[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BID_S3;
		end
		16'h1001:	begin
			BVALID_M1_dma = BVALID_S4;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = BREADY_M1_dma;
			BREADY_S5_dma = 1'b0;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = BID_S4[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BID_S4;
		end
		16'h200?:	begin
			BVALID_M1_dma = BVALID_S5;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = BREADY_M1_dma;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = BID_S5[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BID_S5;
		end
		16'h201?:	begin
			BVALID_M1_dma = BVALID_S5;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = BREADY_M1_dma;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = BID_S5[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BID_S5;
		end
		16'h5000:	begin
			BVALID_M1_dma = BVALID_S6;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = 1'b0;
			BREADY_S6_dma = BREADY_M1_dma;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = BID_S6[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BRESP_S6;
		end
		16'h6000:	begin
			BVALID_M1_dma = BVALID_S7;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = 1'b0;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = BREADY_M1_dma;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = BID_S7[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BRESP_S7;
		end		
		16'h7000:	begin
			BVALID_M1_dma = BVALID_S8;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = 1'b0;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = BREADY_M1_dma;

			BID_M1_dma   = BID_S8[`AXI_ID_BITS-1:0];
			BRESP_M1_dma = BRESP_S8;
		end				
		default:begin
			BVALID_M1_dma = 1'b1;
			// BREADY_S0_dma = 1'b0;
			BREADY_S1_dma = 1'b0;
			BREADY_S2_dma = 1'b0;
			BREADY_S3_dma = 1'b0;
			BREADY_S4_dma = 1'b0;
			BREADY_S5_dma = 1'b0;
			BREADY_S6_dma = 1'b0;
			BREADY_S7_dma = 1'b0;
			BREADY_S8_dma = 1'b0;

			BID_M1_dma   = WRITE_BURST_ID_dma;
			BRESP_M1_dma = `AXI_RESP_DECERR;
		end
		endcase
	end
	else begin
		BVALID_M1_dma = 1'b0;
		// BREADY_S0_dma = 1'b0;
		BREADY_S1_dma = 1'b0;
		BREADY_S2_dma = 1'b0;
		BREADY_S3_dma = 1'b0;
		BREADY_S4_dma = 1'b0;
		BREADY_S5_dma = 1'b0;
		BREADY_S6_dma = 1'b0;
		BREADY_S7_dma = 1'b0;
		BREADY_S8_dma = 1'b0;

		BID_M1_dma   = 4'h0;
		BRESP_M1_dma = `AXI_RESP_DECERR;
	end
end

logic [1:0] state_decoder, nstate_decoder;
localparam CPU_Master = 2'd2;
localparam DMA_Master = 2'd1;
localparam IDLE_Master =2'd0;

always_ff@(posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) state_decoder<=IDLE_Master;
	else state_decoder<=nstate_decoder;
end

always_comb begin
	case(state_decoder)
	IDLE_Master:begin
		if(AWVALID_M1) nstate_decoder=CPU_Master;
		else if (AWVALID_M1_dma) nstate_decoder=DMA_Master;
		else nstate_decoder=IDLE_Master;
	end
	CPU_Master:begin
		if(BREADY_M1 && BVALID_M1) nstate_decoder=IDLE_Master;
		else nstate_decoder=CPU_Master;
	end
	DMA_Master:begin
		if(BREADY_M1_dma && BVALID_M1_dma) nstate_decoder=IDLE_Master;
		else nstate_decoder=DMA_Master;
	end	
	default: begin
		nstate_decoder=IDLE_Master;
	end
	endcase
end

always_comb begin
	case(state_decoder)	
	IDLE_Master:begin
		if (AWVALID_M1_dma) begin
			AWID_S1		= 	AWID_S1_dma;		 
			AWADDR_S1	= 	AWADDR_S1_dma;	 	
			AWLEN_S1	= 	AWLEN_S1_dma;	 	
			AWSIZE_S1	= 	AWSIZE_S1_dma;	 	
			AWBURST_S1	= 	AWBURST_S1_dma;	 	
			AWVALID_S1	= 	AWVALID_S1_dma;	 	
				
			WDATA_S1	= 	WDATA_S1_dma;	 	
			WSTRB_S1	= 	WSTRB_S1_dma;	 	
			WLAST_S1	= 	WLAST_S1_dma;	 	
			WVALID_S1	= 	WVALID_S1_dma;	 	
						
			BREADY_S1	= 	BREADY_S1_dma;
			
			AWID_S2		= 	AWID_S2_dma;		 
			AWADDR_S2	= 	AWADDR_S2_dma;	 	
			AWLEN_S2	= 	AWLEN_S2_dma;	 	
			AWSIZE_S2	= 	AWSIZE_S2_dma;	 	
			AWBURST_S2	= 	AWBURST_S2_dma;	 	
			AWVALID_S2	= 	AWVALID_S2_dma;	 	
					
			WDATA_S2	= 	WDATA_S2_dma;	 	
			WSTRB_S2	= 	WSTRB_S2_dma;	 	
			WLAST_S2	= 	WLAST_S2_dma;	 	
			WVALID_S2	= 	WVALID_S2_dma;	 	
					
			BREADY_S2	= 	BREADY_S2_dma;	 	
			
			AWID_S3		= 	AWID_S3_dma;		 
			AWADDR_S3	= 	AWADDR_S3_dma;	 	
			AWLEN_S3	= 	AWLEN_S3_dma;	 	
			AWSIZE_S3	= 	AWSIZE_S3_dma;	 	
			AWBURST_S3	= 	AWBURST_S3_dma;	 	
			AWVALID_S3	= 	AWVALID_S3_dma;	 	
					
			WDATA_S3	= 	WDATA_S3_dma;	 	
			WSTRB_S3	= 	WSTRB_S3_dma;	 	
			WLAST_S3	= 	WLAST_S3_dma;	 	
			WVALID_S3	= 	WVALID_S3_dma;	 	
					
			BREADY_S3	= 	BREADY_S3_dma;	 		
			
			AWID_S4		= 	AWID_S4_dma;		 
			AWADDR_S4	= 	AWADDR_S4_dma;	 	
			AWLEN_S4	= 	AWLEN_S4_dma;	 	
			AWSIZE_S4	= 	AWSIZE_S4_dma;	 	
			AWBURST_S4	= 	AWBURST_S4_dma;	 	
			AWVALID_S4	= 	AWVALID_S4_dma;	 	
					
			WDATA_S4	= 	WDATA_S4_dma;	 	
			WSTRB_S4	= 	WSTRB_S4_dma;	 	
			WLAST_S4	= 	WLAST_S4_dma;	 	
			WVALID_S4	= 	WVALID_S4_dma;	 	
					
			BREADY_S4	= 	BREADY_S4_dma;	 		
			
			AWID_S5		= 	AWID_S5_dma;		 
			AWADDR_S5	= 	AWADDR_S5_dma;	 	
			AWLEN_S5	= 	AWLEN_S5_dma;	 	
			AWSIZE_S5	= 	AWSIZE_S5_dma;	 	
			AWBURST_S5	= 	AWBURST_S5_dma;	 	
			AWVALID_S5	= 	AWVALID_S5_dma;	 	
					
			WDATA_S5	= 	WDATA_S5_dma;	 	
			WSTRB_S5	= 	WSTRB_S5_dma;	 	
			WLAST_S5	= 	WLAST_S5_dma;	 	
			WVALID_S5	= 	WVALID_S5_dma;	 	
					
			BREADY_S5	= 	BREADY_S5_dma;	 		
			
			AWID_S6		= 	AWID_S6_dma;		 
			AWADDR_S6	= 	AWADDR_S6_dma;	 	
			AWLEN_S6	= 	AWLEN_S6_dma;	 	
			AWSIZE_S6	= 	AWSIZE_S6_dma;	 	
			AWBURST_S6	= 	AWBURST_S6_dma;	 	
			AWVALID_S6	= 	AWVALID_S6_dma;	 	
					
			WDATA_S6	= 	WDATA_S6_dma;	 	
			WSTRB_S6	= 	WSTRB_S6_dma;	 	
			WLAST_S6	= 	WLAST_S6_dma;	 	
			WVALID_S6	= 	WVALID_S6_dma;	 	
					
			BREADY_S6	= 	BREADY_S6_dma;			 		
			
			AWID_S7		= 	AWID_S7_dma;		 
			AWADDR_S7	= 	AWADDR_S7_dma;	 	
			AWLEN_S7	= 	AWLEN_S7_dma;	 	
			AWSIZE_S7	= 	AWSIZE_S7_dma;	 	
			AWBURST_S7	= 	AWBURST_S7_dma;	 	
			AWVALID_S7	= 	AWVALID_S7_dma;	 	
					
			WDATA_S7	= 	WDATA_S7_dma;	 	
			WSTRB_S7	= 	WSTRB_S7_dma;	 	
			WLAST_S7	= 	WLAST_S7_dma;	 	
			WVALID_S7	= 	WVALID_S7_dma;	 	
					
			BREADY_S7	= 	BREADY_S7_dma;	 	 		
			
			AWID_S8		= 	AWID_S8_dma;		 
			AWADDR_S8	= 	AWADDR_S8_dma;	 	
			AWLEN_S8	= 	AWLEN_S8_dma;	 	
			AWSIZE_S8	= 	AWSIZE_S8_dma;	 	
			AWBURST_S8	= 	AWBURST_S8_dma;	 	
			AWVALID_S8	= 	AWVALID_S8_dma;	 	
					
			WDATA_S8	= 	WDATA_S8_dma;	 	
			WSTRB_S8	= 	WSTRB_S8_dma;	 	
			WLAST_S8	= 	WLAST_S8_dma;	 	
			WVALID_S8	= 	WVALID_S8_dma;	 	
					
			BREADY_S8	= 	BREADY_S8_dma;	
		end
		else begin
			AWID_S1		= 	AWID_S1_original;		 
			AWADDR_S1	= 	AWADDR_S1_original;	 	
			AWLEN_S1	= 	AWLEN_S1_original;	 	
			AWSIZE_S1	= 	AWSIZE_S1_original;	 	
			AWBURST_S1	= 	AWBURST_S1_original;	 	
			AWVALID_S1	= 	AWVALID_S1_original;	 	
				
			WDATA_S1	= 	WDATA_S1_original;	 	
			WSTRB_S1	= 	WSTRB_S1_original;	 	
			WLAST_S1	= 	WLAST_S1_original;	 	
			WVALID_S1	= 	WVALID_S1_original;	 	
						
			BREADY_S1	= 	BREADY_S1_original;
			
			AWID_S2		= 	AWID_S2_original;		 
			AWADDR_S2	= 	AWADDR_S2_original;	 	
			AWLEN_S2	= 	AWLEN_S2_original;	 	
			AWSIZE_S2	= 	AWSIZE_S2_original;	 	
			AWBURST_S2	= 	AWBURST_S2_original;	 	
			AWVALID_S2	= 	AWVALID_S2_original;	 	
					
			WDATA_S2	= 	WDATA_S2_original;	 	
			WSTRB_S2	= 	WSTRB_S2_original;	 	
			WLAST_S2	= 	WLAST_S2_original;	 	
			WVALID_S2	= 	WVALID_S2_original;	 	
					
			BREADY_S2	= 	BREADY_S2_original;	 	
			
			AWID_S3		= 	AWID_S3_original;		 
			AWADDR_S3	= 	AWADDR_S3_original;	 	
			AWLEN_S3	= 	AWLEN_S3_original;	 	
			AWSIZE_S3	= 	AWSIZE_S3_original;	 	
			AWBURST_S3	= 	AWBURST_S3_original;	 	
			AWVALID_S3	= 	AWVALID_S3_original;	 	
					
			WDATA_S3	= 	WDATA_S3_original;	 	
			WSTRB_S3	= 	WSTRB_S3_original;	 	
			WLAST_S3	= 	WLAST_S3_original;	 	
			WVALID_S3	= 	WVALID_S3_original;	 	
					
			BREADY_S3	= 	BREADY_S3_original;	 		
			
			AWID_S4		= 	AWID_S4_original;		 
			AWADDR_S4	= 	AWADDR_S4_original;	 	
			AWLEN_S4	= 	AWLEN_S4_original;	 	
			AWSIZE_S4	= 	AWSIZE_S4_original;	 	
			AWBURST_S4	= 	AWBURST_S4_original;	 	
			AWVALID_S4	= 	AWVALID_S4_original;	 	
					
			WDATA_S4	= 	WDATA_S4_original;	 	
			WSTRB_S4	= 	WSTRB_S4_original;	 	
			WLAST_S4	= 	WLAST_S4_original;	 	
			WVALID_S4	= 	WVALID_S4_original;	 	
					
			BREADY_S4	= 	BREADY_S4_original;	 		
			
			AWID_S5		= 	AWID_S5_original;		 
			AWADDR_S5	= 	AWADDR_S5_original;	 	
			AWLEN_S5	= 	AWLEN_S5_original;	 	
			AWSIZE_S5	= 	AWSIZE_S5_original;	 	
			AWBURST_S5	= 	AWBURST_S5_original;	 	
			AWVALID_S5	= 	AWVALID_S5_original;	 	
					
			WDATA_S5	= 	WDATA_S5_original;	 	
			WSTRB_S5	= 	WSTRB_S5_original;	 	
			WLAST_S5	= 	WLAST_S5_original;	 	
			WVALID_S5	= 	WVALID_S5_original;	 	
					
			BREADY_S5	= 	BREADY_S5_original;	 		
			
			AWID_S6		= 	AWID_S6_original;		 
			AWADDR_S6	= 	AWADDR_S6_original;	 	
			AWLEN_S6	= 	AWLEN_S6_original;	 	
			AWSIZE_S6	= 	AWSIZE_S6_original;	 	
			AWBURST_S6	= 	AWBURST_S6_original;	 	
			AWVALID_S6	= 	AWVALID_S6_original;	 	
					
			WDATA_S6	= 	WDATA_S6_original;	 	
			WSTRB_S6	= 	WSTRB_S6_original;	 	
			WLAST_S6	= 	WLAST_S6_original;	 	
			WVALID_S6	= 	WVALID_S6_original;	 	
					
			BREADY_S6	= 	BREADY_S7_original;	 	
			
			AWID_S7		= 	AWID_S7_original;		 
			AWADDR_S7	= 	AWADDR_S7_original;	 	
			AWLEN_S7	= 	AWLEN_S7_original;	 	
			AWSIZE_S7	= 	AWSIZE_S7_original;	 	
			AWBURST_S7	= 	AWBURST_S7_original;	 	
			AWVALID_S7	= 	AWVALID_S7_original;	 	
					
			WDATA_S7	= 	WDATA_S7_original;	 	
			WSTRB_S7	= 	WSTRB_S7_original;	 	
			WLAST_S7	= 	WLAST_S7_original;	 	
			WVALID_S7	= 	WVALID_S7_original;	 	
					
			BREADY_S7	= 	BREADY_S7_original;	 	
			
			AWID_S8		= 	AWID_S8_original;		 
			AWADDR_S8	= 	AWADDR_S8_original;	 	
			AWLEN_S8	= 	AWLEN_S8_original;	 	
			AWSIZE_S8	= 	AWSIZE_S8_original;	 	
			AWBURST_S8	= 	AWBURST_S8_original;	 	
			AWVALID_S8	= 	AWVALID_S8_original;	 	
					
			WDATA_S8	= 	WDATA_S8_original;	 	
			WSTRB_S8	= 	WSTRB_S8_original;	 	
			WLAST_S8	= 	WLAST_S8_original;	 	
			WVALID_S8	= 	WVALID_S8_original;	 	
					
			BREADY_S8	= 	BREADY_S8_original;	 
		end
	end
	CPU_Master: begin
		AWID_S1		= 	AWID_S1_original;		 
		AWADDR_S1	= 	AWADDR_S1_original;	 	
		AWLEN_S1	= 	AWLEN_S1_original;	 	
		AWSIZE_S1	= 	AWSIZE_S1_original;	 	
		AWBURST_S1	= 	AWBURST_S1_original;	 	
		AWVALID_S1	= 	AWVALID_S1_original;	 	
			
		WDATA_S1	= 	WDATA_S1_original;	 	
		WSTRB_S1	= 	WSTRB_S1_original;	 	
		WLAST_S1	= 	WLAST_S1_original;	 	
		WVALID_S1	= 	WVALID_S1_original;	 	
			 	 	
		BREADY_S1	= 	BREADY_S1_original;
		
		AWID_S2		= 	AWID_S2_original;		 
		AWADDR_S2	= 	AWADDR_S2_original;	 	
		AWLEN_S2	= 	AWLEN_S2_original;	 	
		AWSIZE_S2	= 	AWSIZE_S2_original;	 	
		AWBURST_S2	= 	AWBURST_S2_original;	 	
		AWVALID_S2	= 	AWVALID_S2_original;	 	
			 	
		WDATA_S2	= 	WDATA_S2_original;	 	
		WSTRB_S2	= 	WSTRB_S2_original;	 	
		WLAST_S2	= 	WLAST_S2_original;	 	
		WVALID_S2	= 	WVALID_S2_original;	 	
			 	
		BREADY_S2	= 	BREADY_S2_original;	 	
		
		AWID_S3		= 	AWID_S3_original;		 
		AWADDR_S3	= 	AWADDR_S3_original;	 	
		AWLEN_S3	= 	AWLEN_S3_original;	 	
		AWSIZE_S3	= 	AWSIZE_S3_original;	 	
		AWBURST_S3	= 	AWBURST_S3_original;	 	
		AWVALID_S3	= 	AWVALID_S3_original;	 	
			 	
		WDATA_S3	= 	WDATA_S3_original;	 	
		WSTRB_S3	= 	WSTRB_S3_original;	 	
		WLAST_S3	= 	WLAST_S3_original;	 	
		WVALID_S3	= 	WVALID_S3_original;	 	
			 	
		BREADY_S3	= 	BREADY_S3_original;	 		
		
		AWID_S4		= 	AWID_S4_original;		 
		AWADDR_S4	= 	AWADDR_S4_original;	 	
		AWLEN_S4	= 	AWLEN_S4_original;	 	
		AWSIZE_S4	= 	AWSIZE_S4_original;	 	
		AWBURST_S4	= 	AWBURST_S4_original;	 	
		AWVALID_S4	= 	AWVALID_S4_original;	 	
			 	
		WDATA_S4	= 	WDATA_S4_original;	 	
		WSTRB_S4	= 	WSTRB_S4_original;	 	
		WLAST_S4	= 	WLAST_S4_original;	 	
		WVALID_S4	= 	WVALID_S4_original;	 	
			 	
		BREADY_S4	= 	BREADY_S4_original;	 		
		
		AWID_S5		= 	AWID_S5_original;		 
		AWADDR_S5	= 	AWADDR_S5_original;	 	
		AWLEN_S5	= 	AWLEN_S5_original;	 	
		AWSIZE_S5	= 	AWSIZE_S5_original;	 	
		AWBURST_S5	= 	AWBURST_S5_original;	 	
		AWVALID_S5	= 	AWVALID_S5_original;	 	
			 	
		WDATA_S5	= 	WDATA_S5_original;	 	
		WSTRB_S5	= 	WSTRB_S5_original;	 	
		WLAST_S5	= 	WLAST_S5_original;	 	
		WVALID_S5	= 	WVALID_S5_original;	 	
			 	
		BREADY_S5	= 	BREADY_S5_original;	 		
		
		AWID_S6		= 	AWID_S6_original;		 
		AWADDR_S6	= 	AWADDR_S6_original;	 	
		AWLEN_S6	= 	AWLEN_S6_original;	 	
		AWSIZE_S6	= 	AWSIZE_S6_original;	 	
		AWBURST_S6	= 	AWBURST_S6_original;	 	
		AWVALID_S6	= 	AWVALID_S6_original;	 	
			 	
		WDATA_S6	= 	WDATA_S6_original;	 	
		WSTRB_S6	= 	WSTRB_S6_original;	 	
		WLAST_S6	= 	WLAST_S6_original;	 	
		WVALID_S6	= 	WVALID_S6_original;	 	
			 	
		BREADY_S6	= 	BREADY_S6_original;	 		
		
		AWID_S7		= 	AWID_S7_original;		 
		AWADDR_S7	= 	AWADDR_S7_original;	 	
		AWLEN_S7	= 	AWLEN_S7_original;	 	
		AWSIZE_S7	= 	AWSIZE_S7_original;	 	
		AWBURST_S7	= 	AWBURST_S7_original;	 	
		AWVALID_S7	= 	AWVALID_S7_original;	 	
			 	
		WDATA_S7	= 	WDATA_S7_original;	 	
		WSTRB_S7	= 	WSTRB_S7_original;	 	
		WLAST_S7	= 	WLAST_S7_original;	 	
		WVALID_S7	= 	WVALID_S7_original;	 	
			 	
		BREADY_S7	= 	BREADY_S7_original;			
		
		AWID_S8		= 	AWID_S8_original;		 
		AWADDR_S8	= 	AWADDR_S8_original;	 	
		AWLEN_S8	= 	AWLEN_S8_original;	 	
		AWSIZE_S8	= 	AWSIZE_S8_original;	 	
		AWBURST_S8	= 	AWBURST_S8_original;	 	
		AWVALID_S8	= 	AWVALID_S8_original;	 	
			 	
		WDATA_S8	= 	WDATA_S8_original;	 	
		WSTRB_S8	= 	WSTRB_S8_original;	 	
		WLAST_S8	= 	WLAST_S8_original;	 	
		WVALID_S8	= 	WVALID_S8_original;	 	
			 	
		BREADY_S8	= 	BREADY_S8_original;	  
	end
	DMA_Master:begin
		AWID_S1		= 	AWID_S1_dma;		 
		AWADDR_S1	= 	AWADDR_S1_dma;	 	
		AWLEN_S1	= 	AWLEN_S1_dma;	 	
		AWSIZE_S1	= 	AWSIZE_S1_dma;	 	
		AWBURST_S1	= 	AWBURST_S1_dma;	 	
		AWVALID_S1	= 	AWVALID_S1_dma;	 	
			
		WDATA_S1	= 	WDATA_S1_dma;	 	
		WSTRB_S1	= 	WSTRB_S1_dma;	 	
		WLAST_S1	= 	WLAST_S1_dma;	 	
		WVALID_S1	= 	WVALID_S1_dma;	 	
			 	 	
		BREADY_S1	= 	BREADY_S1_dma;
		
		AWID_S2		= 	AWID_S2_dma;		 
		AWADDR_S2	= 	AWADDR_S2_dma;	 	
		AWLEN_S2	= 	AWLEN_S2_dma;	 	
		AWSIZE_S2	= 	AWSIZE_S2_dma;	 	
		AWBURST_S2	= 	AWBURST_S2_dma;	 	
		AWVALID_S2	= 	AWVALID_S2_dma;	 	
			 	
		WDATA_S2	= 	WDATA_S2_dma;	 	
		WSTRB_S2	= 	WSTRB_S2_dma;	 	
		WLAST_S2	= 	WLAST_S2_dma;	 	
		WVALID_S2	= 	WVALID_S2_dma;	 	
			 	
		BREADY_S2	= 	BREADY_S2_dma;	 	
		
		AWID_S3		= 	AWID_S3_dma;		 
		AWADDR_S3	= 	AWADDR_S3_dma;	 	
		AWLEN_S3	= 	AWLEN_S3_dma;	 	
		AWSIZE_S3	= 	AWSIZE_S3_dma;	 	
		AWBURST_S3	= 	AWBURST_S3_dma;	 	
		AWVALID_S3	= 	AWVALID_S3_dma;	 	
			 	
		WDATA_S3	= 	WDATA_S3_dma;	 	
		WSTRB_S3	= 	WSTRB_S3_dma;	 	
		WLAST_S3	= 	WLAST_S3_dma;	 	
		WVALID_S3	= 	WVALID_S3_dma;	 	
			 	
		BREADY_S3	= 	BREADY_S3_dma;	 		
		
		AWID_S4		= 	AWID_S4_dma;		 
		AWADDR_S4	= 	AWADDR_S4_dma;	 	
		AWLEN_S4	= 	AWLEN_S4_dma;	 	
		AWSIZE_S4	= 	AWSIZE_S4_dma;	 	
		AWBURST_S4	= 	AWBURST_S4_dma;	 	
		AWVALID_S4	= 	AWVALID_S4_dma;	 	
			 	
		WDATA_S4	= 	WDATA_S4_dma;	 	
		WSTRB_S4	= 	WSTRB_S4_dma;	 	
		WLAST_S4	= 	WLAST_S4_dma;	 	
		WVALID_S4	= 	WVALID_S4_dma;	 	
			 	
		BREADY_S4	= 	BREADY_S4_dma;	 		
		
		AWID_S5		= 	AWID_S5_dma;		 
		AWADDR_S5	= 	AWADDR_S5_dma;	 	
		AWLEN_S5	= 	AWLEN_S5_dma;	 	
		AWSIZE_S5	= 	AWSIZE_S5_dma;	 	
		AWBURST_S5	= 	AWBURST_S5_dma;	 	
		AWVALID_S5	= 	AWVALID_S5_dma;	 	
			 	
		WDATA_S5	= 	WDATA_S5_dma;	 	
		WSTRB_S5	= 	WSTRB_S5_dma;	 	
		WLAST_S5	= 	WLAST_S5_dma;	 	
		WVALID_S5	= 	WVALID_S5_dma;	 	
			 	
		BREADY_S5	= 	BREADY_S5_dma;	 		
		
		AWID_S6		= 	AWID_S6_dma;		 
		AWADDR_S6	= 	AWADDR_S6_dma;	 	
		AWLEN_S6	= 	AWLEN_S6_dma;	 	
		AWSIZE_S6	= 	AWSIZE_S6_dma;	 	
		AWBURST_S6	= 	AWBURST_S6_dma;	 	
		AWVALID_S6	= 	AWVALID_S6_dma;	 	
			 	
		WDATA_S6	= 	WDATA_S6_dma;	 	
		WSTRB_S6	= 	WSTRB_S6_dma;	 	
		WLAST_S6	= 	WLAST_S6_dma;	 	
		WVALID_S6	= 	WVALID_S6_dma;	 	
			 	
		BREADY_S6	= 	BREADY_S6_dma;	 		
		
		AWID_S7		= 	AWID_S7_dma;		 
		AWADDR_S7	= 	AWADDR_S7_dma;	 	
		AWLEN_S7	= 	AWLEN_S7_dma;	 	
		AWSIZE_S7	= 	AWSIZE_S7_dma;	 	
		AWBURST_S7	= 	AWBURST_S7_dma;	 	
		AWVALID_S7	= 	AWVALID_S7_dma;	 	
			 	
		WDATA_S7	= 	WDATA_S7_dma;	 	
		WSTRB_S7	= 	WSTRB_S7_dma;	 	
		WLAST_S7	= 	WLAST_S7_dma;	 	
		WVALID_S7	= 	WVALID_S7_dma;	 	
			 	
		BREADY_S7	= 	BREADY_S7_dma;  		
		
		AWID_S8		= 	AWID_S8_dma;		 
		AWADDR_S8	= 	AWADDR_S8_dma;	 	
		AWLEN_S8	= 	AWLEN_S8_dma;	 	
		AWSIZE_S8	= 	AWSIZE_S8_dma;	 	
		AWBURST_S8	= 	AWBURST_S8_dma;	 	
		AWVALID_S8	= 	AWVALID_S8_dma;	 	
			 	
		WDATA_S8	= 	WDATA_S8_dma;	 	
		WSTRB_S8	= 	WSTRB_S8_dma;	 	
		WLAST_S8	= 	WLAST_S8_dma;	 	
		WVALID_S8	= 	WVALID_S8_dma;	 	
			 	
		BREADY_S8	= 	BREADY_S8_dma;
	end
	default:begin
		AWID_S1		= 	AWID_S1_original;		 
		AWADDR_S1	= 	AWADDR_S1_original;	 	
		AWLEN_S1	= 	AWLEN_S1_original;	 	
		AWSIZE_S1	= 	AWSIZE_S1_original;	 	
		AWBURST_S1	= 	AWBURST_S1_original;	 	
		AWVALID_S1	= 	AWVALID_S1_original;	 	
			
		WDATA_S1	= 	WDATA_S1_original;	 	
		WSTRB_S1	= 	WSTRB_S1_original;	 	
		WLAST_S1	= 	WLAST_S1_original;	 	
		WVALID_S1	= 	WVALID_S1_original;	 	
			 	 	
		BREADY_S1	= 	BREADY_S1_original;
		
		AWID_S2		= 	AWID_S2_original;		 
		AWADDR_S2	= 	AWADDR_S2_original;	 	
		AWLEN_S2	= 	AWLEN_S2_original;	 	
		AWSIZE_S2	= 	AWSIZE_S2_original;	 	
		AWBURST_S2	= 	AWBURST_S2_original;	 	
		AWVALID_S2	= 	AWVALID_S2_original;	 	
			 	
		WDATA_S2	= 	WDATA_S2_original;	 	
		WSTRB_S2	= 	WSTRB_S2_original;	 	
		WLAST_S2	= 	WLAST_S2_original;	 	
		WVALID_S2	= 	WVALID_S2_original;	 	
			 	
		BREADY_S2	= 	BREADY_S2_original;	 	
		
		AWID_S3		= 	AWID_S3_original;		 
		AWADDR_S3	= 	AWADDR_S3_original;	 	
		AWLEN_S3	= 	AWLEN_S3_original;	 	
		AWSIZE_S3	= 	AWSIZE_S3_original;	 	
		AWBURST_S3	= 	AWBURST_S3_original;	 	
		AWVALID_S3	= 	AWVALID_S3_original;	 	
			 	
		WDATA_S3	= 	WDATA_S3_original;	 	
		WSTRB_S3	= 	WSTRB_S3_original;	 	
		WLAST_S3	= 	WLAST_S3_original;	 	
		WVALID_S3	= 	WVALID_S3_original;	 	
			 	
		BREADY_S3	= 	BREADY_S3_original;	 		
		
		AWID_S4		= 	AWID_S4_original;		 
		AWADDR_S4	= 	AWADDR_S4_original;	 	
		AWLEN_S4	= 	AWLEN_S4_original;	 	
		AWSIZE_S4	= 	AWSIZE_S4_original;	 	
		AWBURST_S4	= 	AWBURST_S4_original;	 	
		AWVALID_S4	= 	AWVALID_S4_original;	 	
			 	
		WDATA_S4	= 	WDATA_S4_original;	 	
		WSTRB_S4	= 	WSTRB_S4_original;	 	
		WLAST_S4	= 	WLAST_S4_original;	 	
		WVALID_S4	= 	WVALID_S4_original;	 	
			 	
		BREADY_S4	= 	BREADY_S4_original;	 		
		
		AWID_S5		= 	AWID_S5_original;		 
		AWADDR_S5	= 	AWADDR_S5_original;	 	
		AWLEN_S5	= 	AWLEN_S5_original;	 	
		AWSIZE_S5	= 	AWSIZE_S5_original;	 	
		AWBURST_S5	= 	AWBURST_S5_original;	 	
		AWVALID_S5	= 	AWVALID_S5_original;	 	
			 	
		WDATA_S5	= 	WDATA_S5_original;	 	
		WSTRB_S5	= 	WSTRB_S5_original;	 	
		WLAST_S5	= 	WLAST_S5_original;	 	
		WVALID_S5	= 	WVALID_S5_original;	 	
			 	
		BREADY_S5	= 	BREADY_S5_original;	 		
		
		AWID_S6		= 	AWID_S6_original;		 
		AWADDR_S6	= 	AWADDR_S6_original;	 	
		AWLEN_S6	= 	AWLEN_S6_original;	 	
		AWSIZE_S6	= 	AWSIZE_S6_original;	 	
		AWBURST_S6	= 	AWBURST_S6_original;	 	
		AWVALID_S6	= 	AWVALID_S6_original;	 	
			 	
		WDATA_S6	= 	WDATA_S6_original;	 	
		WSTRB_S6	= 	WSTRB_S6_original;	 	
		WLAST_S6	= 	WLAST_S6_original;	 	
		WVALID_S6	= 	WVALID_S6_original;	 	
			 	
		BREADY_S6	= 	BREADY_S6_original;	 		
		
		AWID_S7		= 	AWID_S7_original;		 
		AWADDR_S7	= 	AWADDR_S7_original;	 	
		AWLEN_S7	= 	AWLEN_S7_original;	 	
		AWSIZE_S7	= 	AWSIZE_S7_original;	 	
		AWBURST_S7	= 	AWBURST_S7_original;	 	
		AWVALID_S7	= 	AWVALID_S7_original;	 	
			 	
		WDATA_S7	= 	WDATA_S7_original;	 	
		WSTRB_S7	= 	WSTRB_S7_original;	 	
		WLAST_S7	= 	WLAST_S7_original;	 	
		WVALID_S7	= 	WVALID_S7_original;	 	
			 	
		BREADY_S7	= 	BREADY_S7_original;	 		
		
		AWID_S8		= 	AWID_S8_original;		 
		AWADDR_S8	= 	AWADDR_S8_original;	 	
		AWLEN_S8	= 	AWLEN_S8_original;	 	
		AWSIZE_S8	= 	AWSIZE_S8_original;	 	
		AWBURST_S8	= 	AWBURST_S8_original;	 	
		AWVALID_S8	= 	AWVALID_S8_original;	 	
			 	
		WDATA_S8	= 	WDATA_S8_original;	 	
		WSTRB_S8	= 	WSTRB_S8_original;	 	
		WLAST_S8	= 	WLAST_S8_original;	 	
		WVALID_S8	= 	WVALID_S8_original;	 	
			 	
		BREADY_S8	= 	BREADY_S8_original;	 
	end
	endcase
end


endmodule
