`timescale 1ns/10ps
`include "Mul_hybrid.sv"
`include "def.svh"

module Mul_tb;
    logic signed [7:0]  ifmap;
    logic signed [7:0]  filter;
    logic [`Psum_BITS-1:0] result;
	logic [3:0] ifmap_Quant_size;
	logic [3:0] filter_Quant_size;
	
    
	Mul_hybrid Mul2(
        .ifmap(ifmap),
		.filter(filter),
		.ifmap_Quant_size(ifmap_Quant_size),
		.filter_Quant_size(filter_Quant_size),
        .product(result)
    );
  

    logic signed[1:0] ifmap0,ifmap1;
	logic signed[1:0] filter0,filter1;
	integer i0,i1;
	integer f0,f1;
	integer answer0,answer1,answer2,answer3;
	integer result0,result1,result2,result3;
	integer err;
	
    initial begin
		
		$fsdbDumpfile("Mul.fsdb");
		$fsdbDumpvars("+struct", "+mda", Mul2);
		$fsdbDumpMDA(2,Mul2);
		
        err = 0;
		ifmap_Quant_size = 4'd2;
		filter_Quant_size = 4'd2;
		
		for (i1 = 2'b0; i1 <= 2'b11; i1 = i1+2'd1) begin
			for (i0 = 2'b0; i0 <= 2'b11; i0 = i0+2'd1) begin
				for (f1 = 2'b0; f1 <= 2'b11; f1 = f1+2'd1) begin
					for (f0 = 2'b0; f0 <= 2'b11; f0 = f0+2'd1) begin
						
						ifmap[7:4] = {2'd0,i1};
						ifmap[3:0] = {2'd0,i0};
						
						filter[7:4] = {2'd0,f1};
						filter[3:0] = {2'd0,f0};
						//$display("\n\nIfmap to Mul: %b",ifmap);
						//$display("filter to Mul: %b",filter);
						ifmap0 = i0;
						ifmap1 = i1;
						filter0 = f0;
						filter1 = f1;
						
						answer3 = ifmap1 * filter1;
						answer2 = ifmap0 * filter1;
						answer1 = ifmap1 * filter0;
						answer0 = ifmap0 * filter0;
						
						result3 = $signed(result[23:18]);
						result2 = $signed(result[17:12]);
						result1 = $signed(result[11:6]);
						result0 = $signed(result[5:0]);
						#10;
						if ($isunknown(result) == 1'd1)begin
							$display("\n Hybrid Multiplier has some errors");
							$display("1. Your Result:%d * %d is unknown",i1,f1);
							$display("2. Your Result:%d * %d is unknown",i0,f1);
							$display("3. Your Result:%d * %d is unknown",i1,f0);
							$display("4. Your Result:%d * %d is unknown",i0,f0);
							err = err + 1;
						end else if(answer0[5:0] != result[5:0] || answer1[5:0] != result[11:6] ||
									answer2[5:0] != result[17:12] || answer3[5:0] != result[23:18] ) begin
							$display("\n Hybrid Multiplier has some errors");
							$display("1. Correct Ans:%d* %d=%7d", ifmap1, filter1, $signed(answer3));
							$display("1. Your result:%d* %d=%7d", ifmap1, filter1, $signed(result3)); 
							$display("2. Correct Ans:%d* %d=%7d", ifmap0, filter1, $signed(answer2));
							$display("2. Your result:%d* %d=%7d", ifmap0, filter1, $signed(result2));
							$display("3. Correct Ans:%d* %d=%7d", ifmap1, filter0, $signed(answer1));
							$display("3. Your result:%d* %d=%7d", ifmap1, filter0, $signed(result1)); 
							$display("4. Correct Ans:%d* %d=%7d", ifmap0, filter0, $signed(answer0));
							$display("4. Your result:%d* %d=%7d", ifmap0, filter0, $signed(result0));
							err = err + 1;
						end else begin
							/* $display("\n Hybrid Multiplier preforms well");
							$display("1. Correct Result:%d * %d=%7d", ifmap1, filter1, $signed(answer3));
							$display("2. Correct Result:%d * %d=%7d", ifmap0, filter1, $signed(answer2));
							$display("3. Correct Result:%d * %d=%7d", ifmap1, filter0, $signed(answer1));
							$display("4. Correct Result:%d * %d=%7d", ifmap0, filter0, $signed(answer0));  */
							err = err;
						end 
						
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
			$display("%c[5;31m",27);
			$display("                  \n                          ");
			$display("                  !! Congratulations !!                             ");
			$write("%c[0m",27);
			$display("%c[5;35m",27);
			$display("            *             ✿           ✧     ✿                    ");
			$display("                     ✧              ✿                            ");
			$display("                 ✿        ✧            ✧                         ");
			$write("%c[0m",27);
			$display("%c[5;31m",27);
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

