`define CV 2'd0
`define DW 2'd1
`define PW 2'd2
`define GAP 2'd3
module PE_mode(
    input clk, rst,
    input [7:0] pixel, weight,
    input [7:0] pixel_cast,
    input [1:0] mode,
    output logic [7:0] next_pixel,
    output logic signed [15:0] product
);
logic [7:0] pixel_in;
always_comb begin
    case(mode)
        `DW: pixel_in = pixel_cast;
        `PW: pixel_in = pixel;
		default: pixel_in = 0;
    endcase
end
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        next_pixel <= 0;
        product <= 0;
    end else begin
        next_pixel <= pixel_in;
        product <= $signed(pixel_in) * $signed(weight);
		//product <= (weight==0)? 0 : $signed(pixel) * $signed(weight);
    end
end
endmodule