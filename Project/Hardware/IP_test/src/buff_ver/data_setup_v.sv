`define  PW_ifmap_H 28
`define  PW_ifmap_W 28
`define  PW_ifmap_C_WORD 2
`define  PW_BASE_ADDR 0
`define  PW_BIAS 1568

`define  DW_ifmap_H 30
`define  DW_ifmap_W 30
`define  DW_ifmap_C 8 
`define  DW_STRIDE  3
`define  DW_BASE_ADDR 0
`define  DW_STRIDE_NUM 297

//pointwise NHWC
//depthwise NCHW

module data_setup_v(
	input  clk,
	input  rst,
	input  [1:0] mode,
	input  logic fifo_WREADY_col [15:0],	// fifo can write
	output logic fifo_WVALID_col [15:0],	// write fifo
	output logic [7:0]    in_col [15:0],
	
	output logic IM_CS,
	output IM_OE,
	output logic [ 3:0] IM_WEB,
	output logic [13:0] IM_A,
	output logic [31:0] IM_DI,
	input  logic [31:0] IM_DO
);

	//===========FSM=============//
	enum logic[3:0]{
		IDLE,
		PW_LOAD,
		PW_PREPARE,
		PW_STORE,
		DW_LOAD,
		DW_PREPARE,
		DW_STORE
	} cur_state, next_state;
	
	//===========counter===========//
	logic [ 5:0] PW_H_counter;
	logic [ 5:0] PW_W_counter;
	logic [ 5:0] PW_C_counter;
	logic [ 5:0] PW_C_counter_ff;      //used for storing data
	logic [13:0] PW_addr_bias_counter;
	
	
	//===========handshake signal=========//
	logic PW_WREADY_3210; 
	logic PW_WREADY_7654;
	logic handshake_3210;
	logic handshake_7654;
	logic PW_handshake;
	logic [31:0] PW_data_buffer;
	
	//=============depthwise counter=========//
	logic [ 2:0] channel_counter;
	logic [ 2:0] channel_counter_ff;
	logic [ 2:0] height_counter;
	logic [ 2:0] height_counter_ff;
	logic [ 7:0] start_addr;
	logic [ 8:0] stride_counter;
	logic [ 8:0] stride_counter_ff;
	logic [13:0] DW_addr_bias;
	logic [13:0] DW_addr_bias_temp;
	logic [32:0] DW_data_buffer;
	logic [11:0] DW_jump_next_counter;
	
	//========depthwise handshake signal==========//
	logic handshake_c1;
	logic handshake_c2;
	logic handshake_c3;
	logic handshake_c4;
	logic handshake_c5;
	logic DW_handshake;
	logic DW_WREADY_c1;
	logic DW_WREADY_c2;
	logic DW_WREADY_c3;
	logic DW_WREADY_c4;
	logic DW_WREADY_c5;
	
	
	always_ff @(posedge clk or posedge rst) begin
		if( rst ) begin
			cur_state <= IDLE;
		end else begin
			cur_state <= next_state;
		end
	end
	
	//=============================================//
	//next_state_logic
	//=============================================//
	// logic mode; // 0:pointwise 1:depthwise  		
	// assign mode = 1'd1;

	always_comb begin
		case(cur_state)
			IDLE : begin
				case(mode)
					2'd0    : next_state = IDLE;           
					2'd1    : next_state = DW_LOAD;
					2'd2    : next_state = PW_LOAD;
					default : next_state = IDLE;
				endcase 
			end
			PW_LOAD : begin				//one cycle
				next_state = PW_PREPARE;
			end
			PW_PREPARE : begin
				next_state = PW_STORE;	
			end
			PW_STORE: begin
				if(PW_handshake && (PW_addr_bias_counter == `PW_BIAS))     //handshake and last data
					next_state = IDLE;
				else if(PW_handshake)   //handshake 
					next_state = PW_LOAD;
				else begin end			
			end
			
			
			DW_LOAD : begin
				next_state = DW_PREPARE;
			end
			DW_PREPARE : begin
				next_state = DW_STORE;
			end
			DW_STORE : begin
				if((channel_counter_ff   == 3'd4) &&
				   (height_counter_ff    == 3'd2) && 
				   (stride_counter_ff    == `DW_STRIDE_NUM))     //handshake and last data
					next_state = IDLE;
				else if(DW_handshake)   //handshake 
					next_state = DW_LOAD;
				else begin end		
			end
		endcase
	end
	
	//=======================pointwise_counter======================//
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			PW_W_counter         <=  6'd0;
			PW_H_counter         <=  6'd0;
			PW_C_counter         <=  6'd0;
			PW_addr_bias_counter <= 11'd0;
		end
		else begin
			case(cur_state)
				IDLE : begin
					PW_W_counter         <=  6'd0;
					PW_H_counter         <=  6'd0;
					PW_C_counter         <=  6'd0;
					PW_C_counter_ff      <=  6'd0; 
					PW_addr_bias_counter <= 11'd0;
				end
				PW_LOAD : begin
					// total counter
					if(PW_addr_bias_counter < `PW_BIAS) begin
						PW_addr_bias_counter <= PW_addr_bias_counter + 11'd1;
					end else begin
						PW_addr_bias_counter <= PW_addr_bias_counter; 
					end
					
					//Channel (inner loop)
					if(PW_C_counter == (`PW_ifmap_C_WORD - 1)) begin
						PW_C_counter    <= 6'd0;
						PW_C_counter_ff <= PW_C_counter;
					end else begin
						PW_C_counter    <= PW_C_counter + 6'd1;
						PW_C_counter_ff <= PW_C_counter;
					end

					
					//Width (second loop)
					if(PW_W_counter == (`PW_ifmap_W - 1)) begin
						PW_W_counter <= 6'd0; 
					end else if(PW_C_counter == (`PW_ifmap_C_WORD - 1)) begin
						PW_W_counter <= PW_W_counter + 6'd1; 
					end else begin
						PW_W_counter <= PW_W_counter; 
					end
					
					//Height (outter loop)
					if(PW_H_counter == (`PW_ifmap_H - 1)) begin
						PW_H_counter <= 6'd0; 
					end else if(PW_W_counter == (`PW_ifmap_W - 1)) begin
						PW_H_counter <= PW_H_counter + 6'd1; 
					end else begin
						PW_H_counter <= PW_H_counter; 
					end
				end
				default : begin
					PW_W_counter         <= PW_W_counter;
					PW_H_counter         <= PW_H_counter;
					PW_C_counter         <= PW_C_counter;
					PW_addr_bias_counter <= PW_addr_bias_counter;
				end
			endcase
		end
	end
	
	//=====================Input SRAM access control=======================//
	assign IM_CS  = 1'b1;
	assign IM_DI  = 32'd0;
	assign IM_WEB = 4'b1111;
	assign IM_OE  = ((cur_state == PW_PREPARE) ||(cur_state == DW_PREPARE)) ? 1'd1 : 1'd0;
	assign IM_A   = (cur_state ==    PW_LOAD) ? (`PW_BASE_ADDR + PW_addr_bias_counter) : 
					(cur_state ==    DW_LOAD) ? (`DW_BASE_ADDR + DW_addr_bias        ) : 14'd0;
	
	//=====================data setup control=======================//
	assign PW_WREADY_3210 = (   fifo_WREADY_col[0] == 1'd1
							 && fifo_WREADY_col[1] == 1'd1
							 && fifo_WREADY_col[2] == 1'd1
							 && fifo_WREADY_col[3] == 1'd1) ? 1'd1 : 1'd0;
							 
	assign PW_WREADY_7654 = (   fifo_WREADY_col[4] == 1'd1
							 && fifo_WREADY_col[5] == 1'd1
							 && fifo_WREADY_col[6] == 1'd1
							 && fifo_WREADY_col[7] == 1'd1) ? 1'd1 : 1'd0;
							 
	assign PW_handshake   = handshake_3210 | handshake_7654;
	
	assign DW_WREADY_c1 = (	fifo_WREADY_col[ 0] && 
							fifo_WREADY_col[ 1] &&
							fifo_WREADY_col[ 2]);  
	assign DW_WREADY_c2 = (	fifo_WREADY_col[ 3] && 
							fifo_WREADY_col[ 4] &&
							fifo_WREADY_col[ 5]);  
	assign DW_WREADY_c3 = (	fifo_WREADY_col[ 6] && 
							fifo_WREADY_col[ 7] &&
							fifo_WREADY_col[ 8]);  
	assign DW_WREADY_c4 = (	fifo_WREADY_col[ 9] && 
							fifo_WREADY_col[10] &&
							fifo_WREADY_col[11]);  
	assign DW_WREADY_c5 = (	fifo_WREADY_col[12] && 
							fifo_WREADY_col[13] &&
							fifo_WREADY_col[14]); 
							 
	assign DW_handshake = handshake_c1 | handshake_c2 | handshake_c3 | handshake_c4 | handshake_c5;
	//===========pointwise data prepared===========//
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			PW_data_buffer <= 32'd0;
		end else if(cur_state == IDLE) begin
			PW_data_buffer <= 32'd0;
		end else if(cur_state == PW_PREPARE) begin
			PW_data_buffer <= IM_DO;
		end else begin
			PW_data_buffer <= PW_data_buffer;
		end
	end

	
	//===============depthwise counter================//
	always_ff @(posedge clk or posedge rst) begin
		if(rst)begin
			channel_counter <= 3'd0;
		end
		else begin
			case(cur_state)
				IDLE : begin
					channel_counter    <= 3'd0;
					channel_counter_ff <= 3'd0;
					height_counter     <= 2'd0;
					height_counter_ff  <= 2'd0;
					stride_counter     <= 9'd0;
					stride_counter_ff  <= 9'd0;
				end
				DW_LOAD : begin
					//inner loop (channel)
					if(channel_counter == 3'd4) begin 
						channel_counter    <= 3'd0;
						channel_counter_ff <= channel_counter;
					end else begin
						channel_counter    <= channel_counter + 3'd1;
						channel_counter_ff <= channel_counter;
					end
					
					//outer loop (height)
					if(channel_counter == 3'd4 && height_counter == 3'd2) begin 
						height_counter    <= 2'd0;
						height_counter_ff <= height_counter;
					end else if(channel_counter == 3'd4) begin
						height_counter    <= height_counter + 3'd1;
						height_counter_ff <= height_counter;
					end else begin
						height_counter    <= height_counter;
						height_counter_ff <= height_counter;
					end
					
					if(stride_counter == `DW_STRIDE_NUM) begin
						stride_counter     <= stride_counter;
						stride_counter_ff  <= stride_counter;
					end
					else if (channel_counter == 3'd4 && height_counter == 3'd2) begin // transport next convolutional block
						stride_counter     <= stride_counter + `DW_STRIDE;
						stride_counter_ff  <= stride_counter;
					end
					else begin
						stride_counter     <= stride_counter;
						stride_counter_ff  <= stride_counter;
					end
				end
				default : begin end
			endcase
		end
	end
	
	//accum the address of depthwise to load next 5 channel
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			DW_jump_next_counter <= 12'd0;
		end else begin
			if( (cur_state          == DW_STORE       ) &&
				(channel_counter_ff == 3'd4           ) &&
				(height_counter_ff  == 3'd2           ) && 
			    (stride_counter_ff  == `DW_STRIDE_NUM)) begin
				DW_jump_next_counter <= DW_jump_next_counter + 12'd1500;
			end else begin
				DW_jump_next_counter <= DW_jump_next_counter; 
			end
		end
	end
	//=============================depthwise address=========================//
	assign DW_addr_bias_temp = (cur_state == DW_LOAD) ? /* {11'd0, channel_counter} + */
														{11'd0,  height_counter		 } +
														{ 5'd0,  stride_counter		 } +
														{ 2'd0,  DW_jump_next_counter} : 14'd0;
	always_comb begin
		if(cur_state == DW_LOAD) begin
			case( channel_counter )
				3'd0: begin 
					DW_addr_bias = DW_addr_bias_temp;
				end
				3'd1: begin 
					DW_addr_bias = DW_addr_bias_temp + 14'd300;
				end
				3'd2: begin 
					DW_addr_bias = DW_addr_bias_temp + 14'd600;
				end
				3'd3: begin 
					DW_addr_bias = DW_addr_bias_temp + 14'd900;
				end
				3'd4: begin 
					DW_addr_bias = DW_addr_bias_temp + 14'd1200;
				end
			endcase 	
		end
		else begin
			DW_addr_bias = 14'd0;
		end
	end
	
	//================depthwise data prepared======================//
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			DW_data_buffer <= 32'd0;
		end else begin
			if(cur_state == IDLE) begin
				DW_data_buffer <= 32'd0;
			end else if(cur_state == DW_PREPARE) begin
				DW_data_buffer <= IM_DO;
			end else begin
				DW_data_buffer <= DW_data_buffer; 
			end
		end
	end
	
	
	//================depthwise handshake signal and data sorting=================//
	
	always_comb begin
		if(cur_state == PW_STORE) begin
			if(PW_C_counter_ff == 6'd0) begin         //write to 3210 fifo
				if(PW_WREADY_3210) begin
					for (int i = 0; i < 4; i = i + 1) begin
						fifo_WVALID_col[i] = 1'd1;
					end
					handshake_3210         = 1'd1;
					handshake_7654         = 1'd0;
					
					in_col[0] = PW_data_buffer[ 7: 0];
					in_col[1] = PW_data_buffer[15: 8];
					in_col[2] = PW_data_buffer[23:16];
					in_col[3] = PW_data_buffer[31:24];
					
					for (int i = 4; i < 16; i = i + 1) begin
						fifo_WVALID_col[i] = 1'd0;
					end
					for (int i = 4; i < 16; i = i + 1) begin
						in_col[i] = 8'd0;
					end
				end
				else begin
					handshake_3210         = 1'd0;
					handshake_7654         = 1'd0;
					for (int i = 0; i < 16; i = i + 1) begin
						fifo_WVALID_col[i] = 1'd0; 
						in_col[i]          = 8'd0;
					end
				end
			end 
			else if(PW_C_counter_ff == 6'd1) begin //write to 7654 fifo
				if(PW_WREADY_7654) begin
					for (int i = 4; i < 8; i = i + 1) begin
						fifo_WVALID_col[i] = 1'd1;
					end
					handshake_3210         = 1'd0;
					handshake_7654         = 1'd1;
					
					in_col[4] = PW_data_buffer[ 7: 0];
					in_col[5] = PW_data_buffer[15: 8];
					in_col[6] = PW_data_buffer[23:16];
					in_col[7] = PW_data_buffer[31:24];
					
					for (int i = 0; i < 4; i = i + 1) begin
						fifo_WVALID_col[i] = 1'd0;
					end
					for (int i = 8; i < 16; i = i + 1) begin
						fifo_WVALID_col[i] = 1'd0;
					end
					for (int i = 8; i < 16; i = i + 1) begin
						in_col[i] = 8'd0;
					end
					for (int i = 0; i < 4; i = i + 1) begin
						in_col[i] = 8'd0;
					end
				end
				else begin
					handshake_3210         = 1'd0;
					handshake_7654         = 1'd0;
					for (int i = 0; i < 16; i = i + 1) begin
						fifo_WVALID_col[i] = 1'd0; 
						in_col[i]          = 8'd0;
					end
				end
			end 
			else begin end
		end
		//----------------depthwise------------------// 								 
	
		else if(cur_state == DW_STORE) begin
			case(channel_counter_ff)
				3'd0: begin
					if(DW_WREADY_c1) begin
						handshake_c1 = 1'd1;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd0;
						for (int i = 3; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0;
						end
						fifo_WVALID_col[0] = 1'd1;
						fifo_WVALID_col[1] = 1'd1;
						fifo_WVALID_col[2] = 1'd1;
						in_col[0]          = DW_data_buffer[ 7: 0];
						in_col[1]          = DW_data_buffer[15: 8]; 
						in_col[2]          = DW_data_buffer[23:16];
					end
					else begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd0;
						for (int i = 0; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0; 
							in_col[i]          = 8'd0;
						end
					end
				end            
				3'd1: begin  
					if(DW_WREADY_c2) begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd1;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd0;
						for (int i = 0; i < 3; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0;
						end	
						for (int i = 6; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0;
						end							
						fifo_WVALID_col[3] = 1'd1;
						fifo_WVALID_col[4] = 1'd1;
						fifo_WVALID_col[5] = 1'd1;
						in_col[3]          = DW_data_buffer[ 7: 0];
						in_col[4]          = DW_data_buffer[15: 8]; 
						in_col[5]          = DW_data_buffer[23:16];
					end
					else begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd0;
						for (int i = 0; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0; 
							in_col[i]          = 8'd0;
						end
					end
				end            
				3'd2: begin  
					if(DW_WREADY_c3) begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd1;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd0;
						for (int i = 0; i < 6; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0;
						end	
						for (int i = 9; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0;
						end	
						fifo_WVALID_col[6] = 1'd1;
						fifo_WVALID_col[7] = 1'd1;
						fifo_WVALID_col[8] = 1'd1;				
						in_col[6]          = DW_data_buffer[ 7: 0];
						in_col[7]          = DW_data_buffer[15: 8]; 
						in_col[8]          = DW_data_buffer[23:16];
					end
					else begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd0;
						for (int i = 0; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0; 
							in_col[i]          = 8'd0;
						end
					end
				end
				3'd3: begin
					if(DW_WREADY_c4) begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd1;
						handshake_c5 = 1'd0;
						for (int i = 0; i < 9; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0;
						end	
						for (int i = 12; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0;
						end	
						fifo_WVALID_col[ 9] = 1'd1;
						fifo_WVALID_col[10] = 1'd1;
						fifo_WVALID_col[11] = 1'd1;
						in_col[ 9]          = DW_data_buffer[ 7: 0];
						in_col[10]          = DW_data_buffer[15: 8]; 
						in_col[11]          = DW_data_buffer[23:16];
					end
					else begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd0;
						for (int i = 0; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0; 
							in_col[i]          = 8'd0;
						end
					end
				end
				3'd4: begin
					if(DW_WREADY_c5) begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd1;
						for (int i = 0; i < 12; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0;
						end
						fifo_WVALID_col[12] = 1'd1;
						fifo_WVALID_col[13] = 1'd1;
						fifo_WVALID_col[14] = 1'd1;
						in_col[12]          = DW_data_buffer[ 7: 0];
						in_col[13]          = DW_data_buffer[15: 8]; 
						in_col[14]          = DW_data_buffer[23:16];
					end
					else begin
						handshake_c1 = 1'd0;
						handshake_c2 = 1'd0;
						handshake_c3 = 1'd0;
						handshake_c4 = 1'd0;
						handshake_c5 = 1'd0;
						for (int i = 0; i < 16; i = i + 1) begin
							fifo_WVALID_col[i] = 1'd0; 
							in_col[i]          = 8'd0;
						end
					end
				end
				default : begin end
			endcase
		end
		else begin
			handshake_c1 = 1'd0;
			handshake_c2 = 1'd0;
			handshake_c3 = 1'd0;
			handshake_c4 = 1'd0;
			handshake_c5 = 1'd0;
			handshake_3210         = 1'd0;
			handshake_7654         = 1'd0;
			for (int i = 0; i < 16; i = i + 1) begin
				fifo_WVALID_col[i] = 1'd0; 
				in_col[i]          = 8'd0;
			end
		end
	end
endmodule