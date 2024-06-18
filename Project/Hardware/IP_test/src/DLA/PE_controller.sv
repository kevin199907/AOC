module PE_controller(
    input                   clk,
    input                   rst,
    // configuration
    input                   DLA_start,
    input [55:0]            transfer_config,
    // ifmap
    input                   ifmap_ready,
    input                   ifmap_3_ready,
    output logic		    ifmap_valid,
    // filter
    input                   weight_ready,
    output logic            weight_valid,
    // ===================== psum ====================
    output logic            psum_valid[15:0],
    output logic [15:0]     psum_addr[15:0],
    // ==================== weight active ==============
    // DW
    output logic            filter_active[15:0][15:0],

	output logic [1:0]		mode,
	output logic   			store_is,
	input 					all_done_main
);
// ouptut signal
logic ifmap_valid_dw;
logic ifmap_valid_pw;
logic weight_valid_dw;
logic weight_valid_pw;
logic        filter_active_dw[15:0][15:0];
logic [15:0] filter_active_hori_pw;
logic [15:0] filter_active_vert_pw;
logic 		 filter_active_pw[15:0][15:0];
// DW
logic            psum_valid_dw[4:0];
logic			 psum_valid_dw_reg1[4:0];
logic [15:0]     psum_addr_dw[4:0];
logic [15:0] 	 psum_addr_dw_reg1[4:0];
// PW
logic            psum_valid_pw[15:0];
logic [15:0]     psum_addr_pw[15:0];
// configuration
logic [55:0] transfer_config_store;
logic set_info;
// informantion
logic [2:0] opcode;
logic [4:0] ifmap_w;
logic [4:0] ifmap_h;
logic [4:0] ifmap_c;
logic [3:0] filter_w; 
logic [3:0] filter_h; 
logic [4:0] filter_c; 
logic [4:0] filter_n;
logic [4:0] ofmap_w;
logic [4:0] ofmap_h;
logic [4:0] ofmap_c;
logic [4:0] ofmap_n;
logic [9:0] ofmap_size;
// ================================ wire and registers ================================
// Universal
	logic run_done_main;
	logic store_done_main;
   //  logic all_done_main;
// Convolution
// Depthwise
	logic ifmap_hsk_dw;
    logic dw_is;
	// counter
	logic [4:0] ifmap_hsk_cnt_dw;
	logic [11:0] ofmap_cnt_dw;
	logic [4:0] ofmap_c_cnt_dw;
	//done signal
	logic ofmap_done_dw;
	logic ofmap_c_done_dw;
	logic run_done_dw;
// Pointwise
	logic [4:0]  remain_filter_c_pw;
	logic [4:0]  remain_filter_n_pw;
	logic [4:0]  filter_n_pw; 			// filter_n or 16
	logic [9:0]  ifmap_size_pw_wire;	// h * w
	logic [9:0]  ifmap_size_pw; 	   	// h * w
	logic [9:0]  remain_ifmap_size_pw1; // h * w 			  - 1 - 1 - 1 ...... 
	logic [9:0]  remain_ifmap_size_pw2; // h * w + filter_n_pw - 1 - 1 - 1 ...... 
	logic		 done_pw_ifmap1;     	// if done proceed to next channel of this group filter    (ifmap_w * ifmap_h)
	logic		 done_pw_ifmap2;     	// if done proceed to next channel of this group filter    (ifmap_w * ifmap_h) + (number of filter)
	logic		 done_pw_channel;    	// if done proceed to next group of filters			  	   (filter_c)
	logic		 done_pw_fnum;			//													       (filter_n)
	logic		 done_all_pw;
	logic [15:0] psum_ready_pre;
// =================== state ===================
    // ========== universal ========
    enum logic [3:0]{
    		IDLE_MAIN,
    		BUILD_MAIN,
    		RUN_MAIN,
    		STORE_MAIN
    } cs_main, ns_main;
    // ========== for Depthwise ==========
	enum logic[3:0]{
		IDLE_DW,
		LOAD_DW,
		CHECK_DW,
		RUN_DW
	} cs_dw, ns_dw;
	// ========== for Pointwise ==========
	enum logic[3:0]{
		IDLE_PW,
		FILTER_PW,
		IFMAP_PW
	} cs_pw, ns_pw;
