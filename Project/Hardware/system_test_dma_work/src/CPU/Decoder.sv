module Decoder (
input [31:0] inst,
output [4:0] dc_out_opcode,
output [2:0] dc_out_func3,
output dc_out_func7,
output dc_out_func7_mul,
output [4:0] dc_out_rs1_index,
output [4:0] dc_out_rs2_index,
output [4:0] dc_out_rd_index,
output [1:0] dc_out_last2
);

assign dc_out_opcode=inst[6:2];
assign dc_out_func3=inst[14:12];
assign dc_out_func7=inst[30];
assign dc_out_rs1_index=inst[19:15];
assign dc_out_rs2_index=inst[24:20];
assign dc_out_rd_index=inst[11:7];
assign dc_out_func7_mul=inst[25];
assign dc_out_last2=inst[1:0];



endmodule