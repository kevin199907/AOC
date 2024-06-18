module RADDT(
    input [15:0] in[15:0],
    output logic signed [23:0] out
);
assign out = $signed(in[0])+ $signed(in[1])+ $signed(in[2])+ $signed(in[3])+ $signed(in[4])+ $signed(in[5])+ $signed(in[6])+ $signed(in[7])+
    $signed(in[8])+ $signed(in[9])+ $signed(in[10])+ $signed(in[11])+ $signed(in[12])+ $signed(in[13])+ $signed(in[14])+ $signed(in[15]);
endmodule