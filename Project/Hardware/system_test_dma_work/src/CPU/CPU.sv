// `include "ALU.sv"
// `include "Controller.sv"
// `include "CSR.sv"
// `include "Decoder.sv"
// `include "Imm_Ext.sv"
// `include "JB_Unit.sv"
// `include "LD_Filter.sv"
// `include "Mul.sv"
// `include "Mux_3.sv"
// `include "MUX_fordelay.sv"
// `include "Mux.sv"
// `include "Reg_EXE_MEM.sv"
// `include "Reg_ID_EXE.sv"
// `include "Reg_IF_ID.sv"
// `include "Reg_MEM_WB.sv"
// `include "Reg_PC.sv"
// `include "RegFile.sv"
// // `include "SRAM_wrapper.sv"
// `include "wen_shift.sv"
// `include "Adder.sv"
// // `include "Slave_Read.sv"
// `include "Master_Read.sv"
// //`include "Bridge_Read.sv"
// `include "Master_Write.sv"
// // `include "Slave_Write.sv"
// //`include "Bridge_Write.sv"
`include "AXI_define.svh"

module CPU(
    input clk,
    input rst,

	//M0 port
	output logic read_signal_IM, 
	output logic [31:0] pc_32, 
	input [31:0] inst, 
	input stall_IM, 
	input rvalid_out0,

	output logic [1:0] MW_state, 
	output logic [1:0] MW_nstate,
	input [1:0] MR_state, 
	input [1:0] MR_nstate,

	//M1 read port
	output logic read_signal, 
	output logic [31:0] alu_mul_csr, 

	input [31:0] ld_data/*_in*/, 
	input stall_DM, 
	input rvalid_out1,

	//M1 write port
	output logic [3:0] M_dm_w_en_out, 
	output logic [31:0] rs2_data_RegM_out, 
	output logic [3:0] id_in_W, 
	output logic write_signal,
	output logic [31:0] inst_RegM,

	input stall_W,

	input interrupt_e,
	input interrupt_t,
	input hit_data,
	output wfi_signal
);

//---------------declare------------//
	logic [31:0] next_pc, sext_imme, jb_c, jb_pc, rs1_data, rs2_data, inst_memdelay, mul_RegM, csr_RegM, ld_data_reg/*, ld_data*/, ld_data_monkey;
	wire [31:0] alu_out_32, ld_data_f, wb_data, operand1, operand2; 
	// wire [15:0]  alu_out_16;
	wire [4:0] rs1_index, rs2_index, rd_index, opcode, E_op;
	wire [2:0] func3, E_f3, W_f3;
	logic func7, E_f7, branch_en, next_pc_sel;
	logic delay_en,csr_en, func7_mul;
	logic mul_en, OE, OE1;
	logic [31:0] csr_o, new_rs2_data_CSR, mul_out;

	wire [31:0] pc_RegD, inst_RegD, rs1_data_mux, rs2_data_mux, pc_RegE, rs1_data_RegE, rs2_data_RegE, sext_imm_RegE;
	wire [4:0] W_rd_index;
	wire stall, D_rs1_data_sel, D_rs2_data_sel, E_jb_op1_sel, E_alu_op1_sel, E_alu_op2_sel;
	wire [1:0] E_rs1_data_sel, E_rs2_data_sel;
	wire [3:0] M_dm_w_en;

	wire [31:0] alu_out_RegM, new_rs1_data, new_rs2_data, rs2_data_RegM, alu_out_RegW;

	logic [31:0] ld_data_RegW, ld_data_orignal, ld_data_mux;
	logic [4:0] M_op;
	logic [1:0] M_op_last2;
	logic [1:0] op_last2;


	logic [13:0]                address_in_W; 
	logic [3:0]                 w_en_W;
	logic [`AXI_DATA_BITS-1:0]  data_in_W;      

	logic [31:0] data_out_W, address_out_W;
	logic [3:0] w_en_out_M;

	logic stall_IF;

	logic [13:0] address_in; logic[3:0] id_in;
	logic [31:0] data_out;

	logic [13:0] address_out; logic [31:0] data_in;

	logic [31:0] address_out_DM;

	logic [31:0] address_into_sram;

	logic [31:0] rs1_reg, rs2_reg, rs1_data_out, rs2_data_out;
	logic stall_IFD;

	logic stall_MEM;
	logic [31:0] ld_data_temp;
	logic isnot_FREE_W;

	logic [31:0] inst_RegE;

	logic  mie, meie, mtie, intr_ex, intr_t, intr_end_ex, intr_end_t;
	logic [31:0] pc_csr;

	logic write_signal_delay;

	logic real_jump, pred_jump;
	logic [31:0] pc_pred;

	logic t_pnt, nt_pt;

	logic stall_div;
	logic [31:0] div_out;	

	logic div_en;
	logic [31:0] div_RegM;

	logic [31:0] ra;

