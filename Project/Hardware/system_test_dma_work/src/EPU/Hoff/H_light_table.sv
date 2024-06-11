module H_light_table (
    input [7:0]data_in,
    input DC_or_AC, // DC = 0
    output logic [15:0]data_out,
    output logic [4:0]valid_bit_count
);
logic [15:0]data_out_DC;
logic [15:0]data_out_AC;
logic [4:0]valid_bit_count_DC;
logic [4:0]valid_bit_count_AC;
assign data_out = (~DC_or_AC)?data_out_DC:data_out_AC;
assign valid_bit_count = (~DC_or_AC)?valid_bit_count_DC:valid_bit_count_AC;
//We need logic like MUX to decide the output is DC or AC
always_comb begin : DC_table
    case(data_in)
		8'b0000_0000: begin///0
            data_out_DC = 16'b0000_0000_0000_0000;
            valid_bit_count_DC = 5'd2;
        end
        8'b0000_0001: begin////1
            data_out_DC = 16'b0000_0000_0000_0010;
            valid_bit_count_DC = 5'd3;
        end
        8'b0000_0010: begin///2
            data_out_DC = 16'b0000_0000_0000_0011;
            valid_bit_count_DC = 5'd3;
        end
        8'b0000_0011: begin///3
            data_out_DC = 16'b0000_0000_0000_0100;
            valid_bit_count_DC = 5'd3;
        end
        8'b0000_0100: begin///4
            data_out_DC = 16'b0000_0000_0000_0101;
            valid_bit_count_DC = 5'd3;
        end
        8'b0000_0101: begin///5
            data_out_DC = 16'b0000_0000_0000_0110;
            valid_bit_count_DC = 5'd3;
        end
        8'b0000_0110: begin///6
            data_out_DC = 16'b0000_0000_0000_1110;
            valid_bit_count_DC = 5'd4;
        end
        8'b0000_0111: begin///7
            data_out_DC = 16'b0000_0000_0001_1110;
            valid_bit_count_DC = 5'd5;
        end
        8'b0000_1000: begin///8
            data_out_DC = 16'b0000_0000_0011_1110;
            valid_bit_count_DC = 5'd6;
        end
        8'b0000_1001: begin///9
            data_out_DC = 16'b0000_0000_0111_1110;
            valid_bit_count_DC = 5'd7;
        end
        8'b0000_1010: begin///10
            data_out_DC = 16'b0000_0000_1111_1110;
            valid_bit_count_DC = 5'd8;
        end
        8'b0000_1011: begin///11
            data_out_DC = 16'b0000_0001_1111_1110;
            valid_bit_count_DC = 5'd9;
        end
		default: begin
            data_out_DC = 16'b0;
            valid_bit_count_DC = 5'd0;
        end
    endcase
end


always_comb begin: AC_table /// do(0/0)~(0/7)、(1/0)~(1/7)......(F/0)~(F/7)
    case(data_in)
        8'b0000_0000: begin///0
            data_out_AC = 16'b0000_0000_0000_1010;
            valid_bit_count_AC = 5'd4;
        end
        8'b0000_0001: begin////1
            data_out_AC = 16'b0000_0000_0000_0000;
            valid_bit_count_AC = 5'd2;
        end
        8'b0000_0010: begin///2
            data_out_AC = 16'b0000_0000_0000_0001;
            valid_bit_count_AC = 5'd2;
        end
        8'b0000_0011: begin///3
            data_out_AC = 16'b0000_0000_0000_0100;
            valid_bit_count_AC = 5'd3;
        end
        8'b0000_0100: begin///4
            data_out_AC = 16'b0000_0000_0000_1011;
            valid_bit_count_AC = 5'd4;
        end
        8'b0000_0101: begin///5
            data_out_AC = 16'b0000_0000_0001_1010;
            valid_bit_count_AC = 5'd5;
        end
        8'b0000_0110: begin///6
            data_out_AC = 16'b0000_0000_0111_1000;
            valid_bit_count_AC = 5'd7;
        end
        8'b0000_0111: begin///7
            data_out_AC = 16'b0000_0000_1111_1000;
            valid_bit_count_AC = 5'd8;
        end

