// `include "Master_Monitor.sv"
`ifndef AXI_DEFINITION
`define AXI_DEFINITION
`include "AXI_define.svh"
`endif
module out_SRAM_Wrapper_epu (
  input   CLK,
  input   RSTn,
  
  //for AXI port
  input   [`AXI_IDS_BITS-1:0]           ARID,
  input   [`AXI_ADDR_BITS-1:0]          ARADDR,
  input   [`AXI_LEN_BITS-1:0]           ARLEN,
  input   [`AXI_SIZE_BITS-1:0]          ARSIZE,
  input   [1:0]                         ARBURST,
  input                                 ARVALID,
  output  logic                         ARREADY,

  output  logic   [`AXI_IDS_BITS-1:0]   RID,
  output  logic   [`AXI_DATA_BITS-1:0]  RDATA,
  output  logic   [1:0]                 RRESP,
  output  logic                         RLAST,
  output  logic                         RVALID,
  input                                 RREADY,

  input   [`AXI_IDS_BITS-1:0]           AWID,
  input   [`AXI_ADDR_BITS-1:0]          AWADDR,
  input   [`AXI_LEN_BITS-1:0]           AWLEN,
  input   [`AXI_SIZE_BITS-1:0]          AWSIZE,
  input   [1:0]                         AWBURST,
  input                                 AWVALID,
  output  logic                         AWREADY,

  input   [`AXI_DATA_BITS-1:0]          WDATA,
  input   [`AXI_STRB_BITS-1:0]          WSTRB,
  input                                 WLAST,
  input                                 WVALID,
  output  logic                         WREADY,

  output  logic   [`AXI_IDS_BITS-1:0]   BID,
  output  logic   [1:0]                 BRESP,
  output  logic                         BVALID,
  input                                 BREADY,

  //for EPU port
  input     logic [11:0]                A_epu,
  input     logic [3:0]                 WEB_epu,
  input     logic [31:0]                DI_epu,
  input     logic                       end_signal,
  input     logic                       start_signal
);
    logic [3:0]     WEB_axi ;
    logic [11:0]    A   , A_axi   ;
    logic [31:0]   DI  , DI_axi   ;
    logic [31:0]   DO  , DO_axi  , DO_epu ;
    logic WEB;

    
    //FSM for AXI or EPU
    localparam AXI_state=1'b0;
    localparam EPU_state=1'b1;

    logic state, nstate;

    logic [13:0] A_axi_wire;
    assign A_axi=A_axi_wire[11:0];

    always_ff@(posedge CLK or negedge RSTn) begin 
        if(~RSTn) state<=EPU_state;
        else state<=nstate;
    end
    always_comb begin
        case(state)
        EPU_state:begin
            if(end_signal) nstate=AXI_state; //from epu all last signal
            else nstate=EPU_state;
        end
        AXI_state:begin
            if(start_signal) nstate=EPU_state;
            else nstate=AXI_state;
        end
        endcase
    end
    always_comb begin
        case(state)
        AXI_state:begin
            WEB = (WEB_axi==4'b0000)?1'b0:1'b1;
            A   = A_axi  ;
            DI  = DI_axi ;
            DO_axi  = DO ;
            DO_epu  = 32'b0 ;
        end
        EPU_state:begin
            WEB = (WEB_epu==4'b0000)?1'b0:1'b1;
            A   = A_epu  ;
            DI  = DI_epu ;
            DO_epu  = DO ;
            DO_axi  = 32'b0 ;
        end
        endcase
    end

    Master_Monitor Monitor (
        .CLK(CLK),
        .RSTn(RSTn),

        .ARID(ARID),
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),

        .RID(RID),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RLAST(RLAST),
        .RVALID(RVALID),
        .RREADY(RREADY),

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

        .SRAM_WEB(WEB_axi),
        .SRAM_A(A_axi_wire),
        .SRAM_DI(DI_axi),
        .SRAM_DO(DO_axi)
    );

    // 32 bit SRAM
// OUTPUT_SRAM i_output_sram(
//     .CK (CLK),
//     .CS (1'b1),
//     .OE (1'b1),
//     .WEB  (WEB),
//     .A0   (A[0]),
//     .A1   (A[1]),
//     .A2   (A[2]),
//     .A3   (A[3]),
//     .A4   (A[4]),
//     .A5   (A[5]),
//     .A6   (A[6]),
//     .A7   (A[7]),
//     .A8   (A[8]),
//     .DI0  (DI[0]),
//     .DI1  (DI[1]),
//     .DI2  (DI[2]),
//     .DI3  (DI[3]),
//     .DI4  (DI[4]),
//     .DI5  (DI[5]),
//     .DI6  (DI[6]),
//     .DI7  (DI[7]),
//     .DI8  (DI[8]),
//     .DI9  (DI[9]),
//     .DI10  (DI[10]),
//     .DI11  (DI[11]),
//     .DI12  (DI[12]),
//     .DI13  (DI[13]),
//     .DI14  (DI[14]),
//     .DI15  (DI[15]),
//     .DI16  (DI[16]),
//     .DI17  (DI[17]),
//     .DI18  (DI[18]),
//     .DI19  (DI[19]),
//     .DI20  (DI[20]),
//     .DI21  (DI[21]),
//     .DI22  (DI[22]),
//     .DI23  (DI[23]),
//     .DI24  (DI[24]),
//     .DI25  (DI[25]),
//     .DI26  (DI[26]),
//     .DI27  (DI[27]),
//     .DI28  (DI[28]),
//     .DI29  (DI[29]),
//     .DI30  (DI[30]),
//     .DI31  (DI[31]),
//     .DO0  (DO[0]),
//     .DO1  (DO[1]),
//     .DO2  (DO[2]),
//     .DO3  (DO[3]),
//     .DO4  (DO[4]),
//     .DO5  (DO[5]),
//     .DO6  (DO[6]),
//     .DO7  (DO[7]),
//     .DO8  (DO[8]),
//     .DO9  (DO[9]),
//     .DO10  (DO[10]),
//     .DO11  (DO[11]),
//     .DO12  (DO[12]),
//     .DO13  (DO[13]),
//     .DO14  (DO[14]),
//     .DO15  (DO[15]),
//     .DO16  (DO[16]),
//     .DO17  (DO[17]),
//     .DO18  (DO[18]),
//     .DO19  (DO[19]),
//     .DO20  (DO[20]),
//     .DO21  (DO[21]),
//     .DO22  (DO[22]),
//     .DO23  (DO[23]),
//     .DO24  (DO[24]),
//     .DO25  (DO[25]),
//     .DO26  (DO[26]),
//     .DO27  (DO[27]),
//     .DO28  (DO[28]),
//     .DO29  (DO[29]),
//     .DO30  (DO[30]),
//     .DO31  (DO[31])
// );

SRAM i_output_sram (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (1'b0 ),
    .A13  (1'b0 ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (CLK   ),
    .WEB0 (WEB),
    .WEB1 (WEB),
    .WEB2 (WEB),
    .WEB3 (WEB),
    .OE   (1'b1  ),
    .CS   (1'b1  )
  );

endmodule
