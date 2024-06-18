module DLA(
    input                   clk,
    input                   rst,
    input                   DLA_start,
    input [55:0]            transfer_config,
    input                   ifmap_ready,
    input                   ifmap_3_ready,
    output logic            ifmap_valid,
    input [7:0]             ifmap_data[15:0],
    input                   weight_ready,
    output logic            weight_valid,
    input [7:0]             weight_data[15:0][15:0],
    output logic [1:0]      mode,
    output logic [7:0]      DLA_out[15:0],
    output logic            psum_valid[15:0],
    output logic [15:0]     psum_addr[15:0],
    output logic            store_is,
	input					all_done_main
);
// psum
logic filter_active[15:0][15:0];
PE_controller PE_controller0(
    .clk                        (clk),
    .rst                        (rst),
    .DLA_start                  (DLA_start),
    .transfer_config            (transfer_config),
    .ifmap_ready                (ifmap_ready),
    .ifmap_3_ready              (ifmap_3_ready),
    .ifmap_valid                (ifmap_valid),
    .weight_ready               (weight_ready),
    .weight_valid               (weight_valid),
    .psum_valid                 (psum_valid),
    .psum_addr                  (psum_addr),
    .filter_active              (filter_active),
	.mode                       (mode),
    .store_is                   (store_is),
	.all_done_main				(all_done_main)
);
PE_array PE_array0(
    .clk                (clk),
    .rst                (rst),
    .filter_active      (filter_active),
    .mode               (mode),
    .ifmap_data         (ifmap_data),
    .weight_data        (weight_data),
    .DLA_out            (DLA_out)
);

endmodule