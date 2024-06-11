module Mux(
input [31:0] a,
input [31:0] b,
input en,
output logic [31:0] c
);
// assign c=(en)?a:b;

// always@(*)begin
//         if(en==1) c=a;
//         else c=b;
//     end

always@(*)begin
    case(en)
    1'b1:c=a;
    default:c=b;
    endcase
end

endmodule