///////////////////// 1 part  /////////////////////

        8'b0001_0001: begin////1
            data_out_AC = 16'b0000_0000_0000_1100;
            valid_bit_count_AC = 5'd4;
        end
        8'b0001_0010: begin///2
            data_out_AC = 16'b0000_0000_0001_1011;
            valid_bit_count_AC = 5'd5;
        end
        8'b0001_0011: begin///3
            data_out_AC = 16'b0000_0000_0111_1001;
            valid_bit_count_AC = 5'd7;
        end
        8'b0001_0100: begin///4
            data_out_AC = 16'b0000_0001_1111_0110;
            valid_bit_count_AC = 5'd9;
        end
        8'b0001_0101: begin///5
            data_out_AC = 16'b0000_0111_1111_0110;
            valid_bit_count_AC = 5'd11;
        end
        8'b0001_0110: begin///6
            data_out_AC = 16'b1111_1111_1000_0100;
            valid_bit_count_AC = 5'd16;
        end
        8'b0001_0111: begin///7
            data_out_AC = 16'b1111_1111_1000_0101;
            valid_bit_count_AC = 5'd16;
        end
///////////////////// 2 part  /////////////////////

        8'b0010_0001: begin////1
            data_out_AC = 16'b0000_0000_0001_1100;
            valid_bit_count_AC = 5'd5;
        end
        8'b0010_0010: begin///2
            data_out_AC = 16'b0000_0000_1111_1001;
            valid_bit_count_AC = 5'd8;
        end
        8'b0010_0011: begin///3
            data_out_AC = 16'b0000_0011_1111_0111;
            valid_bit_count_AC = 5'd10;
        end
        8'b0010_0100: begin///4
            data_out_AC = 16'b0000_1111_1111_0100;
            valid_bit_count_AC = 5'd12;
        end
        8'b0010_0101: begin///5
            data_out_AC = 16'b1111_1111_1000_1001;
            valid_bit_count_AC = 5'd16;
        end
        8'b0010_0110: begin///6
            data_out_AC = 16'b1111_1111_1000_1010;
            valid_bit_count_AC = 5'd16;
        end
        8'b0010_0111: begin///7
            data_out_AC = 16'b1111_1111_1000_1011;
            valid_bit_count_AC = 5'd16;
        end
///////////////////// 3 part  /////////////////////

        8'b0011_0001: begin////1
            data_out_AC = 16'b0000_0000_0011_1010;
            valid_bit_count_AC = 5'd6;
        end
        8'b0011_0010: begin///2
            data_out_AC = 16'b0000_0001_1111_0111;
            valid_bit_count_AC = 5'd9;
        end
        8'b0011_0011: begin///3
            data_out_AC = 16'b0000_1111_1111_0101;
            valid_bit_count_AC = 5'd12;
        end
        8'b0011_0100: begin///4
            data_out_AC = 16'b1111_1111_1000_1111;
            valid_bit_count_AC = 5'd16;
        end
        8'b0011_0101: begin///5
            data_out_AC = 16'b1111_1111_1001_0000;
            valid_bit_count_AC = 5'd16;
        end
        8'b0011_0110: begin///6
            data_out_AC = 16'b1111_1111_1001_0001;
            valid_bit_count_AC = 5'd16;
        end
        8'b0011_0111: begin///7
            data_out_AC = 16'b1111_1111_1001_0010;
            valid_bit_count_AC = 5'd16;
        end

///////////////////// 4 part  /////////////////////

        8'b0100_0001: begin////1
            data_out_AC = 16'b0000000000111011;
            valid_bit_count_AC = 5'd6;
        end
        8'b0100_0010: begin///2
            data_out_AC = 16'b0000001111111000;
            valid_bit_count_AC = 5'd10;
        end
        8'b0100_0011: begin///3
            data_out_AC = 16'b1111111110010110;
            valid_bit_count_AC = 5'd16;
        end
        8'b0100_0100: begin///4
            data_out_AC = 16'b1111111110010111;
            valid_bit_count_AC = 5'd16;
        end
        8'b0100_0101: begin///5
            data_out_AC = 16'b1111111110011000;
            valid_bit_count_AC = 5'd16;
        end
        8'b0100_0110: begin///6
            data_out_AC = 16'b1111111110011001;
            valid_bit_count_AC = 5'd16;
        end
        8'b0100_0111: begin///7
            data_out_AC = 16'b1111111110011010;
            valid_bit_count_AC = 5'd16;
        end       
