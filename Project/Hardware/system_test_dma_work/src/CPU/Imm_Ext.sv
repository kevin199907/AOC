module Imm_Ext (
input [31:0] inst,
output reg [31:0] imm_ext_out
);
parameter   R_type = 5'b01100,
            I_type = 5'b00100,
            U_lui = 5'b01101,
            U_auipc = 5'b00101,
            I_jalr = 5'b11001,
            J_jal = 5'b11011,
            B_type = 5'b11000,
            I_Load = 5'b00000,
            Store = 5'b01000,
            CSR = 5'b11100;
always @(*) begin
    case(inst[6:2])
    I_type, I_Load, I_jalr, CSR: imm_ext_out={{20{inst[31]}},inst[31:20]};
    Store: imm_ext_out={{20{inst[31]}},inst[31:25],inst[11:7]};
    B_type: imm_ext_out={{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
    U_lui, U_auipc: imm_ext_out={inst[31:12],12'b0};
    J_jal: imm_ext_out={{12{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0};
    default: imm_ext_out=32'b0;

    endcase
end


endmodule