//---------------declare------------//


always@(posedge clk or posedge rst) begin
	if(rst) read_signal_IM<=1'b1;
	else read_signal_IM<=1'b1;
end


Controller controller(	
	.clk(clk), 
	.rst(rst), 
	.op(opcode), 	
	.f3(func3), 
	.f7(func7), 
	.f7_mul(func7_mul), 
	.rd(rd_index), 
	.rs1(rs1_index), 
	.rs2(rs2_index), 
	.branch_en(branch_en), 
	.stall(stall), 
	.next_pc_sel(next_pc_sel), 
	.D_rs1_data_sel(D_rs1_data_sel), 
	.D_rs2_data_sel(D_rs2_data_sel),
	.E_rs1_data_sel(E_rs1_data_sel), 
	.E_rs2_data_sel(E_rs2_data_sel), 
	.E_jb_op1_sel(E_jb_op1_sel),
	.E_alu_op1_sel(E_alu_op1_sel), 
	.E_alu_op2_sel(E_alu_op2_sel), 
	.E_op_out(E_op), 
	.E_f3_out(E_f3), 
	.E_f7_out(E_f7), 
	.E_f7_out_mul(E_f7_mul),
	.M_dm_w_en(M_dm_w_en), 
	.M_op(M_op), 
	.M_op_last2(M_op_last2),
	.W_wb_en(W_wb_en), 
	.W_rd_out(W_rd_index), 
	.W_f3_out(W_f3), 
	.W_wb_data_sel(W_wb_data_sel), 
	.OE(OE), 
	.OE1(OE1),
	.stall_IF(stall_IF), 
	.op_last2(op_last2), 
	.rvalid(rvalid_out1),
	.nt_pt(nt_pt),
	.t_pnt(t_pnt)
);

BPU BPU(
    .clk(clk),
    .rst(rst),
	.stall_IF(stall_IF),
	.stall(stall),
	.E_real_jump(branch_en),
	.E_op(E_op),

    .inst(inst),
    .pc(pc_32),

    .pred_jump(pred_jump),
    .pc_pred(pc_pred),

	.t_pnt(t_pnt),
	.nt_pt(nt_pt)
);

