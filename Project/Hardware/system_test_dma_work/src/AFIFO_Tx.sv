module AFIFO_Tx
#(  parameter   DATA_WIDTH  =   32,
    parameter   ADDR_WIDTH  =   4   )
(
    input                               CLK,
    input                               RSTn,

    // Ports to Write point
    input           [DATA_WIDTH-1:0]    W_DATA,
    input                               WEN,
    output  logic                       W_FULL,
    // Ports to Write point

    // Connection to Rx side
    input           [ADDR_WIDTH-1:0]    R_PTR_GRAY,
    input           [ADDR_WIDTH-1:0]    R_PTR_Binary,
    output  logic   [ADDR_WIDTH-1:0]    W_PTR_GRAY,
    output  logic   [DATA_WIDTH-1:0]    R_DATA_Tx
    // Connection to Rx side
);

logic   [ADDR_WIDTH-1:0]    W_PTR_Binary;
logic   [ADDR_WIDTH-1:0]    W_PTR_Binary_ADD_1;
assign W_PTR_Binary_ADD_1 = W_PTR_Binary + {{(ADDR_WIDTH-1){1'b0}}, 1'b1};
always_ff @( posedge CLK or negedge RSTn ) begin : Binary_Counter
    unique if (~RSTn) begin
        W_PTR_Binary <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        unique if (WEN & (~W_FULL)) begin
            W_PTR_Binary <= W_PTR_Binary_ADD_1;
        end
        else begin
            W_PTR_Binary <= W_PTR_Binary;
        end
    end
end

integer i, j;
logic   [ADDR_WIDTH:0]      Bin_Before_Gray;
logic   [ADDR_WIDTH-1:0]    Converted_Gray;
assign Bin_Before_Gray = {1'b0, W_PTR_Binary_ADD_1};
always_comb begin : Bin2Gray_Converter
    for (i = 0; i < ADDR_WIDTH; i = i + 1) begin
        Converted_Gray[i] = Bin_Before_Gray[i] ^ Bin_Before_Gray[i+1];
    end
end

always_ff @( posedge CLK or negedge RSTn ) begin : GRAY_FF
    unique if (~RSTn) begin
        W_PTR_GRAY <= {ADDR_WIDTH{1'b0}};
    end
    else begin
        unique if (WEN & (~W_FULL)) begin
            W_PTR_GRAY <= Converted_Gray;
        end
        else begin
            W_PTR_GRAY <= W_PTR_GRAY;
        end
    end
end

logic   [DATA_WIDTH-1:0]    FIFO_MEMORY  [(2**(ADDR_WIDTH-1)-1):0];

always_ff @( posedge CLK or negedge RSTn ) begin : FIFO_MEMORY_WRITE
    unique if (~RSTn) begin
        for (j = 0; j < 2**(ADDR_WIDTH-1); j = j + 1) begin
            FIFO_MEMORY[j] <= {DATA_WIDTH{1'b0}};
        end
    end
    else begin
        unique if (WEN) begin
            for (j = 0; j < 2**(ADDR_WIDTH-1); j = j + 1) begin
                FIFO_MEMORY[j] <= (j==W_PTR_Binary[ADDR_WIDTH-2:0])? W_DATA : FIFO_MEMORY[j];
            end
        end
        else begin
            for (j = 0; j < 2**(ADDR_WIDTH-1); j = j + 1) begin
                FIFO_MEMORY[j] <= FIFO_MEMORY[j];
            end
        end
    end
end

assign R_DATA_Tx = FIFO_MEMORY[R_PTR_Binary[ADDR_WIDTH-2:0]];

logic   [ADDR_WIDTH-1:0]    SYNC_R_PTR_GRAY;
Vector_SYNC#(
    .DATA_WIDTH(ADDR_WIDTH),
    .SYNC_STAGE(2)
    )Tx_Vector_SYNC
    (
        .CLK(CLK),
        .RSTn(RSTn),
        .D(R_PTR_GRAY),
        .Q(SYNC_R_PTR_GRAY)
    );

assign W_FULL = 
(W_PTR_GRAY[ADDR_WIDTH-1:ADDR_WIDTH-2] == ~SYNC_R_PTR_GRAY[ADDR_WIDTH-1:ADDR_WIDTH-2])
&(W_PTR_GRAY[ADDR_WIDTH-3:0] == SYNC_R_PTR_GRAY[ADDR_WIDTH-3:0]);

endmodule