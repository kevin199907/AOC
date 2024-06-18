module v_buffer_wrapper(
	//==============data_setup_v=============//
	input clk,
	input rst,
	input  logic [7:0]    in_col [15:0],
	input  logic fifo_WVALID_col [15:0],
	output logic fifo_WREADY_col [15:0],
	

	//==============PE=============//
	input  [1:0] mode,
	input  RVALID_col,     	       // from PE
	output logic RREADY_col,	   // to   PE
	output logic RREADY_col_full,  // to   PE
	output logic [7:0]   out_col [15:0]
);

	logic fifo_RVALID_col [15:0];
	logic fifo_RREADY_col [15:0];

	always_comb begin
		case(mode) 
			2'd0 : begin
				for(int i = 0; i < 16 ; i = i + 1) begin
						fifo_RVALID_col[i] = 1'd0;
				end
			end
			2'd1: begin //----------------------do depthwise
				RREADY_col_full  = ((~fifo_WREADY_col[ 0])&&
								   ( ~fifo_WREADY_col[ 1])&&
								   ( ~fifo_WREADY_col[ 2])&&
								   ( ~fifo_WREADY_col[ 3])&&
								   ( ~fifo_WREADY_col[ 4])&&
								   ( ~fifo_WREADY_col[ 5])&&
								   ( ~fifo_WREADY_col[ 6])&&
								   ( ~fifo_WREADY_col[ 7])&&
								   ( ~fifo_WREADY_col[ 8])&&
								   ( ~fifo_WREADY_col[ 9])&&
								   ( ~fifo_WREADY_col[10])&&
								   ( ~fifo_WREADY_col[11])&&
								   ( ~fifo_WREADY_col[12])&&
								   ( ~fifo_WREADY_col[13])&&
								   ( ~fifo_WREADY_col[14]) );
								   
					RREADY_col =	(fifo_RREADY_col[ 0])&
									(fifo_RREADY_col[ 1])&
									(fifo_RREADY_col[ 2])&
									(fifo_RREADY_col[ 3])&
									(fifo_RREADY_col[ 4])&
									(fifo_RREADY_col[ 5])&
									(fifo_RREADY_col[ 6])&
									(fifo_RREADY_col[ 7])&
									(fifo_RREADY_col[ 8])&
									(fifo_RREADY_col[ 9])&
									(fifo_RREADY_col[10])&
									(fifo_RREADY_col[11])&
									(fifo_RREADY_col[12])&
									(fifo_RREADY_col[13])&
									(fifo_RREADY_col[14]);
				if(RVALID_col) begin
					//將RVALID訊號broadcast給所有fifo
					for(int i = 0; i < 16 ; i = i + 1) begin
						fifo_RVALID_col[i] = 1'd1;
					end
				end 
				else begin
					for(int i = 0; i < 16 ; i = i + 1) begin
						fifo_RVALID_col[i] = 1'd0;
					end
				end
			end
			2'd2: begin //do pointwise
				if(RVALID_col) begin
					RREADY_col = (fifo_RREADY_col[0])&
								 (fifo_RREADY_col[1])&
								 (fifo_RREADY_col[2])&
								 (fifo_RREADY_col[3])&
								 (fifo_RREADY_col[4])&
								 (fifo_RREADY_col[5])&
								 (fifo_RREADY_col[6])&
								 (fifo_RREADY_col[7]);
									 
					if(RREADY_col) begin
						for(int i = 0; i < 8 ; i = i + 1) begin
							fifo_RVALID_col[i] = 1'd1;
						end
						for(int i = 8; i < 16 ; i = i + 1) begin
							fifo_RVALID_col[i] = 1'd0;
						end
					end
					else begin
						for(int i = 0; i < 16 ; i = i + 1) begin
							fifo_RVALID_col[i] = 1'd0;
						end
					end
				end
				else begin
					RREADY_col = 1'd0;
					for(int i = 0; i < 16 ; i = i + 1) begin
						fifo_RVALID_col[i] = 1'd0;
					end
				end
			end
		endcase
	end
	
	
	
	Vertical_buffer V_buffer(
		.clk            (clk            ),
		.rst            (rst            ),
		.in_col         (in_col         ),
		.fifo_WVALID_col(fifo_WVALID_col),
		.fifo_RVALID_col(fifo_RVALID_col),
		.fifo_WREADY_col(fifo_WREADY_col),
		.fifo_RREADY_col(fifo_RREADY_col),
		.out_col        (out_col        )
	);
	
endmodule