// output signal
always_comb begin
	case(mode)
		2'd1: begin
			ifmap_valid = ifmap_valid_dw;
			weight_valid = weight_valid_dw;
		end
		2'd2: begin	
			ifmap_valid = ifmap_valid_pw;
			weight_valid = weight_valid_dw;
		end
		default: ifmap_valid = 0;
	endcase
end
assign store_is = (cs_main==STORE_MAIN);

always_comb begin
	for (int i=0;i<16;i++) begin
		for (int j=0;j<16;j++) begin
			filter_active_pw[i][j] = (filter_active_hori_pw[i] && filter_active_vert_pw[j]);
		end
	end
end
always_comb begin
	case(mode)
		2'd1: begin
			for (int i=0;i<16;i++) begin
				for (int j=0;j<16;j++) begin
					filter_active[i][j] = filter_active_dw[i][j];
				end
			end
		end
		2'd2: begin
			for (int i=0;i<16;i++) begin
				for (int j=0;j<16;j++) begin
					filter_active[i][j] = filter_active_pw[i][j];
				end
			end
		end
		default : begin
			for (int i=0;i<16;i++) begin
				for (int j=0;j<16;j++) begin
					filter_active[i][j] = 0;
				end
			end
		end
	endcase
end
// psum
always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		for (int i=0;i<5;i++) begin
			psum_valid_dw_reg1[i] <= 0;
			psum_addr_dw_reg1[i] <= 0;
		end
	end else begin
		for (int i=0;i<5;i++) begin
			psum_valid_dw_reg1[i] <= psum_valid_dw[i];
			psum_addr_dw_reg1[i] <= psum_addr_dw[i];
		end
	end
end
always_comb begin
	case(mode)
		2'd1: begin
			for (int i=0;i<5;i++) begin
				psum_valid[i] = psum_valid_dw_reg1[i];
				psum_addr[i] = psum_addr_dw_reg1[i];
			end
			for (int i=5;i<16;i++) begin
				psum_valid[i] = 0;
				psum_addr[i] = 0;
			end
		end
		2'd2: begin
			for (int i=0;i<16;i++) begin
				psum_valid[i] = psum_valid_pw[i];
				psum_addr[i] = psum_addr_pw[i];
			end
		end
		default: begin
			for (int i=0;i<16;i++) begin
				psum_valid[i] = 0;
				psum_addr[i] = 0;
			end
		end
	endcase
end
// ======= store transfer_config information =======
    always_ff @(posedge clk or posedge rst) begin
    	if (rst)           transfer_config_store <= 0;
    	else if (set_info) transfer_config_store <= transfer_config;
    	else               ;
    end
    always_ff @(posedge clk or posedge rst) begin
        if(rst)         			  set_info <= 0;
        else if (cs_main==BUILD_MAIN) set_info <= 1;
        else 						  set_info <= 0;
    end
// mode
always_comb begin
	case(opcode)
		3'b001: mode = 2'd1; // DW
		3'b010: mode = 2'd2; // PW
		default: mode = 2'd0;
	endcase
