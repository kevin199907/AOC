`include "../include/def.svh"
module Mul_hybrid (
	input	[7:0]	ifmap,			//input feature map
	input	[7:0]	filter, 		//filter
	input	[3:0]	ifmap_Quant_size,
	input	[3:0]	filter_Quant_size,
	output	logic	[`Psum_BITS-1:0]	product
);

// ifmap as multiplicater
logic [2:0] obseve_reg0;
logic [2:0] obseve_reg1;
logic [2:0] obseve_reg2;
logic [2:0] obseve_reg3;

parameter ADD = 2'b01;
parameter SUB = 2'b10;

logic [14:0]multiplicand_extend;
logic [6:0]multiplicand_extend_tb1_f0;
logic [6:0]multiplicand_extend_tb1_f1;

logic [2:0]multiplicand_extend_tb2_f0;
logic [2:0]multiplicand_extend_tb2_f1;

assign multiplicand_extend = {{7{filter[7]}},filter};
assign multiplicand_extend_tb1_f0 = {{3{filter[3]}},filter[3:0]};
assign multiplicand_extend_tb1_f1 = {{3{filter[7]}},filter[7:4]};

assign multiplicand_extend_tb2_f0 = {filter[1], filter[1:0]};
assign multiplicand_extend_tb2_f1 = {filter[5], filter[5:4]};

logic [22:0]temp_product;

logic right_extend_bit;
assign right_extend_bit = 1'b0;



logic [1:0]mode;
parameter TB0 = 2'd0 ;
parameter TB1 = 2'd1 ;
parameter TB2 = 2'd2 ;


logic [14:0]multiplicater_weight_zero;
logic [14:0]multiplicater_weight_one;
logic [14:0]multiplicater_weight_two;
logic [14:0]multiplicater_weight_three;
logic [14:0]multiplicater_weight_four;
logic [14:0]multiplicater_weight_five;
logic [14:0]multiplicater_weight_six ;
logic [14:0]multiplicater_weight_seven ;

logic [3:0]shift_bits_index_zero;
logic [3:0]shift_bits_index_one;
logic [3:0]shift_bits_index_two;
logic [3:0]shift_bits_index_three;
logic [3:0]shift_bits_index_four;
logic [3:0]shift_bits_index_five;
logic [3:0]shift_bits_index_six;
logic [3:0]shift_bits_index_seven;


logic [1:0]multiplicater_zero;
logic [1:0]multiplicater_one;
logic [1:0]multiplicater_two;
logic [1:0]multiplicater_three;
logic [1:0]multiplicater_four;
logic [1:0]multiplicater_five;
logic [1:0]multiplicater_six;
logic [1:0]multiplicater_seven;


logic [23:0]mul_out;