Mux mux_pc(.a(jb_pc), .b(pc_32+32'd4), .en(next_pc_sel || t_pnt), .c(next_pc)); 

Reg_PC regpc(.clk(clk), 
			 .rst(rst), 
			 .stall(stall), 
			 .next_pc(next_pc), 
			 .current_pc(pc_32), 
			 .stall_IF(stall_IF),
			 .wfi_signal(wfi_signal),
			 .intr_ex(intr_ex),
			 .intr_t(intr_t),
			 .intr_end_ex(intr_end_ex),
			 .pc_csr(pc_csr),
			 .pc_ra(ra),
			 .inst(inst),

			 .pred_pc(pc_pred),
			 .pred_jump(pred_jump),
			 .t_pnt(t_pnt),
			 .nt_pt(nt_pt)
			 );

// assign stall_IF=stall_IM & stall_W;
assign stall_IF=stall_IM | stall_DM | stall_div;
			
Reg_IF_ID reg_if_id(.clk(clk), 
					.rst(rst), 
					.stall(stall), 
					.next_pc_sel(next_pc_sel), 
					.pc(pc_32), 
					.inst(inst), 
					.pc_out(pc_RegD), 
					.inst_out(inst_RegD), 
					.stall_IF(stall_IF),
					.wfi_signal(wfi_signal),
					.intr_ex(intr_ex),
					.intr_end_ex(intr_end_ex),
					.nt_pt(nt_pt),
					.t_pnt(t_pnt)
					);


always@(posedge clk or posedge rst)begin
	if(rst) delay_en<=1'b0;
    else begin
        if(stall_IF) delay_en<=delay_en;
        else delay_en<=(stall||next_pc_sel||t_pnt||nt_pt);
    end
end


MUX_fordelay mux_memdelay(.a(inst_RegD), .b(inst), .en(/*delay_en||(pc_32==32'b0)*/1'b1), .c(inst_memdelay));

Decoder decoder(
	.inst(inst_memdelay), 
	.dc_out_opcode(opcode), 
	.dc_out_func3(func3), 
	.dc_out_func7(func7), 
	.dc_out_rs1_index(rs1_index), 
	.dc_out_rs2_index(rs2_index), 
	.dc_out_rd_index(rd_index), 
	.dc_out_func7_mul(func7_mul), 
	.dc_out_last2(op_last2)
);

Imm_Ext imm_ext(.inst(inst_memdelay), .imm_ext_out(sext_imme));

RegFile regfile(
	.clk(clk), 
	.rst(rst), 
	.wb_en(W_wb_en), 
	.wb_data(wb_data), 
	.W_rd_index(W_rd_index), 
	.rs1_index(rs1_index), 
	.rs2_index(rs2_index), 
	.rs1_data_out(rs1_data), 
	.rs2_data_out(rs2_data),
	.Ra(ra)
);

always@(posedge clk or posedge rst)begin
	if(rst)begin
		rs1_reg<=32'b0;
		rs2_reg<=32'b0;
	end
	else begin
		// rs1_reg<=rs1_data;
		// rs2_reg<=rs2_data;
		if(~stall_IFD)begin
			rs1_reg<=rs1_data;
			rs2_reg<=rs2_data;
		end
		else begin
			rs1_reg<=rs1_reg;
			rs2_reg<=rs2_reg;
		end
	end
end

always@(posedge clk or posedge rst )begin
	if(rst)begin
		stall_IFD<=1'b0;
	end
	else begin
		stall_IFD<=stall_IF;
	end
end

assign rs1_data_out=(~stall_IFD)?rs1_data:rs1_reg;
assign rs2_data_out=(~stall_IFD)?rs2_data:rs2_reg;

Mux mux_rs1_fw(.a(wb_data), .b(rs1_data_out), .en(D_rs1_data_sel), .c(rs1_data_mux));
Mux mux_rs2_fw(.a(wb_data), .b(rs2_data_out), .en(D_rs2_data_sel), .c(rs2_data_mux));

Reg_ID_EXE reg_id_exe(
	.clk(clk), 
	.rst(rst), 
	.stall(stall), 
	.next_pc_sel(next_pc_sel), 
	.pc(pc_RegD), 
	.rs1_data(rs1_data_mux), 
	.rs2_data(rs2_data_mux), 
	.sext_imm(sext_imme), 
	.pc_out(pc_RegE), 
	.rs1_data_out(rs1_data_RegE), 
	.rs2_data_out(rs2_data_RegE), 
	.sext_imm_out(sext_imm_RegE),
	.stall_IF(stall_IF), 
	.inst_RegD(inst_RegD), 
	.inst_RegE(inst_RegE),
	.wfi_signal(wfi_signal),
	.intr_ex(intr_ex),
	.intr_end_ex(intr_end_ex),
	.nt_pt(nt_pt),
	.t_pnt(t_pnt)
);


INTR_CONTROLLER intr_contoller(
    .clk(clk),
    .rst(rst),
    .inst(inst_RegE),

    .interrupt_e(interrupt_e),
    .interrupt_t(interrupt_t), //from sensor wrapper

    .mie(mie),
    .meie(meie),
    .mtie(mtie),
	
    .intr_ex(intr_ex),
    .intr_t(intr_t),
    .intr_end_ex(intr_end_ex),
    .intr_end_t(intr_end_t),
    .wfi_signal(wfi_signal),

	.stall_IF(stall_IF) 
);



Mux_3 mux_3_rs1(.a(wb_data), .b(alu_mul_csr), .c(rs1_data_RegE), .en(E_rs1_data_sel), .d(new_rs1_data));
Mux_3 mux_3_rs2(.a(wb_data), .b(alu_mul_csr), .c(rs2_data_RegE), .en(E_rs2_data_sel), .d(new_rs2_data));

Mux mux_rs1_pc(.a(new_rs1_data), .b(pc_RegE), .en(E_alu_op1_sel), .c(operand1));
Mux mux_rs2_imm(.a(new_rs2_data), .b(sext_imm_RegE), .en(E_alu_op2_sel), .c(operand2)); 

Mux mux_jb(.a(pc_RegE), .b(new_rs1_data), .en(E_jb_op1_sel), .c(jb_c));

ALU alu(.opcode(E_op), .func3(E_f3), .func7(E_f7), .operand1(operand1), .operand2(operand2), .alu_out(alu_out_32));
// assign alu_out_16=alu_out_32[15:0];

Mul mul(.opcode(E_op), .func3(E_f3), .func7_mul(E_f7_mul), .operand1(operand1), .operand2(operand2), .mul_out(mul_out));

Div div(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .stall_IF(stall_IM | stall_DM),
    .opcode(E_op),
    .func3(E_f3),
    .func7_div(E_f7_mul),
    .operand1(operand1),
    .operand2(operand2),
    .div_out(div_out),
    .stall_div(stall_div)
);



JB_Unit jb_unit(.opcode(E_op), .operand1(jb_c), .operand2(sext_imm_RegE), .jb_out(jb_pc));

CSR csr(.clk(clk), 
		.rst(rst), 
		.imm_ext(sext_imm_RegE[11:0]), 
		.E_pc(pc_RegE), 
		.D_pc(pc_RegD),
		.pc_32(pc_32),
		.csr_o(csr_o), 
		.stall(stall), 
		.next_pc_sel(next_pc_sel), 
		.stall_IF(stall_IF),
		.intr_ex(intr_ex), 
		.intr_t(intr_t), 
		.intr_end_ex(intr_end_ex), 
		.intr_end_t(intr_end_t),
		.rs1_data(new_rs1_data), 
		.E_inst(inst_RegE),
		.pc_csr(pc_csr),
		.mie_out(mie),
		.meie_out(meie),
		.mtie_out(mtie),
		.wfi_signal(wfi_signal)
		);

always@(posedge clk or posedge rst )begin
    if(rst)begin
        mul_en<=1'b0;
        csr_en<=1'b0;
		div_en<=1'b0;
    end
    else begin
        if(stall_IF)begin
            mul_en<=mul_en;
            csr_en<=csr_en;
			div_en<=div_en;
        end
        else begin
            mul_en<=((E_op==5'b01100) && E_f7_mul && (E_f3==3'b000||E_f3==3'b001||E_f3==3'b010||E_f3==3'b011))?1'b1:1'b0;
            csr_en<=(E_op==5'b11100)?1'b1:1'b0;
			div_en<=((E_op==5'b01100) && E_f7_mul && (E_f3==3'b100||E_f3==3'b101||E_f3==3'b110||E_f3==3'b111))?1'b1:1'b0;
        end
    end
end

Reg_EXE_MEM reg_exe_mem(
	.clk(clk), 
	.rst(rst), 
	.alu_out(alu_out_32), 
	.rs2_data(new_rs2_data), 
	.alu_out_out(alu_out_RegM), 
	.rs2_data_out(rs2_data_RegM), 
	.mul(mul_out),	
	.csr(csr_o),
	.div(div_out), 
	.mul_out(mul_RegM), 
	.csr_out(csr_RegM), 
	.div_out(div_RegM),
	.stall_IF(stall_IF),
	.inst_RegE(inst_RegE),
	.inst_RegM(inst_RegM)
);

// Mux_3 mux_new(.a(alu_out_RegM), .b(mul_RegM), .c(csr_RegM), .d(div_RegM), .en({csr_en, mul_en, div_en}), .d(alu_mul_csr));

always@(*)begin
    case({csr_en, mul_en, div_en})
    3'b100:alu_mul_csr=csr_RegM;
    3'b010:alu_mul_csr=mul_RegM;
	3'b001:alu_mul_csr=div_RegM;
    default:alu_mul_csr=alu_out_RegM;
    endcase
end


wen_shift wen_shift(
	.last_two(alu_mul_csr[1:0]), 
	.w_en(M_dm_w_en), 
	.wen_shift_out(M_dm_w_en_out), 
	.mem_data(rs2_data_RegM), 
	.mem_data_out(rs2_data_RegM_out)
);

assign read_signal=({M_op, M_op_last2}==7'b0000011 /*&& ~stall_IF*/);

// assign write_signal=(M_op==5'b01000)?1'b1:1'b0;

// always@(posedge clk or posedge rst)begin
// 	if(rst)begin
// 		write_signal_delay<=1'b0;
// 	end
// 	else begin
// 		if(M_op==5'b01000) write_signal_delay<=1'b1;
// 		else write_signal_delay<=1'b0;
// 	end
// end
assign write_signal/*_delay*/=(M_op==5'b01000 && stall_IF)?1'b1:1'b0;

assign id_in_W=8'b0;


// always_ff@(posedge clk or posedge rst) begin
// 	if(rst) begin
// 		ld_data_reg<=32'b0;
// 		ld_data_monkey<=32'b0;
// 	end
// 	else begin
// 		if(~stall_IF)begin
// 			ld_data_reg<=ld_data_in;
// 		end
// 		else ld_data_reg<=ld_data_reg;
// 		ld_data_monkey<=ld_data;
// 	end
// end

// assign ld_data=(stall_IF)?ld_data_reg:ld_data_in;





Reg_MEM_WB reg_mem_wb(
	.clk(clk), 
	.rst(rst), 
	.alu_out(alu_mul_csr), 
	.ld_data(ld_data), 
	.alu_out_out(alu_out_RegW), 
	.ld_data_RegW(ld_data_RegW), 
	.stall_IF(stall_IF), 
	.rvalid(rvalid_out1), 
	.ld_data_orignal(ld_data_orignal)
);

assign ld_data_mux=(stall_IFD)?ld_data:ld_data_RegW;
// assign ld_data_mux=(~stall_IF)?ld_data/*_orignal*/:ld_data_RegW;

logic [31:0] ld_data_kkkekek;
always_ff@(posedge clk or posedge rst )begin
	if(rst)begin
		ld_data_kkkekek<=32'b0;
	end
	else begin
		if(~stall_IF) ld_data_kkkekek<=ld_data;
		else ld_data_kkkekek<=ld_data_RegW;
	end
end

// assign ld_data_mux=ld_data;
logic [31:0] ld_data_hit;
logic hit_delay,hit_delay_delay;
assign ld_data_hit = (hit_data&&hit_delay)?(ld_data_RegW):((hit_data&&~hit_delay)?ld_data_mux:ld_data_RegW);
// assign ld_data_hit = (hit_data&&hit_delay)?((hit_delay_delay&&hit_delay&&hit_data&&~stall_IF&&stall_IFD)?ld_data_mux:ld_data_RegW):((hit_data&&~hit_delay)?ld_data_mux:ld_data_RegW);

always_ff@(posedge clk or posedge rst)begin
	if(rst)begin
		hit_delay<=1'b0;
	end
	else begin
		hit_delay<=hit_data;
	end
end
always_ff@(posedge clk or posedge rst)begin
	if(rst)begin
		hit_delay_delay<=1'b0;
	end
	else begin
		hit_delay_delay<=hit_delay;
	end
end
LD_Filter ld_filter(
	.func3(W_f3), 
	.ld_data(ld_data_RegW/*_RegW*//*_mux*/), /*_RegW*/
	.ld_data_f(ld_data_f), 
	.W_lasttwo(alu_out_RegW[1:0])
);

Mux mux_ld_alu(.a(ld_data_f), .b(alu_out_RegW), .en(W_wb_data_sel), .c(wb_data));

assign branch_en=alu_out_32[0]/* && inst_RegE[6:2]==5'b11000*/;

endmodule
