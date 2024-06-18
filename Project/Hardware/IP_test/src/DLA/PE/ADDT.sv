module ADDT(
    input [23:0] in1, in2, in3,
    output signed [23:0] out
);
assign out = $signed(in1) + $signed(in2) + $signed(in3);
endmodule