end
// =======informantion
assign opcode   = (set_info) ? transfer_config[2:0]   : transfer_config_store[2:0];   // 3
assign ifmap_w  = (set_info) ? transfer_config[7:3]   : transfer_config_store[7:3];   // 5
assign ifmap_h  = (set_info) ? transfer_config[12:8]  : transfer_config_store[12:8];  // 5
assign ifmap_c  = (set_info) ? transfer_config[17:13] : transfer_config_store[17:13]; // 5
assign filter_w = (set_info) ? transfer_config[21:18] : transfer_config_store[21:18]; // 4
assign filter_h = (set_info) ? transfer_config[25:22] : transfer_config_store[25:22]; // 4
assign filter_c = (set_info) ? transfer_config[30:26] : transfer_config_store[30:26]; // 5
assign filter_n = (set_info) ? transfer_config[35:31] : transfer_config_store[35:31]; // 5
assign ofmap_w  = (set_info) ? transfer_config[40:36] : transfer_config_store[40:36]; // 5
assign ofmap_h  = (set_info) ? transfer_config[45:41] : transfer_config_store[45:41]; // 5
assign ofmap_c  = (set_info) ? transfer_config[50:46] : transfer_config_store[50:46]; // 5
assign ofmap_n  = (set_info) ? transfer_config[55:51] : transfer_config_store[55:51]; // 5
assign ofmap_size = ofmap_w * ofmap_h; // 10
//=================== FSM ===============
always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		cs_main <= IDLE_MAIN;
		//cur_state_cv <= IDLE_CV;
		cs_dw <= IDLE_DW;
		cs_pw <= IDLE_PW;
	end	else begin
		cs_main <= ns_main;
		//cur_state_cv <= next_state_cv;
		cs_dw <= ns_dw;
		cs_pw <= ns_pw;
	end
