module FIFO_shift (
    input clk,
    input rst,
    input [31:0]H_final_data,
    input FIFO_in_last,
    input [4:0]total_valid_datas,
    input deal_FF_done,
    input H_data_valid,
    output logic [31:0]data_to_deal_FF,
    output logic collect_bits_valid,
    output logic FIFO_FULL_NEED_STALL,
    output logic to_FF_last,
    output logic out_empty
);

logic [37:0]H_to_FIFO;
assign H_to_FIFO = {FIFO_in_last,total_valid_datas,H_final_data};

logic [37:0]FIFO_to_collect_bits_data;

logic collect_bits_request;
logic FIFO_can_read;


FIFO FIFO0(
    .clk(clk),
    .rst(rst),
    .in_data(H_to_FIFO),
    .read_request(collect_bits_request),
    .write_request(H_data_valid),
    .FIFO_readable(FIFO_can_read),
    .full(FIFO_FULL_NEED_STALL),
    .out_data(FIFO_to_collect_bits_data),
    .out_empty(out_empty)
);



collect_bits collect_bits(
    .clk(clk),
    .rst(rst),
    .FIFO_data(FIFO_to_collect_bits_data),
    .FIFO_can_read(FIFO_can_read),
    .data_request(collect_bits_request),
    .deal_FF_done(deal_FF_done),
    .data_to_deal_FF(data_to_deal_FF),
    .left_reg_full(collect_bits_valid),
    .out_collect_bit_last(to_FF_last)
);


    
endmodule




module collect_bits(
    input clk,
    input rst,
    input [37:0]FIFO_data,
    input FIFO_can_read,
    output logic data_request,
    ///////////// to FF ///////////
    input deal_FF_done,
    output logic [31:0]data_to_deal_FF,
    output logic left_reg_full,
    output logic out_collect_bit_last
);

logic in_collect_bit_last;

logic [63:0] collect_reg;

logic [4:0] stored_valid_datas;

logic [4:0]total_valid_datas;
logic [31:0]encoded_data;
assign total_valid_datas = FIFO_data[36:32];
assign encoded_data = FIFO_data[31:0];


logic [5:0] fill_32_counter;
logic [5:0] full_bits;
logic [5:0] extra_bits; 


///////////////////////////
logic counter_count;
logic counter_over_32;
//////////////////////
logic collect_reg_write;
logic shift_full;
logic shift_normal;
logic shift_extra;


parameter IDLE                  = 3'd0 ;
parameter POP                   = 3'd1 ;
parameter SHIFT                 = 3'd2 ;
parameter OVER_32               = 3'd3 ;
parameter WAIT_0                = 3'd4 ;
parameter FINAL_SHIFT           = 3'd5 ;
parameter DEAL_LAST_SHIFT_FULL  = 3'd6 ;
parameter WAIT_LAST             = 3'd7 ;

logic [2:0] present_state;
logic [2:0] next_state;

always_ff @(posedge clk or posedge rst) begin : FSM_trans
    if(rst) begin
        present_state <= 3'b0;
    end
    else begin
        present_state <= next_state;
    end
end

