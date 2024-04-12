`timescale 1ns/10ps
`include "Mul_hybrid.sv"
`include "def.svh"


module Mul_tb;
    logic signed [7:0]  ifmap;
    logic signed [7:0]  filter;
    logic [`Psum_BITS-1:0] result;
	logic [3:0] ifmap_Quant_size;
	logic [3:0] filter_Quant_size;
	
    
	Mul_hybrid Mul1(
        .ifmap(ifmap),
		.filter(filter),
		.ifmap_Quant_size(ifmap_Quant_size),
		.filter_Quant_size(filter_Quant_size),
        .product(result)
    );
  
  
	logic signed [3:0] f0_value;
	logic signed [3:0] f1_value;
	logic signed [3:0] i_ans;
    integer i;
	integer f0,f1;
	integer answer0,answer1;
	integer result0,result1;
	integer err;
	
    initial begin
		
		$fsdbDumpfile("Mul.fsdb");
		$fsdbDumpvars("+struct", "+mda", Mul1);
		$fsdbDumpMDA(2,Mul1);
		
        err = 0;
		ifmap_Quant_size = 4'd4;
		filter_Quant_size = 4'd4;
		
		
        for (i = 4'b0; i <= 4'b1111; i = i+4'd1) begin
            for (f1 = 4'b0; f1 <= 4'b1111; f1 = f1+4'd1) begin
				for (f0 = 4'b0; f0 <= 4'b1111; f0 = f0+4'd1) begin
					
					ifmap = {4'd0000,i};
					//$display("Ifmap to Mul: %b",ifmap);
					i_ans = i;
					filter[7:4] = f1;
					filter[3:0] = f0;

					f1_value = f1;
					f0_value = f0;
										
					answer1 = i_ans * f1_value;
					answer0 = i_ans * f0_value;
					
					result1 = $signed(result[23:12]);
					result0 = $signed(result[11:0]);
					#10;
					if ($isunknown(result) == 1'd1)begin
						$display("\n Hybrid Multiplier has some errors");
						$display("1. Your Result:%d * %d is unknown",i_ans,f1_value);
						$display("2. Your Result:%d * %d is unknown",i_ans,f0_value);
						err = err + 1;
					end else if(answer0[11:0] != result[11:0] || answer1[11:0] != result[23:12]) begin
						$display("\n Hybrid Multiplier has some errors");
						$display("1. Correct Ans:%d* %d=%7d", i_ans, f1_value, $signed(answer1));
						$display("1. Your result:%d* %d=%7d", i_ans, f1_value, $signed(result1)); 
						$display("2. Correct Ans:%d* %d=%7d", i_ans, f0_value, $signed(answer0));
						$display("2. Your result:%d* %d=%7d", i_ans, f0_value, $signed(result0));
						err = err + 1;
					end else begin
						//$display("\n Hybrid Multiplier preforms well");
						//$display("1. Correct Result:%d * %d=%7d", i_ans, f1_value, $signed(answer1));
						//$display("2. Correct Result:%d * %d=%7d", i_ans, f0_value, $signed(answer0));
						err = err;
					end 
				end 
            end	
			
        end 
		
        if(err > 0)begin
			$display("                  \n                          ");
			$display("                  !!Simulation	Failed!!                           ");
			$display("                  total errors: %7d                    		",err);
			$display("            __                                                    ");
			$display("           _\\/_____________________________                      ");
			$display("          /      |_| |_|                    \\		            ");
			$display("         |  ._.                              |		            ");
			$display("         _\\  __                             _|__	                ");
			$display("        (___(___________________________________)                 ");
			$display("                                                                  ");
			$display("           Creator NCKU AISystem Lab SOUP                         ");
			$display(" Inspired by https://www.instagram.com/p/CujcWdHysYn/?img_index=1 ");
			$display("                                                                  ");
        end else begin
			$display("%c[0;36m",27);
			$display("                  \n                          ");
			$display("                   Hello ! I am Saugy ~                         	");
			$display("         I love Garlic. My special skill is Garlic Attack.      	");
			$display("               I hope you can pass all tbs successfully.        	");
			$write("%c[0m",27);
			$display("%c[0;31m",27);
			$display("            __                                                    ");
			$display("           _\\/_____________________________                      ");
			$display("          /      |_| |_|                    \\		            ");
			$display("         |  ._.                              |		            ");
			$display("         _\\  __                             _|__	                ");
			$display("        (___(___________________________________)                 ");
			$display("                                                                  ");
			$write("%c[0m",27);
			$display("%c[0;36m",27);
			$display("      Creator National Saugy University AISystem Lab SOUP         ");
			$display(" Inspired by https://www.instagram.com/p/CujcWdHysYn/?img_index=1 ");
			$display("                                                                  ");
			$write("%c[0m",27);
        end
		$finish;

    end

endmodule

