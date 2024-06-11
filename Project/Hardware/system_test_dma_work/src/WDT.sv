module WDT (
    input           CLK,
    input           RSTn,

    input           WDEN,
    input           WDLIVE,
    input   [31:0]  WTOCNT,
    output  logic   WTO
);
// Cross domain clocking interface
// logic   [33:0]  WDATA;
// logic   [33:0]  AFIFO_WDATA;
// assign WDATA = {WDEN, WDLIVE, WTOCNT};

// logic   [33:0]  AFIFO_RDATA;

// logic   WDEN_T, WDLIVE_T;
// logic   [31:0]  WTOCNT_T;
// logic   WTO_T;

// logic   AFIFO_FULL, AFIFO_EMPTY;

// logic   CLK1_Write_Enable, CLK2_READ_Enable;


// logic   [33:0]  R_DATA_Tx;
// logic   [3:0]   R_PTR_GRAY, R_PTR_Binary, W_PTR_GRAY;
// AFIFO_Tx #(
//     .DATA_WIDTH(34),
//     .ADDR_WIDTH(4)   )
//     AFIFO_Write
// (
//     .CLK(CLK),
//     .RSTn(RSTn),

//     // Ports to Write point
//     .W_DATA(AFIFO_WDATA),
//     .WEN(CLK1_Write_Enable),
//     .W_FULL(AFIFO_FULL),
//     // Ports to Write point

//     // Connection to Rx side
//     .R_PTR_GRAY(R_PTR_GRAY),
//     .R_PTR_Binary(R_PTR_Binary),
//     .W_PTR_GRAY(W_PTR_GRAY),
//     .R_DATA_Tx(R_DATA_Tx)
//     // Connection to Rx side
// );
// AFIFO_Rx#(
//     .DATA_WIDTH(34),
//     .ADDR_WIDTH(4)   )
//     AFIFO_Read
// (
//     .CLK(CLK2),
//     .RSTn(RSTn2),

//     // Ports to Read point
//     .R_DATA(AFIFO_RDATA),
//     .REN(CLK2_READ_Enable),
//     .R_EMPTY(AFIFO_EMPTY),
//     // Ports to Read point

//     // Connection to Tx side
//     .W_PTR_GRAY(W_PTR_GRAY),
//     .R_PTR_GRAY(R_PTR_GRAY),
//     .R_PTR_Binary(R_PTR_Binary),
//     .R_DATA_Tx(R_DATA_Tx)
//     // Connection to Tx side
// );

// // Clock domain 1 (Fast)

// always_ff @( posedge CLK or negedge RSTn ) begin : Fast_FF
//     unique if (~RSTn) begin
//         AFIFO_WDATA <= 34'h0ffff_ffff;
//         CLK1_Write_Enable <= 1'b0;
//     end
//     else begin
//         AFIFO_WDATA <= (AFIFO_WDATA == WDATA)? AFIFO_WDATA : WDATA;
//         CLK1_Write_Enable <= (AFIFO_WDATA != WDATA);
//     end
// end


// Clock domain 2 (slow)

logic   [31:0]  Timer;
// logic   [33:0]  RDATA;
// assign  WDEN_T   = AFIFO_RDATA[33];
// assign  WDLIVE_T = AFIFO_RDATA[32];
// assign  WTOCNT_T = AFIFO_RDATA[31:0];
always_ff @( posedge CLK or negedge RSTn ) begin : Timer_FF
    unique if (~RSTn) begin
        Timer <= 32'b0;
        // RDATA <= 34'hffff_ffff;
        // WTO_T <= 1'b0;
        // CLK2_READ_Enable <= 1'b0;
        // WDEN_T      <= 1'b0;
        // WDLIVE_T    <= 1'b0;
        // WTOCNT_T    <= 32'b0;
    end
    else begin
        WTO <= ((Timer == WTOCNT) & WDEN);
        priority if (WDLIVE | (~WDEN)) begin
            Timer <= 32'b0;
        end
        else if (WTO) begin
            Timer <= Timer;
        end
        else if (WDEN) begin
            if (Timer == WTOCNT) begin
                Timer <= Timer;
            end
            else begin
                Timer <= Timer + 32'b1;
            end
        end
        else begin
            Timer <= Timer;
        end

        // CLK2_READ_Enable <= CLK2_READ_Enable? 1'b0 : ~AFIFO_EMPTY;
        // RDATA <= (CLK2_READ_Enable)? AFIFO_RDATA : RDATA;

        // unique if (CLK2_READ_Enable) begin
        //     WDEN_T      <= R_DATA_Tx[33];
        //     WDLIVE_T    <= R_DATA_Tx[32];
        //     WTOCNT_T    <= R_DATA_Tx[31:0];
        // end
        // else begin
        //     WDEN_T      <= WDEN_T;
        //     WDLIVE_T    <= WDLIVE_T;
        //     WTOCNT_T    <= WTOCNT_T;
        // end
    end
end

endmodule