`include "def.svh"

module PE (
	input clk,
	input rst,
	//Layer setting 
	input set_info,
	input [2:0] Ch_size,
	input [5:0] ifmap_column,
	input [5:0] ofmap_column,
	input [3:0] ifmap_Quant_size,
	input [3:0] filter_Quant_size,
	//data to PE.sv
	input filter_enable,
	input [7:0] filter,		
	input ifmap_enable,
	input [31:0] ifmap,
	input ipsum_enable,
	input [`Psum_BITS-1:0] ipsum, 
	input opsum_ready,
	//data from PE.sv
	output logic  filter_ready,
	output logic  ifmap_ready,	
	output logic  ipsum_ready,
	output logic  [`Psum_BITS-1:0] opsum,
	output logic  opsum_enable
); 
////////// FIFO control //////////
logic control_info_setting;
logic [2:0] saved_Ch_size;
logic filter_FIFO_empty;
logic filter_FIFO_full;
logic ifmap_FIFO_empty;
logic ifmap_FIFO_full;
logic control_ifmap_en;
logic control_filter_en;

logic [31:0]ifmap_FIFO_out_data;
logic [7:0]filter_FIFO_out_data;

assign filter_ready = !filter_FIFO_full;
assign ifmap_ready = !ifmap_FIFO_full;
/////////////////////////////////
/////////// MUX control /////////
logic [1:0]control_kernal_count_out;
logic control_accumulate_psum_control;
logic control_output_psum_control;
logic control_reset_accumulate_control;
////////////////////////////////
//////////// MUL REGION ///////
logic [7:0] ifmap_to_mul;
logic [23:0] mul_out;
assign mul_out = ifmap_to_mul * filter_FIFO_out_data;
///////////////////////////////
/////////// ADD REGION ///////
logic [23:0] ADD_in;
logic [23:0] ADD_out;
logic [23:0] ACCUMULATE_sel_out;

assign ADD_in = control_accumulate_psum_control ? ipsum : mul_out ;
assign ADD_out = ACCUMULATE_sel_out + ADD_in;
//////////////////////////////
//////////// OUTPUT PSUM REGION /////
logic [23:0] psum_spad_in;
assign opsum =  control_output_psum_control ? ADD_out: 24'b0;
assign psum_spad_in = control_output_psum_control ? 24'b0:ADD_out;
//////////////////////////////////

/////////// PSUM_SPAD region //////
logic [23:0] psum_spad_out;
logic control_psum_spad_en;

assign ACCUMULATE_sel_out = control_reset_accumulate_control ? 24'b0 : psum_spad_out;

//////////////////////////////////

PE_CONTROL PE_CONTROL (
	.clk(clk),
	.rst(rst),
	.set_info(set_info),
	.filter_FIFO_empty(filter_FIFO_empty),
	.ifmap_FIFO_empty(ifmap_FIFO_empty),
	.Ch_size(saved_Ch_size),
	.ipsum_enable(ipsum_enable),
	.opsum_ready(opsum_ready),
	.accumulate_psum_control(control_accumulate_psum_control),
	.reset_accumulate_control(control_reset_accumulate_control),
	.output_psum_control(control_output_psum_control),
	.kernal_count_out(control_kernal_count_out), 
	.psum_spad_en(control_psum_spad_en),
	.ifmap_spad_en(control_ifmap_en),
	.filter_spad_en(control_filter_en),
	.opsum_enable(opsum_enable),
	.ipsum_ready(ipsum_ready),
	.control_info_setting(control_info_setting)

);

FIFO #(.DATA_WIDTH(32), .ADDR_AMOUNT(4), .POINTER_WIDTH(3))IFMAP_SPAD(
	.clk(clk),
	.rst(rst),
	.input_en(ifmap_enable),
	.output_en(control_ifmap_en),
	.input_DATA(ifmap),
	.output_DATA(ifmap_FIFO_out_data),
	.FIFO_empty(ifmap_FIFO_empty),
	.FIFO_full(ifmap_FIFO_full)
);

FIFO #(.DATA_WIDTH(8), .ADDR_AMOUNT(16), .POINTER_WIDTH(5))FILTER_SPAD(
	.clk(clk),
	.rst(rst),
	.input_en(filter_enable),
	.output_en(control_filter_en),
	.input_DATA(filter),
	.output_DATA(filter_FIFO_out_data),
	.FIFO_empty(filter_FIFO_empty),
	.FIFO_full(filter_FIFO_full)
);

MUX_four_to_one MUX_FOR_IFMAP(
	.a(ifmap_FIFO_out_data[7:0]),
	.b(ifmap_FIFO_out_data[15:8]),
	.c(ifmap_FIFO_out_data[23:16]),
	.d(ifmap_FIFO_out_data[31:24]),
	.sel(control_kernal_count_out),
	.out(ifmap_to_mul)
);


always_ff @(posedge clk) begin: psum_spad_en
	if(rst) begin
		psum_spad_out <= 24'b0;
	end
	else if(control_psum_spad_en) begin
		psum_spad_out <= psum_spad_in;
	end
	else begin
		psum_spad_out <= psum_spad_out ;
	end

end


always_ff @(posedge clk) begin : INFO_reg
	if(rst) begin
		saved_Ch_size <= 3'b0;
	end
	else if(control_info_setting)begin
		saved_Ch_size <= Ch_size;
	end
	else begin
		saved_Ch_size <= saved_Ch_size;
	end
end


	 
endmodule



module FIFO #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_AMOUNT = 4,
	parameter POINTER_WIDTH = 3 // pointer width = addr_amount take 2's exp +1
)
(
	input clk,
	input rst,
	input input_en,
	input output_en,
	input [DATA_WIDTH-1:0]input_DATA,
	output logic [DATA_WIDTH-1:0]output_DATA,
	output logic FIFO_empty,
	output logic FIFO_full
);

integer  i;

logic [POINTER_WIDTH-1:0] write_pointer;
logic [POINTER_WIDTH-1:0] read_pointer;
logic [DATA_WIDTH-1:0] FIFO_reg [ADDR_AMOUNT-1:0];
logic write_pt_en;
assign write_pt_en = !FIFO_full && input_en;
assign read_pt_en = !FIFO_empty && output_en;

assign output_DATA = FIFO_reg[read_pointer];
assign FIFO_full = (write_pointer[POINTER_WIDTH-2:0] == read_pointer[POINTER_WIDTH-2:0] && write_pointer[POINTER_WIDTH-1]!=read_pointer[POINTER_WIDTH-1])? 1'b1 : 1'b0;
assign FIFO_empty = (write_pointer == read_pointer) ? 1'b1 : 1'b0;

always_ff @(posedge clk) begin : FIFO_reg_block
	if(rst) begin
		for(i=0;i<ADDR_AMOUNT;i++) begin
			FIFO_reg[i] <= {DATA_WIDTH{1'b0}};
		end
	end
	else if(write_pt_en) begin
		FIFO_reg[write_pointer] <= input_DATA;
	end
end

always_ff @( posedge clk ) begin : write_pointer_block
	if(rst) begin
		write_pointer <= {POINTER_WIDTH{1'b0}};
	end
	else if(write_pt_en) begin
		write_pointer <= write_pointer + 1 ;
	end
	else begin
		write_pointer <= write_pointer;
	end
	
end

always_ff @( posedge clk ) begin : read_pointer_block
	if(rst) begin
		read_pointer <= {POINTER_WIDTH{1'b0}};
	end
	else if(read_pt_en) begin
		read_pointer <= read_pointer + 1 ;
	end
	else begin
		read_pointer <= read_pointer;
	end
	
end


endmodule

module PE_CONTROL (
	input clk,
	input rst,
	input set_info,
	input filter_FIFO_empty,
	input ifmap_FIFO_empty,
	input [2:0]Ch_size,
	input ipsum_enable,
	input opsum_ready,


	output logic accumulate_psum_control,
	output logic reset_accumulate_control,
	output logic output_psum_control,
	output logic [1:0] kernal_count_out, // above this line is for mux 
	output logic psum_spad_en, // psum_reg enable
	output logic ifmap_spad_en,
	output logic filter_spad_en,
	output logic opsum_enable,
	output logic ipsum_ready,
	output logic control_info_setting

);

///// counter wire //////
logic [1:0] ifmap_count_out;
logic [6:0] conv_count_out;
logic conv_count;
logic ifmap_count;
/////////////////////////
///// control wire //////
logic kernal_count;
/////////////////////////

parameter IDLE = 3'd0;
parameter SET_INFO = 3'd1;
parameter CAL_KERNAL = 3'd2;
parameter ACCUMULATE = 3'd3;
parameter WAIT_ACCUMULATE = 3'd4;

logic [2:0] current_state;
logic [2:0] next_state;

always_ff @( posedge clk ) begin : FSM_update_block
	if(rst) begin
		current_state <= 3'd0;
	end
	else begin
		current_state <= next_state;
	end
end

always_comb begin : FSM_state_flaw
	case(current_state)
		IDLE: begin
			if(set_info) begin
				next_state = SET_INFO;
			end
			else begin
				next_state = IDLE;
			end
		end

		SET_INFO: begin
			next_state = CAL_KERNAL;
			// if(/*!(filter_FIFO_empty || ifmap_FIFO_empty)*/set_info) begin
			// 	next_state = CAL_KERNAL;
			// end
			// else begin
			// 	next_state = SET_INFO;
			// end

		end

		CAL_KERNAL: begin
			if(ifmap_count_out == 2'd3 && ifmap_count && ipsum_enable && opsum_ready) begin
				next_state = ACCUMULATE;
			end
			else if(ifmap_count_out == 2'd3 && ifmap_count && !(ipsum_enable || opsum_ready ))begin
				next_state = WAIT_ACCUMULATE;
			end
			else begin
				next_state = CAL_KERNAL;
			end
		end

		ACCUMULATE: begin
			if(opsum_ready != 0) begin
				next_state = CAL_KERNAL;
			end
			else begin
				next_state = ACCUMULATE;
			end

		end

		WAIT_ACCUMULATE: begin
			if(ipsum_enable) begin
				next_state = ACCUMULATE;
			end
			else begin
				next_state = WAIT_ACCUMULATE;
			end

		end

	endcase
end

always_comb begin: FSM_output_signal
	case(current_state)
		IDLE: begin
			kernal_count = 1'b0;
			accumulate_psum_control = 1'b0;
			reset_accumulate_control = 1'b0; 
			output_psum_control = 1'b0;
			psum_spad_en = 1'b0;
			ifmap_spad_en = 1'b0;
			filter_spad_en = 1'b0;
			opsum_enable = 1'b0;
			ipsum_ready = 1'b0;
			control_info_setting = 1'b0;
		end

		SET_INFO: begin

			kernal_count = 1'b0;
			accumulate_psum_control = 1'b0;
			reset_accumulate_control = 1'b0; 
			output_psum_control = 1'b0;
			psum_spad_en = 1'b0;
			ifmap_spad_en = 1'b1;
			filter_spad_en = 1'b1;		
			opsum_enable = 1'b0;
			ipsum_ready = 1'b0;		
			control_info_setting = 1'b1;
		end

		CAL_KERNAL: begin

			kernal_count = 1'b1;
			accumulate_psum_control = 1'b0;
			reset_accumulate_control = 1'b0; 
			output_psum_control = 1'b0;
			psum_spad_en = 1'b1;
			ifmap_spad_en = 1'b1;
			filter_spad_en = 1'b1;	
			opsum_enable = 1'b0;
			ipsum_ready = 1'b0;	
			control_info_setting = 1'b0;			

		end

		ACCUMULATE: begin
			kernal_count = 1'b0;
			accumulate_psum_control = 1'b1;
			reset_accumulate_control = 1'b1 ;
			output_psum_control = 1'b1;
			psum_spad_en = 1'b0;
			ifmap_spad_en = 1'b1;
			filter_spad_en = 1'b1;	
			opsum_enable = 1'b1;
			ipsum_ready = 1'b1;	
			control_info_setting = 1'b0;
		end

		WAIT_ACCUMULATE: begin
			kernal_count = 1'b0;
			accumulate_psum_control = 1'b1;
			reset_accumulate_control = 1'b1 ;
			output_psum_control = 1'b1;
			psum_spad_en = 1'b0;
			ifmap_spad_en = 1'b1;
			filter_spad_en = 1'b1;	
			opsum_enable = 1'b0;
			ipsum_ready = 1'b0;	
			control_info_setting = 1'b0;
		end

	endcase	
end

logic [2:0]temp_Ch_size;
assign temp_Ch_size = Ch_size -3'd1;

assign ifmap_count = (kernal_count_out == temp_Ch_size[1:0]) ? 1'b1 : 1'b0;
assign conv_count = ((kernal_count_out == temp_Ch_size[1:0])&&(ifmap_count_out == 2'd3)) ?1'b1:1'b0;

always_ff @( posedge clk ) begin : Counter_for_ifmap
	if(rst) begin
		ifmap_count_out <= 2'b0;
	end	
	else if(ifmap_count) begin
		ifmap_count_out <= ifmap_count_out + 2'd1;
	end
	else begin
		ifmap_count_out <= ifmap_count_out;
	end
end

always_ff @( posedge clk ) begin : Counter_for_kernal
	if(rst) begin
		kernal_count_out <= 2'b0;
	end	
	else if(kernal_count) begin
		if(kernal_count_out == Ch_size -1 ) begin
			kernal_count_out <= 2'b0;
		end
		else begin
			kernal_count_out <= kernal_count_out + 2'd1;
		end
	end
	else begin
		kernal_count_out <= kernal_count_out;
	end
end

always_ff @( posedge clk ) begin : Counter_for_conv
	if(rst) begin
		conv_count_out <= 7'b0;
	end	
	else if(conv_count) begin
		conv_count_out <= conv_count_out + 7'd1;
	end
	else begin
		conv_count_out <= conv_count_out;
	end
end
	

endmodule	

module MUX_four_to_one(
	input [7:0] a,
	input [7:0] b,
	input [7:0] c,
	input [7:0] d,
	input [1:0] sel,
	output logic [7:0] out
);
always_comb begin
	case(sel)
		2'd0: out = a;
		2'd1: out = b;
		2'd2: out = c;
		2'd3: out = d;

	endcase
end

endmodule