///////////////////// 5 part  /////////////////////

        8'b0101_0001: begin////1
            data_out_AC = 16'b0000000001111010;
            valid_bit_count_AC = 5'd7;
        end
        8'b0101_0010: begin///2
            data_out_AC = 16'b0000011111110111;
            valid_bit_count_AC = 5'd11;
        end
        8'b0101_0011: begin///3
            data_out_AC = 16'b1111111110011110;
            valid_bit_count_AC = 5'd16;
        end
        8'b0101_0100: begin///4
            data_out_AC = 16'b1111111110011111;
            valid_bit_count_AC = 5'd16;
        end
        8'b0101_0101: begin///5
            data_out_AC = 16'b1111111110100000;
            valid_bit_count_AC = 5'd16;
        end
        8'b0101_0110: begin///6
            data_out_AC = 16'b1111111110100001;
            valid_bit_count_AC = 5'd16;
        end
        8'b0101_0111: begin///7
            data_out_AC = 16'b1111111110100010;
            valid_bit_count_AC = 5'd16;
        end  
///////////////////// 6 part  /////////////////////

        8'b0110_0001: begin////1
            data_out_AC = 16'b0000000001111011;
            valid_bit_count_AC = 5'd7;
        end
        8'b0110_0010: begin///2
            data_out_AC = 16'b0000111111110110;
            valid_bit_count_AC = 5'd12;
        end
        8'b0110_0011: begin///3
            data_out_AC = 16'b1111111110100110;
            valid_bit_count_AC = 5'd16;
        end
        8'b0110_0100: begin///4
            data_out_AC = 16'b1111111110100111;
            valid_bit_count_AC = 5'd16;
        end
        8'b0110_0101: begin///5
            data_out_AC = 16'b1111111110101000;
            valid_bit_count_AC = 5'd16;
        end
        8'b0110_0110: begin///6
            data_out_AC = 16'b1111111110101001;
            valid_bit_count_AC = 5'd16;
        end
        8'b0110_0111: begin///7
            data_out_AC = 16'b1111111110101010;
            valid_bit_count_AC = 5'd16;
        end   
///////////////////// 7 part  /////////////////////

        8'b0111_0001: begin////1
            data_out_AC = 16'b0000000011111010;
            valid_bit_count_AC = 5'd8;
        end
        8'b0111_0010: begin///2
            data_out_AC = 16'b0000111111110111;
            valid_bit_count_AC = 5'd12;
        end
        8'b0111_0011: begin///3
            data_out_AC = 16'b1111111110101110;
            valid_bit_count_AC = 5'd16;
        end
        8'b0111_0100: begin///4
            data_out_AC = 16'b1111111110101111;
            valid_bit_count_AC = 5'd16;
        end
        8'b0111_0101: begin///5
            data_out_AC = 16'b1111111110110000;
            valid_bit_count_AC = 5'd16;
        end
        8'b0111_0110: begin///6
            data_out_AC = 16'b1111111110110001;
            valid_bit_count_AC = 5'd16;
        end
        8'b0111_0111: begin///7
            data_out_AC = 16'b1111111110110010;
            valid_bit_count_AC = 5'd16;
        end
