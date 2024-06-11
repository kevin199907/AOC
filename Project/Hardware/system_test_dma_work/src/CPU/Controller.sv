module Controller(
    input clk, input rst,
    input [4:0] op, input [2:0] f3, input f7, input f7_mul,
    input [4:0] rd, input [4:0] rs1, input [4:0] rs2,
    input branch_en,

    output stall, output next_pc_sel,//output [3:0] im_w_en,
    output D_rs1_data_sel, output D_rs2_data_sel,

    output [1:0] E_rs1_data_sel, output [1:0] E_rs2_data_sel, output E_jb_op1_sel,
    output E_alu_op1_sel, output E_alu_op2_sel, output [4:0] E_op_out,
    output [2:0] E_f3_out, output E_f7_out, output E_f7_out_mul,

    output reg [3:0] M_dm_w_en, output reg [4:0] M_op, output logic [1:0] M_op_last2,

    output W_wb_en, output [4:0] W_rd_out, output [2:0] W_f3_out, output W_wb_data_sel,
	output logic OE, OE1,

    input stall_IF,
    input logic [1:0] op_last2,
    input rvalid,

    input t_pnt, nt_pt
);
//registers declaration
reg [4:0] E_op; reg [2:0] E_f3; reg E_f7, E_f7_mul;
reg [4:0] E_rd; reg [4:0] E_rs1; reg [4:0] E_rs2;
reg [4:0] W_op; reg [2:0] M_f3, W_f3; reg [4:0] M_rd, W_rd;
logic [1:0] E_op_last2,  W_op_last2;

wire is_D_rs1_W_rd_overlap, is_D_rs2_W_rd_overlap, is_D_use_rs1, is_D_use_rs2 , is_W_use_rd;
wire is_E_rs1_M_rd_overlap, is_E_rs1_W_rd_overlap, is_E_use_rs1, is_M_use_rd;
wire is_E_rs2_W_rd_overlap, is_E_rs2_M_rd_overlap, is_E_use_rs2;
wire is_DE_overlap, is_D_rs1_E_rd_overlap, is_D_rs2_E_rd_overlap;

logic E_wb_en, M_wb_en;

always@(posedge clk or posedge rst)begin
	if(rst)begin
		OE<=1'b0;
        OE1<=1'b0;
	end
	else begin
        OE1<=1'b1;
		if(stall) OE<=1'b1; //?????��?? ?????��??1'b0
		else OE<=1'b1;
	end
end


//E registers
always@(posedge clk or posedge rst)begin
    if(rst)begin
        E_op<=5'b00000; E_f3<=3'd0; E_rd<=5'd0; E_rs1<=5'd0; E_rs2<=5'd0; E_f7<=1'b0; E_f7_mul<=1'b0; E_op_last2<=2'b00;

    end
    else begin
        // if(stall || next_pc_sel)begin
        //     E_op<=5'd0; E_f3<=3'd0; E_rd<=5'd0; E_rs1<=5'd0; E_rs2<=5'd0; E_f7<=1'b0; E_f7_mul<=1'b0;
        // end
        // else begin
        //     if(stall_IF) begin
        //         E_op<=E_op; E_f3<=E_f3; E_rd<=E_rd; E_rs1<=E_rs1; E_rs2<=E_rs2; E_f7<=E_f7; E_f7_mul<=E_f7_mul;
        //     end
        //     else begin 
        //         E_op<=op; E_f3<=f3; E_rd<=rd; E_rs1<=rs1; E_rs2<=rs2; E_f7<=f7; E_f7_mul<=f7_mul;
        //     end
        // end

        if(stall_IF)begin
            E_op<=E_op; E_f3<=E_f3; E_rd<=E_rd; E_rs1<=E_rs1; E_rs2<=E_rs2; E_f7<=E_f7; E_f7_mul<=E_f7_mul; E_op_last2<=E_op_last2;
        end
        else begin
            if(stall || next_pc_sel || nt_pt || t_pnt)begin
                E_op<=5'b00000; E_f3<=3'd0; E_rd<=5'd0; E_rs1<=5'd0; E_rs2<=5'd0; E_f7<=1'b0; E_f7_mul<=1'b0; E_op_last2<=2'b00;
            end
            else begin 
                E_op<=op; E_f3<=f3; E_rd<=rd; E_rs1<=rs1; E_rs2<=rs2; E_f7<=f7; E_f7_mul<=f7_mul; E_op_last2<=op_last2;
            end
        end
    end
