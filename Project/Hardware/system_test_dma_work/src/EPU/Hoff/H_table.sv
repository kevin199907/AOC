module H_table (
    input [7:0]data_in,
    input DC_or_AC, // DC = 0 !
    input [1:0] mode,// 01->Y
    output logic [15:0]data_out,
    output logic [4:0]valid_bit_count
);
/*output MUX*/
logic [15:0] data_light;
logic [15:0] data_color;
logic [4:0]valid_bit_count_light;
logic [4:0]valid_bit_count_color;
assign data_out = (mode==2'b01)?data_light:data_color;
assign valid_bit_count = (mode==2'b01)?valid_bit_count_light:valid_bit_count_color;
H_light_table light_table(
    .DC_or_AC(DC_or_AC),
    .data_in(data_in),
    .data_out(data_light),
    .valid_bit_count(valid_bit_count_light)
);
H_color_table color_table(
    .DC_or_AC(DC_or_AC),
    .data_in(data_in),
    .data_out(data_color),
    .valid_bit_count(valid_bit_count_color)
);
endmodule