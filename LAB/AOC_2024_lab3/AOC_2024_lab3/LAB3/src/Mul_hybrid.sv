`include "../include/def.svh"
module Mul_hybrid (
	input	[7:0]	ifmap,			//input feature map
	input	[7:0]	filter, 		//filter
	input	[3:0]	ifmap_Quant_size,
	input	[3:0]	filter_Quant_size,
	output	logic	[`Psum_BITS-1:0]	product
);

always_comb begin
	//// tb0
	//product[23:0] = $signed(ifmap)*$signed(filter);
	//// tb1
	//product[23:12] = -12'd7;
	//product[11:0] = 12'd1;
	product[23:12] = $signed(ifmap[3:0])*$signed(filter[7:4]);
	product[11:0] = $signed(ifmap[3:0])*$signed(filter[3:0]); 
	
	//// tb2
	/* product[23:18] = $signed(ifmap[5:4])*$signed(filter[5:4]);
	product[17:12] = $signed(ifmap[1:0])*$signed(filter[5:4]);
	product[11:6] = $signed(ifmap[5:4])*$signed(filter[1:0]); */
	
	//$display("Mul: %d %d",$signed(ifmap[1:0]),$signed(filter[1:0])); 
	//product[5:0] = $signed(ifmap[1:0])*$signed(filter[1:0]);
	//$display("Mul product : %d",$signed(product[5:0]));   
	
end

endmodule