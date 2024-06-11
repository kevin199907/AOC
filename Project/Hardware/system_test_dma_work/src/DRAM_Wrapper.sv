`ifndef AXI_DEFINITION
`define AXI_DEFINITION
`include "../include/AXI_define.svh"
`endif
module DRAM_Wrapper (
    input                               CLK,
    input                               RSTn,

    // Belows are ports connect to DRAM
    output  logic                       CSn,
    output  logic [3:0]                 WEn,
    output  logic                       RASn,
    output  logic                       CASn,
    output  logic [10:0]                A,
    output  logic [31:0]                D,
    input                               VALID,
    input   [31:0]                      Q,
    // Aboves are ports connect to DRAM

    // Belows are ports connect to AXI
    // AW channel
    input   [`AXI_IDS_BITS-1:0]         AWID,
    input   [`AXI_ADDR_BITS-1:0]        AWADDR,
    input   [`AXI_LEN_BITS-1:0]         AWLEN,
    input   [`AXI_SIZE_BITS-1:0]        AWSIZE,
    input   [1:0]                       AWBURST,
    input                               AWVALID,
    output  logic                       AWREADY,
    // W channel
    input   [`AXI_DATA_BITS-1:0]        WDATA,
    input   [`AXI_STRB_BITS-1:0]        WSTRB,
    input                               WLAST,
    input                               WVALID,
    output  logic                       WREADY,
    // B channel
    output  logic [`AXI_IDS_BITS-1:0]   BID,
    output  logic [1:0]                 BRESP,
    output  logic                       BVALID,
    input                               BREADY,
    // AR channel
    input   [`AXI_IDS_BITS-1:0]         ARID,
    input   [`AXI_ADDR_BITS-1:0]        ARADDR,
    input   [`AXI_LEN_BITS-1:0]         ARLEN,
    input   [`AXI_SIZE_BITS-1:0]        ARSIZE,
    input   [1:0]                       ARBURST,
    input                               ARVALID,
    output  logic                       ARREADY,
    // R channel
    output  logic [`AXI_IDS_BITS-1:0]   RID,
    output  logic [`AXI_DATA_BITS-1:0]  RDATA,
    output  logic [1:0]                 RRESP,
    output  logic                       RLAST,
    output  logic                       RVALID,
    input                               RREADY
    // Aboves are ports connect to AXI
);

parameter FIXED = 2'b00;
parameter INCR  = 2'b01;
parameter WRAP  = 2'b10;

parameter CYCLE_COUNT_EXCEED = 3'b100;
logic WRITE_ISSUE, READ_ISSUE;
assign CSn = 1'b0;


/*
|---------------------------|
|                           |
| AXI interface controlling |
|                           |
|---------------------------|
*/
logic WRITE_RECEIVE;
logic [2:0]     DRAM_CS, DRAM_NS;
logic [10:0]    Last_Access_Row, Current_Access_Row, Current_Access_Col;
logic           Count_Meet;
logic [2:0]     Cycle_Counter;

parameter DRAM_RST0  = 3'b000;
parameter DRAM_RST1  = 3'b001;
parameter DRAM_RST2  = 3'b010;
parameter DRAM_ACT   = 3'b011;
parameter DRAM_IDLE  = 3'b100;
parameter DRAM_READ  = 3'b101;
parameter DRAM_WRITE = 3'b110;
parameter DRAM_PRE   = 3'b111;



logic   [1:0]   WRAPPER_MODE, WRAPPER_MODE_NEXT;
logic   READ_STALL;
assign  READ_STALL = RVALID & (~RREADY);// if already valid but not ready, wrapper need to stall to wait
parameter IDLE_MODE  = 2'b00;// IDLE_MODE can be seen as AR & AW mode
parameter READ_MODE  = 2'b01;
parameter WRITE_MODE = 2'b10;
parameter RESP_MODE  = 2'b11;

logic   [`AXI_IDS_BITS-1:0]     WRAPPER_AWID, WRAPPER_ARID;
logic   [`AXI_ADDR_BITS-1:0]    WRAPPER_AWADDR, WRAPPER_ARADDR;
logic   [`AXI_LEN_BITS-1:0]     WRAPPER_AWLEN, WRAPPER_ARLEN;
logic   [`AXI_SIZE_BITS-1:0]    WRAPPER_AWSIZE, WRAPPER_ARSIZE;
logic   [1:0]                   WRAPPER_AWBURST, WRAPPER_ARBURST;

logic   [`AXI_DATA_BITS-1:0]    WRAPPER_WDATA;
logic   [`AXI_STRB_BITS-1:0]    WRAPPER_WSTRB;
logic                           WRAPPER_WLAST;

logic   [`AXI_LEN_BITS-1:0] Burst_Counter;
// WRAPPER_State_Transfer finish
// WRAPPER_State_Transfer is the flip-flop transfer the Wrapper's state
always_ff @( posedge CLK or negedge RSTn ) begin : WRAPPER_State_Transfer
    unique if (~RSTn) begin
        WRAPPER_MODE <= IDLE_MODE;
    end
    else begin
        WRAPPER_MODE <= WRAPPER_MODE_NEXT;
    end
end
// Write_Request_Recorder finish
// Write_Request_Recorder record the write request, if write request pull and read finish then go to write
logic   Write_Request;
always_ff @( posedge CLK or negedge RSTn ) begin : Write_Request_Recorder
    unique if (~RSTn) begin
        Write_Request <= 1'b0;
    end
    else begin
        unique case(WRAPPER_MODE)
        IDLE_MODE:begin
            Write_Request <= AWVALID & AWREADY;
        end
        WRITE_MODE:begin
            Write_Request <= (WVALID & WREADY & WLAST)? 1'b0 : Write_Request;
        end
        default:begin
            Write_Request <= Write_Request;
        end
        endcase
    end
end
always_ff @( posedge CLK or negedge RSTn ) begin : WRITE_RECEIVER
    unique if (~RSTn) begin
        WRITE_RECEIVE <= 1'b0;
    end
    else begin
        unique if (WVALID & WREADY) begin
            WRITE_RECEIVE <= 1'b1;
        end
        else begin
            WRITE_RECEIVE <= (DRAM_CS == DRAM_WRITE & DRAM_NS == DRAM_IDLE)? 1'b0 : WRITE_RECEIVE;
        end
    end
end


// Wrapper_State_Predictor finish
// Wrapper_State_Predictor decide what is next state of wrapper
always_comb begin : Wrapper_State_Predictor
    unique case (WRAPPER_MODE)
    IDLE_MODE:begin
        unique case ({AWVALID & AWREADY, ARVALID & ARREADY})
        2'b00:begin
            WRAPPER_MODE_NEXT = IDLE_MODE;
        end
        2'b01:begin
            WRAPPER_MODE_NEXT = READ_MODE;
        end
        2'b10:begin
            WRAPPER_MODE_NEXT = (WVALID & WREADY & WLAST)? RESP_MODE : WRITE_MODE;
        end
        2'b11:begin// if write and read both shakehand, do read first
            WRAPPER_MODE_NEXT = READ_MODE;
        end
        endcase
    end
    READ_MODE:begin
        unique if (RVALID & RREADY & RLAST)begin
            WRAPPER_MODE_NEXT = (Write_Request)? WRITE_MODE : IDLE_MODE;
        end
        else begin
            WRAPPER_MODE_NEXT = READ_MODE;
        end
    end
    WRITE_MODE:begin
        unique if (WREADY & WVALID & WLAST)begin
            WRAPPER_MODE_NEXT = RESP_MODE;
        end
        else begin
            WRAPPER_MODE_NEXT = WRITE_MODE;
        end
    end
    default:begin// RESP_MODE
        unique if (BVALID & BREADY)begin
            WRAPPER_MODE_NEXT = IDLE_MODE;
        end
        else begin
            WRAPPER_MODE_NEXT = RESP_MODE;
        end
    end
    endcase
end



// AW_Channel_FF record the value on bus when Address Write channel shakehand
always_ff @( posedge CLK or negedge RSTn ) begin : AW_Channel_FF
    unique if (~RSTn) begin
        WRAPPER_AWID    <= 8'b0;
        WRAPPER_AWADDR  <= 32'b0;
        WRAPPER_AWLEN   <= `AXI_LEN_ONE;
        WRAPPER_AWSIZE  <= `AXI_SIZE_WORD;
        WRAPPER_AWBURST <= `AXI_BURST_INC;
    end
    else begin
        WRAPPER_AWID    <= (AWVALID & AWREADY)? AWID    : WRAPPER_AWID;
        WRAPPER_AWADDR  <= (AWVALID & AWREADY)? AWADDR  : WRAPPER_AWADDR;
        WRAPPER_AWLEN   <= (AWVALID & AWREADY)? AWLEN   : WRAPPER_AWLEN;
        WRAPPER_AWSIZE  <= (AWVALID & AWREADY)? AWSIZE  : WRAPPER_AWSIZE;
        WRAPPER_AWBURST <= (AWVALID & AWREADY)? AWBURST : WRAPPER_AWBURST;
    end
end
// W_Channel_FF record the value on bus when Write channel shakehand
always_ff @( posedge CLK or negedge RSTn ) begin : W_Channel_FF
    unique if (~RSTn) begin
        WRAPPER_WDATA <= 32'b0;
        WRAPPER_WSTRB <= 4'b0;
        WRAPPER_WLAST <= 1'b0;
    end
    else begin
        WRAPPER_WDATA <= (WVALID & WREADY)? WDATA : WRAPPER_WDATA;
        WRAPPER_WSTRB <= WSTRB;//(WVALID & WREADY)? WSTRB : WRAPPER_WSTRB;
        WRAPPER_WLAST <= (WVALID & WREADY)? WLAST : WRAPPER_WLAST;
    end
end
// AR_Channel_FF record the value on bus when Address Write channel shakehand
always_ff @( posedge CLK or negedge RSTn ) begin : AR_Channel_FF
    unique if (~RSTn) begin
        WRAPPER_ARID    <= 8'b0;
        WRAPPER_ARADDR  <= 32'b0;
        WRAPPER_ARLEN   <= `AXI_LEN_ONE;
        WRAPPER_ARSIZE  <= `AXI_SIZE_WORD;
        WRAPPER_ARBURST <= `AXI_BURST_INC;
    end
    else begin
        WRAPPER_ARID    <= (ARVALID & ARREADY)? ARID    : WRAPPER_ARID;
        WRAPPER_ARADDR  <= (ARVALID & ARREADY)? ARADDR  : WRAPPER_ARADDR;
        WRAPPER_ARLEN   <= (ARVALID & ARREADY)? ARLEN   : WRAPPER_ARLEN;
        WRAPPER_ARSIZE  <= (ARVALID & ARREADY)? ARSIZE  : WRAPPER_ARSIZE;
        WRAPPER_ARBURST <= (ARVALID & ARREADY)? ARBURST : WRAPPER_ARBURST;
    end
end


logic   [`AXI_ADDR_BITS-1:0]    WADDR_INCR;
logic   [`AXI_ADDR_BITS-1:0]    WADDR_Captured;
logic   [`AXI_ADDR_BITS-1:0]    RADDR_INCR;

// WRITE_ADDR_INCR finish
// WRITE_ADDR_INCR control the write address of increment type
always_ff @( posedge CLK or negedge RSTn ) begin : WRITE_ADDR_INCR
    unique if (~RSTn) begin
        WADDR_INCR      <= 32'b0;
        WADDR_Captured  <= 32'b0;
    end
    else begin
        if ((WVALID & WREADY) | (DRAM_CS == DRAM_WRITE) & (~CASn)) begin
            unique case (WRAPPER_AWBURST)
            FIXED:  WADDR_Captured <= WRAPPER_AWADDR;
            INCR:   WADDR_Captured <= WADDR_INCR;
            WRAP:   WADDR_Captured <= WADDR_INCR;
            default:WADDR_Captured <= WADDR_INCR;
            endcase
        end
        else begin
            WADDR_Captured <= WADDR_Captured;
        end

        unique case (WRAPPER_MODE)
        IDLE_MODE:begin
            WADDR_INCR  <= (AWVALID & AWREADY)? AWADDR : 32'b0;
        end
        WRITE_MODE:begin
            WADDR_INCR  <= ((DRAM_CS == DRAM_WRITE) & (~CASn))? (WADDR_INCR + ((32'b1) << 2)) : WADDR_INCR;
        end
        default:begin
            WADDR_INCR  <= WADDR_INCR;
        end
        endcase
    end
end
// READ_ADDR_INCR finish
// READ_ADDR_INCR control the read address of increment type
always_ff @( posedge CLK or negedge RSTn ) begin : READ_ADDR_INCR
    unique if (~RSTn) begin
        RADDR_INCR  <= 32'b0;
    end
    else begin
        unique case (WRAPPER_MODE)
        IDLE_MODE:begin
            RADDR_INCR  <= (ARVALID & ARREADY)? ARADDR : RADDR_INCR;
        end
        READ_MODE:begin
            RADDR_INCR  <= (RVALID & RREADY)? (RADDR_INCR + ((32'b1)<<WRAPPER_ARSIZE)) : RADDR_INCR;
        end
        default:begin
            RADDR_INCR  <= RADDR_INCR;
        end
        endcase
    end
end
// Burst_counting count the burst and find wheen will stop the burst
always_ff @( posedge CLK or negedge RSTn ) begin : Burst_counting
    unique if (~RSTn) begin
        Burst_Counter <= 4'b0;
    end
    else begin
        unique case (WRAPPER_MODE)
        READ_MODE:  Burst_Counter <= (RVALID & RREADY)? Burst_Counter + 4'b1 : Burst_Counter;
        default:    Burst_Counter <= 4'b0;
        endcase
    end
end

// Wrapper_AXI_Siganls
// Wrapper_AXI_Siganls provide different signals when different state
logic   DRAM_WRITE_REQUEST;
logic   DRAM_READ_REQUEST;
always_ff @( posedge CLK or negedge RSTn ) begin : Wrapper_AXI_Siganls
    unique if (~RSTn) begin
        ARREADY <= 1'b0;
        AWREADY <= 1'b0;
        WREADY  <= 1'b0;
        BVALID  <= 1'b0;

        RID     <= 8'b0;

        BID     <= 8'b0;
        BRESP   <= `AXI_RESP_SLVERR;
        WRITE_ISSUE <= 1'b0;
        READ_ISSUE  <= 1'b0;
    end
    else begin
        unique case(WRAPPER_MODE)
        IDLE_MODE:begin
            ARREADY <= (ARREADY & ARVALID)? 1'b0 : (~READ_ISSUE);
            AWREADY <= (AWREADY & AWVALID)? 1'b0 : (~WRITE_RECEIVE)&(~WRITE_ISSUE);
            WREADY  <= 1'b0;//(WREADY & WVALID)? 1'b0 : (~WRITE_RECEIVE);
            BVALID  <= 1'b0;

            RID     <= 8'b0;

            BID     <= 8'b0;
            BRESP   <= `AXI_RESP_SLVERR;

            WRITE_ISSUE <= (AWREADY & AWVALID)? 1'b1 : (((DRAM_CS == DRAM_WRITE) & (~CASn) & WRAPPER_WLAST & (Last_Access_Row == Current_Access_Row))? 1'b0 : WRITE_ISSUE);
            READ_ISSUE  <= (ARREADY & ARVALID)? 1'b1 : READ_ISSUE;
        end
        READ_MODE:begin
            ARREADY <= 1'b0;
            AWREADY <= 1'b0;
            WREADY  <= 1'b0;
            BVALID  <= 1'b0;

            RID     <= WRAPPER_ARID;

            BID     <= 8'b0;
            BRESP   <= `AXI_RESP_SLVERR;

            WRITE_ISSUE <= ((DRAM_CS == DRAM_WRITE) & (~CASn) & WRAPPER_WLAST & (Last_Access_Row == Current_Access_Row))? 1'b0 : WRITE_ISSUE;
            READ_ISSUE  <= (RVALID & RREADY & RLAST)? 1'b0 : READ_ISSUE;
        end
        WRITE_MODE:begin
            ARREADY <= 1'b0;
            AWREADY <= 1'b0;
            WREADY  <= (WREADY & WVALID)? 1'b0 : (~WRITE_RECEIVE);
            BVALID  <= (WVALID & WREADY & WLAST);

            RID     <= 8'h0;

            BID     <= WRAPPER_AWID;
            BRESP   <= `AXI_RESP_SLVERR;

            WRITE_ISSUE <= ((DRAM_CS == DRAM_WRITE) & (~CASn) & WRAPPER_WLAST & (Last_Access_Row == Current_Access_Row))? 1'b0 : WRITE_ISSUE;
            READ_ISSUE  <= READ_ISSUE;
        end
        default:begin // RESP_MODE
            ARREADY <= 1'b0;
            AWREADY <= 1'b0;
            WREADY  <= 1'b0;
            BVALID  <= ~(BVALID & BREADY);

            RID     <= 8'h0;

            BID     <= WRAPPER_AWID;
            BRESP   <= `AXI_RESP_OKAY;

            WRITE_ISSUE <= ((DRAM_CS == DRAM_WRITE) & (~CASn) & WRAPPER_WLAST & (Last_Access_Row == Current_Access_Row))? 1'b0 : WRITE_ISSUE;
            READ_ISSUE  <= READ_ISSUE;
        end
        endcase
    end 
end























/*
|------------------|
|                  |
| DRAM controlling |
|                  |
|------------------|
*/



always_ff @( posedge CLK or negedge RSTn ) begin : Cycle_Counter_FF
    unique if (~RSTn) begin
        Cycle_Counter <= 3'b000;
    end
    else begin
        Cycle_Counter <= (DRAM_CS != DRAM_NS)? 3'b000 : ((Count_Meet)? Cycle_Counter :  Cycle_Counter + 3'b1);
    end
end
assign Count_Meet = (Cycle_Counter == CYCLE_COUNT_EXCEED);

always_ff @( posedge CLK or negedge RSTn ) begin : Last_Access_Row_FF
    unique if (~RSTn) begin
        Last_Access_Row <= 11'b0;
    end
    else begin
        Last_Access_Row <= ((DRAM_CS == DRAM_ACT) & (Cycle_Counter == 3'b000))? Current_Access_Row : Last_Access_Row;
    end
end

always_ff @( posedge CLK or negedge RSTn ) begin : DRAM_STATE_FF
    unique if (~RSTn) begin
        DRAM_CS <= DRAM_RST0;// at initial, precahrge one time
    end
    else begin
        DRAM_CS <= DRAM_NS;
    end
end

always_comb begin : DRAM_STATE_Predictor
    unique case (DRAM_CS)
    DRAM_RST0:begin
        DRAM_NS = DRAM_RST1;
    end
    DRAM_RST1:begin
        unique if (Count_Meet) begin
            DRAM_NS = DRAM_RST2;
        end
        else begin
            DRAM_NS = DRAM_CS;
        end 
    end
    DRAM_RST2:begin
        unique if (Count_Meet) begin
            DRAM_NS = DRAM_PRE;
        end
        else begin
            DRAM_NS = DRAM_CS;
        end 
    end
    DRAM_ACT:begin
        unique if (Count_Meet) begin
            DRAM_NS = DRAM_IDLE;
        end
        else begin
            DRAM_NS = DRAM_CS;
        end 
    end
    DRAM_READ:begin
        unique if (Count_Meet) begin
            DRAM_NS = (Last_Access_Row == Current_Access_Row)? DRAM_IDLE : DRAM_PRE;
        end
        else begin
            DRAM_NS = DRAM_CS;
        end
    end
    DRAM_WRITE:begin
        unique if (Count_Meet) begin
            DRAM_NS = (Last_Access_Row == Current_Access_Row)? DRAM_IDLE : DRAM_PRE;
        end
        else begin
            DRAM_NS = DRAM_CS;
        end
    end
    DRAM_IDLE:begin
        unique case ({WRITE_ISSUE, READ_ISSUE})
        2'b00:  DRAM_NS = DRAM_CS;
        2'b01:  DRAM_NS = DRAM_READ;
        2'b10:  DRAM_NS = DRAM_WRITE;
        default:DRAM_NS = DRAM_READ;// if read and write both issue, do read first
        endcase
    end
    default:begin // PRE charge stage
        DRAM_NS = (Count_Meet)? DRAM_ACT : DRAM_CS;
    end
    endcase
end



assign D = WRAPPER_WDATA;
always_comb begin : DRAM_Control_Address
    unique case (DRAM_CS)
    DRAM_RST0:begin
        RASn = 1'b1;
        CASn = 1'b1;
        WEn  = 4'hf;

        A = 11'b0;
        Current_Access_Row = Last_Access_Row;
        Current_Access_Col = 11'b0;
    end
    DRAM_RST1:begin
        RASn = ~(Cycle_Counter == 3'b0);
        CASn = 1'b1;
        WEn  = 4'hf;

        A = Current_Access_Row;
        Current_Access_Row = Last_Access_Row;
        Current_Access_Col = 11'b0;
    end
    DRAM_RST2:begin
        RASn = 1'b1;
        CASn = ~(Cycle_Counter == 3'b0);
        WEn  = 4'hf;

        A = Current_Access_Row;
        Current_Access_Row = Last_Access_Row;
        Current_Access_Col = 11'b0;
    end
    DRAM_ACT:begin
        unique case ({WRITE_ISSUE, READ_ISSUE})
        2'b00:begin
            Current_Access_Row = Last_Access_Row;
            Current_Access_Col = 11'b0;
        end
        2'b01:begin
            unique case (WRAPPER_ARBURST)
            FIXED:begin
                Current_Access_Row = WRAPPER_ARADDR[22:12];
                Current_Access_Col = {1'b0, WRAPPER_ARADDR[11: 2]};
            end
            INCR:begin
                Current_Access_Row = RADDR_INCR[22:12];
                Current_Access_Col = {1'b0, RADDR_INCR[11: 2]};
            end
            WRAP:begin
                unique if (RADDR_INCR < 32'h201f_ffff) begin
                    Current_Access_Row = RADDR_INCR[22:12];
                    Current_Access_Col = {1'b0, RADDR_INCR[11: 2]};
                end
                else begin
                    Current_Access_Row = 11'h3ff;
                    Current_Access_Col = 11'h7ff;
                end
            end
            default:begin
                Current_Access_Row = Last_Access_Row;
                Current_Access_Col = 11'b0;
            end
            endcase
        end
        2'b10:begin
            unique case (WRAPPER_AWBURST)
            FIXED:begin
                Current_Access_Row = WRAPPER_AWADDR[22:12];
                Current_Access_Col = {1'b0, WRAPPER_AWADDR[11: 2]};
            end
            INCR:begin
                Current_Access_Row = WADDR_INCR[22:12];
                Current_Access_Col = {1'b0, WADDR_INCR[11: 2]};
            end
            WRAP:begin
                unique if (WADDR_INCR < 32'h201f_ffff) begin
                    Current_Access_Row = WADDR_INCR[22:12];
                    Current_Access_Col = {1'b0, WADDR_INCR[11: 2]};
                end
                else begin
                    Current_Access_Row = 11'h3ff;
                    Current_Access_Col = 11'h7ff;
                end
            end
            default:begin
                Current_Access_Row = Last_Access_Row;
                Current_Access_Col = 11'b0;
            end
            endcase
        end
        default:begin
            unique case (WRAPPER_ARBURST)
            FIXED:begin
                Current_Access_Row = WRAPPER_ARADDR[22:12];
                Current_Access_Col = {1'b0, WRAPPER_ARADDR[11: 2]};
            end
            INCR:begin
                Current_Access_Row = RADDR_INCR[22:12];
                Current_Access_Col = {1'b0, RADDR_INCR[11: 2]};
            end
            WRAP:begin
                unique if (RADDR_INCR < 32'h201f_ffff) begin
                    Current_Access_Row = RADDR_INCR[22:12];
                    Current_Access_Col = {1'b0, RADDR_INCR[11: 2]};
                end
                else begin
                    Current_Access_Row = 11'h3ff;
                    Current_Access_Col = 11'h7ff;
                end
            end
            default:begin
                Current_Access_Row = Last_Access_Row;
                Current_Access_Col = 11'b0;
            end
            endcase
        end
        endcase

        A = Current_Access_Row;
        RASn = ~(Cycle_Counter == 3'b0);
        CASn = 1'b1;
        WEn  = 4'hf;
    end
    DRAM_IDLE:begin
        RASn = 1'b1;
        CASn = 1'b1;
        WEn  = 4'hf;

        A = Current_Access_Row;
        Current_Access_Row = Last_Access_Row;
        Current_Access_Col = 11'b0;
    end
    DRAM_READ:begin
        unique case (WRAPPER_ARBURST)
        FIXED:begin
            Current_Access_Row = WRAPPER_ARADDR[22:12];
            Current_Access_Col = {1'b0, WRAPPER_ARADDR[11: 2]};
        end
        INCR:begin
            Current_Access_Row = RADDR_INCR[22:12];
            Current_Access_Col = {1'b0, RADDR_INCR[11: 2]};
        end
        WRAP:begin
            unique if (RADDR_INCR < 32'h201f_ffff) begin
                Current_Access_Row = RADDR_INCR[22:12];
                Current_Access_Col = {1'b0, RADDR_INCR[11: 2]};
            end
            else begin
                Current_Access_Row = 11'h3ff;
                Current_Access_Col = 11'h7ff;
            end
        end
        default:begin
            Current_Access_Row = Last_Access_Row;
            Current_Access_Col = 11'b0;
        end
        endcase

        A = Current_Access_Col;
        RASn = 1'b1;
        CASn = ~((Cycle_Counter == 3'b000) & (Last_Access_Row == Current_Access_Row) & (~RVALID));
        WEn  = 4'hf;
    end
    DRAM_WRITE:begin
        unique case (WRAPPER_AWBURST)
        FIXED:begin
            Current_Access_Row = WRAPPER_AWADDR[22:12];
            Current_Access_Col = {1'b0, WRAPPER_AWADDR[11: 2]};
        end
        INCR:begin
            Current_Access_Row = WADDR_INCR[22:12];
            Current_Access_Col = {1'b0, WADDR_INCR[11: 2]};
        end
        WRAP:begin
            unique if (WADDR_INCR < 32'h201f_ffff) begin
                Current_Access_Row = WADDR_INCR[22:12];
                Current_Access_Col = {1'b0, WADDR_INCR[11: 2]};
            end
            else begin
                Current_Access_Row = 11'h3ff;
                Current_Access_Col = 11'h7ff;
            end
        end
        default:begin
            Current_Access_Row = Last_Access_Row;
            Current_Access_Col = 11'b0;
        end
        endcase

        A = Current_Access_Col;
        RASn = 1'b1;
        CASn = ~((Cycle_Counter == 3'b000) & (Last_Access_Row == Current_Access_Row));
        WEn  = (Cycle_Counter == 3'b000)? ~WRAPPER_WSTRB : 4'hf;
    end
    default:begin // Pre charge
        A = Last_Access_Row;
        Current_Access_Row = Last_Access_Row;
        Current_Access_Col = 11'b0;
        RASn = ~(Cycle_Counter == 3'b000);
        CASn = 1'b1;
        WEn  = (Cycle_Counter == 3'b000)? 4'h0 : 4'hf;
    end
    endcase
end


always_ff @( posedge CLK or negedge RSTn ) begin : DRAM_OUTPUT_FF
    unique if (~RSTn) begin
        RDATA   <= 32'h0;
        RLAST   <= 1'b0;
        RVALID  <= 1'b0;
    end
    else begin
        unique if (WRAPPER_MODE == READ_MODE) begin
            RDATA   <= (VALID)? Q : RDATA;
            RLAST   <= (VALID)? (Burst_Counter == WRAPPER_ARLEN) : RLAST;
            RVALID  <= (RVALID & RREADY)? 1'b0 : ((VALID)? 1'b1 : RVALID);
        end
        else begin
            RDATA   <= RDATA;
            RLAST   <= RLAST;
            RVALID  <= RVALID;
        end
    end
end

endmodule