end

//M registers
always @(posedge clk or posedge rst) begin
    if (rst) begin
        M_op<=5'b00000; M_f3<=3'd0; M_rd<=5'd0; M_op_last2<=2'b00;
    end
    else begin
        if(stall_IF) begin
            M_op<=M_op; M_f3<=M_f3; M_rd<=M_rd;
            //??��?????�?DM IM �?�?DM�?�?�?�?read_sinal�???��??1
            if(rvalid) M_op_last2<=M_op_last2/*{2'b00}*/;
            else M_op_last2<=M_op_last2;
        end
        else begin
            M_op<=E_op; M_f3<=E_f3; M_rd<=E_rd; M_op_last2<=E_op_last2;
        end
    end
end

//W registers
always @(posedge clk or posedge rst) begin
    if (rst) begin
        W_op<=5'b00000; W_f3<=3'd0; W_rd<=5'd0; W_op_last2<=2'b00;
    end
    else begin
        if(stall_IF) begin
            W_op<=W_op; W_f3<=W_f3; W_rd<=W_rd; W_op_last2<=W_op_last2;
        end
        else begin
            W_op<=M_op; W_f3<=M_f3; W_rd<=M_rd; W_op_last2<=M_op_last2;
        end
    end
end

//D stage
//D_rs1_data_sel   forwarding is 1
assign D_rs1_data_sel = is_D_rs1_W_rd_overlap ? 1'b1 : 1'b0;
assign is_D_rs1_W_rd_overlap = is_D_use_rs1 & is_W_use_rd & (rs1 == W_rd) & W_rd != 5'b0;
assign is_D_use_rs1 = (rs1 != 5'b0) ? 1'b1 : 1'b0;
assign is_W_use_rd = (W_rd != 5'b0 && W_wb_en==1'b1) ? 1'b1 : 1'b0;//

//D_rs2_data_sel  forwarding is 1
assign D_rs2_data_sel = is_D_rs2_W_rd_overlap ? 1'b1 : 1'b0;
assign is_D_rs2_W_rd_overlap = is_D_use_rs2 & is_W_use_rd & (rs2 == W_rd) & W_rd != 5'b0;
assign is_D_use_rs2 = (rs2 != 5'b0) ? 1'b1 : 1'b0;
//assign is_W_use_rd = (W_rd != 5'b0) ? 1'b1 : 1'b0;

//E stage
//E_rs1_data_sel  0: W stage forwarding  1: M stage forwading 2: direct data 
assign E_rs1_data_sel = is_E_rs1_M_rd_overlap ? 2'd1 : 
        is_E_rs1_W_rd_overlap ? 2'd0 : 2'd2;
assign is_E_rs1_W_rd_overlap = is_E_use_rs1 & is_W_use_rd & (E_rs1 == W_rd) & W_rd != 5'b0;
assign is_E_rs1_M_rd_overlap = is_E_use_rs1 & is_M_use_rd & (E_rs1 == M_rd) & M_rd != 5'b0;
assign is_E_use_rs1 = (E_rs1 != 5'b0) ? 1'b1 : 1'b0;
//is_W_use_rd = ?
assign is_M_use_rd = (M_rd != 5'b0 & M_wb_en) ? 1'b1 : 1'b0;

//??��?��?? ??��?��?????
assign M_wb_en=(M_op==5'b01100||M_op==5'b00100||M_op==5'b01101||M_op==5'b00101||
    M_op==5'b11011||M_op==5'b11001||M_op==5'b00000||M_op==5'b11100)?1'b1:1'b0;

//E_rs2_data_sel  0: W stage forwarding  1: M stage forwading 2: direct data 
assign E_rs2_data_sel = is_E_rs2_M_rd_overlap ? 2'd1 : 
        is_E_rs2_W_rd_overlap ? 2'd0 : 2'd2;
assign is_E_rs2_W_rd_overlap = is_E_use_rs2 & is_W_use_rd & (E_rs2 == W_rd) & W_rd != 5'b0;
assign is_E_rs2_M_rd_overlap = is_E_use_rs2 & is_M_use_rd & (E_rs2 == M_rd) & M_rd != 5'b0;
assign is_E_use_rs2 = (E_rs2 != 5'b0) ? 1'b1 : 1'b0;
//is_W_use_rd = ?
//is_M_use_rd = ?

//jb_op1_sel ??�jal ???jb_op1_sel???1  (jalr???0)
//assign jb_op1_sel=(E_op==5'b11001||E_op==5'b11011)?1'b1:1'b0;
assign E_jb_op1_sel=(E_op==5'b11011||E_op==5'b11000)?1'b1:1'b0;

//alu_op1_sel ??�rs1??????1
assign E_alu_op1_sel=(E_op==5'b01100||E_op==5'b00100||E_op==5'b00000||E_op==5'b01000||E_op==5'b11000)?1'b1:1'b0;

//alu_op2_sel ??�rs2??????1
assign E_alu_op2_sel=(E_op==5'b11000||E_op==5'b01100)?1'b1:1'b0;

assign E_op_out=E_op;
assign E_f3_out=E_f3;
assign E_f7_out=E_f7;
assign E_f7_out_mul=E_f7_mul;




//M stage
//M_dm_w_en //??��?��??(???�???��??)
always @(*) begin
    if(M_op==5'b01000)begin
        case(M_f3)
            3'b000: M_dm_w_en=4'b0001;
            3'b001: M_dm_w_en=4'b0011;
            3'b010: M_dm_w_en=4'b1111;
            default: M_dm_w_en=4'b0000;
        endcase
    end
    else M_dm_w_en=4'b0000;
end


//W stage
//wb_en ??�表中�??�????rd??��??
assign W_wb_en=(W_op==5'b01100||W_op==5'b00100||W_op==5'b01101||W_op==5'b00101||
    W_op==5'b11011||W_op==5'b11001||W_op==5'b00000||W_op==5'b11100)?1'b1:1'b0;

//W_wb_data_sel ??�Load???wb_sel???1
assign W_wb_data_sel=(W_op==5'b00000)?1'b1:1'b0;

//W_rd_index
assign W_rd_out=W_rd;

assign W_f3_out=W_f3;

//stall 
assign stall = ((E_op == 5'b00000 ? 1'b1 : 1'b0) & is_DE_overlap) /*|((E_op == 5'b01100 ? 1'b1 : 1'b0) & E_f7_mul == 1'b1)*/;
assign is_DE_overlap = (is_D_rs1_E_rd_overlap | is_D_rs2_E_rd_overlap);
assign is_D_rs1_E_rd_overlap = is_D_use_rs1 & (rs1 == E_rd) & E_rd != 5'b0;
//is_D_use_rs1 = ?;
assign is_D_rs2_E_rd_overlap = is_D_use_rs2 & (rs2 == E_rd) & E_rd != 5'b0;
//is_D_use_rs2 = ?;


//next_pc_sel ???branch???1
// assign next_pc_sel=(branch_en && (E_op==5'b11011||E_op==5'b11001||E_op==5'b11000))?1'b1:1'b0;
assign next_pc_sel=((E_op==5'b11011||E_op==5'b11001)/*||(branch_en&&E_op==5'b11000)*/)?1'b1:1'b0;

endmodule
