// sram
`include "./sram/SRAM_wrapper.sv"
// `include "./sram/SRAM_rtl.sv"
// buff_ver
`include "./buff_ver/Vertical_buffer.sv"
`include "./buff_ver/v_buffer_wrapper.sv"
`include "./buff_ver/data_setup_v.sv"
`include "./buff_ver/Sync_fifo.sv"
// buff_hor
`include "./buff_hor/control.sv"
`include "./buff_hor/Horizonal_buffer.sv"
`include "./buff_hor/Sync_v2_FIFO.sv"
`include "./buff_hor/Vertical_v2_buffer.sv"
// PE
`include "./DLA/PE/PE.sv"
`include "./DLA/PE/PE_mode.sv"
`include "./DLA/PE/PE_row.sv"
`include "./DLA/PE/PE_row_mode0.sv"
`include "./DLA/PE/PE_row_mode3.sv"
`include "./DLA/PE/PE_row_mode6.sv"
`include "./DLA/PE/PE_row_mode9.sv"
`include "./DLA/PE/PE_row_mode12.sv"
`include "./DLA/PE/RADDT.sv"
`include "./DLA/PE_array.sv"
`include "./DLA/PE_controller.sv"
`include "./DLA/DLA.sv"
`include "./DLA/h_swish.sv"
`include "./DLA/PE/ADDT.sv"
// psum
`include "./psum/psum_buffer.sv"

module top (
    input clk,
    input rst
);
logic DLA_start;
//==========data_setup_v===========//
logic               fifo_WREADY_col [15:0];
logic               fifo_WVALID_col [15:0];
logic [7:0]         in_col [15:0];
// IM
logic               IM_CS;
logic               IM_OE;
logic [ 3:0]        IM_WEB;
logic [13:0]        IM_A;
logic [31:0]        IM_DI;
logic [31:0]        IM_DO;
// WM
logic               WM_OE;
logic [13:0]        WM_A;
logic [31:0]        WM_DO;
// DM
logic [31:0]        DM_DO;
logic [3:0]         DM_WEB;
logic [13:0]        DM_A;
logic [31:0]        DM_DI;
//======Vertical_buffer_wrapper======//
logic [7:0]         out_col [15:0];
logic               RREADY_col;
logic               RVALID_col;
logic               RREADY_col_full;

//=====Horizontal_buffer========//
logic               fifo_WREADY_row  [15:0][15:0];
logic               fifo_RVALID_row  [15:0][15:0];
logic               fifo_WVALID_row  [15:0][15:0];
logic               fifo_RREADY_row  [15:0][15:0];
logic  [7:0]        in_row  [15:0][15:0];
logic  [7:0]        out_row [15:0][15:0];
logic  [6:0]        state;
logic               total_ready;
logic               total_valid;

// DLA
logic [1:0]         mode;
logic [55:0]        transfer_config;
logic [7:0]         DLA_out[15:0];
logic               psum_valid[15:0];
logic [15:0]        psum_addr[15:0];
logic               store_is;
// psum
logic               store_done;

always_ff @(posedge clk or posedge rst) begin
	if(rst) begin
		DLA_start <= 1'd1;
	end
	else begin
		DLA_start <= 1'd0;
	end
end

assign transfer_config = 56'b00000_01000_11100_11100_01000_01000_0001_0001_01000_11100_11100_010; // pw 28*28
//assign transfer_config = 56'b00000_01000_11100_11100_01000_01000_0001_0001_01000_11010_11010_010; //pw 26*26
//assign transfer_config = 56'b00000_01000_01010_01010_11111_01000_0011_0011_01000_11110_11110_001; //dw

// SRAM Wrapper
SRAM_wrapper WM1(
    .CK     (clk    ),
    .CS     (1'b1   ),
    .OE     (WM_OE  ),
    .WEB    (4'b1111),
    .A      (WM_A   ),
    .DI     (32'd0  ),
    .DO     (WM_DO   )
);
SRAM_wrapper IM1(
    .CK     (clk   ),
    .CS     (IM_CS ),
    .OE     (IM_OE ),
    .WEB    (IM_WEB),
    .A      (IM_A  ),
    .DI     (IM_DI ),
    .DO     (IM_DO )
);
SRAM_wrapper DM1(
    .CK     (clk    ),
    .CS     (1'b1   ),
    .OE     (1'b1   ),
    .WEB    (DM_WEB ),
    .A      (DM_A   ),
    .DI     (DM_DI  ),
    .DO     (DM_DO  )
);
// buff_ver
data_setup_v data_s_v(
	.clk                (clk            ),
	.rst                (rst            ),
    .mode               (mode           ),
	.fifo_WREADY_col    (fifo_WREADY_col),
	.fifo_WVALID_col    (fifo_WVALID_col),
    .in_col             (in_col         ),
	.IM_CS              (IM_CS          ),
	.IM_OE              (IM_OE          ),
    .IM_WEB             (IM_WEB         ),
    .IM_A               (IM_A           ),
    .IM_DI              (IM_DI          ),
	.IM_DO              (IM_DO          )
);
v_buffer_wrapper v_buffer_wrapper1(
	.clk                (clk            ),
	.rst                (rst            ),
	.in_col             (in_col         ),
	.fifo_WVALID_col    (fifo_WVALID_col),
	.fifo_WREADY_col    (fifo_WREADY_col),
    .mode               (mode           ),
	.RVALID_col         (RVALID_col     ),
	.RREADY_col         (RREADY_col     ),
    .RREADY_col_full    (RREADY_col_full),
	.out_col            (out_col        )
);
//buff_hor
control horizonal_comtrol(
	.clk                (clk),
    .rst                (rst),
	.A                  (WM_A),
	.WM_OE              (WM_OE),
    .DO                 (WM_DO),
	.fifo_WREADY_row    (fifo_WREADY_row),
    .fifo_WVALID_row    (fifo_WVALID_row),
	.in_row             (in_row),
	.state              (state)
);
Horizonal_buffer Horizonal_buffer(
	.clk                (clk),
    .rst                (rst),
	.in_row             (in_row),
	.fifo_WVALID_row    (fifo_WVALID_row),
    .fifo_WREADY_row    (fifo_WREADY_row),
    .fifo_RREADY_row    (fifo_RREADY_row),
	.out_row            (out_row),
	.state              (state),
	.total_ready        (total_ready),
    .total_valid        (total_valid)
);
// PE
DLA DLA0(
    .clk                (clk),
    .rst                (rst),
    .DLA_start          (DLA_start),
    .transfer_config    (transfer_config),
    .ifmap_ready        (RREADY_col),
    .ifmap_3_ready      (RREADY_col_full),
    .ifmap_valid        (RVALID_col),
    .ifmap_data         (out_col),
    .weight_ready       (total_ready),
    .weight_valid       (total_valid),
    .weight_data        (out_row),
    .mode               (mode),
    .DLA_out            (DLA_out),
    .psum_valid         (psum_valid),
    .psum_addr          (psum_addr),
    .store_is           (store_is),
	.all_done_main		(store_done)
);
// psum buffer
psum_buffer psum_buffer0(
    .clk                (clk),
    .rst                (rst),
    .psum_valid         (psum_valid),
    .psum_addr          (psum_addr),
    .psum_data          (DLA_out),
    .mode               (mode),
    .store_is           (store_is),
    .store_done         (store_done),
    .DM_WEB             (DM_WEB),
    .DM_A               (DM_A),
    .DM_DI              (DM_DI)
);

endmodule