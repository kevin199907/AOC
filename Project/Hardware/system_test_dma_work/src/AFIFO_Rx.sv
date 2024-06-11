module AFIFO_Rx
#(  parameter   DATA_WIDTH  =   32,
    parameter   ADDR_WIDTH  =   4   )
(
    input                               CLK,
    input                               RSTn,

    // Ports to Read point
    output  logic   [DATA_WIDTH-1:0]    R_DATA,
    input                               REN,
    output  logic                       R_EMPTY,
    // Ports to Read point

    // Connection to Tx side
    input           [ADDR_WIDTH-1:0]    W_PTR_GRAY,
    output  logic   [ADDR_WIDTH-1:0]    R_PTR_GRAY,
    output  logic   [ADDR_WIDTH-1:0]    R_PTR_Binary,
    input           [DATA_WIDTH-1:0]    R_DATA_Tx
    // Connection to Tx side
);

logic   [ADDR_WIDTH-1:0]    R_PTR_Binary_ADD_1;
assign R_PTR_Binary_ADD_1 = R_PTR_Binary + {{(ADDR_WIDTH-1){1'b0}}, 1'b1};
always_ff @( posedge CLK or negedge RSTn ) begin : Binary_Counter
    unique if (~RSTn) begin
        R_PTR_Binary <= {DATA_WIDTH{1'b0}};
    end
    else begin
        unique if (REN & (~R_EMPTY)) begin
            R_PTR_Binary <= R_PTR_Binary_ADD_1;
        end
        else begin
            R_PTR_Binary <= R_PTR_Binary;
        end
    end
end

integer i, j;
logic   [ADDR_WIDTH:0]      Bin_Before_Gray;
logic   [ADDR_WIDTH-1:0]    Converted_Gray;
assign Bin_Before_Gray = {1'b0, R_PTR_Binary_ADD_1};
always_comb begin : Bin2Gray_Converter
    for (i = 0; i < ADDR_WIDTH; i = i + 1) begin
        Converted_Gray[i] = Bin_Before_Gray[i] ^ Bin_Before_Gray[i+1];
    end
end

always_ff @( posedge CLK or negedge RSTn ) begin : GRAY_FF
    unique if (~RSTn) begin
        R_PTR_GRAY <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        unique if (REN & (~R_EMPTY)) begin
            R_PTR_GRAY <= Converted_Gray;
        end
        else begin
            R_PTR_GRAY <= R_PTR_GRAY;
        end
    end
end

logic   [ADDR_WIDTH-1:0]    SYNC_W_PTR_GRAY;
Vector_SYNC#(
    .DATA_WIDTH(ADDR_WIDTH),
    .SYNC_STAGE(2)
    )Rx_Vector_SYNC
    (
        .CLK(CLK),
        .RSTn(RSTn),
        .D(W_PTR_GRAY),
        .Q(SYNC_W_PTR_GRAY)
    );

always_ff @( posedge CLK or negedge RSTn ) begin : R_DATA_FF
    unique if (~RSTn) begin
        R_DATA <= {DATA_WIDTH{1'b0}};
    end
    else begin
        R_DATA <= (REN)? R_DATA_Tx : R_DATA;
    end
end

assign R_EMPTY = (SYNC_W_PTR_GRAY == R_PTR_GRAY);
    
endmodule