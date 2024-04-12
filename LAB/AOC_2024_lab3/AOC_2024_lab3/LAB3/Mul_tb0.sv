`timescale 1ns/10ps
`include "Mul_hybrid.sv"
`include "def.svh"


module Mul_tb;
    logic signed [7:0]  ifmap;
    logic signed [7:0]  filter;
    logic [`Psum_BITS-1:0] result;
	logic [3:0] ifmap_Quant_size;
	logic [3:0] filter_Quant_size;
	
    
	Mul_hybrid Mul0(
        .ifmap(ifmap),
		.filter(filter),
		.ifmap_Quant_size(ifmap_Quant_size),
		.filter_Quant_size(filter_Quant_size),
        .product(result)
    );
  
    integer i,f;
	integer answer;
	integer err;
    
	
    initial begin
		
		$fsdbDumpfile("Mul.fsdb");
		$fsdbDumpvars("+struct", "+mda", Mul0);
		$fsdbDumpMDA(2,Mul0);
		
        err = 0;
		ifmap_Quant_size = 4'd8;
		filter_Quant_size = 4'd8;
		
        for (i = 8'b0; i <= 8'b1111_1111; i = i+8'd1) begin
            for (f = 8'b0; f <= 8'b1111_1111; f = f+8'd1) begin
				
				ifmap = i;
				filter = f;
				answer = ifmap * filter;
				#10;
				if ($isunknown(result) == 1'd1)begin
					$display("\n Hybrid Multiplier has some errors");
					$display("Your Result:%d * %d is unknown",ifmap,filter);
					err = err + 1;
				end else if(answer[23:0] != result) begin
					$display("\n Hybrid Multiplier has some errors");
					$display("Correct Ans:%d * %d=%7d", ifmap, filter, $signed(answer));
					$display("Your result:%d * %d=%7d", ifmap, filter, $signed(result));
					err = err + 1;
				end else begin
					//$display("Correct Result:%d * %d=%7d", ifmap, filter, $signed(result));
					err = err;
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
			$display("%c[0;31m",27);
			$display("                  \n                          ");
			$display("                  !!Simulation PASS!!                           ");
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
			$write("%c[0m",27);
        end
		$finish;
    end

endmodule

