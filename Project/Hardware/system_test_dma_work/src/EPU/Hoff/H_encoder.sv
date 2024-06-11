
module H_encoder (
    input clk,
    input rst,
    input valid,//ac
    input DC_valid,//dc
    input last,
    input logic [11:0]af_RLC_data_AC,
    input logic [15:0]af_RLC_data_DC,
    input deal_FF_done,
    input logic [1:0] mode,
    output logic [31:0]data_to_deal_FF,
    output logic to_FF_valid,
    output logic to_FF_last,
    output logic stall,
    output logic out_empty
    

);
///////////////////////

/////////////////////

logic [15:0]H_in_data;
logic stored_RLE_AC_valid;
logic stored_RLE_DC_valid;
logic AC_valid_delay;
logic DC_valid_delay;
logic [1:0]stored_mode;
logic stored_last;

// DC AC data process (MUX)
///////////////////////
logic [15:0] extend_af_RLC_data_AC;
assign extend_af_RLC_data_AC = {af_RLC_data_AC[11:8],4'b0,af_RLC_data_AC[7:0]};

logic [15:0] in_H_encoder_reg;
assign in_H_encoder_reg = DC_valid ? af_RLC_data_DC : extend_af_RLC_data_AC;

logic stall_delay;
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        stall_delay <= 1'b0;
    end
    else begin
        stall_delay <= stall;
    end
end
/////////////////////
always_ff @(posedge clk or posedge rst) begin : buffer_in
    if(rst) begin
        H_in_data <= 16'b0;
    end
    else if(stall_delay) begin
        H_in_data <= H_in_data;
    end
    else if(valid || DC_valid) begin
        H_in_data <= in_H_encoder_reg; 
    end
    else begin
        H_in_data <= H_in_data;
    end
end

always_ff @(posedge clk or posedge rst) begin : buffer_in_valid
    if(rst) begin
        stored_RLE_AC_valid <= 1'b0; 
        stored_RLE_DC_valid <= 1'b0;
        AC_valid_delay <= 1'b0; 
        DC_valid_delay <= 1'b0;
        stored_mode <= 2'b00;
        stored_last <= 1'b0;
    end
    else begin
        AC_valid_delay <= valid; 
        DC_valid_delay <= DC_valid;
        if(valid) begin
            stored_RLE_AC_valid <= 1'b1; 
            stored_RLE_DC_valid <= 1'b0;
            stored_mode <= mode;
            stored_last <= last;
        end
        else if(DC_valid) begin
            stored_RLE_AC_valid <= 1'b0; 
            stored_RLE_DC_valid <= 1'b1;
            stored_mode <= mode;
            stored_last <= last;
        end
        else begin
            stored_RLE_AC_valid <= stored_RLE_AC_valid ; 
            stored_RLE_DC_valid <= stored_RLE_DC_valid;
            stored_mode <= stored_mode;
            stored_last <= stored_last;
        end
    end
end


logic [11:0] to_AC_coe_table;
logic [3:0] zero_amount;
assign to_AC_coe_table = H_in_data[11:0];
assign zero_amount = H_in_data[15:12];

logic [11:0]AC_coe_out;
logic [3:0]AC_coe_out_group;

AC_coe_table AC_coe_table(
    .in_table(to_AC_coe_table),
    .DC_or_AC(stored_RLE_AC_valid), // DC = 0
    .real_restore_value(AC_coe_out),
    .group(AC_coe_out_group)
);

logic [7:0]data_in_H_table;
assign data_in_H_table = {zero_amount, AC_coe_out_group};

logic [15:0]data_out_H_table;
logic [4:0]H_bit_count;


H_table H_table0(
    .data_in(data_in_H_table),
    .DC_or_AC(stored_RLE_AC_valid), // DC = 0
    .mode(stored_mode/*select light or color*/),     // 01->Y
    .data_out(data_out_H_table),
    .valid_bit_count(H_bit_count)
);

logic [31:0]concated_value;

concatenater concatenater(
    .af_AC_table_value(AC_coe_out),
    .af_AC_valid_bits(AC_coe_out_group),
    .af_H_table_value(data_out_H_table),
    .concated_value(concated_value)    
);

logic [4:0] total_valid_bits;
assign total_valid_bits = {1'b0,AC_coe_out_group} + H_bit_count;
logic [4:0] concatenated_shift_left_bits;
assign concatenated_shift_left_bits = 5'd32 -  total_valid_bits;

logic [31:0] in_shfited_concatenated_value;
assign in_shfited_concatenated_value = concated_value << concatenated_shift_left_bits;


FIFO_shift FIFO_SHIFT0(
    .clk(clk),
    .rst(rst),
    .H_final_data(in_shfited_concatenated_value),
    .FIFO_in_last(stored_last),
    .total_valid_datas(total_valid_bits),
    .deal_FF_done(deal_FF_done),
    .H_data_valid(AC_valid_delay | DC_valid_delay ),
    .data_to_deal_FF(data_to_deal_FF),
    .collect_bits_valid(to_FF_valid),
    .FIFO_FULL_NEED_STALL(stall),
    .to_FF_last(to_FF_last),
    .out_empty(out_empty)
);

   
endmodule


module AC_coe_table (
    input [11:0] in_table,
    input DC_or_AC,
    output logic [11:0]real_restore_value,
    output logic [3:0] group
);

logic [11:0]group_jg_value;
logic [12:0]real_restore_value_temp;
assign real_restore_value = real_restore_value_temp[11:0];
always_comb begin
    if(!DC_or_AC) begin
        if(in_table[11]==1'b1) begin
            real_restore_value_temp = (in_table + 12'b1111_1111_1111);
        end
        else begin
            real_restore_value_temp = {1'b0,in_table};
        end
    end 
    else begin
        if(in_table[7]==1'b1) begin
            real_restore_value_temp = {4'b0,(in_table[7:0] + 8'b1111_1111)};
        end
        else begin
            real_restore_value_temp = {1'b0,in_table};
        end
    end
end

always_comb begin
    if(!DC_or_AC) begin
        if(in_table[11]==1'b1) begin
            group_jg_value = ~(in_table) + 12'd1;
        end
        else begin
            group_jg_value = in_table;
        end
    end
    else begin
        if(in_table[7]==1'b1) begin//AC
            group_jg_value = {4'b0,~(in_table[7:0]) + 8'd1};
        end
        else begin
            group_jg_value = in_table;
        end
    end
end

always_comb begin
    if(group_jg_value[11]==1'b1) begin
        group = 4'd12;
    end
    else if(group_jg_value[10]==1'b1) begin
        group = 4'd11;
    end
    else if(group_jg_value[9]==1'b1) begin
        group = 4'd10;
    end
    else if(group_jg_value[8]==1'b1) begin
        group = 4'd9;
    end
    else if(group_jg_value[7]==1'b1) begin
        group = 4'd8;
    end
    else if(group_jg_value[6]==1'b1) begin
        group = 4'd7;
    end
    else if(group_jg_value[5]==1'b1) begin
        group = 4'd6;
    end
    else if(group_jg_value[4]==1'b1) begin
        group = 4'd5;
    end
    else if(group_jg_value[3]==1'b1) begin
        group = 4'd4;
    end
    else if(group_jg_value[2]==1'b1) begin
        group = 4'd3;
    end
    else if(group_jg_value[1]==1'b1) begin
        group = 4'd2;
    end
    else if(group_jg_value[0]==1'b1) begin
        group = 4'd1;
    end
    else begin
        group = 4'd0;
    end
end


endmodule

module concatenater (
    input [11:0]af_AC_table_value,
    input [3:0]af_AC_valid_bits,
    input [15:0]af_H_table_value,
    output logic [31:0]concated_value
);

logic [3:0] shift_bits;
logic [11:0]tem_af_AC_table_value;
logic [31:0]tem_concated_value;

assign shift_bits = 4'd12- af_AC_valid_bits;
assign tem_af_AC_table_value = af_AC_table_value << shift_bits;
assign tem_concated_value = {4'b0000,af_H_table_value,tem_af_AC_table_value};
assign concated_value = tem_concated_value >> shift_bits;
    
endmodule
