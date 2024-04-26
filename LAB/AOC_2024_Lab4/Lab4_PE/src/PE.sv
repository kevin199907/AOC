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

	 
endmodule
	
	