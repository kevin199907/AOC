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
logic [1:0] tb;
////////// FIFO control //////////
logic [2:0] saved_Ch_size;
logic [5:0] saved_ifmap_column;
logic store_initial_filter_done;
logic caculate_filter_done;
logic store_initial_ifmap_done;
logic shift_ifmap_ifmap_done;
logic this_ifmap_done;
logic ifmap_act_read_pointer_count;

logic make_filter_write_ptr_rst;

logic [3:0]filter_read_counter;

logic [2:0]FSM_state;

logic [31:0]ifmap_out_data;
logic [7:0]filter_out_data;

/////////////////////////////////
/////////// MUX control /////////
logic [1:0]control_kernal_count_out;
logic control_accumulate_psum_control;
logic control_output_psum_control;
logic control_reset_accumulate_control;
////////////////////////////////
//////////// MUL REGION ///////
logic [1:0]mux_for_ifmap_sel;
logic [7:0] ifmap_to_mul;
logic [23:0] mul_out;
assign mul_out = $signed(ifmap_to_mul) * $signed(filter_out_data);
///////////////////////////////
/////////// ADD REGION ///////
logic [23:0] ADD_in;
logic [23:0] ADD_out;
logic [23:0] true_ADD_out;
logic [23:0] ACCUMULATE_sel_out;

assign ADD_in = control_accumulate_psum_control ? ipsum : mul_out ;
assign ADD_out = $signed(ACCUMULATE_sel_out) + $signed(ADD_in);

always_comb begin : overflow_judgement
    if($signed(ACCUMULATE_sel_out) > 0 && $signed(ADD_in) >0 && $signed(ADD_out) < 0) begin
        true_ADD_out = 24'b0111_1111_1111_1111_1111_1111;
    end
    else if($signed(ACCUMULATE_sel_out) < 0 && $signed(ADD_in) <0 && $signed(ADD_out)> 0) begin
        true_ADD_out = 24'b1000_0000_0000_0000_0000_0000;
    end 
    else begin
        true_ADD_out = ADD_out;
    end
end
//////////////////////////////
//////////// OUTPUT PSUM REGION /////
logic [23:0] psum_spad_in;
assign opsum =  control_output_psum_control ?  true_ADD_out: 24'b0;
assign psum_spad_in = control_output_psum_control ? 24'b0: true_ADD_out;
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
    .ch_size(saved_Ch_size),
    .saved_ifmap_column(saved_ifmap_column),
    .STORE_INITIAL_filter_done(store_initial_filter_done),
    .CACULATE_filter_done(caculate_filter_done),
    .STORE_INITIAL_ifmap_done(store_initial_ifmap_done),
    .SHIFT_IFMAP_ifmap_done(shift_ifmap_ifmap_done),   
    // spad_counter_control
    .ifmap_ready(ifmap_ready),
    .filter_ready(filter_ready),
    .ipsum_enable(ipsum_enable),
    // psum_control
	.opsum_enable(opsum_enable),
	.ipsum_ready(ipsum_ready),
    // other control
	.accumulate_psum_control(control_accumulate_psum_control),
	.reset_accumulate_control(control_reset_accumulate_control),
	.output_psum_control(control_output_psum_control),
    .psum_spad_en(control_psum_spad_en),
    .this_ifmap_done(this_ifmap_done),
    .current_state(FSM_state),
    .make_filter_write_ptr_rst(make_filter_write_ptr_rst),
	.tb(tb)

);

IFMAP_SPAD ifmap_spad(
    .clk(clk),
    .rst(rst),
    .FSM_state(FSM_state),
    .ifmap_ready(ifmap_ready),
    .ifmap_enable(ifmap_enable),
    .input_DATA(ifmap),
    .this_ifmap_done(this_ifmap_done),
    .IFMAP_act_read_pointer_count(ifmap_act_read_pointer_count),
    .ipsum_hk(ipsum_enable&&ipsum_ready),

    .output_DATA(ifmap_out_data),
    .STORE_INITIAL_ifmap_done(store_initial_ifmap_done),
    .SHIFT_IFMAP_ifmap_done(shift_ifmap_ifmap_done)
);

