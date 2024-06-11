module Sensor_Wrapper (
    input                               CLK,
    input                               RSTn,

    // CPU inputs
    output  logic                       sctrl_en,
    output  logic                       sctrl_clear,
    output  logic   [11:0]              sctrl_addr,
    // CPU outputs
    input           [31:0]              sctrl_out,
    input                               sctrl_interrupt,

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


parameter stcrl_en_addr = 32'h1000_8000;
parameter sctrl_clear_addr = 32'h1000_9000;
parameter sctrl_job_addr = 32'h1000_9004;


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
    default:begin // RESP_MODE
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
    if (~RSTn) begin
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
    if (~RSTn) begin
        WRAPPER_WDATA <= 32'b0;
        WRAPPER_WSTRB <= 4'b0;
        WRAPPER_WLAST <= 1'b0;
    end
    else begin
        WRAPPER_WDATA <= (WVALID & WREADY)? WDATA : 32'b0;
        WRAPPER_WSTRB <= (WVALID & WREADY)? WSTRB : 4'b0;
        WRAPPER_WLAST <= (WVALID & WREADY)? WLAST : 1'b0;
    end
end
// AR_Channel_FF record the value on bus when Address Write channel shakehand
always_ff @( posedge CLK or negedge RSTn ) begin : AR_Channel_FF
    if (~RSTn) begin
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
logic   [`AXI_ADDR_BITS-1:0]    RADDR_INCR;

// WRITE_ADDR_INCR finish
// WRITE_ADDR_INCR control the write address of increment type
always_ff @( posedge CLK or negedge RSTn ) begin : WRITE_ADDR_INCR
    unique if (~RSTn) begin
        WADDR_INCR  <= 32'b0;
    end
    else begin
        unique case (WRAPPER_MODE)
        IDLE_MODE:begin
            WADDR_INCR  <= (AWVALID & AWREADY)? AWADDR : 32'b0;
        end
        WRITE_MODE:begin
            WADDR_INCR  <= (WVALID & WREADY)? (WADDR_INCR + ((32'b1)<<WRAPPER_AWSIZE)) : WADDR_INCR;
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
            RADDR_INCR  <= (ARVALID & ARREADY)? ARADDR : 32'h0;
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

logic   Write_enable;
// Wrapper_Control_Decode
// Wrapper_Control_Decode provide different signals when different state
always_comb begin : Wrapper_Control_Decode
    unique case(WRAPPER_MODE)
    IDLE_MODE:begin
        ARREADY = 1'b1;
        AWREADY = 1'b1;
        WREADY  = 1'b0;
        BVALID  = 1'b0;

        RID     = 8'b0;

        BID     = 8'b0;
        BRESP   = `AXI_RESP_SLVERR;
    end
    READ_MODE:begin
        ARREADY = 1'b0;
        AWREADY = 1'b0;
        WREADY  = 1'b0;
        BVALID  = 1'b0;

        RID     = WRAPPER_ARID;

        BID     = 8'b0;
        BRESP   = `AXI_RESP_SLVERR;
    end
    WRITE_MODE:begin
        ARREADY = 1'b0;
        AWREADY = 1'b0;
        WREADY  = 1'b1;
        BVALID  = 1'b0;

        RID     = 8'b0;

        BID     = 8'b0;
        BRESP   = `AXI_RESP_SLVERR;
    end
    default:begin // RESP_MODE
        ARREADY = 1'b0;
        AWREADY = 1'b0;
        WREADY  = 1'b0;
        BVALID  = ~Write_enable;

        RID     = 8'b0;

        BID     = WRAPPER_AWID;
        BRESP   = `AXI_RESP_OKAY;
    end
    endcase
end


parameter FIXED = 2'b00;
parameter INCR  = 2'b01;
parameter WRAP  = 2'b10;
logic   [31:0]  WADDR_RECEIVED;

always_comb begin : Sensor_Peripheral_Comb
    unique case (WRAPPER_MODE)
    READ_MODE:begin
        unique case (WRAPPER_ARBURST)
        FIXED:  sctrl_addr = WRAPPER_ARADDR[13:2];
        INCR:   sctrl_addr = RADDR_INCR[13:2];
        WRAP:   sctrl_addr = WRAPPER_ARADDR[13:2];
        default:sctrl_addr = 6'b0;
        endcase

        WADDR_RECEIVED = 32'h0;
    end
    WRITE_MODE:begin
        sctrl_addr = 6'b0;

        unique case (WRAPPER_AWBURST)
        FIXED:  WADDR_RECEIVED = WRAPPER_AWADDR;
        INCR:   WADDR_RECEIVED = WADDR_INCR;
        WRAP:   WADDR_RECEIVED = WADDR_INCR;
        default:WADDR_RECEIVED = 32'h0;
        endcase
    end
    RESP_MODE:begin
        sctrl_addr = 6'b0;

        unique case (WRAPPER_AWBURST)
        FIXED:  WADDR_RECEIVED = WRAPPER_AWADDR;
        INCR:   WADDR_RECEIVED = WADDR_INCR;
        WRAP:   WADDR_RECEIVED = WADDR_INCR;
        default:WADDR_RECEIVED = 32'h0;
        endcase
    end
    default:begin
        sctrl_addr = 6'b0;
        WADDR_RECEIVED = 32'h0;
    end
    endcase
end

always_ff @( posedge CLK or negedge RSTn ) begin : stcrl_en_clear
    unique if (~RSTn) begin
        sctrl_en <= 1'b0;
        sctrl_clear<= 1'b0;
        Write_enable <= 1'b0;
    end
    else begin
        Write_enable <= Write_enable? 1'b0 : (WVALID & WREADY);
        unique case (WADDR_RECEIVED)
        sctrl_clear_addr:begin
            sctrl_clear <= (Write_enable)? WRAPPER_WDATA[0] : sctrl_clear;
            sctrl_en <= sctrl_en;
        end
        stcrl_en_addr:begin
            sctrl_clear <= sctrl_clear;
            sctrl_en <= (Write_enable)? WRAPPER_WDATA[0] : sctrl_en;
        end
        default:begin
            sctrl_clear <= sctrl_clear;
            sctrl_en <= sctrl_en;
        end
        endcase
    end
end

always_ff @( posedge CLK or negedge RSTn ) begin : Sensor_Peripheral_FF
    unique if (~RSTn) begin
        RVALID  <= 1'b0;
        RLAST   <= 1'b0;
        RDATA   <= 32'b0;
    end
    else begin
        unique case (WRAPPER_MODE)
        READ_MODE:begin
            RVALID  <= RVALID? 1'b0 : (WRAPPER_MODE==READ_MODE);
            RLAST   <= (Burst_Counter == WRAPPER_ARLEN);
        end
        default:begin
            RVALID  <= RVALID;
            RLAST   <= 1'b0;
        end
        endcase

        unique case (WRAPPER_ARADDR)
        sctrl_clear_addr:begin
            RDATA <= {31'b0, sctrl_clear};
        end
        stcrl_en_addr:begin
            RDATA <= {31'b0, sctrl_en};
        end
        sctrl_job_addr:begin
            RDATA <= {31'b0, sctrl_interrupt};
        end
        default:begin
            RDATA <= sctrl_out;
        end
        endcase
    end
end

endmodule