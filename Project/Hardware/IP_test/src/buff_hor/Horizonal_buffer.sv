module Horizonal_buffer(
	input 				clk,
	input 				rst,
	input  [7:0] 		in_row[15:0][15:0], //from data_setup_v
	input  logic 		fifo_WVALID_row[15:0][15:0], //from data_setup_v
	//from PE
	output logic 		fifo_WREADY_row[15:0][15:0], //to data_setup_v 
	output logic 		fifo_RREADY_row[15:0][15:0], //to PE
	output logic [7:0]  out_row[15:0][15:0], //to PE
	input  logic [6:0] 	state,
	output logic 		total_ready,
	input  logic 		total_valid
);
logic fifo_RVALID_row   [15:0][15:0];
int i;
int j;
always@(posedge clk)begin
for(i=0;i<16;i=i+1)begin
	for(j=0;j<16;j=j+1)
		fifo_RVALID_row[i][j]<=total_valid;
	end
end
always@(posedge clk)begin
	if(state>=6'd18)
	total_ready<=1'd1;
	else
	total_ready<=1'd0;
end

Vertical_v2_buffer fifo_0(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row[0][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row[0][15:0]),
	.in_col     	(in_row [0][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row[0][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row[0][15:0]),
	.out_col   		(out_row [0][15:0]        )
);

Vertical_v2_buffer fifo_1(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [1][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [1][15:0]),
	.in_col     	(in_row [1][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row[1][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row[1][15:0]),
	.out_col   		(out_row [1][15:0]        )
);

Vertical_v2_buffer fifo_2(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [2][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [2][15:0]),
	.in_col     	(in_row [2][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [2][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [2][15:0]),
	.out_col   		(out_row [2][15:0]        )
);

Vertical_v2_buffer fifo_3(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [3][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [3][15:0]),
	.in_col     	(in_row [3][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [3][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [3][15:0]),
	.out_col   		(out_row [3][15:0]        )
);

Vertical_v2_buffer fifo_4(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row[4][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row[4][15:0] ),
	.in_col     	(         in_row[4][15:0]),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [4][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [4][15:0]),
	.out_col   		(out_row [4][15:0]        )
);

Vertical_v2_buffer fifo_5(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [5][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [5][15:0]),
	.in_col     	(in_row [5][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [5][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [5][15:0]),
	.out_col   		(out_row [5][15:0]        )
);

Vertical_v2_buffer fifo_6(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [6][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [6][15:0]),
	.in_col     	(in_row [6][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [6][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [6][15:0]),
	.out_col   		(out_row [6][15:0]        )
);

Vertical_v2_buffer fifo_7(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [7][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [7][15:0]),
	.in_col     	(in_row [7][15:0]        ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [7][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [7][15:0]),
	.out_col   		(out_row [7][15:0]        )
);

Vertical_v2_buffer fifo_8(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [8][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [8][15:0]),
	.in_col     	(in_row [8][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [8][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [8][15:0]),
	.out_col   		(out_row [8][15:0]        )
);

Vertical_v2_buffer fifo_9(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [9][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [9][15:0]),
	.in_col     	(in_row [9][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [9][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [9][15:0]),
	.out_col   		(out_row [9][15:0]        )
);

Vertical_v2_buffer fifo_10(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [10][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [10][15:0]),
	.in_col     	(in_row [10][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [10][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [10][15:0]),
	.out_col   		(out_row [10][15:0]       )
);

Vertical_v2_buffer fifo_11(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [11][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [11][15:0]),
	.in_col     	(in_row [11][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [11][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [11][15:0]),
	.out_col   		(out_row [11][15:0]        )
);

Vertical_v2_buffer fifo_12(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [12][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [12][15:0]),
	.in_col     	(in_row [12][15:0]        ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [12][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [12][15:0]),
	.out_col   		(out_row[12][15:0]       )
);

Vertical_v2_buffer fifo_13(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [13][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [13][15:0]),
	.in_col     	(in_row [13][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [13][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [13][15:0]),
	.out_col   		(out_row [13][15:0]        )
);

Vertical_v2_buffer fifo_14(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [14][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [14][15:0]),
	.in_col     	(in_row [14][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [14][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [14][15:0]),
	.out_col   		(out_row [14][15:0]        )
);

Vertical_v2_buffer fifo_15(
	//input
	.clk        	(clk                ),
	.rst        	(rst                ),
	.fifo_WVALID_col(fifo_WVALID_row [15][15:0]),
	.fifo_RVALID_col(fifo_RVALID_row [15][15:0]),
	.in_col     	(in_row [15][15:0]         ),
	//output
	.fifo_WREADY_col(fifo_WREADY_row [15][15:0]),
	.fifo_RREADY_col(fifo_RREADY_row [15][15:0]),
	.out_col   		(out_row [15][15:0]       )
);
endmodule