module Vector_SYNC 
#(  parameter   DATA_WIDTH  =   32,
    parameter   SYNC_STAGE  =   2   )
(
    input                       CLK,
    input                       RSTn,
    input           [DATA_WIDTH-1:0] D,
    output  logic   [DATA_WIDTH-1:0] Q
);

logic   [DATA_WIDTH-1:0] Sequential_FF [SYNC_STAGE-1:0];
assign Q = Sequential_FF[SYNC_STAGE-1];

integer i;
always_ff @( posedge CLK or negedge RSTn) begin : SYNC_FlipFlops
    unique if (~RSTn) begin
        for (i = 0; i < SYNC_STAGE; i = i + 1)begin
            Sequential_FF[i]  <= 0;
        end
    end
    else begin
        Sequential_FF[0] <= D;
        for (i = 1; i < SYNC_STAGE; i = i + 1)begin
            Sequential_FF[i]  <= Sequential_FF[i - 1];
        end
    end
end


    
endmodule