always_comb begin
	if(ifmap_Quant_size == 4'd8 && filter_Quant_size == 4'd8) begin
		mode = TB0;
		shift_bits_index_one = 4'd1;
		shift_bits_index_two = 4'd2;
		shift_bits_index_three = 4'd3;
		shift_bits_index_four = 4'd4;
		shift_bits_index_five = 4'd5;
		shift_bits_index_six = 4'd6;
		shift_bits_index_seven = 4'd7;
		multiplicater_zero ={ifmap[0] , right_extend_bit} ;
		multiplicater_one = {ifmap[1] , ifmap[0]} ;
		multiplicater_two = {ifmap[2] , ifmap[1]} ;
		multiplicater_three = {ifmap[3] , ifmap[2]} ;
		multiplicater_four = {ifmap[4] , ifmap[3]} ;
		multiplicater_five = {ifmap[5] , ifmap[4]} ;
		multiplicater_six = {ifmap[6] , ifmap[5]} ;
		multiplicater_seven = {ifmap[7] , ifmap[6]} ;

	end
	else if(ifmap_Quant_size == 4'd4 && filter_Quant_size == 4'd4) begin
		mode = TB1;
		shift_bits_index_one = 4'd1;
		shift_bits_index_two = 4'd2;
		shift_bits_index_three = 4'd3;
		// dont care four
		shift_bits_index_four = 4'd4;
		//
		shift_bits_index_five = 4'd1;
		shift_bits_index_six = 4'd2;
		shift_bits_index_seven = 4'd3;

		multiplicater_zero ={ifmap[0] , right_extend_bit} ;
		multiplicater_one = {ifmap[1] , ifmap[0]} ;
		multiplicater_two = {ifmap[2] , ifmap[1]} ;
		multiplicater_three = {ifmap[3] , ifmap[2]} ;

		multiplicater_four = {ifmap[4] , right_extend_bit} ;
		multiplicater_five = {ifmap[5] , ifmap[4]} ;
		multiplicater_six = {ifmap[6] , ifmap[5]} ;
		multiplicater_seven = {ifmap[7] , ifmap[6]} ;
	end
	else if(ifmap_Quant_size == 4'd2 && filter_Quant_size == 4'd2) begin
		mode = TB2;
		shift_bits_index_one = 4'd1;
		// dont care below
		shift_bits_index_two = 4'd2;
		shift_bits_index_three = 4'd3;
		shift_bits_index_four = 4'd4;
		shift_bits_index_five = 4'd1;
		shift_bits_index_six = 4'd2;
		shift_bits_index_seven = 4'd3;

		multiplicater_zero ={ifmap[0] , right_extend_bit} ;
		multiplicater_one = {ifmap[1] , ifmap[0]} ;
		//don't care
		multiplicater_two = {ifmap[2] , ifmap[1]} ;
		multiplicater_three = {ifmap[3] , ifmap[2]} ;
		//
		multiplicater_four = {ifmap[4] , right_extend_bit} ;
		multiplicater_five = {ifmap[5] , ifmap[4]} ;

		//don't care
		multiplicater_six = {ifmap[6] , ifmap[5]} ;
		multiplicater_seven = {ifmap[7] , ifmap[6]} ;

	end
	else begin
		mode = TB0;
	end
end

