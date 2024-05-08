//`include "def.svh"

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
logic [5:0] saved_ifmap_column;
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
        saved_ifmap_column <= 6'b0;
	end
	else if(control_info_setting)begin
		saved_Ch_size <= Ch_size;
        saved_ifmap_column <= ifmap_column;
	end
	else begin
		saved_Ch_size <= saved_Ch_size;
        saved_ifmap_column <= saved_ifmap_column ;
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

module IFMAP_SPAD (
    input clk,
    input rst,
    input ifmap_spad_write_ptr_count,
    input ifmap_spad_read_fixed_ptr_count,
    input ifmap_pad_read_act_ptr_count
);

logic [31:0]ifmap_reg [3:0];
logic [1:0] write_pointer;


always_ff @(posedge clk) begin : IFMAP_SPAD_write_ptr
    if(rst) begin
        write_pointer <= 2'b0;
    end
    else if(ifmap_spad_write_ptr_count) begin
        write_pointer <= write_pointer + 2'd1;
    end
    else begin
        write_pointer <= write_pointer;
    end
end

always_ff @(posedge clk) begin : IFMAP_SPAD_read_fixed_ptr
    if(rst) begin
        fix_read_pointer <= 2'b0;
    end
    else if(ifmap_spad_read_fixed_ptr_count) begin
        fix_read_pointer <= fix_read_pointer + 2'b1;
    end
    else begin
        fix_read_pointer <= fix_read_pointer ;
    end
end
    
always_ff @(posedge clk) begin : IFMAP_SPAD_read_act_ptr
    if(rst) begin
        act_read_pointer <= 2'b0;
    end
    else if(ifmap_pad_read_act_ptr_count) begin
        act_read_pointer <= act_read_pointer + 2'b1;
    end
    else begin
        act_read_pointer <= fix_read_pointer;
    end 
end

endmodule

module FILTER_SPAD (
    input clk,
    input rst
);


    
endmodule


module PE_CONTROL(
    input clk,
    input rst,
    input [2:0]ch_size,
    input filter_ready,
    input ifmap_ready,
    input [5:0]ifmap_column,


    output logic filter_spad_write_ptr_count,
    output logic filter_spad_read_ptr_count,
    output logic ifmap_spad_write_ptr_count,
    output logic ifmap_pad_read_act_ptr_count,
    output logic ifmap_spad_read_fixed_ptr_count  

);
logic [3:0] conv_count;
assign conv_count = ch_size + ch_size + ch_size;
logic [3:0] ch_size_min_one;
assign ch_size_min_one = ch_size - 3'd1;

// counter //
logic [3:0] store_initial_counter;
logic [3:0] filter_counter;
////////////


parameter IDLE = 3'd0;
parameter SET_INFO =3'd1;
parameter STORE_INITIAL = 3'd2;
parameter CACULATE = 3'd3;
parameter WAIT_ACCUMULATE = 3'd4;
parameter ACCUMULATE = 3'd5;
parameter SHIFT_IFMAP = 3'd6;

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
        next_state = STORE_INITIAL;
    end
    STORE_INITIAL: begin
        if(store_initial_counter == conv_count - 4'd1) begin
            next_state = CACULATE;
        end
        else begin
            next_state = STORE_INITIAL;
        end
    end
    CACULATE: begin // same filter scan ifmap
        if(filter_counter == conv_count - 4'd1) begin
            next_state = WAIT_ACCUMULATE;
        end
        else begin
            next_state = CACULATE;
        end
    end
    WAIT_ACCUMULATE: begin
        next_state = ACCUMULATE;
    end
    ACCUMULATE: begin
        if(!filter_ready && !ifmap_ready) begin
            next_state = IDLE;
        end
        else if(ifmap_conv_times == ifmap_column) begin
            next_state = STORE_INITIAL;
        end else begin
            next_state = SHIFT_IFMAP;
        end
    end
    SHIFT_IFMAP: begin

    end


	endcase
end

always_comb begin : FSM_output_signal
	case(current_state)
    IDLE: begin

    end
    SET_INFO: begin

    end
    STORE_INITIAL: begin
        filter_spad_write_ptr_count = 1'b1;
        if(store_initial_counter < 4'd3 )
            ifmap_spad_write_ptr_count = 1'b1;
        else begin
            ifmap_spad_write_ptr_count = 1'b1;
        end

    end
    CACULATE: begin
        filter_spad_read_ptr_count = 1'b1;
        if(filter_counter == ch_size_min_one || filter_counter == (ch_size_min_one+ch_size_min_one) || filter_counter == (ch_size_min_one+ch_size_min_one+ch_size_min_one) ) begin
            ifmap_pad_read_act_ptr_count = 1'b1;
        end
        else begin
            ifmap_pad_read_act_ptr_count = 1'b0;
        end
    end
    WAIT_ACCUMULATE: begin
        ipsum_ready = 1'b1;
        opsum_enable = 1'b0;
        ifmap_conv_times_count = 1'b1;
    end
    ACCUMULATE: begin
        ipsum_ready = 1'b1;
        opsum_enable = 1'b1;
    end
    SHIFT_IFMAP: begin
        ifmap_spad_write_ptr_count = 1'b1;
        ifmap_spad_read_fixed_ptr_count  = 1'b1;

    end


	endcase
end



always_ff @(posedge clk) begin : _STORE_INITIAL_COUNTER
    if(rst) begin
        store_initial_counter <= 4'd0;
    end
    else if(current_state == STORE_INITIAL)begin
        store_initial_counter <= store_initial_counter + 4'd1;
    end
    else if(current_state == !STORE_INITIAL)begin
        store_initial_counter <= 4'd0;
    end
end

always_ff @( posedge clk ) begin : CACULATE_FILTER_COUNTER // caculate how much cycle in CACLUATE state
    if(rst) begin
        filter_counter <= 4'b0;
    end
    else if(filter_spad_read_ptr_count) begin
        filter_counter <= filter_counter + 4'd1;
    end
    else begin
        filter_counter <= 4'b0;
    end
end


always_ff @( posedge clk ) begin : _IFMAP_CONV_TIMES
    if(rst) begin
        ifmap_conv_times <= 6'b0;
    end
    else if(current_state == WAIT_ACCUMULATE) begin
        ifmap_conv_times <= ifmap_conv_times + 6'd1;
    end
    else if(current_state == STORE_INITIAL)begin
        ifmap_conv_times <= 6'd3;
    end
    else begin
        ifmap_conv_times <= ifmap_conv_times ;
    end
end

endmodule