end
always_comb begin
    case (cs_main)
        IDLE_MAIN : begin
			ns_main = (DLA_start===1'b1)? BUILD_MAIN : IDLE_MAIN;
			ns_pw = cs_pw;
			ns_dw = cs_dw;
		end
        BUILD_MAIN: begin
			ns_main = RUN_MAIN;
			ns_pw = cs_pw;
			ns_dw = cs_dw;
		end
        RUN_MAIN: begin
			ns_main = ((run_done_dw || done_all_pw)===1'b1)? STORE_MAIN : RUN_MAIN;
            case(opcode)
                3'b001: begin // DW
                    case(cs_dw)
                        IDLE_DW:    ns_dw = (set_info===1'b1)? LOAD_DW : IDLE_DW;
                        CHECK_DW:   ns_dw = (run_done_dw===1'b1)? IDLE_DW : LOAD_DW;
                        LOAD_DW:    ns_dw = ((ifmap_3_ready&&weight_ready)===1'b1)? RUN_DW : LOAD_DW;
                        RUN_DW:     ns_dw = (run_done_dw===1'b1)? IDLE_DW : (ofmap_done_dw===1'b1)? CHECK_DW : RUN_DW;
                        default :   ns_dw = IDLE_DW;
                    endcase
                end
                3'b010: begin
                    case(cs_pw)
                        IDLE_PW:   	ns_pw = (set_info===1'b1)? FILTER_PW : IDLE_PW;
                        FILTER_PW:	ns_pw = (weight_ready===1'b1)? IFMAP_PW : FILTER_PW;
						IFMAP_PW:	ns_pw = (done_all_pw===1'b1)? IDLE_PW : 
							((done_pw_ifmap2 && !done_pw_fnum)===1'b1) ? FILTER_PW : IFMAP_PW ; 
                        default:   	ns_pw = IDLE_PW;
                    endcase
                end
            endcase
        end
        STORE_MAIN: ns_main = (all_done_main===1'b1)? IDLE_MAIN : (store_done_main===1'b1)? BUILD_MAIN : STORE_MAIN;
        default: ns_main = IDLE_MAIN;
    endcase
end
// ========================================================== DW ==============================================
// control signal
    assign ifmap_hsk_dw = ((cs_dw==RUN_DW) && ifmap_ready && ifmap_valid_dw)? 1'b1 : 1'b0;
    assign dw_is = (cs_main==RUN_MAIN)&&(opcode==3'b001);
	assign weight_valid_dw = ofmap_c_done_dw;
    always_comb begin // ifmap_valid_dw
        if (dw_is) begin
            if (cs_dw==RUN_DW) ifmap_valid_dw = 1;
            else ifmap_valid_dw = 0;
        end else ifmap_valid_dw = 0;
    end
	// filter active
	always_comb begin
		if ((dw_is)&&(cs_dw==RUN_DW)) begin
			if (ofmap_c>=(ofmap_c_cnt_dw+5)) begin
				for(int i=0;i<3;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 1;
				for(int i=0;i<3;i++) for(int j=3;j<16;j++) filter_active_dw[i][j] = 0;

				for(int i=3;i<6;i++) for(int j=3;j<6;j++) filter_active_dw[i][j] = 1;
				for(int i=3;i<6;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 0;
				for(int i=3;i<6;i++) for(int j=6;j<16;j++) filter_active_dw[i][j] = 0;

				for(int i=6;i<9;i++) for(int j=6;j<9;j++) filter_active_dw[i][j] = 1;
				for(int i=6;i<9;i++) for(int j=0;j<6;j++) filter_active_dw[i][j] = 0;
				for(int i=6;i<9;i++) for(int j=9;j<16;j++) filter_active_dw[i][j] = 0;

				for(int i=9;i<12;i++) for(int j=9;j<12;j++) filter_active_dw[i][j] = 1;
				for(int i=9;i<12;i++) for(int j=0;j<9;j++) filter_active_dw[i][j] = 0;
				for(int i=9;i<12;i++) for(int j=12;j<16;j++) filter_active_dw[i][j] = 0;

				for(int i=12;i<15;i++) for(int j=12;j<15;j++) filter_active_dw[i][j] = 1;
				for(int i=12;i<15;i++) for(int j=0;j<12;j++) filter_active_dw[i][j] = 0;
				for(int i=12;i<15;i++) for(int j=15;j<16;j++) filter_active_dw[i][j] = 0;

				for(int i=15;i<16;i++) for(int j=0;j<16;j++) filter_active_dw[i][j] = 0;
			end	else begin
				case((ofmap_c-ofmap_c_cnt_dw))
					1: begin
						for(int i=0;i<3;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 1;
						for(int i=0;i<3;i++) for(int j=3;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=3;i<16;i++) for(int j=0;j<16;j++) filter_active_dw[i][j] = 0;
					end
					2: begin
						for(int i=0;i<3;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 1;
						for(int i=0;i<3;i++) for(int j=3;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=3;i<6;i++) for(int j=3;j<6;j++) filter_active_dw[i][j] = 1;
						for(int i=3;i<6;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 0;
						for(int i=3;i<6;i++) for(int j=6;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=6;i<16;i++) for(int j=0;j<16;j++) filter_active_dw[i][j] = 0;
					end
					3: begin
						for(int i=0;i<3;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 1;
						for(int i=0;i<3;i++) for(int j=3;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=3;i<6;i++) for(int j=3;j<6;j++) filter_active_dw[i][j] = 1;
						for(int i=3;i<6;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 0;
						for(int i=3;i<6;i++) for(int j=6;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=6;i<9;i++) for(int j=6;j<9;j++) filter_active_dw[i][j] = 1;
						for(int i=6;i<9;i++) for(int j=0;j<6;j++) filter_active_dw[i][j] = 0;
						for(int i=6;i<9;i++) for(int j=9;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=9;i<16;i++) for(int j=0;j<16;j++) filter_active_dw[i][j] = 0;
					end
					4: begin
						for(int i=0;i<3;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 1;
						for(int i=0;i<3;i++) for(int j=3;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=3;i<6;i++) for(int j=3;j<6;j++) filter_active_dw[i][j] = 1;
						for(int i=3;i<6;i++) for(int j=0;j<3;j++) filter_active_dw[i][j] = 0;
						for(int i=3;i<6;i++) for(int j=6;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=6;i<9;i++) for(int j=6;j<9;j++) filter_active_dw[i][j] = 1;
						for(int i=6;i<9;i++) for(int j=0;j<6;j++) filter_active_dw[i][j] = 0;
						for(int i=6;i<9;i++) for(int j=9;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=9;i<12;i++) for(int j=9;j<12;j++) filter_active_dw[i][j] = 1;
						for(int i=9;i<12;i++) for(int j=0;j<9;j++) filter_active_dw[i][j] = 0;
						for(int i=9;i<12;i++) for(int j=12;j<16;j++) filter_active_dw[i][j] = 0;

						for(int i=12;i<16;i++) for(int j=0;j<16;j++) filter_active_dw[i][j] = 0;
					end
					default: begin
						for(int i=0;i<16;i++) for(int j=0;j<16;j++) filter_active_dw[i][j] = 0;
					end
				endcase
			end
		end else for(int i=0;i<16;i++) for(int j=0;j<16;j++) filter_active_dw[i][j] = 0;
	end
    // done signal
    always_comb begin // ofmap_done_dw
		if ((cs_dw==RUN_DW) && (ifmap_hsk_cnt_dw==2) && ifmap_hsk_dw) ofmap_done_dw = 1'b1;
		else ofmap_done_dw = 0;
	end
	always_comb begin // ofmap_c_done_dw
		if ((cs_dw==RUN_DW) && (ofmap_cnt_dw==(ofmap_size-1)) && (ofmap_done_dw)) ofmap_c_done_dw = 1'b1;
		else ofmap_c_done_dw = 0;
	end
	always_comb begin
		if ((cs_dw==RUN_DW) && ((ofmap_c_cnt_dw+5)>=ofmap_c) && ofmap_c_done_dw) run_done_dw = 1'b1;
		else run_done_dw = 0;
	end
	// counter
	always_ff @(posedge clk or posedge rst) begin
		if (rst) ifmap_hsk_cnt_dw <= 0;
		else if (cs_dw==RUN_DW) begin
			if (ofmap_done_dw) ifmap_hsk_cnt_dw <= 0;
			else if(ifmap_hsk_dw) ifmap_hsk_cnt_dw <= ifmap_hsk_cnt_dw+1;
		end else ifmap_hsk_cnt_dw <= 0;
	end
	always_ff @(posedge clk or posedge rst) begin
		if (rst) ofmap_cnt_dw <= 0;
		else begin
			if (dw_is) begin
				if (ofmap_c_done_dw) ofmap_cnt_dw <= 0;
				else if (ofmap_done_dw) ofmap_cnt_dw <= ofmap_cnt_dw +1;
				else ;
			end else ofmap_cnt_dw <= 0;
		end
	end
	always_ff @(posedge clk or posedge rst) begin
		if (rst) ofmap_c_cnt_dw <= 0;
		else begin
			if (dw_is) begin
				if (run_done_dw) ofmap_c_cnt_dw <= 0;
				else if (ofmap_c_done_dw) ofmap_c_cnt_dw <= ofmap_c_cnt_dw+5;
				else ;
			end else ofmap_c_cnt_dw <= 0;
		end
	end
	// psum DW
	always_ff @(posedge clk or posedge rst) begin
		if (rst) for(int i=0;i<5;i++) psum_addr_dw[i] <= 0;
		else begin
			if (dw_is) begin
				if (cs_dw==IDLE_DW) begin
					if (set_info) for(int i=0;i<5;i++) psum_addr_dw[i] <= i*ofmap_size;
                    else ;
				end else if (cs_dw==RUN_DW) begin
					if (ofmap_c_done_dw)    for(int i=0;i<5;i++) psum_addr_dw[i] <= (ofmap_c_cnt_dw+5+i)*ofmap_size;
					else if (ofmap_done_dw) for(int i=0;i<5;i++) psum_addr_dw[i] <= psum_addr_dw[i]+1;
					else ;
				end else ;
			end else    for(int i=0;i<5;i++) psum_addr_dw[i] <= 0;
		end
	end
    always_comb begin
		if (dw_is&&ofmap_done_dw) begin
			if (ofmap_c>=(ofmap_c_cnt_dw+5)) for(int i=0;i<5;i++) psum_valid_dw[i] = 1;
			else begin
				case((ofmap_c-ofmap_c_cnt_dw))
					1 : begin
						psum_valid_dw[0] = 1;
						psum_valid_dw[1] = 0;
						psum_valid_dw[2] = 0;
						psum_valid_dw[3] = 0;
						psum_valid_dw[4] = 0;
					end
					2 : begin
						psum_valid_dw[0] = 1;
						psum_valid_dw[1] = 1;
						psum_valid_dw[2] = 0;
						psum_valid_dw[3] = 0;
						psum_valid_dw[4] = 0;
					end
					3 : begin
						psum_valid_dw[0] = 1;
						psum_valid_dw[1] = 1;
						psum_valid_dw[2] = 1;
						psum_valid_dw[3] = 0;
						psum_valid_dw[4] = 0;
					end
					4 : begin
						psum_valid_dw[0] = 1;
						psum_valid_dw[1] = 1;
						psum_valid_dw[2] = 1;
						psum_valid_dw[3] = 1;
						psum_valid_dw[4] = 0;
					end
					default : begin
						psum_valid_dw[0] = 0;
						psum_valid_dw[1] = 0;
						psum_valid_dw[2] = 0;
						psum_valid_dw[3] = 0;
						psum_valid_dw[4] = 0;
					end
				endcase
			end
		end else for(int i=0;i<5;i++) psum_valid_dw[i] = 0;
	end
// ===================== PW ===================
always_comb begin
	if ((cs_main==RUN_MAIN)&&(opcode==3'b010)) begin
		case (cs_pw) 
			IDLE_PW : begin
				ifmap_valid_pw   	= 1'd0;
				psum_ready_pre[0] 	= 1'd0;
			end
			FILTER_PW : begin
				ifmap_valid_pw   	= 1'd0;
				psum_ready_pre[0] 	= 1'd0;
			end
			IFMAP_PW : begin
				ifmap_valid_pw   	= (!done_pw_ifmap1) ? 1'd1 : 1'd0;
				psum_ready_pre[0] 	= (ifmap_valid_pw && ifmap_ready) ? 1'd1 : 1'd0;						
			end
			default : begin
				ifmap_valid_pw   	= 1'd0;
				psum_ready_pre[0] 	= 1'd0;
			end
		endcase
		if (remain_filter_c_pw < 5'd16) begin
			filter_active_vert_pw = (16'b1111_1111_1111_1111 >> (5'd16 - remain_filter_c_pw));
		end else begin
			filter_active_vert_pw = 16'b1111_1111_1111_1111;
		end
		//------
		if (remain_filter_n_pw < 5'd16) begin
			filter_active_hori_pw = (16'b1111_1111_1111_1111 >> (5'd16 - remain_filter_n_pw));
		end else begin
			filter_active_hori_pw = 16'b1111_1111_1111_1111;
		end
	end
end

assign ifmap_size_pw_wire  = ifmap_w * ifmap_h;
assign filter_n_pw         = (filter_n <= 5'd16)			  ? filter_n : 5'd16;
assign done_pw_ifmap1      = (remain_ifmap_size_pw1 == 10'd0) ? 1'd1 : 1'd0;
assign done_pw_ifmap2      = (remain_ifmap_size_pw2 == 10'd0) ? 1'd1 : 1'd0;
assign done_pw_channel     = (remain_filter_c_pw <= 5'd16)    ? 1'd1 : 1'd0;
assign done_pw_fnum        = (remain_filter_n_pw <= 5'd16)    ? 1'd1 : 1'd0;
assign weight_valid_pw 	   = (cs_pw==IFMAP_PW && ((ns_pw==FILTER_PW)||(ns_pw==IDLE_PW)))? 1'd1 : 1'd0;

always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		ifmap_size_pw         <= 10'd0;
		remain_ifmap_size_pw1 <= 10'd0;
		remain_ifmap_size_pw2 <= 10'd0;
		done_all_pw			  <= 1'd0;
		remain_filter_c_pw 	  <= 5'd0;
		remain_filter_n_pw 	  <= 5'd0;
	end else  if ((opcode==3'b010)&&(cs_main==RUN_MAIN)) begin
		if (set_info) begin
			ifmap_size_pw         <= ifmap_size_pw_wire;
			remain_ifmap_size_pw1 <= ifmap_size_pw_wire;
			remain_ifmap_size_pw2 <= ifmap_size_pw_wire + {5'd0, filter_n_pw};
			done_all_pw			  <= 1'd0;
			remain_filter_c_pw 	  <= filter_c;
			remain_filter_n_pw 	  <= filter_n;
			psum_valid_pw[0]	  <= 1'd0;
		end else if (!done_pw_ifmap1 && ifmap_valid_pw && ifmap_ready) begin
			ifmap_size_pw         <= ifmap_size_pw;
			remain_ifmap_size_pw1 <= remain_ifmap_size_pw1 - 10'd1;
			remain_ifmap_size_pw2 <= remain_ifmap_size_pw2 - 10'd1;
			done_all_pw			  <= 1'd0;
			remain_filter_c_pw 	  <= remain_filter_c_pw;
			remain_filter_n_pw 	  <= remain_filter_n_pw;
			psum_valid_pw[0]	  <= 1'd1;
		end else if (done_pw_ifmap1 && !done_pw_ifmap2) begin
			ifmap_size_pw         <= ifmap_size_pw;
			remain_ifmap_size_pw1 <= remain_ifmap_size_pw1;
			remain_ifmap_size_pw2 <= remain_ifmap_size_pw2 - 10'd1;
			done_all_pw			  <= 1'd0;
			remain_filter_c_pw 	  <= remain_filter_c_pw;
			remain_filter_n_pw 	  <= remain_filter_n_pw;
			psum_valid_pw[0]	  <= 1'd0;
		end else if (done_pw_ifmap2 && !done_pw_channel) begin
			ifmap_size_pw         <= ifmap_size_pw;
			remain_ifmap_size_pw1 <= ifmap_size_pw;
			remain_ifmap_size_pw2 <= (done_pw_fnum) ? 
										(ifmap_size_pw + {5'd0, remain_filter_n_pw}) : 
											(ifmap_size_pw + 10'd16);
			done_all_pw			  <= 1'd0;
			remain_filter_c_pw 	  <= remain_filter_c_pw - 5'd16;
			remain_filter_n_pw 	  <= remain_filter_n_pw;
			psum_valid_pw[0]	  <= 1'd0;
		end else if (done_pw_ifmap2 && done_pw_channel && !done_pw_fnum) begin
			ifmap_size_pw         <= ifmap_size_pw;
			remain_ifmap_size_pw1 <= ifmap_size_pw;
			remain_ifmap_size_pw2 <= ((remain_filter_n_pw - 5'd16) <= 5'd16) ? 
										(ifmap_size_pw + {5'd0, (remain_filter_n_pw - 5'd16)}) : 
											(ifmap_size_pw + 10'd16);
			done_all_pw			  <= 1'd0;
			remain_filter_c_pw 	  <= filter_c;
			remain_filter_n_pw 	  <= remain_filter_n_pw - 5'd16;
			psum_valid_pw[0]	  <= 1'd0;
		end else if (done_pw_ifmap2 && done_pw_channel && done_pw_fnum) begin
			ifmap_size_pw         <= 10'd0;
			remain_ifmap_size_pw1 <= 10'd0;
			remain_ifmap_size_pw2 <= 10'd0;
			done_all_pw			  <= 1'd1;
			remain_filter_c_pw 	  <= 5'd0;
			remain_filter_n_pw 	  <= 5'd0;
			psum_valid_pw[0]	  <= 1'd0;
		end else begin
			ifmap_size_pw         <= ifmap_size_pw;
			remain_ifmap_size_pw1 <= remain_ifmap_size_pw1;
			remain_ifmap_size_pw2 <= remain_ifmap_size_pw2;
			done_all_pw			  <= done_all_pw;
			remain_filter_c_pw 	  <= remain_filter_c_pw;
			remain_filter_n_pw 	  <= remain_filter_n_pw;
			psum_valid_pw[0]	  <= 1'd0;
		end
	end else begin
		ifmap_size_pw         <= 10'd0;
		remain_ifmap_size_pw1 <= 10'd0;
		remain_ifmap_size_pw2 <= 10'd0;
		done_all_pw			  <= 1'd0;
		remain_filter_c_pw 	  <= 5'd0;
		remain_filter_n_pw 	  <= 5'd0;
		psum_valid_pw[0]	  <= 1'd0;
	end
end
// psum_valid[1]~[15]
always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		psum_valid_pw[1]  <= 1'd0;
		psum_valid_pw[2]  <= 1'd0;
		psum_valid_pw[3]  <= 1'd0;
		psum_valid_pw[4]  <= 1'd0;
		psum_valid_pw[5]  <= 1'd0;
		psum_valid_pw[6]  <= 1'd0;
		psum_valid_pw[7]  <= 1'd0;
		psum_valid_pw[8]  <= 1'd0;
		psum_valid_pw[9]  <= 1'd0;
		psum_valid_pw[10] <= 1'd0;
		psum_valid_pw[11] <= 1'd0;
		psum_valid_pw[12] <= 1'd0;
		psum_valid_pw[13] <= 1'd0;
		psum_valid_pw[14] <= 1'd0;
		psum_valid_pw[15] <= 1'd0;
	end else if ((cs_main==RUN_MAIN)&&(opcode == 3'b010)) begin  
		psum_valid_pw[1]  <= psum_valid_pw[0];
		psum_valid_pw[2]  <= psum_valid_pw[1];
		psum_valid_pw[3]  <= psum_valid_pw[2];
		psum_valid_pw[4]  <= psum_valid_pw[3];
		psum_valid_pw[5]  <= psum_valid_pw[4];
		psum_valid_pw[6]  <= psum_valid_pw[5];
		psum_valid_pw[7]  <= psum_valid_pw[6];
		psum_valid_pw[8]  <= psum_valid_pw[7];
		psum_valid_pw[9]  <= psum_valid_pw[8];
		psum_valid_pw[10] <= psum_valid_pw[9];
		psum_valid_pw[11] <= psum_valid_pw[10];
		psum_valid_pw[12] <= psum_valid_pw[11];
		psum_valid_pw[13] <= psum_valid_pw[12];
		psum_valid_pw[14] <= psum_valid_pw[13];
		psum_valid_pw[15] <= psum_valid_pw[14];
	end else begin
		psum_valid_pw[1]  <= 1'd0;
		psum_valid_pw[2]  <= 1'd0;
		psum_valid_pw[3]  <= 1'd0;
		psum_valid_pw[4]  <= 1'd0;
		psum_valid_pw[5]  <= 1'd0;
		psum_valid_pw[6]  <= 1'd0;
		psum_valid_pw[7]  <= 1'd0;
		psum_valid_pw[8]  <= 1'd0;
		psum_valid_pw[9]  <= 1'd0;
		psum_valid_pw[10] <= 1'd0;
		psum_valid_pw[11] <= 1'd0;
		psum_valid_pw[12] <= 1'd0;
		psum_valid_pw[13] <= 1'd0;
		psum_valid_pw[14] <= 1'd0;
		psum_valid_pw[15] <= 1'd0;
	end
end
// psum address
always @(posedge clk) begin
	if (rst) for(int i=0; i<16; i=i+1) psum_addr_pw[i] <= 0;
	else if ((cs_main==RUN_MAIN) && (opcode==3'b010)) begin
		for (int i=0; i<16; i=i+1) begin
			if (set_info) psum_addr_pw[i] <= {6'd0, ifmap_size_pw_wire} * i;
			else if (psum_valid_pw[i]) psum_addr_pw[i] <= psum_addr_pw[i] + 1;
			else psum_addr_pw[i] <= psum_addr_pw[i];
		end
	end else for(int i=0; i<16; i=i+1) psum_addr_pw[i] <= 0;
end


/*// monitor
logic [15:0] monitor;
always_ff @(posedge clk or posedge rst) begin
	if (rst) monitor <= 0;
	else if ((cs_dw==LOAD_DW)&&(ns_dw==RUN_DW)) monitor <= monitor+1;
	else ;
end*/
endmodule