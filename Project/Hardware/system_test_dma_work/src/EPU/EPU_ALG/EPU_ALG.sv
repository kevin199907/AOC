module EPU_ALG
#(
    block_num=64
)
(
    input                clk,
    input                rst,
    input                start,
    input [127:0]        data_read,

    output logic [11:0]  addr,
    output logic [31:0]  TO_SRAM_DATA,
    output logic [3:0]   WE,
    output logic [11:0]  sram_addr,
    output logic         last_to_cpu
);
//define
//control signal
logic [1:0]     next_mode;   //2'00:IDLE, 2'b01:Y, 2'b10:Cr, 2'b11:Cb
logic [3:0]     cs, ns;
//=================================addr============================================//
logic [11:0]    next_addr;
logic [11:0]    addr_block, next_addr_block;
//================================================================================//
//RGB to YCrCb
logic [7:0]     R[3:0];
logic [7:0]     G[3:0];
logic [7:0]     B[3:0];
logic [7:0]     data_ycrcb[3:0];
logic           finish_ycrcb;
//YCrCb mem
logic           finish_ycrcb_mem;
logic [7:0]     data_ycrcb_mem[7:0][7:0];
logic           full_ycrcb;
//DCT
logic [13:0]    dct_out[7:0][7:0];
logic           finish_dct;
//mul_matrix
logic [11:0]    quan_out[7:0][7:0];
logic           finish_quan;
//zigzag
logic [11:0]    zag_out[7:0][7:0];
//RLE
logic [15:0]    data_dc;
logic [15:0]    data_ac;
logic           dc_done;
logic           rle_last;
//DPCM
logic [11:0]    dpcm_in;
logic [11:0]    dpcm_out_y, dpcm_out_cr, dpcm_out_cb;
logic           dpcm_done_y, dpcm_done_cr, dpcm_done_cb;
logic           dpcm_last_y, dpcm_last_cr, dpcm_last_cb;
//
logic           EPU_end;
logic           FF_end;
logic           read;
//HFC
//*************************************************************
logic           rle_stall;
logic           out_empty;
logic [11:0]    data_hfc_ac;
logic [15:0]    data_hfc_dc;
logic           ac_done;
logic           DC_valid;
logic [1:0]     mode;
//*************************************************************
logic           we_FULL;
//block finish
logic           block_finish;
logic           block_finish_3;

logic           block_finish_reg;
logic [3:0]     next_block_finish_3, block_finish_3_reg;
logic [7:0]     next_finish_count, finish_count;
//addr hold
logic addr_hold;
//===================================controlsignal===============================================//
assign block_finish = rle_last;
//
always_ff @(posedge clk or posedge rst) begin
    if (rst) block_finish_reg <= 1'b0;
    else block_finish_reg <= block_finish;