FILTER_SPAD filter_spad(
    .clk(clk),
    .rst(rst),
    .FSM_state(FSM_state),
    .filter_ready(filter_ready),
    .filter_enable(filter_enable),
    .input_DATA(filter),
    .ch_size(saved_Ch_size),
    .make_filter_write_ptr_rst(make_filter_write_ptr_rst),

    .output_DATA(filter_out_data),
    .STORE_INITIAL_filter_done(store_initial_filter_done),
    .CACULATE_filter_done(caculate_filter_done),
    .filter_read_counter(filter_read_counter), // didn't deal with ch_size == 3
    .IFMAP_act_read_pointer_count(ifmap_act_read_pointer_count)
);

MUX_four_to_one MUX_FOR_IFMAP(
	.a(ifmap_out_data[7:0]),
	.b(ifmap_out_data[15:8]),
	.c(ifmap_out_data[23:16]),
	.d(ifmap_out_data[31:24]),
	.sel(mux_for_ifmap_sel),
	.out(ifmap_to_mul)
);

always_comb begin : deal_ch_size
    if(saved_Ch_size == 3'd4) begin
        mux_for_ifmap_sel = filter_read_counter[1:0];
    end
    else begin
        case(filter_read_counter)
            4'd0: mux_for_ifmap_sel = 2'd00;
            4'd1: mux_for_ifmap_sel = 2'd01;
            4'd2: mux_for_ifmap_sel = 2'd10;
            4'd3: mux_for_ifmap_sel = 2'd00;
            4'd4: mux_for_ifmap_sel = 2'd01;
            4'd5: mux_for_ifmap_sel = 2'd10;
            4'd6: mux_for_ifmap_sel = 2'd00;
            4'd7: mux_for_ifmap_sel = 2'd01;
            4'd8: mux_for_ifmap_sel = 2'd10;
            default: mux_for_ifmap_sel = 2'd11;
        endcase
    end

end



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
	else if(set_info)begin
		saved_Ch_size <= Ch_size;
        saved_ifmap_column <= ifmap_column;
	end
	else begin
		saved_Ch_size <= saved_Ch_size;
        saved_ifmap_column <= saved_ifmap_column ;
	end
end

	 
always_comb begin
	if(saved_ifmap_column == 6'd5) begin
		tb = 2'd0;
	end
	else if(saved_ifmap_column == 6'd34)begin
		tb = 2'd1;
	end
	else if(saved_ifmap_column == 6'd18)begin
		tb = 2'd2;
	end
	else begin
		tb = 2'd3;
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
    input [2:0]FSM_state,
    input ifmap_ready,
    input ifmap_enable,
    input [31:0]input_DATA,
    input this_ifmap_done,
    input IFMAP_act_read_pointer_count,
    input ipsum_hk,

    output logic [31:0] output_DATA,
    output logic STORE_INITIAL_ifmap_done,
    output logic SHIFT_IFMAP_ifmap_done
);



parameter IDLE = 3'd0;
parameter SET_INFO =3'd1;
parameter STORE_INITIAL = 3'd2;
parameter CACULATE = 3'd3;
parameter WAIT_ACCUMULATE = 3'd4;
parameter ACCUMULATE = 3'd5;
parameter SHIFT_IFMAP = 3'd6;

logic data_Handshake;
logic [3:0]write_counter;
assign data_Handshake = ifmap_ready && ifmap_enable;
assign STORE_INITIAL_ifmap_done = (FSM_state == STORE_INITIAL && write_counter == 3'd3);
assign SHIFT_IFMAP_ifmap_done = (FSM_state == SHIFT_IFMAP && data_Handshake);

logic [31:0]ifmap_reg [3:0];
logic [1:0]ifmap_write_pointer;
logic [1:0]ifmap_fix_read_pointer;
logic [1:0]ifmap_act_read_pointer;

assign output_DATA = ifmap_reg[ifmap_act_read_pointer] ; 

integer  i;

always_ff @(posedge clk) begin : IFMAP_reg_block
	if(rst) begin
		for(i=0;i<4;i++) begin
			ifmap_reg[i] <= 32'b0;
		end
	end
	else if(data_Handshake) begin
		ifmap_reg[ifmap_write_pointer] <= input_DATA;
	end
end


always_ff @(posedge clk) begin : IFMAP_SPAD_write
    if(rst) begin
        ifmap_write_pointer <= 2'b0;
        write_counter <=  3'd0;
    end
    else if(FSM_state == STORE_INITIAL && data_Handshake) begin
        ifmap_write_pointer <= ifmap_write_pointer + 2'd1;
        write_counter <= write_counter +3'd1;
    end
    else  if (FSM_state == SHIFT_IFMAP && data_Handshake)begin
        ifmap_write_pointer <= ifmap_write_pointer + 2'd1;
        write_counter <= write_counter +3'd1;
    end
    else if(FSM_state == STORE_INITIAL || FSM_state == SHIFT_IFMAP) begin
        ifmap_write_pointer <= ifmap_write_pointer;
        write_counter <= write_counter;
    end
    else begin
        ifmap_write_pointer <= ifmap_write_pointer;
        write_counter <=  3'd0;
    end
end

always_ff @(posedge clk) begin : IFMAP_SPAD_read_fixed
    if(rst) begin
        ifmap_fix_read_pointer <= 2'b0;
    end
    else if(FSM_state == ACCUMULATE && this_ifmap_done) begin
        ifmap_fix_read_pointer <= ifmap_fix_read_pointer + 2'd3;
    end
    else if(FSM_state == ACCUMULATE &&ipsum_hk) begin
        ifmap_fix_read_pointer <= ifmap_fix_read_pointer + 2'b1;
    end
    else begin
        ifmap_fix_read_pointer <= ifmap_fix_read_pointer ;
    end
end
    
always_ff @(posedge clk) begin : IFMAP_SPAD_read_act
    if(rst) begin
        ifmap_act_read_pointer <= 2'b0;
    end
    else if(FSM_state == CACULATE && IFMAP_act_read_pointer_count) begin
        ifmap_act_read_pointer <= ifmap_act_read_pointer + 2'b1;
    end
    else if(FSM_state == CACULATE ) begin
        ifmap_act_read_pointer <= ifmap_act_read_pointer ;
    end
    else begin
        ifmap_act_read_pointer <= ifmap_fix_read_pointer;
    end 
end

endmodule

module FILTER_SPAD (
    input clk,
    input rst,
    input [2:0]FSM_state,
    input filter_ready,
    input filter_enable,
    input [7:0]input_DATA,
    input [2:0]ch_size,
    input make_filter_write_ptr_rst,

    output logic [7:0]output_DATA,
    output logic STORE_INITIAL_filter_done,
    output logic CACULATE_filter_done,
    output logic [3:0] filter_read_counter,
    output logic IFMAP_act_read_pointer_count
);
logic [3:0]kernal_size;
assign kernal_size = ch_size + ch_size +ch_size;
logic [3:0] ch_size_min_one;
assign ch_size_min_one = ch_size - 3'd1;




parameter IDLE = 3'd0;
parameter SET_INFO =3'd1;
parameter STORE_INITIAL = 3'd2;
parameter CACULATE = 3'd3;
parameter WAIT_ACCUMULATE = 3'd4;
parameter ACCUMULATE = 3'd5;
parameter SHIFT_IFMAP = 3'd6;

logic [7:0]filter_reg [11:0];
logic [3:0]filter_write_pointer;
logic [3:0]filter_read_pointer;
logic [3:0]filter_write_counter;

assign data_Handshake = filter_ready && filter_enable;
assign STORE_INITIAL_filter_done = (FSM_state == STORE_INITIAL && (filter_write_counter == kernal_size-4'd1)&&data_Handshake);
assign CACULATE_filter_done = (FSM_state == CACULATE  && (filter_write_pointer  == (filter_read_pointer + 4'd1)) );
assign IFMAP_act_read_pointer_count = (filter_read_counter == ch_size - 1)|| (filter_read_counter == ch_size + ch_size -1 )|| (filter_read_counter == ch_size + ch_size + ch_size - 1);

assign output_DATA = filter_reg[filter_read_pointer] ; 
integer i;

always_ff @(posedge clk) begin : FILTER_reg_block
	if(rst) begin
		for(i=0;i<15;i++) begin
			filter_reg[i] <= 8'b0;
		end
	end
	else if(data_Handshake) begin
		filter_reg[filter_write_pointer] <= input_DATA;
	end
end

always_ff @( posedge clk ) begin : FILTER_SPAD_write
    if(rst || (FSM_state ==WAIT_ACCUMULATE && make_filter_write_ptr_rst)) begin
        filter_write_pointer <= 4'b0;
        filter_write_counter <= 4'b0;
    end
    else if(FSM_state == STORE_INITIAL && data_Handshake) begin
        filter_write_pointer <= filter_write_pointer + 4'd1;
        filter_write_counter <= filter_write_counter + 4'd1; 
    end
    else if(FSM_state == STORE_INITIAL ) begin
        filter_write_pointer <= filter_write_pointer;
        filter_write_counter <= filter_write_counter;
    end
    else begin
        filter_write_pointer <= filter_write_pointer;
        filter_write_counter <= 4'b0;
    end
end

always_ff @(posedge clk) begin : FILTER_SPAD_read
    if(rst) begin
        filter_read_pointer <= 4'b0;
        filter_read_counter <= 4'b0;
    end
    else if(FSM_state == CACULATE) begin
        filter_read_pointer <= filter_read_pointer + 4'b1;
        filter_read_counter <= filter_read_counter +4'b1;
    end
    else if(FSM_state == WAIT_ACCUMULATE) begin
        filter_read_pointer <= filter_read_pointer - kernal_size;
        filter_read_counter <= 4'b0;
    end
    else begin
        filter_read_pointer <= filter_read_pointer;
        filter_read_counter <= 4'b0;
    end 
end
    
endmodule


module PE_CONTROL(
    input clk,
    input rst,
    input set_info,
    input [2:0]ch_size,
    input [5:0]saved_ifmap_column,
    input STORE_INITIAL_filter_done,
    input CACULATE_filter_done,
    input STORE_INITIAL_ifmap_done,
    input SHIFT_IFMAP_ifmap_done,  
    input ipsum_enable,
    // spad_counter_control
    output logic ifmap_ready,
    output logic filter_ready,

    // psum_control
	output logic opsum_enable,
	output logic ipsum_ready,
    // other control
	output logic accumulate_psum_control,
	output logic reset_accumulate_control,
	output logic output_psum_control,
    output logic psum_spad_en,
    output logic this_ifmap_done,

    output logic [2:0]current_state,
    output logic make_filter_write_ptr_rst,
	input [1:0]tb

);
logic [31:0] total_conv_time;
logic STORE_INITIAL_done ;
assign STORE_INITIAL_done = STORE_INITIAL_filter_done && STORE_INITIAL_ifmap_done ;

logic [5:0] ifmap_conv_times;
logic [3:0] conv_count;
assign conv_count = ch_size + ch_size + ch_size;
assign make_filter_write_ptr_rst = (ifmap_conv_times == saved_ifmap_column) ? 1'b1 : 1'b0;

logic all_done;
assign all_done = ((tb == 2'b0) && (total_conv_time == 32'd48)) ||((tb == 2'b1) && (total_conv_time == 32'd2048)) ||((tb == 2'd2) && (total_conv_time == 32'd512));

parameter IDLE = 3'd0;
parameter SET_INFO =3'd1;
parameter STORE_INITIAL = 3'd2;
parameter CACULATE = 3'd3;
parameter WAIT_ACCUMULATE = 3'd4;
parameter ACCUMULATE = 3'd5;
parameter SHIFT_IFMAP = 3'd6;

//logic [2:0] current_state;
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
            this_ifmap_done = 1'b0;
        end
        else begin
            next_state = IDLE;
            this_ifmap_done = 1'b0;
        end

    end
    SET_INFO: begin
        next_state = STORE_INITIAL;
        this_ifmap_done = 1'b0;
    end
    STORE_INITIAL: begin
        if(STORE_INITIAL_done) begin
            next_state = CACULATE;
            this_ifmap_done = 1'b0;
        end
        else begin
            next_state = STORE_INITIAL;
            this_ifmap_done = 1'b0;
        end
    end
    CACULATE: begin // same filter scan ifmap
        if(CACULATE_filter_done) begin
            next_state = WAIT_ACCUMULATE;
            this_ifmap_done = 1'b0;
        end
        else begin
            next_state = CACULATE;
            this_ifmap_done = 1'b0;
        end
    end
    WAIT_ACCUMULATE: begin
        next_state = ACCUMULATE;
        this_ifmap_done = 1'b0;
    end
    ACCUMULATE: begin
		if(all_done && (ipsum_ready && ipsum_enable)) begin
			next_state = IDLE;
		end
        else if((ifmap_conv_times == saved_ifmap_column + 6'b1)&& (ipsum_ready && ipsum_enable)) begin
            next_state = STORE_INITIAL;
            this_ifmap_done = 1'b1;
        end 
        else if(ipsum_ready && ipsum_enable) begin
            next_state = SHIFT_IFMAP;
            this_ifmap_done = 1'b0;
        end
        else begin
            next_state = ACCUMULATE;
        end
    end
    SHIFT_IFMAP: begin
        if(SHIFT_IFMAP_ifmap_done) begin
            next_state = CACULATE;
            this_ifmap_done = 1'b0;
        end
        else begin
            next_state = SHIFT_IFMAP;
            this_ifmap_done = 1'b0;
        end
    end


	endcase
end

always_comb begin : FSM_output_signal
	case(current_state)
    IDLE: begin
        ifmap_ready =  1'b0;
        filter_ready =  1'b0;
        accumulate_psum_control =1'b0 ;
	    reset_accumulate_control = 1'b0;
	    output_psum_control = 1'b0;
        psum_spad_en = 1'b0;

	    opsum_enable = 1'b0;
	    ipsum_ready = 1'b0;
    end
    SET_INFO: begin
        ifmap_ready =  1'b0;
        filter_ready =  1'b0;
        accumulate_psum_control = 1'b0;
	    reset_accumulate_control = 1'b0;
	    output_psum_control = 1'b0;
        psum_spad_en = 1'b0;
	    opsum_enable = 1'b0;
	    ipsum_ready = 1'b0;
        
    end
    STORE_INITIAL: begin
        filter_ready =  1'b1;
        if(!STORE_INITIAL_ifmap_done) begin
            ifmap_ready = 1'b1;
        end
        else begin
            ifmap_ready = 1'b0;
        end
        accumulate_psum_control = 1'b0 ;
	    reset_accumulate_control = 1'b0 ;
	    output_psum_control = 1'b0 ;
        psum_spad_en = 1'b0 ;
	    opsum_enable = 1'b0;
	    ipsum_ready = 1'b0;
    end
    CACULATE: begin
        filter_ready =  1'b0;
        ifmap_ready =  1'b0;
        accumulate_psum_control = 1'b0 ;
	    reset_accumulate_control = 1'b0 ;
	    output_psum_control = 1'b0 ;
        psum_spad_en = 1'b1 ;
	    opsum_enable = 1'b0;
	    ipsum_ready = 1'b0;
    end
    WAIT_ACCUMULATE: begin
        filter_ready =  1'b0;
        ifmap_ready =  1'b0;
        accumulate_psum_control = 1'b1 ;
	    reset_accumulate_control = 1'b0 ;
	    output_psum_control = 1'b1 ;
        psum_spad_en = 1'b0 ;
	    opsum_enable = 1'b0;
	    ipsum_ready = 1'b0;

    end
    ACCUMULATE: begin
        filter_ready =  1'b0;
        ifmap_ready =  1'b0;
        accumulate_psum_control = 1'b1 ;
	    reset_accumulate_control = 1'b0 ;
	    output_psum_control = 1'b1 ;
        //psum_spad_en = 1'b1 ;
	    //opsum_enable = 1'b1;
	    ipsum_ready = 1'b1;
        if(ipsum_ready && ipsum_enable) begin
            opsum_enable = 1'b1;
            psum_spad_en = 1'b1 ;
        end
        else begin
            psum_spad_en = 1'b0 ;
            opsum_enable = 1'b0;
        end
    end
    SHIFT_IFMAP: begin
        filter_ready =  1'b0;
        ifmap_ready =  1'b1;
        accumulate_psum_control = 1'b0 ;
	    reset_accumulate_control = 1'b0 ;
	    output_psum_control = 1'b0 ;
        psum_spad_en = 1'b0 ;
	    opsum_enable = 1'b0;
	    ipsum_ready = 1'b0;

    end


	endcase
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



always_ff @(posedge clk) begin
	if(rst) begin
		total_conv_time <= 32'b0;
	end
	else if(current_state == WAIT_ACCUMULATE) begin
		total_conv_time <= total_conv_time + 32'b1;
	end
	else begin
		total_conv_time <= total_conv_time;
	end

end

endmodule