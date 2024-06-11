module BPU(
    input clk,
    input rst,
    input stall_IF,
    input stall,
    input [4:0] E_op,
    input E_real_jump,
    
    input [31:0] inst,
    input [31:0] pc,
    output logic pred_jump,
    output logic [31:0] pc_pred,
    output logic t_pnt,
    output logic nt_pt
);
typedef enum logic [1:0] {  
    STRONGLY_NT, WEAKLY_NT, WEAKLY_T, STRONGLY_T
} stateType;

stateType state, nstate;

logic branch_inst;
logic [31:0] imm;
logic pred_jump_D, pred_jump_E;

logic [31:0] right_reg; 
logic [31:0] wrong_reg; 

assign branch_inst = (E_op==5'b11000);
assign imm = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
assign pc_pred = (pc + imm) & (~32'd1);

always_ff@(posedge clk or posedge rst)begin
    if(rst) state<=WEAKLY_NT;
    else begin
        if(stall_IF || stall) state<=state;
        else state<=nstate;
    end
end

always_comb begin
    case(state)
    STRONGLY_NT:begin
        if(branch_inst)begin
            if(E_real_jump) nstate=WEAKLY_NT;
            else nstate=STRONGLY_NT;
        end
        else nstate=STRONGLY_NT;
    end
    WEAKLY_NT:begin
        if(branch_inst)begin
            if(E_real_jump) nstate=WEAKLY_T;
            else nstate=STRONGLY_NT;
        end
        else nstate=WEAKLY_NT;
    end
    WEAKLY_T:begin
        if(branch_inst)begin
            if(E_real_jump) nstate=STRONGLY_T;
            else nstate=WEAKLY_NT;
        end
        else nstate=WEAKLY_T;
    end
    STRONGLY_T:begin
        if(branch_inst)begin
            if(E_real_jump) nstate=STRONGLY_T;
            else nstate=WEAKLY_T;
        end
        else nstate=STRONGLY_T;
    end
    endcase
end

always_comb begin
    case(inst[6:2]==5'b11000)
    1'b1:begin
        case(state)
        STRONGLY_NT:begin
            pred_jump=1'b0;
        end
        WEAKLY_NT:begin
            pred_jump=1'b0;
        end
        WEAKLY_T:begin
            pred_jump=1'b1;
        end
        STRONGLY_T:begin
            pred_jump=1'b1;
        end
        endcase    
    end
    default: pred_jump=1'b0;
    endcase
end

always_ff @(posedge clk or posedge rst)begin
    if(rst)begin
        right_reg<=32'b0;
        wrong_reg<=32'b0;
    end
    else begin
        if(stall_IF || stall)begin
            right_reg<=right_reg;
            wrong_reg<=wrong_reg; 
        end
        else begin
            if(branch_inst)begin
                case(state)
                STRONGLY_NT:begin
                    if(E_real_jump)begin
                        right_reg<=right_reg;
                        wrong_reg<=wrong_reg+32'b1;
                    end
                    else begin
                        right_reg<=right_reg+32'b1;
                        wrong_reg<=wrong_reg;
                    end
                end
                WEAKLY_NT:begin
                    if(E_real_jump)begin
                        right_reg<=right_reg;
                        wrong_reg<=wrong_reg+32'b1;
                    end
                    else begin
                        right_reg<=right_reg+32'b1;
                        wrong_reg<=wrong_reg;
                    end
                end
                WEAKLY_T:begin
                    if(E_real_jump)begin
                        right_reg<=right_reg+32'b1;
                        wrong_reg<=wrong_reg;
                    end
                    else begin
                        right_reg<=right_reg;
                        wrong_reg<=wrong_reg+32'b1;
                    end
                end
                STRONGLY_T:begin
                    if(E_real_jump)begin
                        right_reg<=right_reg+32'b1;
                        wrong_reg<=wrong_reg;
                    end
                    else begin
                        right_reg<=right_reg;
                        wrong_reg<=wrong_reg+32'b1;
                    end
                end
                endcase    
            end
            else begin
                right_reg<=right_reg;
                wrong_reg<=wrong_reg;
            end
        end
        
    end
end

always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        pred_jump_D<=1'b0;
        pred_jump_E<=1'b0;
    end
    else begin
        if(stall_IF || stall)begin
            pred_jump_D<=pred_jump_D;
            pred_jump_E<=pred_jump_E;
        end
        else begin
            pred_jump_D<=pred_jump;
            pred_jump_E<=pred_jump_D;
        end
    end        
end

always_comb begin
    if(E_real_jump && branch_inst) begin
        if(pred_jump_E)begin
            //taken but predict not taken
            t_pnt=1'b0;
            //not taken but predict taken
            nt_pt=1'b0;
        end
        else begin
            t_pnt=1'b1;
            nt_pt=1'b0;
        end
    end
    else if(~E_real_jump && branch_inst)begin
        if(pred_jump_E)begin
            t_pnt=1'b0;
            nt_pt=1'b1;
        end
        else begin
            t_pnt=1'b0;
            nt_pt=1'b0;
        end
    end
    else begin
        t_pnt=1'b0;
        nt_pt=1'b0;
    end
end

endmodule