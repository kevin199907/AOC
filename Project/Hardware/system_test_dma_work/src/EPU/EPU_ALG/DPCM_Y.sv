//block num = 64
`define modeY  2'b01
`define modeCr 2'b10
`define modeCb 2'b11
module DPCM_Y
(
    input                           clk,
    input                           rst,
    input  [1:0]                    mode,
    input  [11:0]                   dc_data,
    input                           dc_done,
    output logic [11:0]             dpcm_out,
    output logic                    dpcm_done,
    output logic                    dpcm_last
);
//define
logic                        cs, ns;
logic [7:0]                  counter, counter_next;
logic signed [11:0] data_dc;
logic signed [11:0] data_dc1_reg;
//signed input
assign data_dc = dc_data;
//state
always_ff @( posedge clk or posedge rst ) begin
    if (rst) cs <= 1'b0;
    else cs <= ns;
end
//next state
always_comb begin
    case (cs)
        1'b0 : ns = ((dc_done) && (mode==`modeY) )? 1'd1 : 1'd0;   //first dc
        1'b1 : ns = (dpcm_last)? 1'd0 : 1'd1;
    endcase
end
//count dc_done num
assign counter_next = ((dc_done) && (mode==`modeY) )? (counter+8'd1) : counter;
always_ff @(posedge clk or posedge rst) begin
    if (rst) counter <= 8'b0;
    else counter <= counter_next;
end
//generate dpcm_last
assign dpcm_last = (counter_next==8'd64)? 1'b1 : 1'b0;
//data_dc1 reg
always_ff @(posedge clk or posedge rst) begin
    if (rst) data_dc1_reg <= 12'b0;
    else if ((cs==1'b0) && (dc_done) && (mode==`modeY)) data_dc1_reg <= data_dc;
    else data_dc1_reg <= data_dc1_reg;
end
//output
always_comb begin
    if ((cs==1'b0) && (dc_done) && (mode==`modeY) ) begin
        dpcm_out  = data_dc;
        dpcm_done = 1'b1;
    end
    else if ((cs==1'b1) && (dc_done) && (mode==`modeY) ) begin
        dpcm_out  = (data_dc1_reg - data_dc);
        dpcm_done = 1'b1;
    end
    else begin
        dpcm_out  = 8'b0;
        dpcm_done = 1'b0;
    end
end

endmodule