module Vertical_v2_buffer(
	input clk,
	input rst,
	input  [7:0]    in_col   [15:0], 	   //from data_setup_v
	input  logic fifo_WVALID_col   [15:0], //from data_setup_v
	input  logic fifo_RVALID_col   [15:0], //from PE
	output logic fifo_WREADY_col   [15:0], //to data_setup_v 
	output logic fifo_RREADY_col   [15:0], //to PE
	output logic [7:0]   out_col   [15:0]  //to PE
);

Sync_v2_FIFO fifo_col1(
	//input
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [0]),
	.fifo_RVALID(fifo_RVALID_col [0]),
	.buf_in     (in_col [0]         ),
	//output
	.fifo_WREADY(fifo_WREADY_col [0]),
	.fifo_RREADY(fifo_RREADY_col [0]),
	.buf_out    (out_col [0]        )
);

Sync_v2_FIFO fifo_col2(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [1]),
	.fifo_RVALID(fifo_RVALID_col [1]),
	.buf_in     (in_col [1]         ),
	
	.fifo_WREADY(fifo_WREADY_col [1]),
	.fifo_RREADY(fifo_RREADY_col [1]),
	.buf_out    (out_col [1]        )
);

Sync_v2_FIFO fifo_col3(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [2]),
	.fifo_RVALID(fifo_RVALID_col [2]),
	.buf_in     (in_col [2]     ),
	
	.fifo_WREADY(fifo_WREADY_col [2]),
	.fifo_RREADY(fifo_RREADY_col [2]),
	.buf_out    (out_col [2]        )
);

Sync_v2_FIFO fifo_col4(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [3]),
	.fifo_RVALID(fifo_RVALID_col [3]),
	.buf_in     (in_col [3]         ),
	
	.fifo_WREADY(fifo_WREADY_col [3]),
	.fifo_RREADY(fifo_RREADY_col [3]),
	.buf_out    (out_col [3]        )
);

Sync_v2_FIFO fifo_col5(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [4]),
	.fifo_RVALID(fifo_RVALID_col [4]),
	.buf_in     (in_col [4]         ),
	
	.fifo_WREADY(fifo_WREADY_col [4]),
	.fifo_RREADY(fifo_RREADY_col [4]),
	.buf_out    (out_col [4]        )
);

Sync_v2_FIFO fifo_col6(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [5]),
	.fifo_RVALID(fifo_RVALID_col [5]),
	.buf_in     (in_col [5]         ),
	
	.fifo_WREADY(fifo_WREADY_col [5]),
	.fifo_RREADY(fifo_RREADY_col [5]),
	.buf_out    (out_col [5]        )
);

Sync_v2_FIFO fifo_col7(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [6]),
	.fifo_RVALID(fifo_RVALID_col [6]),
	.buf_in     (in_col [6]         ),
	
	.fifo_WREADY(fifo_WREADY_col [6]),
	.fifo_RREADY(fifo_RREADY_col [6]),
	.buf_out    (out_col [6]        )
);

Sync_v2_FIFO fifo_col8(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [7]),
	.fifo_RVALID(fifo_RVALID_col [7]),
	.buf_in     (in_col [7]         ),
	
	.fifo_WREADY(fifo_WREADY_col [7]),
	.fifo_RREADY(fifo_RREADY_col [7]),
	.buf_out    (out_col [7]        )
);

Sync_v2_FIFO fifo_col9(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [8]),
	.fifo_RVALID(fifo_RVALID_col [8]),
	.buf_in     (in_col [8]         ),
	
	.fifo_WREADY(fifo_WREADY_col [8]),
	.fifo_RREADY(fifo_RREADY_col [8]),
	.buf_out    (out_col [8]        )
);

Sync_v2_FIFO fifo_col10(
	.clk        (clk                ),
	.rst        (rst                ),
	.fifo_WVALID(fifo_WVALID_col [9]),
	.fifo_RVALID(fifo_RVALID_col [9]),
	.buf_in     (in_col [9]         ),
	
	.fifo_WREADY(fifo_WREADY_col [9]),
	.fifo_RREADY(fifo_RREADY_col [9]),
	.buf_out    (out_col [9]        )
);

Sync_v2_FIFO fifo_col11(
	.clk        (clk                 ),
	.rst        (rst                 ),
	.fifo_WVALID(fifo_WVALID_col [10]),
	.fifo_RVALID(fifo_RVALID_col [10]),
	.buf_in     (in_col [10]         ),
	
	.fifo_WREADY(fifo_WREADY_col [10]),
	.fifo_RREADY(fifo_RREADY_col [10]),
	.buf_out    (out_col [10]        )
);

Sync_v2_FIFO fifo_col12(
	.clk        (clk                 ),
	.rst        (rst                 ),
	.fifo_WVALID(fifo_WVALID_col [11]),
	.fifo_RVALID(fifo_RVALID_col [11]),
	.buf_in     (in_col [11]         ),
	
	.fifo_WREADY(fifo_WREADY_col [11]),
	.fifo_RREADY(fifo_RREADY_col [11]),
	.buf_out    (out_col [11]        )
);

Sync_v2_FIFO fifo_col13(
	.clk        (clk                 ),
	.rst        (rst                 ),
	.fifo_WVALID(fifo_WVALID_col [12]),
	.fifo_RVALID(fifo_RVALID_col [12]),
	.buf_in     (in_col [12]         ),
	
	.fifo_WREADY(fifo_WREADY_col [12]),
	.fifo_RREADY(fifo_RREADY_col [12]),
	.buf_out    (out_col [12]        )
);

Sync_v2_FIFO fifo_col14(
	.clk        (clk                 ),
	.rst        (rst                 ),
	.fifo_WVALID(fifo_WVALID_col [13]),
	.fifo_RVALID(fifo_RVALID_col [13]),
	.buf_in     (in_col [13]         ),
	
	.fifo_WREADY(fifo_WREADY_col [13]),
	.fifo_RREADY(fifo_RREADY_col [13]),
	.buf_out    (out_col [13]        )
);

Sync_v2_FIFO fifo_col15(
	.clk        (clk                 ),
	.rst        (rst                 ),
	.fifo_WVALID(fifo_WVALID_col [14]),
	.fifo_RVALID(fifo_RVALID_col [14]),
	.buf_in     (in_col [14]         ),
	
	.fifo_WREADY(fifo_WREADY_col [14]),
	.fifo_RREADY(fifo_RREADY_col [14]),
	.buf_out    (out_col [14]        )
);

Sync_v2_FIFO fifo_col16(
	.clk        (clk                 ),
	.rst        (rst                 ),
	.fifo_WVALID(fifo_WVALID_col [15]),
	.fifo_RVALID(fifo_RVALID_col [15]),
	.buf_in     (in_col [15]         ),
	
	.fifo_WREADY(fifo_WREADY_col [15]),
	.fifo_RREADY(fifo_RREADY_col [15]),
	.buf_out    (out_col [15]        )
);
endmodule