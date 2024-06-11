module EPU(
    input                                   clk,
    input                                   rst,
    //to input sram port
    output      logic [11:0]                A_s7,
    input       logic                       start_signal_s7,
    input       logic [127:0]               DO_s7,


    //to output sram port
    output      logic [11:0]                A_s8,
    output      logic [3:0]                 WEB_s8,
    output      logic [31:0]                DI_s8,
    output      logic                       start_signal_s8,   

    //mutual port
    output      logic                       end_signal     
);
///put your design here
assign start_signal_s8 = start_signal_s7;

EPU_ALG epu_alg (
    .clk                (clk),
    .rst                (rst),
    .start              (start_signal_s7),
    .data_read          (DO_s7),
    .addr               (A_s7),
    .TO_SRAM_DATA       (DI_s8),
    .WE                 (WEB_s8),
    .sram_addr          (A_s8),
    .last_to_cpu        (end_signal)
);

endmodule