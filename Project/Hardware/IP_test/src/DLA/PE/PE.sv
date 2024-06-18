module PE(
    input clk, rst,
    input [7:0] pixel, weight,
    output logic [7:0] next_pixel,
    output logic signed [15:0] product
);
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        next_pixel <= 0;
        product <= 0;
    end else begin
        next_pixel <= pixel;
        product <= $signed(pixel) * $signed(weight);
		//product <= (weight==0)? 0 : $signed(pixel) * $signed(weight);
    end
end
endmodule