///////////////////// 8 part  /////////////////////

        8'b1000_0001: begin////1
            data_out_AC = 16'b0000000111111000;
            valid_bit_count_AC = 5'd9;
        end
        8'b1000_0010: begin///2
            data_out_AC = 16'b0111111111000000;
            valid_bit_count_AC = 5'd15;
        end
        8'b1000_0011: begin///3
            data_out_AC = 16'b1111111110110110;
            valid_bit_count_AC = 5'd16;
        end
        8'b1000_0100: begin///4
            data_out_AC = 16'b1111111110110111;
            valid_bit_count_AC = 5'd16;
        end
        8'b1000_0101: begin///5
            data_out_AC = 16'b1111111110111000;
            valid_bit_count_AC = 5'd16;
        end
        8'b1000_0110: begin///6
            data_out_AC = 16'b1111111110111001;
            valid_bit_count_AC = 5'd16;
        end
        8'b1000_0111: begin///7
            data_out_AC = 16'b1111111110111010;
            valid_bit_count_AC = 5'd16;
        end
///////////////////// 9 part  /////////////////////

        8'b1001_0001: begin////1
            data_out_AC = 16'b0000000111111001;
            valid_bit_count_AC = 5'd9;
        end
        8'b1001_0010: begin///2
            data_out_AC = 16'b1111111110111110;
            valid_bit_count_AC = 5'd16;
        end
        8'b1001_0011: begin///3
            data_out_AC = 16'b1111111110111111;
            valid_bit_count_AC = 5'd16;
        end
        8'b1001_0100: begin///4
            data_out_AC = 16'b1111111111000000;
            valid_bit_count_AC = 5'd16;
        end
        8'b1001_0101: begin///5
            data_out_AC = 16'b1111111111000001;
            valid_bit_count_AC = 5'd16;
        end
        8'b1001_0110: begin///6
            data_out_AC = 16'b1111111111000010;
            valid_bit_count_AC = 5'd16;
        end
        8'b1001_0111: begin///7
            data_out_AC = 16'b1111111111000011;
            valid_bit_count_AC = 5'd16;
        end
///////////////////// 10 part  /////////////////////

        8'b1010_0001: begin////1
            data_out_AC = 16'b0000000111111010;
            valid_bit_count_AC = 5'd9;
        end
        8'b1010_0010: begin///2
            data_out_AC = 16'b1111111111000111;
            valid_bit_count_AC = 5'd16;
        end
        8'b1010_0011: begin///3
            data_out_AC = 16'b1111111111001000;
            valid_bit_count_AC = 5'd16;
        end
        8'b1010_0100: begin///4
            data_out_AC = 16'b1111111111001001;
            valid_bit_count_AC = 5'd16;
        end
        8'b1010_0101: begin///5
            data_out_AC = 16'b1111111111001010;
            valid_bit_count_AC = 5'd16;
        end
        8'b1010_0110: begin///6
            data_out_AC = 16'b1111111111001011;
            valid_bit_count_AC = 5'd16;
        end
        8'b1010_0111: begin///7
            data_out_AC = 16'b1111111111001100;
            valid_bit_count_AC = 5'd16;
        end
///////////////////// 11 part  /////////////////////

        8'b1011_0001: begin////1
            data_out_AC = 16'b0000001111111001;
            valid_bit_count_AC = 5'd10;
        end
        8'b1011_0010: begin///2
            data_out_AC = 16'b1111111111010000;
            valid_bit_count_AC = 5'd16;
        end
        8'b1011_0011: begin///3
            data_out_AC = 16'b1111111111010001;
            valid_bit_count_AC = 5'd16;
        end
        8'b1011_0100: begin///4
            data_out_AC = 16'b1111111111010010;
            valid_bit_count_AC = 5'd16;
        end
        8'b1011_0101: begin///5
            data_out_AC = 16'b1111111111010011;
            valid_bit_count_AC = 5'd16;
        end
        8'b1011_0110: begin///6
            data_out_AC = 16'b1111111111010100;
            valid_bit_count_AC = 5'd16;
        end
        8'b1011_0111: begin///7
            data_out_AC = 16'b1111111111010101;
            valid_bit_count_AC = 5'd16;
        end
