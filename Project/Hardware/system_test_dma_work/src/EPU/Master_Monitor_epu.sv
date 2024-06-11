`ifndef AXI_DEFINITION
`define AXI_DEFINITION
`include "./../include/AXI_define.svh"
`endif
`ifndef MASTER_MONITOR_EPU
`define MASTER_MONITOR_EPU
module Master_Monitor_epu (
    input   CLK,
    input   RSTn,

    input   [`AXI_IDS_BITS-1:0]         ARID,
    input   [`AXI_ADDR_BITS-1:0]        ARADDR,
    input   [`AXI_LEN_BITS-1:0]         ARLEN,
    input   [`AXI_SIZE_BITS-1:0]        ARSIZE,
    input   [1:0]                       ARBURST,
    input                               ARVALID,
    output  logic                       ARREADY,

    output  logic   [`AXI_IDS_BITS-1:0] RID,
    output  logic   [`AXI_DATA_BITS-1:0]RDATA,
    output  logic   [1:0]               RRESP,
    output  logic                       RLAST,
    output  logic                       RVALID,
    input                               RREADY,

    input   [`AXI_IDS_BITS-1:0]         AWID,
    input   [`AXI_ADDR_BITS-1:0]        AWADDR,
    input   [`AXI_LEN_BITS-1:0]         AWLEN,
    input   [`AXI_SIZE_BITS-1:0]        AWSIZE,
    input   [1:0]                       AWBURST,
    input                               AWVALID,
    output  logic                       AWREADY,

    
    input   [`AXI_DATA_BITS-1:0]        WDATA,
    input   [`AXI_STRB_BITS-1:0]        WSTRB,
    input                               WLAST,
    input                               WVALID,
    output  logic                       WREADY,

    output  logic   [`AXI_IDS_BITS-1:0] BID,
    output  logic   [1:0]               BRESP,
    output  logic                       BVALID,
    input                               BREADY,


    output  logic   [3:0]               SRAM_WEB,
    output  logic   [11:0]              SRAM_A,
    output  logic   [127:0]              SRAM_DI,
    input   logic   [127:0]              SRAM_DO
);

// SRAM's state machines state

logic   [1:0]   WRAPPER_MODE, WRAPPER_MODE_NEXT;
logic   READ_STALL;
assign  READ_STALL = RVALID & (~RREADY);// if already valid but not ready, wrapper need to stall to wait
parameter IDLE_MODE  = 2'b00;// IDLE_MODE can be seen as AR & AW mode
parameter READ_MODE  = 2'b01;
parameter WRITE_MODE = 2'b10;
parameter RESP_MODE  = 2'b11;
parameter FIXED = 2'b00;
parameter INCR  = 2'b01;
parameter WRAP  = 2'b10;

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
        default:begin// if write and read both shakehand, do read first
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
        WRAPPER_WDATA <= (WVALID & WREADY)? WDATA : 32'b0;
        WRAPPER_WSTRB <= (WVALID & WREADY)? WSTRB : 4'b0;
        WRAPPER_WLAST <= (WVALID & WREADY)? WLAST : 1'b0;
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
        if (WVALID & WREADY) begin
            unique case (WRAPPER_AWBURST)
            FIXED:  WADDR_Captured <= WRAPPER_AWADDR[13:0];
            INCR:   WADDR_Captured <= WADDR_INCR[13:0];
            WRAP:   WADDR_Captured <= WADDR_INCR[13:0];
            default:WADDR_Captured <= WADDR_INCR[13:0];
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
            WADDR_INCR  <= (WVALID & WREADY)? (WADDR_INCR + ((32'b1) << 2)) : WADDR_INCR;
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
    default:begin
        ARREADY = 1'b0;
        AWREADY = 1'b0;
        WREADY  = 1'b0;
        BVALID  = 1'b1;

        RID     = 8'b0;

        BID     = WRAPPER_AWID;
        BRESP   = `AXI_RESP_OKAY;
    end
    endcase
end

// SRAM Peripheral are the wires and registers which control and route the SRAM ports

// SRAM_Interface_Input connects to SRAM's input ports



always_comb begin : SRAM_Interface_Input
    unique case (WRAPPER_MODE)
    WRITE_MODE:begin
        SRAM_A = WADDR_Captured[13:4];

        case(WADDR_Captured[3:2])
        2'b00: begin
            SRAM_WEB=(WRAPPER_WSTRB!=4'b0000)?4'b1110:4'b1111;
            SRAM_DI={96'b0, WRAPPER_WDATA};
        end
        2'b01: begin
            SRAM_WEB=(WRAPPER_WSTRB!=4'b0000)?4'b1101:4'b1111;
            SRAM_DI={64'b0, WRAPPER_WDATA, 32'b0};
        end
        2'b10: begin
            SRAM_WEB=(WRAPPER_WSTRB!=4'b0000)?4'b1011:4'b1111;
            SRAM_DI={32'b0, WRAPPER_WDATA, 64'b0};
        end
        default: begin
            SRAM_WEB=(WRAPPER_WSTRB!=4'b0000)?4'b0111:4'b1111;
            SRAM_DI={WRAPPER_WDATA, 96'b0};
        end
        endcase
        // SRAM_DI     = WRAPPER_WDATA;
        // SRAM_WEB    = ~WRAPPER_WSTRB;
    end
    READ_MODE:begin
        SRAM_DI     = WRAPPER_WDATA;
        SRAM_WEB    = 4'hF;

        unique case (WRAPPER_ARBURST)
        FIXED:  SRAM_A = WRAPPER_ARADDR[13:2];
        INCR:   SRAM_A = RADDR_INCR[13:2];
        WRAP:   SRAM_A = RADDR_INCR[13:2];
        default:SRAM_A = RADDR_INCR[13:2];
        endcase
    end
    RESP_MODE:begin
        unique case (WRAPPER_AWBURST)
        FIXED:  begin
            SRAM_A = WRAPPER_AWADDR[13:4];
            case(WRAPPER_AWADDR[3:2])
            2'b00: begin 
                SRAM_WEB=4'b1110; 
                SRAM_DI={96'b0, WRAPPER_WDATA};
            end
            2'b01: begin 
                SRAM_WEB=4'b1101; 
                SRAM_DI={64'b0, WRAPPER_WDATA, 32'b0};
            end
            2'b10: begin 
                SRAM_WEB=4'b1011; 
                SRAM_DI={32'b0, WRAPPER_WDATA, 64'b0};
            end
            2'b11: begin 
                SRAM_WEB=4'b0111; 
                SRAM_DI={WRAPPER_WDATA, 96'b0};
            end
            endcase                
        end
        INCR:   begin
            SRAM_A = WADDR_Captured[13:4];
            case(WADDR_Captured[3:2])
            2'b00: begin 
                SRAM_WEB=4'b1110; 
                SRAM_DI={96'b0, WRAPPER_WDATA};
            end
            2'b01: begin 
                SRAM_WEB=4'b1101; 
                SRAM_DI={64'b0, WRAPPER_WDATA, 32'b0};
            end
            2'b10: begin 
                SRAM_WEB=4'b1011; 
                SRAM_DI={32'b0, WRAPPER_WDATA, 64'b0};
            end
            2'b11: begin 
                SRAM_WEB=4'b0111; 
                SRAM_DI={WRAPPER_WDATA, 96'b0};
            end
            endcase
        end
        default:begin
            SRAM_A = WADDR_INCR[13:4];
            case(WADDR_INCR[3:2])
            2'b00: begin 
                SRAM_WEB=4'b1110; 
                SRAM_DI={96'b0, WRAPPER_WDATA};
            end
            2'b01: begin 
                SRAM_WEB=4'b1101; 
                SRAM_DI={64'b0, WRAPPER_WDATA, 32'b0};
            end
            2'b10: begin 
                SRAM_WEB=4'b1011; 
                SRAM_DI={32'b0, WRAPPER_WDATA, 64'b0};
            end
            2'b11: begin 
                SRAM_WEB=4'b0111; 
                SRAM_DI={WRAPPER_WDATA, 96'b0};
            end
            endcase
        end
        endcase
        // SRAM_DI     = WRAPPER_WDATA;

        // SRAM_WEB    = ~WRAPPER_WSTRB;

        // unique case (WRAPPER_AWBURST)
        // FIXED:  SRAM_A = WRAPPER_AWADDR[15:2];
        // INCR:   SRAM_A = WADDR_Captured[15:2];
        // WRAP:   SRAM_A = WADDR_INCR[15:2];
        // default:SRAM_A = WADDR_INCR[15:2];
        // endcase
    end
    default:begin
        SRAM_DI     = WRAPPER_WDATA;
        SRAM_WEB    = 4'hF;

        SRAM_A      = 14'b1;
    end
    endcase
end

logic   SRAM_SYNC_RVALID, SRAM_RVALID;
// SRAM_Interface_Output connects to SRAM's output ports
always_ff @( posedge CLK or negedge RSTn ) begin : SRAM_Interface_Output
    priority if (~RSTn) begin
        // Buffered (Flip-flops) output connect to AXIs
        RDATA   <= 32'b0;
        RVALID  <= 1'b0;
        RLAST   <= 1'b0;
		RRESP	<= `AXI_RESP_SLVERR;
    end
    else if (WRAPPER_MODE == READ_MODE) begin
        unique if (READ_STALL) begin// if RVALID and not shakehand, then stall
            // Buffered (Flip-flops) output connect to AXIs
            RDATA   <= RDATA;
            RVALID  <= RVALID;
            RLAST   <= RLAST;
			RRESP	<= RRESP;
        end
		else begin
            // Buffered (Flip-flops) output connect to AXIs
            RDATA   <= SRAM_DO;
            RVALID  <= (RVALID)? 1'b0 : SRAM_RVALID;// after shakehand, need at least one period unvalid
            RLAST   <= (WRAPPER_MODE == READ_MODE & WRAPPER_ARLEN == Burst_Counter);
			RRESP	<= (SRAM_RVALID)? `AXI_RESP_OKAY : `AXI_RESP_SLVERR;
        end
	end
	else begin
		RDATA   <= 32'b0;
	    RVALID  <= 1'b0;
	    RLAST   <= 1'b0;
		RRESP	<= `AXI_RESP_SLVERR;
	end
end
// SRAM_synchronized are signals synchronized to SRAM because SRAM delay 1 period
always_ff @( posedge CLK or negedge RSTn ) begin : SRAM_synchronized
    unique if (~RSTn)begin
        SRAM_RVALID         <= 1'b0;
    end
    else begin 
        SRAM_RVALID         <= (RVALID)? 1'b0 : (WRAPPER_MODE == READ_MODE);
    end
end

endmodule
`endif