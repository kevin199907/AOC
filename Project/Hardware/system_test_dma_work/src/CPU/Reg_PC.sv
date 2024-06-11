module Reg_PC (
input clk,
input rst,
input stall,
input [31:0] next_pc,
output reg [31:0] current_pc,
input stall_IF,
input wfi_signal,
input intr_ex,
input intr_t,
input intr_end_ex,
input [31:0] pc_csr,
input [31:0] pc_ra,
input [31:0] inst,

input [31:0] pred_pc,
input pred_jump,
input t_pnt,
input nt_pt
);
logic [31:0] original_pc;

always @(posedge clk or posedge rst ) begin
    if(rst) begin
        current_pc<=32'd0;
    end
    else begin        
        if(stall || stall_IF /*|| wfi_signal*/) current_pc<=current_pc;
        else if(inst == 32'h00008067) current_pc<=pc_ra;
        else if(nt_pt) current_pc<=original_pc+32'd4;
        else if(pred_jump) current_pc<=pred_pc;
        else if(wfi_signal) current_pc<=current_pc;
        else if(intr_ex || intr_end_ex || intr_t) current_pc<=pc_csr;
        else current_pc<=next_pc;
    end
end



always@(posedge clk or posedge rst)begin
    if(rst)begin
        original_pc<=32'd0;
    end
    else begin
        if(pred_jump)begin
            original_pc<=current_pc;
        end
        else begin
            original_pc<=original_pc;
        end
    end
end

endmodule