///////////////////// 12 part  /////////////////////

        8'b1100_0001: begin////1
            data_out_AC = 16'b0000001111111010;
            valid_bit_count_AC = 5'd10;
        end
        8'b1100_0010: begin///2
            data_out_AC = 16'b1111111111011001;
            valid_bit_count_AC = 5'd16;
        end
        8'b1100_0011: begin///3
            data_out_AC = 16'b1111111111011010;
            valid_bit_count_AC = 5'd16;
        end
        8'b1100_0100: begin///4
            data_out_AC = 16'b1111111111011011;
            valid_bit_count_AC = 5'd16;
        end
        8'b1100_0101: begin///5
            data_out_AC = 16'b1111111111011100;
            valid_bit_count_AC = 5'd16;
        end
        8'b1100_0110: begin///6
            data_out_AC = 16'b1111111111011101;
            valid_bit_count_AC = 5'd16;
        end
        8'b1100_0111: begin///7
            data_out_AC = 16'b1111111111011110;
            valid_bit_count_AC = 5'd16;
        end 
///////////////////// 13 part  /////////////////////

        8'b1101_0001: begin////1
            data_out_AC = 16'b0000011111111000;
            valid_bit_count_AC = 5'd11;
        end
        8'b1101_0010: begin///2
            data_out_AC = 16'b1111111111100010;
            valid_bit_count_AC = 5'd16;
        end
        8'b1101_0011: begin///3
            data_out_AC = 16'b1111111111100011;
            valid_bit_count_AC = 5'd16;
        end
        8'b1101_0100: begin///4
            data_out_AC = 16'b1111111111100100;
            valid_bit_count_AC = 5'd16;
        end
        8'b1101_0101: begin///5
            data_out_AC = 16'b1111111111100101;
            valid_bit_count_AC = 5'd16;
        end
        8'b1101_0110: begin///6
            data_out_AC = 16'b1111111111100110;
            valid_bit_count_AC = 5'd16;
        end
        8'b1101_0111: begin///7
            data_out_AC = 16'b1111111111100111;
            valid_bit_count_AC = 5'd16;
        end  
///////////////////// 14 part  /////////////////////

        8'b1110_0001: begin////1
            data_out_AC = 16'b1111111111101011;
            valid_bit_count_AC = 5'd16;
        end
        8'b1110_0010: begin///2
            data_out_AC = 16'b1111111111101100;
            valid_bit_count_AC = 5'd16;
        end
        8'b1110_0011: begin///3
            data_out_AC = 16'b1111111111101101;
            valid_bit_count_AC = 5'd16;
        end
        8'b1110_0100: begin///4
            data_out_AC = 16'b1111111111101110;
            valid_bit_count_AC = 5'd16;
        end
        8'b1110_0101: begin///5
            data_out_AC = 16'b1111111111101111;
            valid_bit_count_AC = 5'd16;
        end
        8'b1110_0110: begin///6
            data_out_AC = 16'b1111111111110000;
            valid_bit_count_AC = 5'd16;
        end
        8'b1110_0111: begin///7
            data_out_AC = 16'b1111111111110001;
            valid_bit_count_AC = 5'd16;
        end  
///////////////////// 15 part  /////////////////////
		8'b1111_0000: begin////0
            data_out_AC = 16'b0000011111111001;
            valid_bit_count_AC = 5'd11;
        end
        8'b1111_0001: begin////1
            data_out_AC = 16'b1111111111110101;
            valid_bit_count_AC = 5'd16;
        end
        8'b1111_0010: begin///2
            data_out_AC = 16'b1111111111110110;
            valid_bit_count_AC = 5'd16;
        end
        8'b1111_0011: begin///3
            data_out_AC = 16'b1111111111110111;
            valid_bit_count_AC = 5'd16;
        end
        8'b1111_0100: begin///4
            data_out_AC = 16'b1111111111111000;
            valid_bit_count_AC = 5'd16;
        end
        8'b1111_0101: begin///5
            data_out_AC = 16'b1111111111111001;
            valid_bit_count_AC = 5'd16;
        end
        8'b1111_0110: begin///6
            data_out_AC = 16'b1111111111111010;
            valid_bit_count_AC = 5'd16;
        end
        8'b1111_0111: begin///7
            data_out_AC = 16'b1111111111111011;
            valid_bit_count_AC = 5'd16;
        end  
        default: begin
            data_out_AC = 16'b0;
            valid_bit_count_AC = 5'd0;
        end                                   
    endcase
    

end


















endmodule