always_comb begin : transiton_logic 
    case(present_state)
        IDLE:begin
            if(FIFO_can_read) begin
                next_state = POP;
                out_collect_bit_last = 1'b0;
            end
            else begin
                next_state = IDLE;
                out_collect_bit_last = 1'b0;
            end
        end

        POP: begin
            if(fill_32_counter + {1'b0,stored_valid_datas} >=7'd32) begin
                next_state = OVER_32;
                out_collect_bit_last = 1'b0;
            end
            else begin
                next_state = SHIFT;
                out_collect_bit_last = 1'b0;
            end
        end

        SHIFT: begin
            if(in_collect_bit_last) begin
                next_state = DEAL_LAST_SHIFT_FULL;
                out_collect_bit_last = 1'b0;
            end
            else begin
                next_state = IDLE;
                out_collect_bit_last = 1'b0;
            end
        end
        DEAL_LAST_SHIFT_FULL: begin
            next_state = WAIT_LAST;
            out_collect_bit_last = 1'b0;
        end
        WAIT_LAST : begin
            if(deal_FF_done) begin
                next_state = IDLE;
                out_collect_bit_last = 1'b1;
            end
            else begin
                next_state = WAIT_LAST;
                out_collect_bit_last = 1'b1;
            end
        end
        
        OVER_32: begin
            next_state = WAIT_0;
            out_collect_bit_last = 1'b0;
        end

        WAIT_0: begin
            if(in_collect_bit_last && (extra_bits == 5'b0)) begin
                out_collect_bit_last = 1'b1;
            end
            else begin
                out_collect_bit_last = 1'b0;
            end
            if(deal_FF_done) begin
                if(in_collect_bit_last && (extra_bits == 5'b0)) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = FINAL_SHIFT;
                end
            end
            else begin
                next_state = WAIT_0;
            end
        end
        FINAL_SHIFT: begin
            if(in_collect_bit_last && (extra_bits != 6'b0)) begin
                next_state = DEAL_LAST_SHIFT_FULL;
                out_collect_bit_last = 1'b0;
            end
            else begin
                next_state = IDLE;
                out_collect_bit_last = 1'b0;
            end
        end
    endcase
end

always_comb begin : output_logic 
    case(present_state)
        IDLE:begin
            if(FIFO_can_read) begin
                data_request        = 1'b1;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b0;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b0;
                shift_extra         = 1'b0;
            end
            else begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b0;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b0;
                shift_extra         = 1'b0;
            end
        end

        POP: begin
            if(fill_32_counter + {1'b0,stored_valid_datas} >=7'd32) begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b0;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b0;
                shift_extra         = 1'b0;
            end
            else begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b0;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b0;
                shift_extra         = 1'b0;
            end

        end

        SHIFT: begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b0;
                /////////////////////////
                counter_count       = 1'b1;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b1;
                shift_full          = 1'b0;
                shift_extra         = 1'b0;
        end
        DEAL_LAST_SHIFT_FULL: begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b0;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b1;
                shift_extra         = 1'b0;            
        end
        WAIT_LAST : begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b1;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b0;
                shift_extra         = 1'b0;
        end
        
        
        OVER_32: begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b0;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b1;
                shift_extra         = 1'b0;
        end

        WAIT_0: begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b1;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b0;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b0;
                shift_extra         = 1'b0;
            
        end
        FINAL_SHIFT: begin
                data_request        = 1'b0;
                data_to_deal_FF     = collect_reg[63:32];
                left_reg_full       = 1'b0;
                /////////////////////////
                counter_count       = 1'b0;
                counter_over_32     = 1'b1;
                //collect_reg_write   = 1'b0;
                shift_normal        = 1'b0;
                shift_full          = 1'b0;
                shift_extra         = 1'b1;
        end
        
    endcase
end


///////////// fill_32 counter ////////

always_ff@(posedge clk or posedge rst) begin :counter_block
    if(rst) begin
        fill_32_counter <= 6'b0;
    end
    else if(counter_count) begin
        fill_32_counter <= fill_32_counter + {1'b0,stored_valid_datas};
    end
    else if(counter_over_32) begin
        fill_32_counter <= fill_32_counter + {1'b0,stored_valid_datas}- 6'd32;
    end
    else begin
        fill_32_counter <= fill_32_counter;
    end
end

/////////// collect_reg///////////
always_ff @( posedge clk or posedge rst ) begin : collect_reg_block
    if(rst) begin
        collect_reg <= 64'b0;
    end
    else if(data_request) begin
        collect_reg[31:0] <= encoded_data;
    end
    else if(shift_normal) begin
        collect_reg <= collect_reg << stored_valid_datas;
    end
    else if(shift_full) begin
        collect_reg <= collect_reg << (6'd32-fill_32_counter);//full_bits;
    end
    else if(shift_extra) begin
        collect_reg <= collect_reg << extra_bits;
    end
    else begin
        collect_reg <= collect_reg;
    end
end
//////////// stored_valid_bits /////////
always_ff @(posedge clk or posedge rst) begin : total_valid_bits_storage
    if(rst) begin
        stored_valid_datas <= 5'b0;
    end
    else if(data_request) begin
        stored_valid_datas <= total_valid_datas;
    end
    else begin
        stored_valid_datas <=stored_valid_datas;
    end
end
//////////// extra_bits 、 full_bits //////////
always_ff @( posedge clk or posedge rst ) begin : extra_bit_and_full_bits
    if(rst) begin
        extra_bits  <= 6'b0;
        full_bits   <= 6'b0;
    end
    else if(present_state == POP && (fill_32_counter + {1'b0,stored_valid_datas} >=7'd32))begin
        full_bits <= 6'd32-fill_32_counter;
        extra_bits <= fill_32_counter + {1'b0,stored_valid_datas} - 6'd32;
    end
    else begin
         full_bits <= full_bits;
         extra_bits <= extra_bits;
    end
end

/////////// last //////////////
always_ff @( posedge clk or posedge rst ) begin 
    if(rst) begin
        in_collect_bit_last <= 1'b0;
    end
    else if(data_request) begin
        in_collect_bit_last <= FIFO_data[37];
    end
    else begin
        in_collect_bit_last <= in_collect_bit_last ;
    end
end


endmodule

module FIFO (
    input clk,
    input rst,
    input [37:0]in_data,
    input read_request,
    input write_request,
    output logic FIFO_readable,
    output logic FIFO_writable,
    output logic full,
    output logic [37:0]out_data,
    output logic out_empty
);
    
logic [6:0]write_index; // 7bit
logic [6:0]read_index;
logic [37:0]FIFO_reg [63:0]; // 6bit

logic empty;
assign out_empty = empty;


logic FIFO_write_ptr_count;
logic FIFO_read_ptr_count;
assign FIFO_write_ptr_count = write_request && ~(full);
assign FIFO_read_ptr_count = read_request && ~(empty);
assign out_data = FIFO_reg[read_index[5:0]];

assign FIFO_readable = ~(empty);

integer i;

always_ff @(posedge clk or posedge rst ) begin : FIFO_restore
    if(rst) begin
       for(i =0 ; i<64;i++ ) begin
        FIFO_reg[i] <= 38'b0;
       end 
    end
    else begin
        if(FIFO_write_ptr_count) begin
            FIFO_reg[write_index[5:0]] <= in_data;
        end
    end
end

always_ff @( posedge clk or posedge rst ) begin : write_ptr
    if(rst) begin
        write_index <= 7'b0;
    end
    else if(FIFO_write_ptr_count) begin
        write_index <= write_index +7'd1;
    end
    else begin
        write_index <= write_index;
    end
end

always_ff @( posedge clk or posedge rst ) begin : read_ptr
    if(rst) begin
        read_index <= 7'b0;
    end
    else if(FIFO_read_ptr_count) begin
        read_index <= read_index +7'd1;
    end
    else begin
        read_index <= read_index;
    end
end


always_comb begin : empty_full_jg
    if(write_index[6] != read_index[6] && write_index[5:0] == read_index[5:0]) begin
        full = 1'b1;
        empty = 1'b0;
    end
    else if(write_index == read_index) begin
        full = 1'b0;
        empty = 1'b1;
    end
    else begin
        full = 1'b0;
        empty = 1'b0;
    end
end

endmodule