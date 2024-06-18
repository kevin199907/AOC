`define BUF_WIDTH     2
`define BUF_DATA_SIZE 8
`define BUF_DEPTH    (1<<`BUF_WIDTH)

//4 * 8 bits
module Sync_v2_FIFO(	input clk, 
					input rst, 
					input fifo_WVALID, // from sram
					input fifo_RVALID, // from PU
					input [`BUF_DATA_SIZE-1:0] buf_in,
					output logic fifo_WREADY, //to sram
					output logic fifo_RREADY, //to PU
					output logic [`BUF_DATA_SIZE-1:0] buf_out );   //total reg 2.5 bytes
 
 
	logic [`BUF_DATA_SIZE -1:0]  buf_mem[`BUF_DEPTH -1 : 0];  //4 byte 
	logic [`BUF_DEPTH     -1:0]  fifo_counter;
	logic [`BUF_WIDTH     -1:0]  rd_ptr, wr_ptr;
	logic buf_empty;
	logic buf_full;

	assign 	buf_empty = (fifo_counter ==  8'd0)? 1'd1       : 1'd0;
	assign 	buf_full  = (fifo_counter ==  8'd4)? 1'd1       : 1'd0;
	assign  buf_out   = (/*  fifo_RVALID   && */  !buf_empty)?buf_mem[rd_ptr]: `BUF_DATA_SIZE'd0;
	
	//control signal
	assign fifo_WREADY = !buf_full; 
	assign fifo_RREADY = !buf_empty; 
	
	always @(posedge clk or posedge rst) begin
		if(rst)
			fifo_counter <= `BUF_WIDTH'd0;		
		else if( (!buf_full && fifo_WVALID) && ( !buf_empty && fifo_RVALID ) )  
			fifo_counter <= fifo_counter;			
		else if( !buf_full && fifo_WVALID )			
			fifo_counter <= fifo_counter + `BUF_WIDTH'd1;
		else if( !buf_empty && fifo_RVALID )		
			fifo_counter <= fifo_counter - `BUF_WIDTH'd1;
		else
			fifo_counter <= fifo_counter;		
	end

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			for(int i = 0; i < `BUF_DEPTH ; i = i + 1)begin
				buf_mem[i] <= `BUF_DATA_SIZE'd0;
			end
		end
		else if( fifo_WVALID && !buf_full )
			buf_mem[ wr_ptr ] <= buf_in;	
 		else 
			buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
	end

	always @(posedge clk or posedge rst) begin
		if(rst) begin
		wr_ptr <= `BUF_WIDTH'd0;		
		rd_ptr <= `BUF_WIDTH'd0;		
		end
		else begin
			if( !buf_full && fifo_WVALID )    
				wr_ptr <= wr_ptr + `BUF_WIDTH'd1;		
			else  
				wr_ptr <= wr_ptr;
				
			if( !buf_empty && fifo_RVALID )   
				rd_ptr <= rd_ptr + `BUF_WIDTH'd1;		
			else 
				rd_ptr <= rd_ptr;
		end
	end
endmodule