`timescale 1ns/10ps
`define CYCLE 10.0
`include "PE.sv"  // change to "PE.v" , if you implent by verilog
`define PATH "/home/.../Lab4_PE/"  //change to your own path
`define MAX 100 // adjust the cycle you need 
`include "def.svh"
// PE tb final version2

module PE_tb;
	logic clk;
	logic rst;
	//Layer setting 
	logic set_info;
	logic [2:0] Ch_size;
	logic [5:0] ifmap_column;
	logic [5:0] ofmap_column;
	//logic [1:0] batch_size;
	//logic [12:0] processing_pass;
	logic [3:0] ifmap_Quant_size;
	logic [3:0] filter_Quant_size;
	//data to PE.sv
	logic filter_enable;
	logic [7:0] filter;		
	logic ifmap_enable;
	logic [31:0] ifmap;
	logic ipsum_enable;
	logic [`Psum_BITS-1:0] ipsum; 
	logic opsum_ready;	
	//data from PE.sv
	logic filter_ready;
	logic ifmap_ready;	
	logic ipsum_ready;
	logic [`Psum_BITS-1:0] opsum;
	logic opsum_enable;	
	
	// record clock cycle
	longint counter;
	always_ff @(posedge clk or posedge rst) begin
		if(rst)
			counter <= 64'd0;
		else
			counter <= counter + 64'd1;
		// display old value
		//$display("At time %t, counter value is %d", $time, counter);
	end
	
	//After set_info, you can start request data
	PE PE0(
		.clk(clk),
		.rst(rst),
		//setting Layer info
		.set_info(set_info),
		.Ch_size(Ch_size),
		.ifmap_column(ifmap_column),
		.ofmap_column(ofmap_column),
		.ifmap_Quant_size(ifmap_Quant_size),
		.filter_Quant_size(filter_Quant_size),
		//data to PE.sv
		.filter_enable(filter_enable),
		.filter(filter),		
		.ifmap_enable(ifmap_enable),
		.ifmap(ifmap),
		.ipsum_enable(ipsum_enable),
		.ipsum(ipsum),
		.opsum_ready(opsum_ready),
		// data from PE.sv
		.filter_ready(filter_ready),
        .ifmap_ready(ifmap_ready),	
        .ipsum_ready(ipsum_ready),
        .opsum(opsum), 
        .opsum_enable(opsum_enable)
	);
	
	logic start;
	always #(`CYCLE/2) clk = ~clk;
	initial begin
		clk = 1;
		rst = 0;
		start = 1;
		set_info = 1'd0;
		//Layer setting 
		Ch_size = 3'd0;
		ifmap_column = 6'd0;
		ofmap_column = 6'd0;
		//batch_size = 2'd0;
		//processing_pass = 13'd0;
		ifmap_Quant_size = 3'd0;
		filter_Quant_size = 3'd0;
		#(`CYCLE) start = 0;
		rst = 1;
		#(`CYCLE) rst = 0;
		set_info = 1'd1;
		//Layer setting 
		Ch_size = `channel;	
		ifmap_column = `ifmap_col;	
		ofmap_column = `ofmap_col;
		//batch_size = `batch_size; 
		//processing_pass = `pro_pass;		
		ifmap_Quant_size = `ifmap_bit;
		filter_Quant_size = `filter_bit;
		
		#(`CYCLE) set_info = 1'd0;
		//Layer setting 
		Ch_size = 3'd0;
		ifmap_column = 6'd0;
		ofmap_column = 6'd0;
		ifmap_Quant_size = 3'd0;
		filter_Quant_size = 3'd0;
	end
		
	///////////////		Read In data	///////////////
	/////	ifmap	/////
	//path string
	string full_path_ifmap_00,full_path_ifmap_10,full_path_ifmap_20,full_path_ifmap_21,full_path_ifmap_30;	
	logic signed [7:0]ifmap_MEM[`batch_size-1:0][`ifmap_col-1:0][`channel-1:0]; 
	//tb0 : 1 Batch_Size * 5 Ifmap_Column * 4 Channel
	integer i2,i1,i0;
	integer ifmap_read1,ifmap_read0;
	integer i_read1,i_read0;	
	
	initial begin
		i1=0;
		i0=0;
		//define path
		$sformat(full_path_ifmap_00, "%s%s", `PATH, "/tb0_data/ifmap0.txt");
		$sformat(full_path_ifmap_10, "%s%s", `PATH, "/tb1_data/ifmap0.txt");
		$sformat(full_path_ifmap_20, "%s%s", `PATH, "/tb2_data/ifmap0.txt");
		$sformat(full_path_ifmap_21, "%s%s", `PATH, "/tb2_data/ifmap1.txt");
		$sformat(full_path_ifmap_30, "%s%s", `PATH, "/tb3_data/ifmap0.txt");
		
		//read files
		`ifdef tb0
			ifmap_read0 = $fopen(full_path_ifmap_00,"r");
		`endif 
		`ifdef tb1
			ifmap_read0 = $fopen(full_path_ifmap_10,"r");
		`endif
		`ifdef tb2 // batch_size 2 
			ifmap_read0 = $fopen(full_path_ifmap_20,"r");
			ifmap_read1 = $fopen(full_path_ifmap_21,"r");
		`endif
		`ifdef tb3
			ifmap_read0 = $fopen(full_path_ifmap_30,"r");
		`endif
		 
		
		while(!$feof(ifmap_read0))begin
			//tb2 : batch size 2, other 1 
			`ifdef tb2 // batch_size 2 
				i_read0 = $fscanf(ifmap_read0,"%d",ifmap_MEM[0][i1][i0]);
				i_read1 = $fscanf(ifmap_read1,"%d",ifmap_MEM[1][i1][i0]);
			`else
				i_read0 = $fscanf(ifmap_read0,"%d",ifmap_MEM[0][i1][i0]);
			`endif
			if(i0 == (`channel-1)) begin
				i0 = 0;
				i1 = i1 + 1;
			end else begin
				i0 = i0 + 1;
				i1 = i1;
			end 
			if(i0 == 0 && i1 == `ifmap_col)
				break; 
		end
		$fclose(ifmap_read0);
		$fclose(ifmap_read1);
		/* for (int x=0;x<`batch_size;x++)begin
			for(int y=0;y<`ifmap_col;y++) begin
				for(int z=0;z<`channel;z++) begin
					$display("ifmap_MEM[%2d][%2d][%2d]:%d",x,y,z,ifmap_MEM[x][y][z]);
				end
			end 
		end   */
	end 
	
	
	
	/////	filter	/////
	//path string
	string full_path_filter_0,full_path_filter_1,full_path_filter_2,full_path_filter_3;
	logic signed [7:0]filter_MEM[`kernel-1:0][`filter_col-1:0][`channel-1:0]; 
	//tb0 : 16 Kernel * 3 Sliding_Window * 4 Channel
	integer f2,f1,f0;
	integer filter_read;
	integer f_read;
	
	initial begin
		f2=0;
		f1=0;
		f0=0;
		f_read=0;
		//define path
		$sformat(full_path_filter_0, "%s%s", `PATH, "/tb0_data/filter.txt");
		$sformat(full_path_filter_1, "%s%s", `PATH, "/tb1_data/filter.txt");
		$sformat(full_path_filter_2, "%s%s", `PATH, "/tb2_data/filter.txt");
		$sformat(full_path_filter_3, "%s%s", `PATH, "/tb3_data/filter.txt");
		//read files
		`ifdef tb0
			filter_read  = $fopen(full_path_filter_0,"r");
		`endif
		`ifdef tb1
			filter_read  = $fopen(full_path_filter_1,"r");
		`endif
		`ifdef tb2
			filter_read  = $fopen(full_path_filter_2,"r");
		`endif
		`ifdef tb3
			filter_read  = $fopen(full_path_filter_3,"r");
		`endif
				
		while(!$feof(filter_read))begin
			f_read = $fscanf(filter_read,"%d",filter_MEM[f2][f1][f0]);
			if(f0 == (`channel-1)) begin
				f0 = 0;
				if(f1 == (`filter_col-1)) begin
					f1 = 0;
					f2 = f2 + 1;
				end else begin
					f1 = f1 + 1;
					f2 = f2;
				end 
			end else begin
				f2 = f2;
				f1 = f1;
				f0 = f0 + 1;
			end
			if(f0 == 0 && f1 == 0 && f2 == `kernel)
				break;
		end
		$fclose(filter_read);
	end 
	
	/////	input Psum	/////
	//path string
	string full_path_ipsum_00,full_path_ipsum_10,full_path_ipsum_20,full_path_ipsum_21,full_path_ipsum_30;
	logic signed [`Psum_BITS-1:0]ipsum_MEM[`batch_size-1:0][`kernel-1:0][`ofmap_col-1:0]; 
	//tb0 : 1 Batch_Size * 16 Channel * 3 Ofmap_Column 
	integer p2,p1,p0;
	integer ipsum_read1,ipsum_read0;
	integer p_read1,p_read0;
	
	initial begin
		p1=0;
		p0=0;
		p_read0=0;
		p_read1=0;
		
		//define path
		$sformat(full_path_ipsum_00, "%s%s", `PATH, "/tb0_data/ipsum0.txt");
		$sformat(full_path_ipsum_10, "%s%s", `PATH, "/tb1_data/ipsum0.txt");
		$sformat(full_path_ipsum_20, "%s%s", `PATH, "/tb2_data/ipsum0.txt");
		$sformat(full_path_ipsum_21, "%s%s", `PATH, "/tb2_data/ipsum1.txt");
		$sformat(full_path_ipsum_30, "%s%s", `PATH, "/tb3_data/ipsum0.txt");
		
		//read files
		`ifdef tb0
			ipsum_read0 = $fopen(full_path_ipsum_00,"r");
		`endif
		`ifdef tb1
			ipsum_read0 = $fopen(full_path_ipsum_10,"r");
		`endif
		`ifdef tb2 // batch_size 2 
			ipsum_read0 = $fopen(full_path_ipsum_20,"r");
			ipsum_read1 = $fopen(full_path_ipsum_21,"r");
		`endif
		`ifdef tb3
			ipsum_read0 = $fopen(full_path_ipsum_30,"r");
		`endif
		
		
		while(!$feof(ipsum_read0))begin
			`ifdef tb2 // batch_size 2 
				p_read0 = $fscanf(ipsum_read0,"%d",ipsum_MEM[0][p1][p0]);
				p_read1 = $fscanf(ipsum_read1,"%d",ipsum_MEM[1][p1][p0]);
			`else
				p_read0 = $fscanf(ipsum_read0,"%d",ipsum_MEM[0][p1][p0]);
			`endif
			if(p0 == (`ofmap_col-1))begin
				p0 = 0;
				p1 = p1 + 1;
			end else begin
				p0 = p0 + 1;
				p1 = p1;
			end
			if(p0 == 0 && p1 == `kernel)
				break;
		end
		$fclose(ipsum_read0);
		$fclose(ipsum_read1);
	end
	
	/////	Answer	/////
	`ifdef tb3 //hybrid
		localparam golden_kernel = `kernel / 2;
		localparam golden_column = `ofmap_col*2;
	`else
		localparam golden_kernel = `kernel;
		localparam golden_column = `ofmap_col;
	`endif
	logic signed [`Psum_BITS-1:0] opsum_MEM[`batch_size-1:0][golden_kernel-1:0][golden_column-1:0];
	//tb0 : 1 Batch_Size * 16 Channel * 3 Ofmap_Column 
	integer o2,o1,o0;
	integer opsum_read;
	integer o_read0;
	string full_path_golden_0,full_path_golden_1,full_path_golden_2,full_path_golden_3;
	
	initial begin
		o2=0;
		o1=0;
		o0=0;
		o_read0=0;
		//define path
		$sformat(full_path_golden_0, "%s%s", `PATH, "/tb0_data/golden.txt");
		$sformat(full_path_golden_1, "%s%s", `PATH, "/tb1_data/golden.txt");
		$sformat(full_path_golden_2, "%s%s", `PATH, "/tb2_data/golden.txt");
		$sformat(full_path_golden_3, "%s%s", `PATH, "/tb3_data/golden.txt");
		
		//read files
		`ifdef tb0
			opsum_read = $fopen(full_path_golden_0,"r");
		`endif
		`ifdef tb1
			opsum_read = $fopen(full_path_golden_1,"r");
		`endif
		`ifdef tb2
			opsum_read = $fopen(full_path_golden_2,"r");
		`endif
		`ifdef tb3
			opsum_read = $fopen(full_path_golden_3,"r");
		`endif
		
		//read data 
		while(!$feof(opsum_read))begin
			o_read0 = $fscanf(opsum_read,"%d",opsum_MEM[o2][o1][o0]);
			if(o0 == (golden_column-1)) begin
				o0 = 0;
				if(o1 == (golden_kernel-1)) begin
					o1 = 0;
					o2 = o2 + 1;
				end else begin
					o1 = o1 + 1;
					o2 = o2;
				end 
			end else begin
				o2 = o2;
				o1 = o1;
				o0 = o0 + 1;
			end
			if(o0 == 0 && o1 == 0 && o2 == `batch_size)
				break;	
		end	
		
		$fclose(opsum_read);
		
	end
	 
	///////////////		Send Out Data	///////////////
	
	///// 	ifmap 	/////
	logic [5:0] ifmap_ptr2, ifmap_ptr1; 
	logic i_done; 
	logic [9:0] i0_repeat, i1_repeat;
	`ifdef tb3 //hybrid
		localparam i_delivery_column = `ifmap_col/2 - 1;
	`else
		localparam i_delivery_column = `ifmap_col-1;
	`endif
	logic ifmap_undone;
	logic receiving_ifmap;
	localparam repeat_time = `pro_pass*16 - 1 ;
	
	always_comb begin
		`ifdef tb0
			if(counter%10 == 3) begin 
				receiving_ifmap = 1;
		`elsif tb1 
			if(counter%10 == 1 || counter%10 == 3 || counter%10 == 4 || counter%10 == 6 || counter%10 == 9) begin 
				receiving_ifmap = 1;
		`elsif tb2
			if(counter%10 == 2) begin 
				receiving_ifmap = 1;
		`else 
			if(counter%10 == 6) begin 
				receiving_ifmap = 1;
		`endif
		
		end else begin
			receiving_ifmap = 0;
		end 
		
		ifmap_undone = rst || set_info || start || receiving_ifmap; 
		ifmap_enable = (ifmap_ready && !ifmap_undone && !i_done); 
	end 

	always_ff@(posedge rst or posedge clk) begin
		if(rst) begin		
			ifmap_ptr2 <= 6'd0;
			ifmap_ptr1 <= 6'd1;
			`ifdef tb3 //hybrid
				ifmap[31:16] <= {ifmap_MEM[0][1][3][3:0],ifmap_MEM[0][1][2][3:0],
								 ifmap_MEM[0][1][1][3:0],ifmap_MEM[0][1][0][3:0]};
				ifmap[15:0] <= {ifmap_MEM[0][0][3][3:0],ifmap_MEM[0][0][2][3:0],
								ifmap_MEM[0][0][1][3:0],ifmap_MEM[0][0][0][3:0]};
			`elsif tb1 // 3 channels 
				ifmap <= {8'd0,ifmap_MEM[0][0][2],ifmap_MEM[0][0][1],ifmap_MEM[0][0][0]};
			`else 
				ifmap <= {ifmap_MEM[0][0][3],ifmap_MEM[0][0][2],ifmap_MEM[0][0][1],ifmap_MEM[0][0][0]};
			`endif
			i_done <= 1'd0; 
			i0_repeat <= 10'd0;
			i1_repeat <= 10'd0;
			$display("*Ifmap Distribution Info* Time:%20d, Ifmap Buffer Coordinate [Batch Size][Column][Channel]"
							,$time);
		`ifdef tb3 //hybrid
			$display("*Ifmap Distribution Info* Time:%20d, Enable:%d, Ifmap Buffer is preparing for[0][1,0][3,2,1,0]"
							,$time,ifmap_enable);
		`else
			$display("*Ifmap Distribution Info* Time:%20d, Enable:%d, Ifmap Buffer is preparing for[0][0][3,2,1,0]"
							,$time,ifmap_enable);
		`endif
		end else begin
			if(ifmap_ready && !ifmap_undone) begin
				`ifdef tb3 //hybrid
					ifmap[31:16] <= {ifmap_MEM[ifmap_ptr2][(ifmap_ptr1*2+1)][3][3:0],
									 ifmap_MEM[ifmap_ptr2][(ifmap_ptr1*2+1)][2][3:0],
									 ifmap_MEM[ifmap_ptr2][(ifmap_ptr1*2+1)][1][3:0],
									 ifmap_MEM[ifmap_ptr2][(ifmap_ptr1*2+1)][0][3:0]};
					ifmap[15:0] <= {ifmap_MEM[ifmap_ptr2][(ifmap_ptr1*2)][3][3:0],
					                ifmap_MEM[ifmap_ptr2][(ifmap_ptr1*2)][2][3:0],
					                ifmap_MEM[ifmap_ptr2][(ifmap_ptr1*2)][1][3:0],
					                ifmap_MEM[ifmap_ptr2][(ifmap_ptr1*2)][0][3:0]};
				`elsif tb1 // 3 channel
					ifmap <= {8'd0,
							  ifmap_MEM[ifmap_ptr2][ifmap_ptr1][2],
							  ifmap_MEM[ifmap_ptr2][ifmap_ptr1][1],
							  ifmap_MEM[ifmap_ptr2][ifmap_ptr1][0]};
				`else
					ifmap <= {ifmap_MEM[ifmap_ptr2][ifmap_ptr1][3],
							  ifmap_MEM[ifmap_ptr2][ifmap_ptr1][2],
							  ifmap_MEM[ifmap_ptr2][ifmap_ptr1][1],
							  ifmap_MEM[ifmap_ptr2][ifmap_ptr1][0]};
				`endif
				
				if(ifmap_ptr2 == 6'd2) begin
					ifmap_ptr1 <= ifmap_ptr1;
					ifmap_ptr2 <= ifmap_ptr2;
					i_done <= 1'd1;
					if(i_done) begin
						//$display("*Ifmap* Enable:%d. All ifmaps are sended out. ",ifmap_enable);
					end else begin
					`ifdef tb3 //hybrid
						$display("*Ifmap* Time:%20d, last ifmap[31:16]:%3d%3d%3d%3d",$time,
						$signed(ifmap[31:28]),$signed(ifmap[27:24]),$signed(ifmap[23:20]),$signed(ifmap[19:16]));
						$display("*Ifmap* Time:%20d, last ifmap[15:0]:%3d%3d%3d%3d",$time,
						$signed(ifmap[15:12]),$signed(ifmap[11:8]),$signed(ifmap[7:4]),$signed(ifmap[3:0]));
					`else
						$display("*Ifmap* Time:%20d, last ifmap:%5d%5d%5d%5d ",$time,
						$signed(ifmap[31:24]),$signed(ifmap[23:16]),$signed(ifmap[15:8]),$signed(ifmap[7:0]));
					`endif
					end 
					
				end else begin
					$display("*Ifmap Info* Time:%20d, i0_repeat:%d, i1_repeat:%d"
							,$time,i0_repeat,i1_repeat);
					i_done <= 1'd0;
					if(ifmap_ptr1 == i_delivery_column) begin
						`ifdef tb2 // batch_size 2 
							if(i0_repeat < 10'd15) begin
								ifmap_ptr2 <= ifmap_ptr2;
								i0_repeat  <= i0_repeat + 10'd1;
								i1_repeat  <= i1_repeat;
							end else if (i0_repeat == 10'd15 && ifmap_ptr2 == 6'd0)begin 
								ifmap_ptr2 <= ifmap_ptr2 + 6'd1;
								i0_repeat  <= i0_repeat;
								i1_repeat  <= i1_repeat;
							end else if (i1_repeat < 10'd15 && ifmap_ptr2 == 6'd1)begin
								ifmap_ptr2 <= ifmap_ptr2;
								i0_repeat  <= i0_repeat;
								i1_repeat  <= i1_repeat + 10'd1;
							end else if (i1_repeat == 10'd15 && ifmap_ptr2 == 6'd1)begin
								ifmap_ptr2 <= ifmap_ptr2 + 6'd1;
								i0_repeat  <= i0_repeat;
								i1_repeat  <= i1_repeat;
							end  
						`else
							if(i0_repeat < repeat_time) begin
								ifmap_ptr2 <= ifmap_ptr2;
								i0_repeat  <= i0_repeat + 10'd1;
							end else if (i0_repeat == repeat_time && ifmap_ptr2 == 6'd0)begin 
								ifmap_ptr2 <= ifmap_ptr2 + 6'd2;
								i0_repeat  <= i0_repeat;	
							end  
							i1_repeat  <= i1_repeat;
						`endif 
						ifmap_ptr1 <= 6'd0;
					end else begin
						ifmap_ptr2 <= ifmap_ptr2;
						ifmap_ptr1 <= ifmap_ptr1+ 6'd1;
						i0_repeat  <= i0_repeat;
						i1_repeat  <= i1_repeat;
					end 
					`ifdef tb3 //hybrid
						$display("*Ifmap* Time:%20d, ifmap[31:16] %3d%3d%3d%3d / [15:0] %3d%3d%3d%3d",$time,
							$signed(ifmap[31:28]),$signed(ifmap[27:24]),$signed(ifmap[23:20]),$signed(ifmap[19:16]),
							$signed(ifmap[15:12]),$signed(ifmap[11:8]),$signed(ifmap[7:4]),$signed(ifmap[3:0]));
						$display("*Ifmap* Time:%20d, next ifmap Buffer[%2d][%2d,%2d][3,2,1,0]",
							$time,ifmap_ptr2,(ifmap_ptr1*2+1),(ifmap_ptr1*2));
					`else
						$display("*Ifmap* Time:%20d, ifmap:%5d%5d%5d%5d, next ifmap Buffer[%2d][%2d][3,2,1,0]",$time,
							$signed(ifmap[31:24]),$signed(ifmap[23:16]),$signed(ifmap[15:8]),$signed(ifmap[7:0]),
							ifmap_ptr2,ifmap_ptr1);
					`endif
				end 
				
			// ifmap no handshake
			end	else begin
				ifmap_ptr2 <= ifmap_ptr2;
				ifmap_ptr1 <= ifmap_ptr1;
			end	
			
		end
	end 
	
	///// 	filter 	/////
	logic [9:0] filter_ptr2, filter_ptr1, filter_ptr0;
	logic f_done;
	logic [1:0] f_repeat; //tb2 batch_size 2
	`ifdef tb3 //hybrid
		localparam f_delivery_kernel = `kernel/2;
	`else
		localparam f_delivery_kernel = `kernel;
	`endif
	logic filter_undone;
	logic receiving_filter;
	
	always_comb begin
		`ifdef tb0
			if(counter%10 == 9) begin 
				receiving_filter = 1;
		`elsif tb1 
			if(counter%10 == 0 || counter%10 == 2 || counter%10 == 4 || counter%10 == 6 || counter%10 == 8) begin 
				receiving_filter = 1;
		`elsif tb2
			if(counter%10 == 1) begin 
				receiving_filter = 1;
		`else 
			if(counter%10 == 0) begin 
				receiving_filter = 1;
		`endif
		
		end else begin
			receiving_filter = 0;
		end 
		
		filter_undone = rst || set_info || start || receiving_filter;
		filter_enable = (filter_ready && !filter_undone && !f_done);
	end 
	
	always_ff@(posedge rst or posedge clk) begin
		if(rst) begin		
			filter_ptr2 <= 10'd0;
			filter_ptr1 <= 10'd0;
			filter_ptr0 <= 10'd1;
			f_done <= 1'd0;
			f_repeat <= 1'd0;
			$display("\n");
			$display("*Filter Distribution Info* Time:%20d, Filter Buffer Coordinate [Kernel][Column][Channel]"
						,$time);
			// Assign filter value	
			`ifdef tb3 // hybrid
				filter[7:0]<= {filter_MEM[1][0][0][3:0],filter_MEM[0][0][0][3:0]};
			`else
				filter <= filter_MEM[0][0][0];
			`endif
			
			//Filter Delivery Info	
			`ifdef tb3 // hybrid
				$display("*Filter Distribution Info* Time:%20d, Enable:%d, Filter Buffer is preparing for[1,0][0][0]"
							,$time,filter_enable);
			`else
				$display("*Filter Distribution Info* Time:%20d, Enable:%d, Filter Buffer is preparing for[0][0][0]"
							,$time,filter_enable);
			`endif
		end else begin
		//$display("*parameter* Time:%20d, f_repeat:%d,filter_ptr2 %d,f_done",$time,f_repeat,filter_ptr2,f_done);
		// f-done v.s. handshake	
			if(filter_ready && !filter_undone) begin
				///// Assign filter value
				`ifdef tb3 // hybrid
					filter <= {filter_MEM[(2*filter_ptr2+1)][filter_ptr1][filter_ptr0][3:0],
							   filter_MEM[(2*filter_ptr2)][filter_ptr1][filter_ptr0][3:0]};
				`else
					filter <=  filter_MEM[filter_ptr2][filter_ptr1][filter_ptr0];
				`endif
				
				if(filter_ptr2 == f_delivery_kernel) begin /// a round of filter has sended out
					//$display("*Filter send out a round* Time:%20d, f_repeat:%d",$time,f_repeat);
					if(f_repeat == 2'd2) begin
						//$display("*Filter* Enable:%d. All filters are sended out.",filter_enable);
						f_done <= 1'd1;
						filter_ptr0 <= filter_ptr0;
						filter_ptr1 <= filter_ptr1;
						filter_ptr2 <= filter_ptr2;
						f_repeat <= f_repeat;
					end else if(f_repeat == 2'd1) begin //for tb3 2 image
						$display("*Filter* Time:%20d, last filter:%5d.",$time,$signed(filter[7:0]));
						filter_ptr0 <= filter_ptr0;
						filter_ptr1 <= filter_ptr1;
						filter_ptr2 <= filter_ptr2;
						f_done <= 1'd1;
						f_repeat <= f_repeat + 2'd1;
					end else begin
						`ifdef tb3 // Hybrid 
							$display("*Filter* Time:%20d, last filter:%3d%3d.",
								$time,$signed(filter[7:4]),$signed(filter[3:0]));
						`elsif tb2 // batch_size 2 
							$display("*Filter* Time:%20d, filter:%5d.",$time,$signed(filter[7:0]));
							$display("Buffer isn't available and needs to prepare for next filter in next cycle.");
						`else 
							$display("*Filter* Time:%20d, last filter:%5d.",$time,$signed(filter[7:0]));
						`endif
						filter_ptr0 <= 10'd0;
						filter_ptr1 <= 10'd0;
						f_done   <= 1'd1;
						`ifdef tb2 // batch_size 2 
							f_repeat <= f_repeat + 2'd1;
							filter_ptr2 <= 10'd0;
						`else
							f_repeat <= 2'd2;
							filter_ptr2 <= filter_ptr2;
						`endif
					end
					
				end else begin /// sendING out a round of filter 
					//$display("*Filter Info* Time:%20d, f_repeat:%d",$time,f_repeat);
					if(filter_ptr0 == `channel-1) begin
						filter_ptr0 <= 10'd0;
						if(filter_ptr1 == 10'd2) begin 
							filter_ptr2 <= filter_ptr2 + 10'd1;
							filter_ptr1 <= 10'd0;
						end else begin
							filter_ptr2 <= filter_ptr2;
							filter_ptr1 <= filter_ptr1 + 10'd1;
						end 
					end else begin
						filter_ptr2 <= filter_ptr2;
						filter_ptr1 <= filter_ptr1;
						filter_ptr0 <= filter_ptr0 + 10'd1;
					end 
					f_done <= 1'd0; // 
					f_repeat <= f_repeat;
					
					`ifdef tb3 // Hybrid 
						$display("*Filter* Time:%20d, filter[7:4][3:0]:%3d%3d",$time,$signed(filter[7:4]),$signed(filter[3:0]));
						$display("*Filter* Time:%20d, next filter Buffer[%2d,%2d][%2d][%2d]"
							,$time,(2*filter_ptr2+1),(2*filter_ptr2),filter_ptr1,filter_ptr0);
					`else
						$display("*Filter* Time:%20d, filter:%5d, next filter Buffer[%2d][%2d][%2d]"
						,$time,$signed(filter[7:0]),filter_ptr2,filter_ptr1,filter_ptr0);
					`endif
				end 
				
			// filter no handshake
			end	else begin
				f_done <= f_done;
				filter_ptr2 <= filter_ptr2;
				filter_ptr1 <= filter_ptr1;
				filter_ptr0 <= filter_ptr0;
			end	
		end
	end
	

	logic [9:0] ipsum_ptr2, ipsum_ptr1, ipsum_ptr0;
	logic ip_done;
	`ifdef tb3 //hybrid
		localparam ip_delivery_kernel = `kernel/2;
	`else
		localparam ip_delivery_kernel = `kernel;
	`endif
	logic ipsum_undone;
	logic receiving_ipsum;
	
	always_comb begin
		`ifdef tb0
			if(counter%10 == 2) begin 
				receiving_ipsum = 1;
		`elsif tb1 
			if(counter%10 == 1 || counter%10 == 3 || counter%10 == 5 || counter%10 == 7 || counter%10 == 9) begin 
				receiving_ipsum = 1;
		`elsif tb2
			if(counter%10 == 7) begin 
				receiving_ipsum = 1;
		`else 
			if(counter%10 == 4) begin 
				receiving_ipsum = 1;
		`endif
		end else begin
			receiving_ipsum = 0;
		end
		
		ipsum_undone = rst || set_info || start || receiving_ipsum;
		ipsum_enable = (ipsum_ready && !ipsum_undone && !ip_done);
	end 
	
	always_ff@(posedge rst or posedge clk) begin
		if(rst) begin		
			ipsum_ptr2 <= 10'd0;
			ipsum_ptr1 <= 10'd0;
			ipsum_ptr0 <= 10'd1;
			`ifdef tb3 // hybrid
				ipsum <= {ipsum_MEM[0][1][0][11:0],ipsum_MEM[0][0][0][11:0]};
			`else
				ipsum <= ipsum_MEM[0][0][0];
			`endif
			ip_done <= 1'd0;
			$display("\n");
			$display("*Input Psum Distribution Info* Time:%20d, Ipsum Buffer Coordinate [Batch Size][Channel][Column]"
						,$time);
			`ifdef tb3 // hybrid
				$display("*Input Psum Distribution Info* Time:%20d, Enable:%d, Ipsum Buffer is preparing for[0][1,0][0]"
							,$time,ipsum_enable);
			`else
				$display("*Input Psum Distribution Info* Time:%20d, Enable:%d, Ipsum Buffer is preparing for[0][0][0]"
							,$time,ipsum_enable);
			`endif
			
		end else begin
			if(ipsum_ready && !ipsum_undone) begin
				`ifdef tb3 // hybrid
					ipsum <= {ipsum_MEM[ipsum_ptr2][2*ipsum_ptr1+1][ipsum_ptr0][11:0],
							  ipsum_MEM[ipsum_ptr2][2*ipsum_ptr1][ipsum_ptr0][11:0]};
				`else
					ipsum <= ipsum_MEM[ipsum_ptr2][ipsum_ptr1][ipsum_ptr0];
				`endif
				if(ipsum_ptr2 == 6'd2) begin
					ipsum_ptr2 <= ipsum_ptr2;
					ipsum_ptr1 <= ipsum_ptr1;
					ipsum_ptr0 <= ipsum_ptr0;
					ip_done <= 1'd1;
					if(ip_done) begin
						//$display("*Ipsum* Enable:%d. All ipsums are sended out. ",ipsum_enable);
					end else begin
					`ifdef tb3 // hybrid
						$display("*Ipsum* Time:%20d, last ipsum:%7d%7d",$time,
							$signed(ipsum[23:12]),$signed(ipsum[11:0]));
					`else
						$display("*Ipsum* Time:%20d, last ipsum:%10d",$time,$signed(ipsum));
					`endif
					end
				end else begin
					if(ipsum_ptr0 == (`ofmap_col-1)) begin
						ipsum_ptr0 <= 10'd0;
						if(ipsum_ptr1 == ip_delivery_kernel-1) begin 
							`ifdef tb2 // batch_size 2 
								ipsum_ptr2 <= ipsum_ptr2 + 10'd1;
							`else
								ipsum_ptr2 <= 10'd2;
							`endif
							ipsum_ptr1 <= 10'd0;
						end else begin
							ipsum_ptr2 <= ipsum_ptr2;
							ipsum_ptr1 <= ipsum_ptr1 + 10'd1;
						end 
					end else begin
						ipsum_ptr2 <= ipsum_ptr2;
						ipsum_ptr1 <= ipsum_ptr1;
						ipsum_ptr0 <= ipsum_ptr0 + 10'd1;
					end 
					ip_done <= 1'd0;
					`ifdef tb3 // hybrid
						$display("*Ipsum* Time:%20d, ipsum:%7d%7d, next ipsum Buffer[%2d][%2d,%2d][%2d]",
						$time,$signed(ipsum[23:12]),$signed(ipsum[11:0]),
						ipsum_ptr2,(2*ipsum_ptr1+1),(2*ipsum_ptr1),ipsum_ptr0);
					`else
						$display("*Ipsum* Time:%20d, ipsum:%10d, next ipsum Buffer[%2d][%2d][%2d]"
						,$time,$signed(ipsum),ipsum_ptr2,ipsum_ptr1,ipsum_ptr0);
					`endif
				end 
	
			// ipsum not ready
			end	else begin
				ip_done <= ip_done;
				ipsum_ptr2 <= ipsum_ptr2;
				ipsum_ptr1 <= ipsum_ptr1;
				ipsum_ptr0 <= ipsum_ptr0;
			end	
		end
	end

	//////////	Compare Answer	//////////
	integer err;
	logic [12:0] output_count;
	logic [7:0] op2;
	logic [7:0] op1;
	logic [7:0] op0;
	logic [7:0] op_batch;
	logic [7:0] op_ch;
	logic [7:0] op_col;
	logic signed [`Psum_BITS-1:0] answer0;
	logic signed [`Psum_BITS-1:0] result0;
	`ifdef tb3 //hybrid
		localparam ans_kernel = `kernel/2;
	`else
		localparam ans_kernel = `kernel;
	`endif
	logic opsum_undone;

	always_comb begin
		opsum_undone = rst || set_info || start ;
		opsum_ready = !opsum_undone;
	end 
	
	assign result0 = opsum; 
	always_ff@(posedge rst or posedge clk) begin
		if(rst) begin
			op2 <= 8'd0;
			op1 <= 8'd0;
			op0 <= 8'd1;
			op_batch <= 8'd0;
			op_ch 	 <= 8'd0;
			op_col 	 <= 8'd0;
			`ifdef tb3 // hybrid
				answer0 <= {opsum_MEM[0][0][1][11:0],opsum_MEM[0][0][0][11:0]};
			`else
				answer0 <= opsum_MEM[0][0][0];
			`endif
			output_count <= 13'd0;
			err <= 0;
		end else begin
			if(opsum_enable && opsum_ready && output_count <= (`ofmap_total-1) ) begin
				output_count <= output_count + 13'd1;
				`ifdef tb3 // hybrid
					//$display("\n Time:%20d: Counter %10d." ,$time,counter);
					answer0 <= {opsum_MEM[op2][op1][2*op0+1][11:0],opsum_MEM[op2][op1][2*op0][11:0]};
					if( result0 != answer0 || $isunknown(result0[23:12]) == 1'd1 
										   || $isunknown(result0[11:0]) == 1'd1) begin
						err <= err + 1;
						$display("\n Time:%20d: Ofmap%3d channel%2d,%2d column%3d is \033[0;31m\ WRONG."
							,$time, op_batch, (op_ch*2+1), (op_ch*2), op_col);
						$write("%c[0m",27);
						if($isunknown(result0[23:12]) == 1'd1) begin
							$display("Channel%3d Correct ans %7d / Your ans Unknown",
							(op_ch*2+1),$signed(answer0[23:12]));
						end else begin
							$display("Channel%3d Correct ans %7d / Your ans %7d",
							(op_ch*2+1),$signed(answer0[23:12]),$signed(result0[23:12]));
						end 
						
						if($isunknown(result0[11:0]) == 1'd1) begin
							$display("Channel%3d Correct ans %7d / Your ans Unknown",
							(op_ch*2),$signed(answer0[11:0]));
						end else begin
							$display("Channel%3d Correct ans %7d / Your ans %7d",
							(op_ch*2),$signed(answer0[11:0]),$signed(result0[11:0]));
						end
						
					end else begin
						$display("%c[0;33m",27);
						$display("\n Time:%20d: Ofmap%3d channel%2d,%2d column%3d : %7d%7d is correct." ,$time, 
							op_batch, (op_ch*2+1), (op_ch*2), op_col,$signed(answer0[23:12]),$signed(answer0[11:0]));
						$write("%c[0m",27);
						err <= err;
					end 
				`else
					answer0 <= opsum_MEM[op2][op1][op0];
					//$display("\n Time:%20d: Counter %10d." ,$time,counter);
					if($isunknown(result0) == 1'd1) begin
						err <= err + 1;
						$display("\n Time:%20d, Ofmap%3d channel%3d column%3d is WRONG."
							,$time, op_batch, op_ch, op_col);
						$display("Correct ans %10d / Your ans Unknown",answer0); 
					end else if($signed(result0) != $signed(answer0)) begin
						err <= err + 1;
						$display("\n Time:%20d, Ofmap%3d channel%3d column%3d is \033[0;31m\ WRONG."
							,$time, op_batch, op_ch, op_col);
						$write("%c[0m",27);
						$display("Correct ans %10d / Your ans %10d",answer0,result0);
					end else begin
						$display("%c[0;33m",27);
						$display("\n Time:%20d, Ofmap%3d channel%3d column%3d : %10d is correct."
							,$time, op_batch, op_ch, op_col,$signed(answer0));
						$write("%c[0m",27);
						err <= err;
					end 
				`endif
				
				if(op0 == (`ofmap_col-1)) begin
					op0 <= 6'd0; 
					if(op1 == ans_kernel-1) begin 
						op2 <= op2 + 6'd1;
						op1 <= 6'd0;
					end else begin
						op2 <= op2;
						op1 <= op1 + 6'd1;
					end
				end else begin
					op0 <= op0 + 6'd1;
					op1 <= op1;
					op2 <= op2;
				end 
				
				if(op_col == (`ofmap_col-1)) begin
					op_col <= 6'd0; 
					if(op_ch == ans_kernel-1) begin 
						op_batch <= op_batch + 6'd1;
						op_ch <= 6'd0;
					end else begin
						op_batch <= op_batch;
						op_ch <= op_ch + 6'd1;
					end
				end else begin
					op_col <= op_col + 6'd1;
					op_ch <= op_ch;
					op_batch <= op_batch;
				end
				
			//opsum haven't arrived
			end else begin
				output_count <= output_count;
				op2 <= op2;
				op1 <= op1;
				op0 <= op0;
				op_batch <= op_batch;
				op_ch    <= op_ch;
				op_col   <= op_col;
				err <= err;
			end 
		end 
	end 
	
	logic opsum_all_done;
	longint total_cycle;
	// total cycles you spend 
	always_ff@(posedge rst or posedge clk) begin
		if(rst) begin
			total_cycle <= 64'd0;
			opsum_all_done <= 1'd0;
		end else if( !opsum_all_done && output_count == `ofmap_total ) begin
			total_cycle <= counter;
			opsum_all_done <= 1'd1;
		end else begin
			total_cycle <= total_cycle;
			opsum_all_done <= opsum_all_done;
		end 
	end
			
	initial begin
		$fsdbDumpfile("PE.fsdb");
		$fsdbDumpvars("+struct", "+mda", PE0);
		$fsdbDumpMDA(2,PE0); 
		
		#(`CYCLE*`MAX)
			if(err > 0 || (output_count!=`ofmap_total))begin
				$display("                          \n   ");
				
				if(output_count != `ofmap_total) begin
					$display("	!Error! You only have only %8d sets of opsum \n", output_count);
				end else begin
					$display("          Totally has %10d errors \n", err);
				end
				
				if(opsum_all_done) begin
					$display("In %20d cycles, You have sent out all opsums.\n",total_cycle);
				end 
				
				$display("****************************               Sad  GIRAFFE   ");
				$display("****************************               __     *  	  ");
				$display("**                        **               \\ \\____|___	 	  ");
				$display("**                        **                \\    Q    \\    ");
				$display("**                        **                 |     __  )   ");
				$display("**   OOOOOOOOOOOOOPS!     **                 |_    ___/    ");
				$display("**   Oh! NOOOOOOOOOO!     **                 |_)  |        ");
				$display("**   OOOOOOOOOOOOOPS!     **                 |   _|        ");
				$display("**                        **                 |  (_|        ");
				$display("**                        **                 |_   |        ");
				$display("** !!Simulation Failed!!  **                 |_)  |        ");
				$display("**                        **                 |   _|        ");
				$display("**                        **                 |  (_|        ");
				$display("**                        **                 |    |       ");
				$display("**                        **          ______ |   _|      ");
				$display("**                        **         /          (_|       ");
				$display("**  GIRAFFE LULU Creator  **       ./_      __    |       ");
				$display("** NCKU AISystem Lab SOUP **      /|__)    /  \\   |       ");
				$display("****************************     / |       \\__/   |       ");
				$display("****************************  /\\/  |    ______    |        ");
				$display("                             /__\\  |   |      |   |         ");
				$display("                                   |   |      |   |         ");
				$display("                                   |___|      |___|         ");
				$display("                                   |___|      |___|         ");
				$display("                          \n   ");
			end else begin
				
				$display("\n In %20d cycles, You have sent out all opsums.",total_cycle);
				$display("%c[0;33m",27);
			`ifdef tb0 
				$display("****************************              HAPPY  GIRAFFE   ");
				$display("****************************                __     *  	   ");
				$display("**                        **                \\ \\____|___	   ");
				$display("**                        **                 \\    ^    \\    ");
				$display("**                        **                  |         )   ");
				$display("**   UUUUU~ HOOOOOOO~     **                  |_    ___/    ");
				$display("**   CONGRATULATIONS!     **                  |_)  |        ");
				$display("**   UUUUU~ HOOOOOOO~     **                  |   _|        ");
				$display("**                        **                  |  (_|        ");
				$display("**                        **                  |_   |        ");
				$display("**  !!Simulation PASS!!   **                  |_)  |        ");
				$display("**                        **                  |   _|        ");
				$display("**                        **   ___            |  (_|        ");
				$display("**                        **  \\  /            |    |       ");
				$display("**                        **   \\/\\     ______ |   _|      ");
				$display("**                        **      \\   /          (_|       ");
				$display("**  GIRAFFE LULU Creator  **       \\./_      __    |        ");
				$display("** NCKU AISystem Lab SOUP **        |__)    /  \\   |         ");
				$display("****************************        |       \\__/   |        ");
				$display("****************************        |    ______    |         ");
				$display("                                    |   |      |   |         ");
				$display("                                    |   |      |   |         ");
				$display("                                    |___|      |___|        ");
				$display("                                    |___|      |___|        ");
				$display("                          \n   ");
	
			`elsif tb1

				$display("                       ~~ Simulation PASS ~~                                  ");
				//$display("                                                                                  ");
				$display("           * * * * * * * * * * *                                                ");
				$display("          *  TWO HAPPY Giraffes *           *     __                          ");
				$display("           * * * * * * * * * * *         ___|____/ /                          ");
				$display("                                        /     ^   /                           ");
				$display("                __     *  	       (         |                              ");
				$display("                \\ \\____|___	        \\___     |                             ");
				$display("                 \\    ^    \\                |_   |                          ");
				$display("                  |         )               |_)  |                            ");
				$display("                  |_    ___/                |    |                            ");
				$display("                  |_)  |                    |_   |                            ");
				$display("                  |   _|                    |_)  |                            ");
				$display("                  |  (_|                    |    |                            ");
				$display("                  |_   |                    |   _|                            ");
				$display("                  |_)  |                    |  (_|                            ");
				$display("                  |   _|                    |    |                            ");
				$display("   ___            |  (_|                    |_   |             ___         ");
				$display("  \\  /            |    |                    |_)  |             \\  /         "); 
				$display("   \\/\\     ______ |   _|                    |    |_______      /\\/             ");
				$display("      \\   /          (_|         ♥ ~        |         |_| \\   /              ");
				$display("       \\./_      __    |         ~ ♥        |    __        \\./                ");
				$display("        |__)    /  \\   |                    |   /  \\        |               ");
				$display("        |       \\__/   |                    |   \\__/       _|               ");
				$display("        |    ______    |                    |    _______  (_|                 ");
				$display("        |   |      |   |                    |   |       |   |                 ");
				$display("        |   |      |   |                    |   |       |   |                 ");
				$display("        |___|      |___|                    |___|       |___|                 ");
				$display("        |___|      |___|                    |___|       |___|                 ");
				$display("                          \n   ");
			`else 
				`ifdef tb3
					$display("%c[5;33m",27);
				`endif
				$display("                             ~~ Simulation PASS ~~                                  ");
				$display("      * * * * * * * * * * * * * * * * * * *                                    ");
				$display("     * TWO HAPPY Giraffes & A baby Giraffe *         *     __                          ");
				$display("      * * * * * * * * * * * * * * * * * * *       ___|____/ /                          ");
				$display("                                                 /     ^   /                           ");
				$display("                __     *  	                (         |                              ");
				$display("                \\ \\____|___	                 \\___     |                             ");
				$display("                 \\    ^    \\                         |_   |                          ");
				$display("                  |         )                        |_)  |                            ");
				$display("                  |_    ___/                         |    |                            ");
				$display("                  |_)  |            __    *          |_   |                            ");
				$display("                  |   _|            \\ \\___|___       |_)  |                            ");
				$display("                  |  (_|             \\   ^    \\      |    |                            ");
				$display("                  |_   |              |        )     |   _|                            ");
				$display("                  |_)  |              |    ___/      |  (_|                            ");
				$display("                  |   _|              |_  |          |    |                            ");
				$display("   ___            |  (_|              |_) |          |_   |             ___         ");
				$display("  \\  /            |    |              |_  |          |_)  |             \\  /         "); 
				$display("   \\/\\     ______ |   _|              |_) |          |    |_______      /\\/             ");
				$display("      \\   /          (_|              |   |          |         |_| \\   /              ");
				$display("       \\./_      __    |   *     _____|  _|          |    __        \\./           ");
				$display("        |__)    /  \\   |    \\   /   __  (_|          |   /  \\        |               ");
				$display("        |       \\__/   |     \\./   /  \\   |          |   \\__/       _|               ");
				$display("        |    ______    |      |    \\__/   |          |    _______  (_|                 ");
				$display("        |   |      |   |      |   _____   |          |   |       |   |                 ");
				$display("        |   |      |   |      |  |     |  |          |   |       |   |                 ");
				$display("        |___|      |___|      |__|     |__|          |___|       |___|                 ");
				$display("        |___|      |___|      |__|     |__|          |___|       |___|                 ");
				$display("                          \n   ");
			`endif
				$write("%c[0m",27);
				// Here comes HAPPY Giraffes
			end
		 
		$finish;
	end
	
endmodule 