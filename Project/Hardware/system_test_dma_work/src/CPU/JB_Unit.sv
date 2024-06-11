//相較PPT有多拉opcode判斷
module JB_Unit (
input [4:0] opcode,
input [31:0] operand1,
input [31:0] operand2,
output [31:0] jb_out
);

// always @(*) begin
//     // case(opcode)
//     //     5'b11000, 5'b11011: jb_out=operand1+operand2;
//     //     5'b11001: jb_out=(operand1+operand2)&(~32'b1);
//     //     default: jb_out=32'b1; 
//     // endcase
//     if(opcode==5'b11000||opcode==5'b11011) jb_out=operand1+operand2;
//     else if(opcode==5'b11001) jb_out=(operand1+operand2)&(~32'b1);
//     else jb_out=32'b1;
// end

assign jb_out = (operand1 + operand2) & (~32'd1);
endmodule