end
//
assign next_finish_count = (block_finish_3)? (finish_count+8'd1) : finish_count;
always_ff @(posedge clk or posedge rst) begin
    if (rst) finish_count <= 8'b0;
    else if (block_finish_3) finish_count <= next_finish_count;
    else finish_count <= finish_count;
end
//
assign block_finish_3 = (next_block_finish_3==4'd3)? 1'b1 : 1'b0;
assign next_block_finish_3 = (block_finish)? (block_finish_3_reg+4'd1) : block_finish_3_reg;
always_ff @(posedge clk or posedge rst) begin
    if (rst) block_finish_3_reg <= 4'b0;
    else if (next_block_finish_3==4'd3) block_finish_3_reg <= 4'b0;
    else if (block_finish) block_finish_3_reg <= next_block_finish_3;
    else block_finish_3_reg <= block_finish_3_reg;
end
//===================================address===============================================//
//addr
always_ff @(posedge clk or posedge rst) begin
    if (rst) addr <= 12'b0;
    else if (cs==4'd0) addr <= 12'b0;
    else addr <= next_addr;
end
always_comb begin
    if (cs==4'd0) next_addr = 12'b0;
    else if (cs==4'd1) begin
        if (read==1'b1) begin
            if (block_finish) next_addr = next_addr_block;
            else if (addr==(next_addr_block+12'd15)) next_addr = next_addr_block;
            else if (addr_hold) next_addr = next_addr_block;//*************************************
            else next_addr = addr + 12'd1;
        end
        else begin
            if (block_finish) next_addr = next_addr_block;
            else next_addr = addr;
        end
    end
    else next_addr = addr;
end
//addr block
always_ff @(posedge clk or posedge rst) begin
    if (rst) addr_block <= 12'b0;
    else addr_block <= next_addr_block;
end
always_comb begin
    if (cs==4'd0) next_addr_block = 12'b0;
    else begin
        if (block_finish_3==1'b1) next_addr_block = addr_block+12'd16;
        else next_addr_block = addr_block;
    end
end
//addr hold//**************************************************************************
always_ff @(posedge clk or posedge rst) begin
    if (rst) addr_hold <= 1'b0;
    else if (full_ycrcb) addr_hold <= 1'b1;
    else if (block_finish) addr_hold <= 1'b0;
    else addr_hold <= addr_hold;
end
//====================================controller==========================================//
//state
always_ff @(posedge clk or posedge rst) begin
    if (rst) cs <= 4'b0;
    else cs <= ns;
end
//next state
always_comb begin
    case (cs)
        4'b0    : ns = (start)? 4'd1 : 4'd0;
        4'd1    : ns = (EPU_end) ? 4'd15 : 4'd1;
        4'd15   : ns = 4'd15;
        default : ns = 4'b0;
    endcase
end
//siganl
always_comb begin
    case (cs)
        4'd0 : begin
           read = 1'b0;
        end
        4'd1 : begin
           read = /*(block_finish)? 1'b0 : */1'b1;//*******************************************
        end
        4'd15 : begin
            read = 1'b0;
        end
        default : begin
            read = 1'b0;
        end
    endcase
end
//==================================================================================//
//mode
always_ff @(posedge clk or posedge rst) begin
    if (rst) mode <= 2'd1;
    else if (cs==4'b0) mode <= 2'd1;
    else mode <= next_mode;
end
// assign next_mode = (block_finish)? ((mode==2'b11)? 2'b01 : (mode+2'd1)) : mode;
always_comb begin
    if (block_finish) begin
        case (mode)
            2'd1 : next_mode = 2'd3;
            2'd3 : next_mode = 2'd2;
            2'd2 : next_mode = 2'd1;
            default : next_mode = 2'd0;
        endcase
    end
    else begin
        next_mode = mode;
    end
end
//***************************************************************************************************
//delay
logic read_1, read_2;
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        read_1      <= 1'b0;
        read_2      <= 1'b0;
    end
    else begin
        read_1 <= read;
        read_2 <= read_1;
    end
end
//***************************************************************************************************
//RGB dcoder
assign R[3] = (read_2)? data_read[23:16] : 8'b0;
assign G[3] = (read_2)? data_read[15:8 ] : 8'b0;
assign B[3] = (read_2)? data_read[7 :0 ] : 8'b0;
assign R[2] = (read_2)? data_read[55:48] : 8'b0;
assign G[2] = (read_2)? data_read[47:40] : 8'b0;
assign B[2] = (read_2)? data_read[39:32] : 8'b0;
assign R[1] = (read_2)? data_read[87:80] : 8'b0;
assign G[1] = (read_2)? data_read[79:72] : 8'b0;
assign B[1] = (read_2)? data_read[71:64] : 8'b0;
assign R[0] = (read_2)? data_read[119:112] : 8'b0;
assign G[0] = (read_2)? data_read[111:104] : 8'b0;
assign B[0] = (read_2)? data_read[103:96]  : 8'b0;
//toYCrCb
toYCrCb #(4) toycrcb0(
    .clk        (clk),
    .rst        (rst),
    .start      (read_2),
    .in_R       (R),
    .in_G       (G),
    .in_B       (B),
    .mode       (mode),
    .finish     (finish_ycrcb),
    .out        (data_ycrcb)
);
//YCrCb mem
//**********************************************
logic block_finish_reg_2, block_finish_reg_3;
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        block_finish_reg_2 <= 1'b0;
        block_finish_reg_3 <= 1'b0;
    end
    else begin 
        block_finish_reg_2 <= block_finish_reg;
        block_finish_reg_3 <= block_finish_reg_2;
    end
end
//**********************************************
ycrcb_mem ycrcb_mem0(
    .clk        (clk),
    .rst        (rst),
    .load       (finish_ycrcb),
    .finish     (block_finish_reg_3),//***************************************
    .data_ycrcb (data_ycrcb),
    .ycrcb_mem  (data_ycrcb_mem),
    .full       (full_ycrcb) 
);
//DCT
DCT dct0(
    .clk        (clk),
    .rst        (rst),
    .start      (full_ycrcb),
    .hold_end   (block_finish),
    .in         (data_ycrcb_mem),
    .out        (dct_out),
    .finish     (finish_dct)
);
//mul_matrix
mul_matrix #(14) mul_matrix0
(
    .clk        (clk),
    .rst        (rst),
    .start      (finish_dct),
    .in         (dct_out),
    .mode       (mode),
    .out        (quan_out),
    .finish     (finish_quan)
);
//zigzag
zigzag #(12) zigzag0
(
    .in         (quan_out),
    .out        (zag_out)
);
//RLE
RLE #(12) rle0
(
    .clk        (clk),
    .rst        (rst),
    .stall      (rle_stall),
    .start      (finish_quan),
    .rle_in     (zag_out),
    .data_dc    (data_dc),
    .data_ac    (data_ac),
    .dc_done    (dc_done),
    .done       (ac_done),
    .rle_last   (rle_last),
    .empty      (out_empty),
    .last       (ac_last)
);
//HFC
assign data_hfc_ac = { (data_ac[15:12]), (data_ac[7:0]) };
//DPCM
assign dpcm_in = data_dc[11:0];
DPCM_Y dpcmy
(
    .clk            (clk),
    .rst            (rst),
    .mode           (mode),
    .dc_data        (dpcm_in),
    .dc_done        (dc_done),
    .dpcm_out       (dpcm_out_y),
    .dpcm_done      (dpcm_done_y),
    .dpcm_last      (dpcm_last_y)
);
DPCM_Cr dpcmcr
(
    .clk            (clk),
    .rst            (rst),
    .mode           (mode),
    .dc_data        (dpcm_in),
    .dc_done        (dc_done),
    .dpcm_out       (dpcm_out_cr),
    .dpcm_done      (dpcm_done_cr),
    .dpcm_last      (dpcm_last_cr)
);
DPCM_Cb dpcmcb
(
    .clk            (clk),
    .rst            (rst),
    .mode           (mode),
    .dc_data        (dpcm_in),
    .dc_done        (dc_done),
    .dpcm_out       (dpcm_out_cb),
    .dpcm_done      (dpcm_done_cb),
    .dpcm_last      (dpcm_last_cb)
);
always_comb begin
    case (mode)
        2'b01 : begin
            DC_valid    = dpcm_done_y;
            data_hfc_dc = {4'b0, dpcm_out_y};
        end
        2'b10 : begin
            DC_valid    = dpcm_done_cr;
            data_hfc_dc = {4'b0, dpcm_out_cr};
        end
        2'b11 : begin
            DC_valid    = dpcm_done_cb;
            data_hfc_dc = {4'b0, dpcm_out_cb};
        end
        default : begin
            DC_valid    = 1'b0;
            data_hfc_dc = 16'b0;
        end
    endcase
end
//finish signal
assign EPU_end = ((finish_count==8'd63)&&(block_finish_3==1'b1))? 1'b1 : 1'b0;
assign FF_end = ((finish_count==8'd63)&&(ac_last==1'b1)&&(mode==2'd3))? 1'b1 : 1'b0;
//HFF
H_FF h_ff0 
(
    .clk                   (clk),
    .rst                   (rst),
    .last                  (FF_end),
    .valid                 (ac_done),
    .DC_valid              (DC_valid),
    .af_RLC_data_AC        (data_hfc_ac),
    .af_RLC_data_DC        (data_hfc_dc),
    .mode                  (mode),
    .TO_SRAM_DATA          (TO_SRAM_DATA),
    .WE                    (WE),
    .sram_addr             (sram_addr),
    .last_to_cpu           (last_to_cpu),
    .we_FULL               (rle_stall),
    .out_empty             (out_empty)
);
endmodule