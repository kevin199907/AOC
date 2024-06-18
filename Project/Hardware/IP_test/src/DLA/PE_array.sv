/*==========================
// mode define
    `define CV 2'd0
    `define DW 2'd1
    `define PW 2'd2
    `define GAP 2'd3
==========================*/
module PE_array(
    input clk, rst,
    input filter_active[15:0][15:0],
    input [1:0] mode,
    input [7:0] ifmap_data[15:0],
    input [7:0] weight_data[15:0][15:0],
    output logic [7:0] DLA_out[15:0]
);
logic [7:0] pixel0[15:0], pixel1[15:0], pixel2[15:0], pixel3[15:0],
    pixel4[15:0], pixel5[15:0], pixel6[15:0], pixel7[15:0],
    pixel8[15:0], pixel9[15:0], pixel10[15:0], pixel11[15:0],
    pixel12[15:0], pixel13[15:0], pixel14[15:0], pixel15[15:0];
logic [7:0] pixel16[15:0];
logic [7:0] weight0[15:0], weight1[15:0], weight2[15:0], weight3[15:0],
    weight4[15:0], weight5[15:0], weight6[15:0],weight7[15:0],
    weight8[15:0], weight9[15:0], weight10[15:0], weight11[15:0],
    weight12[15:0], weight13[15:0], weight14[15:0], weight15[15:0];
logic [15:0] product0[15:0], product1[15:0], product2[15:0], product3[15:0],
    product4[15:0], product5[15:0], product6[15:0],product7[15:0],
    product8[15:0], product9[15:0], product10[15:0], product11[15:0],
    product12[15:0],product13[15:0], product14[15:0], product15[15:0];

