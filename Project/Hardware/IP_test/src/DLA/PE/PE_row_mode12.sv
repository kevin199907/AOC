module PE_row_mode12(
    input clk, rst,
    input [1:0] mode,
    input [7:0] pixel[15:0],
    input [7:0] pixel_cast[2:0],
    input [7:0] weight[15:0],
    output [7:0] next_pixel[15:0],
    output logic signed [15:0] product[15:0]
);
PE      pe0  (.clk(clk),.rst(rst),.pixel(pixel[0 ]),.weight(weight[0 ]),.next_pixel(next_pixel[0 ]),.product(product[0 ]));
PE      pe1  (.clk(clk),.rst(rst),.pixel(pixel[1 ]),.weight(weight[1 ]),.next_pixel(next_pixel[1 ]),.product(product[1 ]));
PE      pe2  (.clk(clk),.rst(rst),.pixel(pixel[2 ]),.weight(weight[2 ]),.next_pixel(next_pixel[2 ]),.product(product[2 ]));
PE      pe3  (.clk(clk),.rst(rst),.pixel(pixel[3 ]),.weight(weight[3 ]),.next_pixel(next_pixel[3 ]),.product(product[3 ]));
PE      pe4  (.clk(clk),.rst(rst),.pixel(pixel[4 ]),.weight(weight[4 ]),.next_pixel(next_pixel[4 ]),.product(product[4 ]));
PE      pe5  (.clk(clk),.rst(rst),.pixel(pixel[5 ]),.weight(weight[5 ]),.next_pixel(next_pixel[5 ]),.product(product[5 ]));
PE      pe6  (.clk(clk),.rst(rst),.pixel(pixel[6 ]),.weight(weight[6 ]),.next_pixel(next_pixel[6 ]),.product(product[6 ]));
PE      pe7  (.clk(clk),.rst(rst),.pixel(pixel[7 ]),.weight(weight[7 ]),.next_pixel(next_pixel[7 ]),.product(product[7 ]));
PE      pe8  (.clk(clk),.rst(rst),.pixel(pixel[8 ]),.weight(weight[8 ]),.next_pixel(next_pixel[8 ]),.product(product[8 ]));
PE      pe9  (.clk(clk),.rst(rst),.pixel(pixel[9 ]),.weight(weight[9 ]),.next_pixel(next_pixel[9 ]),.product(product[9 ]));
PE      pe10 (.clk(clk),.rst(rst),.pixel(pixel[10]),.weight(weight[10]),.next_pixel(next_pixel[10]),.product(product[10]));
PE      pe11 (.clk(clk),.rst(rst),.pixel(pixel[11]),.weight(weight[11]),.next_pixel(next_pixel[11]),.product(product[11]));
PE_mode pe12 (.clk(clk),.rst(rst),.pixel(pixel[12]),.weight(weight[12]),.next_pixel(next_pixel[12]),.product(product[12]),.mode(mode),.pixel_cast(pixel_cast[0]));
PE_mode pe13 (.clk(clk),.rst(rst),.pixel(pixel[13]),.weight(weight[13]),.next_pixel(next_pixel[13]),.product(product[13]),.mode(mode),.pixel_cast(pixel_cast[1]));
PE_mode pe14 (.clk(clk),.rst(rst),.pixel(pixel[14]),.weight(weight[14]),.next_pixel(next_pixel[14]),.product(product[14]),.mode(mode),.pixel_cast(pixel_cast[2]));
PE      pe15 (.clk(clk),.rst(rst),.pixel(pixel[15]),.weight(weight[15]),.next_pixel(next_pixel[15]),.product(product[15]));
endmodule