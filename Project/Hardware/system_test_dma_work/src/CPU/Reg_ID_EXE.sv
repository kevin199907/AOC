module Reg_ID_EXE(
    input clk,
    input rst,
    input stall,
    input next_pc_sel, //�??確�??    
    input [31:0] pc,
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] sext_imm,
    input [31:0] inst_RegD,
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] sext_imm_out,
    output reg [31:0] inst_RegE,
    input stall_IF,
    input wfi_signal,
    input intr_ex,
    input intr_end_ex,
    input nt_pt,
    input t_pnt
);
always@(posedge clk or posedge rst)begin
    if(rst)begin
        pc_out<=32'd0;
        rs1_data_out<=32'd0;
        rs2_data_out<=32'd0;
        sext_imm_out<=32'd0;
        inst_RegE<=32'd0;
    end
    else begin
        // if(stall || next_pc_sel)begin
        //     pc_out<=32'd0;
        //     rs1_data_out<=32'd0;
        //     rs2_data_out<=32'd0;
        //     sext_imm_out<=32'd0;
        // end
        // else begin
        //     if(stall_IF)begin
        //         pc_out<=pc_out;
        //         rs1_data_out<=rs1_data_out;
        //         rs2_data_out<=rs2_data_out;
        //         sext_imm_out<=sext_imm_out;
        //     end
        //     else begin
        //         pc_out<=pc;
        //         rs1_data_out<=rs1_data;
        //         rs2_data_out<=rs2_data;
        //         sext_imm_out<=sext_imm;
        //     end
        // end

        if(stall_IF)begin
            pc_out<=pc_out;
            rs1_data_out<=rs1_data_out;
            rs2_data_out<=rs2_data_out;
            sext_imm_out<=sext_imm_out;
            inst_RegE<=inst_RegE;
        end
        else begin
            if(stall || next_pc_sel || wfi_signal || intr_ex || intr_end_ex || nt_pt || t_pnt)begin
                pc_out<=32'd0;
                rs1_data_out<=32'd0;
                rs2_data_out<=32'd0;
                sext_imm_out<=32'd0;
                inst_RegE<=32'd0;
            end
            else begin
                pc_out<=pc;
                rs1_data_out<=rs1_data;
                rs2_data_out<=rs2_data;
                sext_imm_out<=sext_imm;
                inst_RegE<=inst_RegD;
            end
        end
    end
end
endmodule