logic [23:0] RADDT_out [15:0];
logic [23:0] ADDT_out [4:0];
logic [23:0] PE_out[15:0];
logic [31:0] PE_out_pw0[15:0];
logic signed [31:0] PE_out_pw1[15:0];
/*
always_comb begin
    for (int i=0;i<16;i++) begin
        pixel0 [i] = ifmap_data[i];
    end
end
*/
always_comb begin
	case(mode)
		2'd1: begin
			pixel0[0 ] = (filter_active[0 ][0 ]==1'b1)? ifmap_data[0 ] : 0;
			pixel0[1 ] = (filter_active[1 ][0 ]==1'b1)? ifmap_data[1 ] : 0;
			pixel0[2 ] = (filter_active[2 ][0 ]==1'b1)? ifmap_data[2 ] : 0;
			pixel0[3 ] = (filter_active[3 ][3 ]==1'b1)? ifmap_data[3 ] : 0;
			pixel0[4 ] = (filter_active[4 ][3 ]==1'b1)? ifmap_data[4 ] : 0;
			pixel0[5 ] = (filter_active[5 ][3 ]==1'b1)? ifmap_data[5 ] : 0;
			pixel0[6 ] = (filter_active[6 ][6 ]==1'b1)? ifmap_data[6 ] : 0;
			pixel0[7 ] = (filter_active[7 ][6 ]==1'b1)? ifmap_data[7 ] : 0;
			pixel0[8 ] = (filter_active[8 ][6 ]==1'b1)? ifmap_data[8 ] : 0;
			pixel0[9 ] = (filter_active[9 ][9 ]==1'b1)? ifmap_data[9 ] : 0;
			pixel0[10] = (filter_active[10][9 ]==1'b1)? ifmap_data[10] : 0;
			pixel0[11] = (filter_active[11][9 ]==1'b1)? ifmap_data[11] : 0;
			pixel0[12] = (filter_active[12][12]==1'b1)? ifmap_data[12] : 0;
			pixel0[13] = (filter_active[13][12]==1'b1)? ifmap_data[13] : 0;
			pixel0[14] = (filter_active[14][12]==1'b1)? ifmap_data[14] : 0;
			pixel0[15] = 0;
		end
		default: begin
			for (int i=0;i<16;i++) pixel0[i] = ifmap_data[i];
		end
	endcase
end
always_comb begin
    for (int i=0;i<16;i++) begin
        weight0 [i] = (filter_active[0 ][i]==1'b1)? (weight_data[0 ][i]) : 0;
        weight1 [i] = (filter_active[1 ][i]==1'b1)? (weight_data[1 ][i]) : 0;
        weight2 [i] = (filter_active[2 ][i]==1'b1)? (weight_data[2 ][i]) : 0;
        weight3 [i] = (filter_active[3 ][i]==1'b1)? (weight_data[3 ][i]) : 0;
        weight4 [i] = (filter_active[4 ][i]==1'b1)? (weight_data[4 ][i]) : 0;
        weight5 [i] = (filter_active[5 ][i]==1'b1)? (weight_data[5 ][i]) : 0;
        weight6 [i] = (filter_active[6 ][i]==1'b1)? (weight_data[6 ][i]) : 0;
        weight7 [i] = (filter_active[7 ][i]==1'b1)? (weight_data[7 ][i]) : 0;
        weight8 [i] = (filter_active[8 ][i]==1'b1)? (weight_data[8 ][i]) : 0;
        weight9 [i] = (filter_active[9 ][i]==1'b1)? (weight_data[9 ][i]) : 0;
        weight10[i] = (filter_active[10][i]==1'b1)? (weight_data[10][i]) : 0;
        weight11[i] = (filter_active[11][i]==1'b1)? (weight_data[11][i]) : 0;
        weight12[i] = (filter_active[12][i]==1'b1)? (weight_data[12][i]) : 0;
        weight13[i] = (filter_active[13][i]==1'b1)? (weight_data[13][i]) : 0;
        weight14[i] = (filter_active[14][i]==1'b1)? (weight_data[14][i]) : 0;
        weight15[i] = (filter_active[15][i]==1'b1)? (weight_data[15][i]) : 0;
    end
end


PE_row_mode0  PE_row0 (.clk(clk),.rst(rst),.pixel(pixel0 ),.weight(weight0 ),.next_pixel(pixel1 ),.product(product0 ),.mode(mode),.pixel_cast(ifmap_data[2:0]));
PE_row        PE_row1 (.clk(clk),.rst(rst),.pixel(pixel1 ),.weight(weight1 ),.next_pixel(pixel2 ),.product(product1 ));
PE_row        PE_row2 (.clk(clk),.rst(rst),.pixel(pixel2 ),.weight(weight2 ),.next_pixel(pixel3 ),.product(product2 ));
PE_row_mode3  PE_row3 (.clk(clk),.rst(rst),.pixel(pixel3 ),.weight(weight3 ),.next_pixel(pixel4 ),.product(product3 ),.mode(mode),.pixel_cast(ifmap_data[5:3]));
PE_row        PE_row4 (.clk(clk),.rst(rst),.pixel(pixel4 ),.weight(weight4 ),.next_pixel(pixel5 ),.product(product4 ));
PE_row        PE_row5 (.clk(clk),.rst(rst),.pixel(pixel5 ),.weight(weight5 ),.next_pixel(pixel6 ),.product(product5 ));
PE_row_mode6  PE_row6 (.clk(clk),.rst(rst),.pixel(pixel6 ),.weight(weight6 ),.next_pixel(pixel7 ),.product(product6 ),.mode(mode),.pixel_cast(ifmap_data[8:6]));
PE_row        PE_row7 (.clk(clk),.rst(rst),.pixel(pixel7 ),.weight(weight7 ),.next_pixel(pixel8 ),.product(product7 ));
PE_row        PE_row8 (.clk(clk),.rst(rst),.pixel(pixel8 ),.weight(weight8 ),.next_pixel(pixel9 ),.product(product8 ));
PE_row_mode9  PE_row9 (.clk(clk),.rst(rst),.pixel(pixel9 ),.weight(weight9 ),.next_pixel(pixel10),.product(product9 ),.mode(mode),.pixel_cast(ifmap_data[11:9]));
PE_row        PE_row10(.clk(clk),.rst(rst),.pixel(pixel10),.weight(weight10),.next_pixel(pixel11),.product(product10));
PE_row        PE_row11(.clk(clk),.rst(rst),.pixel(pixel11),.weight(weight11),.next_pixel(pixel12),.product(product11));
PE_row_mode12 PE_row12(.clk(clk),.rst(rst),.pixel(pixel12),.weight(weight12),.next_pixel(pixel13),.product(product12),.mode(mode),.pixel_cast(ifmap_data[14:12]));
PE_row        PE_row13(.clk(clk),.rst(rst),.pixel(pixel13),.weight(weight13),.next_pixel(pixel14),.product(product13));
PE_row        PE_row14(.clk(clk),.rst(rst),.pixel(pixel14),.weight(weight14),.next_pixel(pixel15),.product(product14));
PE_row        PE_row15(.clk(clk),.rst(rst),.pixel(pixel15),.weight(weight15),.next_pixel(pixel16),.product(product15));

RADDT RADDT0  (.in(product0 ),.out(RADDT_out[0 ]));
RADDT RADDT1  (.in(product1 ),.out(RADDT_out[1 ]));
RADDT RADDT2  (.in(product2 ),.out(RADDT_out[2 ]));
RADDT RADDT3  (.in(product3 ),.out(RADDT_out[3 ]));
RADDT RADDT4  (.in(product4 ),.out(RADDT_out[4 ]));
RADDT RADDT5  (.in(product5 ),.out(RADDT_out[5 ]));
RADDT RADDT6  (.in(product6 ),.out(RADDT_out[6 ]));
RADDT RADDT7  (.in(product7 ),.out(RADDT_out[7 ]));
RADDT RADDT8  (.in(product8 ),.out(RADDT_out[8 ]));
RADDT RADDT9  (.in(product9 ),.out(RADDT_out[9 ]));
RADDT RADDT10 (.in(product10),.out(RADDT_out[10]));
RADDT RADDT11 (.in(product11),.out(RADDT_out[11]));
RADDT RADDT12 (.in(product12),.out(RADDT_out[12]));
RADDT RADDT13 (.in(product13),.out(RADDT_out[13]));
RADDT RADDT14 (.in(product14),.out(RADDT_out[14]));
RADDT RADDT15 (.in(product15),.out(RADDT_out[15]));

ADDT ADDT0 (.in1(RADDT_out[0 ]),.in2(RADDT_out[1 ]),.in3(RADDT_out[2 ]),.out(ADDT_out[0]));
ADDT ADDT1 (.in1(RADDT_out[3 ]),.in2(RADDT_out[4 ]),.in3(RADDT_out[5 ]),.out(ADDT_out[1]));
ADDT ADDT2 (.in1(RADDT_out[6 ]),.in2(RADDT_out[7 ]),.in3(RADDT_out[8 ]),.out(ADDT_out[2]));
ADDT ADDT3 (.in1(RADDT_out[9 ]),.in2(RADDT_out[10]),.in3(RADDT_out[11]),.out(ADDT_out[3]));
ADDT ADDT4 (.in1(RADDT_out[12]),.in2(RADDT_out[13]),.in3(RADDT_out[14]),.out(ADDT_out[4]));

always_comb begin
    case(mode)
        2'd1: begin
            for (int i=0;i<5;i++) PE_out[i] = ADDT_out[i];
            for (int i=5;i<16;i++) PE_out[i] = 0;
        end
        2'd2: begin
            for (int i =0;i<16;i++) PE_out[i] = RADDT_out[i];
        end
        default:begin
            for (int i =0;i<16;i++) PE_out[i] = 0;
        end
    endcase
end

always_comb begin
    for (int i =0;i<16;i++) PE_out_pw0[i] = (PE_out[i] * 8'b11000011);
    /*for (int i =0;i<16;i++) begin
        if (PE_out_pw0[i][15:0] == 16'b1000_0000_0000_0000) begin
            if (PE_out_pw0[i][16]) DLA_out[i] = PE_out_pw0[i][23:16]+1;
            else DLA_out[i] = PE_out_pw0[i][23:16];
        end else begin
            if (PE_out_pw0[15]) DLA_out[i] = PE_out_pw0[i][23:16]+1;
            else DLA_out[i] = PE_out_pw0[i][23:16];
        end
    end*/
    for (int i =0;i<16;i++) begin
        if (PE_out_pw0[i][15] == 1'b1) begin
            DLA_out[i] = PE_out_pw0[i][23:16]+1;
        end else begin
            DLA_out[i] = PE_out_pw0[i][23:16];
        end
    end
    //for (int i =0;i<16;i++) PE_out_pw1[i] = (PE_out_pw0[i] >>>16);
    //for (int i =0;i<16;i++) DLA_out[i] = PE_out_pw1[i] [7:0];
end
// h_swish h_swish0 (.clk(clk),.rst(rst),.conv_output(PE_out[0 ]),.requant_output(DLA_out[0 ]));
// h_swish h_swish1 (.clk(clk),.rst(rst),.conv_output(PE_out[1 ]),.requant_output(DLA_out[1 ]));
// h_swish h_swish2 (.clk(clk),.rst(rst),.conv_output(PE_out[2 ]),.requant_output(DLA_out[2 ]));
// h_swish h_swish3 (.clk(clk),.rst(rst),.conv_output(PE_out[3 ]),.requant_output(DLA_out[3 ]));
// h_swish h_swish4 (.clk(clk),.rst(rst),.conv_output(PE_out[4 ]),.requant_output(DLA_out[4 ]));
// h_swish h_swish5 (.clk(clk),.rst(rst),.conv_output(PE_out[5 ]),.requant_output(DLA_out[5 ]));
// h_swish h_swish6 (.clk(clk),.rst(rst),.conv_output(PE_out[6 ]),.requant_output(DLA_out[6 ]));
// h_swish h_swish7 (.clk(clk),.rst(rst),.conv_output(PE_out[7 ]),.requant_output(DLA_out[7 ]));
// h_swish h_swish8 (.clk(clk),.rst(rst),.conv_output(PE_out[8 ]),.requant_output(DLA_out[8 ]));
// h_swish h_swish9 (.clk(clk),.rst(rst),.conv_output(PE_out[9 ]),.requant_output(DLA_out[9 ]));
// h_swish h_swish10(.clk(clk),.rst(rst),.conv_output(PE_out[10]),.requant_output(DLA_out[10]));
// h_swish h_swish11(.clk(clk),.rst(rst),.conv_output(PE_out[11]),.requant_output(DLA_out[11]));
// h_swish h_swish12(.clk(clk),.rst(rst),.conv_output(PE_out[12]),.requant_output(DLA_out[12]));
// h_swish h_swish13(.clk(clk),.rst(rst),.conv_output(PE_out[13]),.requant_output(DLA_out[13]));
// h_swish h_swish14(.clk(clk),.rst(rst),.conv_output(PE_out[14]),.requant_output(DLA_out[14]));
// h_swish h_swish15(.clk(clk),.rst(rst),.conv_output(PE_out[15]),.requant_output(DLA_out[15]));

endmodule