module Mux_3(
input [31:0] a,
input [31:0] b,
input [31:0] c,
input [1:0] en,
output logic [31:0] d
);
// assign d=(en[1])?c: en[0]?b:a;
//0:a 1:b 2:c
always@(*)begin
    case(en)
    2'd0:d=a;
    2'd1:d=b;
    default:d=c;
    endcase
end

endmodule