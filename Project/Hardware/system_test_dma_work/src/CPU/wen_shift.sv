module wen_shift (
    input  	[1:0] last_two,
    input  	logic [3:0] w_en,
	input	logic [31:0] mem_data,
    output 	logic[3:0] wen_shift_out,
	output 	logic [31:0] mem_data_out
);
always@(*)begin
	if(w_en!=4'b0000)begin
		case(last_two)
		2'b01 : begin
			wen_shift_out={w_en[2:0],1'b0};
			mem_data_out={mem_data[23:0],8'b0};
		end
		2'b10 : begin
			wen_shift_out={w_en[1:0],2'b00};
			mem_data_out={mem_data[15:0],16'b0};
		end
		2'b11 : begin
			wen_shift_out={w_en[0],3'b000};
			mem_data_out={mem_data[7:0],24'b0};
		end
		default: begin
			wen_shift_out=w_en;
			mem_data_out=mem_data;
		end
		endcase
	end
	else begin
		wen_shift_out=w_en;
		mem_data_out=mem_data;
	end
end
endmodule
