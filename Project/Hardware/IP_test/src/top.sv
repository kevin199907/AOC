`include "SRAM_wrapper.sv"



module top (
    input clk,
    input rst
);



SRAM_wrapper WM1(
    .CK(clk),
    .CS(CS),
    .OE(1'b1),
    .WEB(),
    .A(),
    .DI(),
    .DO()
);

SRAM_wrapper IM1(
    .CK(clk),
    .CS(CS),
    .OE(1'b1),
    .WEB(),
    .A(),
    .DI(),
    .DO()
);

SRAM_wrapper DM1(
    .CK(clk),
    .CS(1'b1),
    .OE(1'b1),
    .WEB(),
    .A(),
    .DI(),
    .DO()
);

endmodule