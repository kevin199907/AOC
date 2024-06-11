module H_FF (
    input clk,
    input rst,
    input last,
    input logic valid,//ac
    input DC_valid,//dc
    input logic [11:0]af_RLC_data_AC,
    input logic [15:0]af_RLC_data_DC,
    input logic [1:0] mode,
    output logic [31:0] TO_SRAM_DATA,
    output logic [3:0]WE,
    output logic [11:0] sram_addr,
	output logic last_to_cpu,
    output logic we_FULL,
    output logic out_empty
);

wire     deal_FF_done;
logic     [31:0] data_to_deal_FF;
logic     to_FF_valid;
logic     to_FF_last;

H_encoder H_encoder0(
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .DC_valid(DC_valid),
    .last(last),
    .af_RLC_data_AC(af_RLC_data_AC),
    .af_RLC_data_DC(af_RLC_data_DC),
    .deal_FF_done(deal_FF_done),//
    .data_to_deal_FF(data_to_deal_FF),//
    .to_FF_valid(to_FF_valid),//
    .mode(mode),
    .to_FF_last(to_FF_last),
    .stall(we_FULL),
    .out_empty(out_empty)
);

FF_SRAM FF_SRAM0 (
    .rst(rst),
    .clk(clk),
    .valid(to_FF_valid),//
    .last(to_FF_last),
    .data(data_to_deal_FF),//
    .done(deal_FF_done),//
    .TO_SRAM_DATA(TO_SRAM_DATA),
    .WE(WE),
    .sram_addr(sram_addr),
	.last_to_cpu(last_to_cpu)
);
endmodule