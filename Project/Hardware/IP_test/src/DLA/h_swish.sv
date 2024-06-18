`define dequant_scaling 177
`define requant_scaling 64
`define quant_bias 0
module h_swish(
	input clk,
	input rst,
	input  logic[23:0] conv_output,///(16,8)
//	input  logic[23:0] quant_bias,//0
//	input  logic[7:0]  dequant_scale,//b1
//	input  logic[7:0]  requant_scale,//03
	output logic[23:0]requant_output
);
//logic signed[23:0]dequant_input_pre;
logic signed[63:0]requant_input_pre;
logic signed[23:0]dequant_input;
logic signed[31:0]h_swish_input;
logic signed[31:0]requant_input;
logic signed[31:0]data_ox;
logic signed[31:0]data_ox_twos;
always@(*)begin
	dequant_input = $signed(conv_output)+`quant_bias;//(16,8)
	h_swish_input = $signed(dequant_input)*`dequant_scaling>>>13; //(mul)177/8192     (24,8)
	
	if(h_swish_input[31]==1'd1)begin
		if(h_swish_input <= 32'b1111_1111_1111_1111_1111_1100_0000_0000)//-4
			requant_input = 0;
		else  begin
			requant_input_pre=($signed(h_swish_input)*$signed((h_swish_input+32'b0000_0000_0000_0000_0000_1100_0000_0000)))>>>4;//(48,16)
			requant_input = requant_input_pre[39:8];
		end
	end else begin
		if(h_swish_input<32'b0000_0000_0000_0000_0000_0100_0000_0000)begin//4
			requant_input_pre = (h_swish_input*(h_swish_input+32'b0000_0000_0000_0000_0000_0100_0000_0000))>>>4;
			requant_input = requant_input_pre[39:8];
		end else requant_input=h_swish_input;	
	end
		data_ox=(requant_input*`requant_scaling);
		//data_o=(requant_input*`requant_scaling)>>>6;
		data_ox_twos=(~data_ox)+1;
	if(data_ox[31]==0)begin			
 		if(data_ox[7]==1) requant_output=data_ox[15:8]+8'd1;
		else requant_output=data_ox[15:8];
	end else begin
		if ((data_ox_twos[31:8]==0)&data_ox_twos[7:0]<=8'b10_0000_00) requant_output=8'd0;
		else if(data_ox[7]==1) requant_output=data_ox[15:8]+8'd1;
		else requant_output=data_ox[15:8];			
	end
end
endmodule