always_comb begin
	if(mode == TB0) begin
		case(multiplicater_zero)
			ADD: multiplicater_weight_zero = multiplicand_extend;
			SUB: multiplicater_weight_zero = ~(multiplicand_extend) +15'b1;
			default: multiplicater_weight_zero =15'b0;
		endcase
		
		case(multiplicater_one)
			ADD: multiplicater_weight_one = multiplicand_extend << shift_bits_index_one;
			SUB: multiplicater_weight_one = (~(multiplicand_extend) +15'b1) << shift_bits_index_one;
			default: multiplicater_weight_one =15'b0;			
		endcase

		case(multiplicater_two)
			ADD: multiplicater_weight_two = multiplicand_extend << shift_bits_index_two;
			SUB: multiplicater_weight_two = (~(multiplicand_extend) +15'b1) << shift_bits_index_two;
			default: multiplicater_weight_two =15'b0;	
		endcase

		case(multiplicater_three)
			ADD: multiplicater_weight_three = multiplicand_extend << shift_bits_index_three;
			SUB: multiplicater_weight_three = (~(multiplicand_extend) +15'b1) << shift_bits_index_three;
			default: multiplicater_weight_three =15'b0;	
		endcase
		
		case(multiplicater_four)
			ADD: multiplicater_weight_four = multiplicand_extend << shift_bits_index_four;
			SUB: multiplicater_weight_four = (~(multiplicand_extend) +15'b1) << shift_bits_index_four;
			default: multiplicater_weight_four =15'b0;	
		endcase

		case(multiplicater_five)
			ADD: multiplicater_weight_five = multiplicand_extend << shift_bits_index_five;
			SUB: multiplicater_weight_five = (~(multiplicand_extend) +15'b1) << shift_bits_index_five;
			default: multiplicater_weight_five =15'b0;	
		endcase

		case(multiplicater_six)
			ADD: multiplicater_weight_six = multiplicand_extend << shift_bits_index_six;
			SUB: multiplicater_weight_six = (~(multiplicand_extend) +15'b1) << shift_bits_index_six;
			default: multiplicater_weight_six =15'b0;	
		endcase
	
		case(multiplicater_seven)
			ADD: multiplicater_weight_seven = multiplicand_extend << shift_bits_index_seven;
			SUB: multiplicater_weight_seven = (~(multiplicand_extend) +15'b1) << shift_bits_index_seven;
			default: multiplicater_weight_seven =15'b0;	
		endcase	


		temp_product = multiplicater_weight_seven + multiplicater_weight_six + multiplicater_weight_five + multiplicater_weight_four + 
				  multiplicater_weight_three + multiplicater_weight_two + multiplicater_weight_one + multiplicater_weight_zero ;
		
		if(temp_product == 15'b100_0000_0000_0000) begin
			product = {9'b0,temp_product[14:0]};
		end
		else begin
			product = {{9{temp_product[14]}},temp_product[14:0]};
		end
	end

	else if(mode == TB1) begin
		case(multiplicater_zero)
			ADD: begin
				multiplicater_weight_zero[6:0] = multiplicand_extend_tb1_f0;
				multiplicater_weight_four[6:0] = multiplicand_extend_tb1_f1;
			end
			SUB: begin
				multiplicater_weight_zero[6:0] = ~(multiplicand_extend_tb1_f0) +7'b1;
				multiplicater_weight_four[6:0] = (~(multiplicand_extend_tb1_f1) +7'b1) ;
			end 
			default: begin
				multiplicater_weight_zero =15'b0;
				multiplicater_weight_four =15'b0;
			end 
		endcase
		
		case(multiplicater_one)
			ADD: begin
				multiplicater_weight_one[6:0] = multiplicand_extend_tb1_f0 << shift_bits_index_one;
				multiplicater_weight_five[6:0] = multiplicand_extend_tb1_f1 << shift_bits_index_five;
			end 
			SUB: begin
				multiplicater_weight_one[6:0] = (~(multiplicand_extend_tb1_f0) +7'b1) << shift_bits_index_one;
				multiplicater_weight_five[6:0] = (~(multiplicand_extend_tb1_f1) +7'b1) << shift_bits_index_five;
			end 
			default: begin
				multiplicater_weight_one =15'b0;	
				multiplicater_weight_five =15'b0;	
			end		
		endcase

		case(multiplicater_two)
			ADD: begin
				multiplicater_weight_two[6:0] = multiplicand_extend_tb1_f0 << shift_bits_index_two;
				multiplicater_weight_six[6:0] = multiplicand_extend_tb1_f1 << shift_bits_index_six;
			end 
			SUB: begin
				multiplicater_weight_two[6:0] = (~(multiplicand_extend_tb1_f0) +7'b1) << shift_bits_index_two;
				multiplicater_weight_six[6:0] = (~(multiplicand_extend_tb1_f1) +7'b1) << shift_bits_index_six;
			end
			default: begin
				multiplicater_weight_two =15'b0;	
				multiplicater_weight_six =15'b0;
			end
		endcase

		case(multiplicater_three)
			ADD: begin
				multiplicater_weight_three[6:0] = multiplicand_extend_tb1_f0 << shift_bits_index_three;
				multiplicater_weight_seven[6:0] = multiplicand_extend_tb1_f1 << shift_bits_index_seven;
			end
			SUB:  begin
				multiplicater_weight_three[6:0] = (~(multiplicand_extend_tb1_f0) +7'b1) << shift_bits_index_three;	
				multiplicater_weight_seven[6:0] = (~(multiplicand_extend_tb1_f1) +7'b1) << shift_bits_index_seven;			
			end
			default: begin
				multiplicater_weight_three =15'b0;	
				multiplicater_weight_seven =15'b0;
			end 
		endcase
		////////

		temp_product[6:0] =   multiplicater_weight_zero[6:0] + multiplicater_weight_one[6:0] + multiplicater_weight_two[6:0] + multiplicater_weight_three[6:0];
		temp_product[18:12] =  multiplicater_weight_four[6:0] + multiplicater_weight_five[6:0] + multiplicater_weight_six[6:0] + multiplicater_weight_seven[6:0];

		if(temp_product[6:0] == 7'b100_0000) begin
			product[11:0] = 12'b0000_0100_0000;
		end
		else begin
			product[11:0] = {{5{temp_product[6]}},temp_product[6:0]};
		end
		if(temp_product[18:12] == 7'b100_0000) begin
			product[23:12] = 12'b0000_0100_0000;
		end
		else begin
			product[23:12] = {{5{temp_product[18]}},temp_product[18:12]};
		end
	end

	else if(mode == TB2) begin
		//i0
		case(multiplicater_zero)
			ADD: begin
				multiplicater_weight_zero[2:0] = multiplicand_extend_tb2_f0;
				multiplicater_weight_two[2:0] = multiplicand_extend_tb2_f1;
			end
			SUB: begin
				multiplicater_weight_zero[2:0] = ~(multiplicand_extend_tb2_f0) +3'b1;
				multiplicater_weight_two[2:0] = (~(multiplicand_extend_tb2_f1) +3'b1) ;
			end 
			default: begin
				multiplicater_weight_zero =15'b0;
				multiplicater_weight_two =15'b0;
			end 
		endcase
		
		case(multiplicater_one)
			ADD: begin
				multiplicater_weight_one[2:0] = multiplicand_extend_tb2_f0 << shift_bits_index_one;
				multiplicater_weight_three[2:0] = multiplicand_extend_tb2_f1 << shift_bits_index_one;
			end 
			SUB: begin
				multiplicater_weight_one[2:0] = (~(multiplicand_extend_tb2_f0) +3'b1) << shift_bits_index_one;
				multiplicater_weight_three[2:0] = (~(multiplicand_extend_tb2_f1) +3'b1) << shift_bits_index_one;
			end 
			default: begin
				multiplicater_weight_one =15'b0;	
				multiplicater_weight_three =15'b0;	
			end		
		endcase
		//i1
		case(multiplicater_four)
			ADD: begin
				multiplicater_weight_four[2:0] = multiplicand_extend_tb2_f0;
				multiplicater_weight_six[2:0] = multiplicand_extend_tb2_f1;
			end
			SUB: begin
				multiplicater_weight_four[2:0] = ~(multiplicand_extend_tb2_f0) +3'b1;
				multiplicater_weight_six[2:0] = (~(multiplicand_extend_tb2_f1) +3'b1) ;
			end 
			default: begin
				multiplicater_weight_four =15'b0;
				multiplicater_weight_six =15'b0;
			end 
		endcase

		case(multiplicater_five)
			ADD: begin
				multiplicater_weight_five[2:0] = multiplicand_extend_tb2_f0 << shift_bits_index_one;
				multiplicater_weight_seven[2:0] = multiplicand_extend_tb2_f1 << shift_bits_index_one;
			end
			SUB: begin
				multiplicater_weight_five[2:0] = (~(multiplicand_extend_tb2_f0) +3'b1)  << shift_bits_index_one;
				multiplicater_weight_seven[2:0] = (~(multiplicand_extend_tb2_f1) +3'b1) << shift_bits_index_one ;
			end 
			default: begin
				multiplicater_weight_five =15'b0;
				multiplicater_weight_seven =15'b0;
			end 
		endcase

		temp_product[2:0] = multiplicater_weight_zero[2:0] + multiplicater_weight_one[2:0] ; // i0_f0

		temp_product[14:12] = multiplicater_weight_two[2:0] + multiplicater_weight_three[2:0] ; // i0_f1
		
		temp_product[8:6] = multiplicater_weight_four[2:0] + multiplicater_weight_five[2:0] ; //i1_f0


		temp_product[20:18] = multiplicater_weight_six[2:0] + multiplicater_weight_seven[2:0] ; // i1_f1

		obseve_reg0 = temp_product[2:0];
		obseve_reg1 = temp_product[8:6];
		obseve_reg2 = temp_product[14:12];
		obseve_reg3 = temp_product[20:18];
/*
		product[5:0] = {{3{temp_product[2]}},temp_product[2:0]};
		product[11:6] = {{3{temp_product[8]}},temp_product[8:6]};
		product[17:12] = {{3{temp_product[14]}},temp_product[14:12]};
		product[23:18] = {{3{temp_product[20]}},temp_product[20:18]};
*/

		if(temp_product[2:0] == 3'b100) begin
			product[5:0] = 6'b00_0100;
		end
		else begin
			product[5:0] = {{3{temp_product[2]}},temp_product[2:0]};
		end
		if(temp_product[8:6] == 3'b100) begin
			product[11:6] = 6'b00_0100;
		end
		else begin
			product[11:6] = {{3{temp_product[8]}},temp_product[8:6]};
		end
		if(temp_product[14:12] == 3'b100) begin
			product[17:12] = 6'b00_0100;
		end
		else begin
			product[17:12] = {{3{temp_product[14]}},temp_product[14:12]};
		end
		if(temp_product[20:18] == 3'b100) begin
			product[23:18] = 6'b00_0100;
		end
		else begin
			product[23:18] = {{3{temp_product[20]}},temp_product[20:18]};
		end

	end
end



endmodule


