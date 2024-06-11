module Reg_EXE_MEM(
    input clk,
    input rst,
    input [31:0] alu_out,
    input [31:0] rs2_data,
    input [31:0] mul,
    input [31:0] csr,
    input [31:0] div,
    output reg [31:0] alu_out_out,
    output reg [31:0] rs2_data_out,
    output logic [31:0] mul_out,
    output logic [31:0] csr_out,
    output logic [31:0] div_out,
    input stall_IF,
    input [31:0] inst_RegE,
    output logic [31:0] inst_RegM
);
always @(posedge clk or posedge rst) begin
    if(rst)begin
        alu_out_out<=32'd0;
        rs2_data_out<=32'd0;
        mul_out<=32'd0;
        csr_out<=32'd0;
        inst_RegM<=32'd0;
        div_out<=32'b0;
    end
    else begin
        if(stall_IF)begin
            alu_out_out<=alu_out_out;
            rs2_data_out<=rs2_data_out;
            mul_out<=mul_out;
            csr_out<=csr_out;
            inst_RegM<=inst_RegM;
            div_out<=div_out;
        end
        else begin
            alu_out_out<=alu_out;
            rs2_data_out<=rs2_data;
            mul_out<=mul;
            csr_out<=csr;
            inst_RegM<=inst_RegE;
            div_out<=div;
        end
    end
end
endmodule
