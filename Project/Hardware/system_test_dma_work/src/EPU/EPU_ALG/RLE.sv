//1/4 12:49
//in: 8*8 Nbits
//out: 8*8 Nbits

module RLE
#(
    parameter N = 12
)
(
    input                       clk,
    input                       rst,
    input                       start,
    input                       stall,  //********************************************************
    input  [N-1:0]              rle_in[7:0][7:0],
    output logic [N+3:0]        data_dc,
    output logic [N+3:0]        data_ac,
    output logic                dc_done,
    output logic                done,
    output logic                rle_last,
    input                       empty,   //*****************************
    output logic                last
);
//define
logic bin[7:0][7:0];                        //to binary matrix
logic [62:0] line_bin, line, line_shift;    //pend to line, and shift left to scan
logic [7:0]  counter, EOB, EOB_reg;         //when counter >= EOB, generate EOB signal and last
logic [7:0]  count_zero, count_zero_reg;    //count zero numbers
logic [2:0]  col_ptr, row_ptr;              //col:0->7(top to down), row: 7->0 (left to right)
logic find,  scan_pt;                       //find EOB, scan point
logic [1:0]  cs, ns;
//************************************************************************
//logic last;
assign rle_last = ((cs==2'd2)&&(empty==1'b1))? 1'b1 : 1'b0;
//************************************************************************
//state
always_ff @(posedge clk or posedge rst) begin
    if (rst) cs <= 2'b0;
    else cs <= ns;
end
//next state
always_comb begin
    case (cs)
        2'b0 : ns = (start)? 2'd1 : 2'b0;
        2'd1 : ns = (last)?  2'd2 : 2'd1;
        2'd2 : ns = (empty)? 2'b0 : 2'd2;
        default : ns = 2'b0;
    endcase
end
//generate binary matrix, zero=>0, none-zero=>1
always_comb begin
    for (int i=0; i<8; i=i+1) begin
        for (int j=0; j<8; j=j+1) begin
            bin[i][j] = (rle_in[i][j] == {N{1'b0}})? 1'b0 : 1'b1;
        end
    end
end
//pend to a line and delete DC
assign line_bin = { /*bin07*/  bin[0][6], bin[0][5], bin[0][4], bin[0][3], bin[0][2], bin[0][1], bin[0][0],
                    bin[1][7], bin[1][6], bin[1][5], bin[1][4], bin[1][3], bin[1][2], bin[1][1], bin[1][0],
                    bin[2][7], bin[2][6], bin[2][5], bin[2][4], bin[2][3], bin[2][2], bin[2][1], bin[2][0],
                    bin[3][7], bin[3][6], bin[3][5], bin[3][4], bin[3][3], bin[3][2], bin[3][1], bin[3][0],
                    bin[4][7], bin[4][6], bin[4][5], bin[4][4], bin[4][3], bin[4][2], bin[4][1], bin[4][0],
                    bin[5][7], bin[5][6], bin[5][5], bin[5][4], bin[5][3], bin[5][2], bin[5][1], bin[5][0],
                    bin[6][7], bin[6][6], bin[6][5], bin[6][4], bin[6][3], bin[6][2], bin[6][1], bin[6][0],
                    bin[7][7], bin[7][6], bin[7][5], bin[7][4], bin[7][3], bin[7][2], bin[7][1], bin[7][0] };
//================================    RLE    ================================//
//line sel
assign line = line_shift;
assign scan_pt = line[62];
//cout zero numbers
always @(*) begin
    if (count_zero_reg == 8'd16) count_zero = (line[62])? 8'd1 : 8'b0;
    else count_zero = (line[62])? 8'b0 : (count_zero_reg + 8'd1);
end
//count_zero registers and line shift left
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        count_zero_reg <= 8'b0;
        line_shift <= 63'b0;
    end
    else if ((cs==2'b0)&&(start)) begin
        count_zero_reg <= 8'b0;
        line_shift <= line_bin;
    end
    //****************************************************************************
    else if (stall) begin
        count_zero_reg <= count_zero_reg;
        line_shift <= line_shift;
    end
    //****************************************************************************
    else begin 
        count_zero_reg <= count_zero;
        line_shift <= (line << 1);
    end
end
//output
//AC
always @(posedge clk or posedge rst) begin
    if (rst) begin
        done    <= 1'b0;
        last    <= 1'b0;
        data_ac <= 16'b0;
    end
    //**************************************
    else if (cs==2'd2) begin
        done <= 1'b0;
        last <= 1'b0;
        data_ac <= 16'b0; 
    end
    //**************************************************
    else if (cs==2'b1) begin
        //*********************************
        if (stall) begin
            done <= 1'b0;
            last <= 1'b0;
            data_ac <= 16'b0;
        end
        //**********************************
        else if (counter >= EOB) begin  //counter >= EOB, 
            done    <= 1'b1;
            last    <= 1'b1;
            data_ac <= (EOB==8'd62)? ({count_zero_reg[3:0], rle_in[col_ptr][row_ptr]}) : 16'b0;
        end
        else if (count_zero == 8'd16) begin //zeros=16, out = (15,0)
            done    <= 1'b1;
            last    <= 1'b0;
            data_ac <= { 4'd15, {N{1'b0}} };
        end
        else if (scan_pt==1'b1) begin //detect non-zero, out = (zero numbers, this non-zero number)
            done    <= 1'b1;
            last    <= 1'b0;
            data_ac <= { count_zero_reg[3:0], rle_in[col_ptr][row_ptr] };
        end
        else begin
            done    <= 1'b0;
            last    <= 1'b0;
            data_ac <= 16'b0;
        end
    end
    else begin
        done    <= 1'b0;
        last    <= 1'b0;
        data_ac <= 16'b0;
    end
end
//DC
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dc_done <= 1'b0;
        data_dc <= 16'b0;
    end
    //*****************************************
    else if (cs==2'd2) begin
        dc_done <= 1'b0;
        data_dc <= 16'b0;
    end
    //*******************************************
    else if (cs==2'b0) begin 
        dc_done <= start;
        data_dc <= {4'b0, (rle_in[0][7])};
    end
    else begin
        dc_done <= 1'b0;
        data_dc <= 16'b0;
    end
end
//================================    matrix pointer    ================================//
//row: 7->0, column: 0->7
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        row_ptr <= 3'b0;
        col_ptr <= 3'b0;
    end
    else if ((cs==2'b0)&&(start==1'b1)) begin
        row_ptr <= 3'd6;    //start at 6 on column 1, because delete dc
        col_ptr <= 3'b0;
    end
    //****************************************************************************
    else if (stall) begin
        row_ptr <= row_ptr;
        col_ptr <= col_ptr;
    end
    //****************************************************************************
    else if (row_ptr==3'd0) begin
        row_ptr <= 3'd7;
        col_ptr <= (col_ptr+3'd1);
    end
    else if (last) begin
        row_ptr <= 3'd0;
        col_ptr <= 3'd0;
    end
    else begin
        row_ptr <= (row_ptr-3'd1);
        col_ptr <= col_ptr;
    end
end
//================================    EOB    ================================//
//counter
always @(posedge clk or posedge rst) begin
    if (rst) counter <= 8'b0;
    //*************************************************************empty
    else if (cs==2'd2) counter <= 8'b0;
    //*************************************************************stall
    else if ((cs==2'b0)&&(start)) counter <= 8'b0;
    //****************************************************************************
    else if (stall) counter <= counter;
    //****************************************************************************
    else if (counter>=EOB) counter <= 8'b0;
    else if (cs==2'd1) counter <= (counter + 8'd1);
    else counter <= counter;
end
//state
logic [3:0] cs_EOB, ns_EOB;
always_ff @(posedge clk or posedge rst) begin
    if (rst) cs_EOB <= 4'b0;
    else cs_EOB <= ns_EOB;
end
//next state, S0: IDLE, S1~S7: SCAN, S15: find EOB to IDLE
always_comb begin
    case (cs_EOB)
        4'b0  : ns_EOB = (start)? 4'd1  : 4'b0;
        4'd1  : ns_EOB = (find)?  4'd15 : 4'd2;
        4'd2  : ns_EOB = (find)?  4'd15 : 4'd3;
        4'd3  : ns_EOB = (find)?  4'd15 : 4'd4;
        4'd4  : ns_EOB = (find)?  4'd15 : 4'd5;
        4'd5  : ns_EOB = (find)?  4'd15 : 4'd6;
        4'd6  : ns_EOB = (find)?  4'd15 : 4'd7;
        4'd7  : ns_EOB = (find)?  4'd15 : 4'd8;
        4'd8  : ns_EOB = (find)?  4'd15 : 4'd0;
        4'd15 : ns_EOB = (last)?  4'b0  : 4'd15;
        default : ns_EOB = 4'b0;
    endcase
end
//count EOB
always_comb begin
    case (cs_EOB)
        4'd0 : begin
            find = 1'b0;
            EOB = 8'hff;
        end
        4'd1 : begin    //63-56
            if (bin[7][0]) begin    //last number !=0, no EOB
                find = 1'b1;
                EOB = 8'd62;
            end
            else if (bin[7][1]) begin
                find = 1'b1;
                EOB = 8'd62;
            end
            else if (bin[7][2]) begin
                find = 1'b1;
                EOB = 8'd61;
            end
            else if (bin[7][3]) begin
                find = 1'b1;
                EOB = 8'd60;
            end
            else if (bin[7][4]) begin
                find = 1'b1;
                EOB = 8'd59;
            end
            else if (bin[7][5]) begin
                find = 1'b1;
                EOB = 8'd58;
            end
            else if (bin[7][6]) begin
                find = 1'b1;
                EOB = 8'd57;
            end
            else if (bin[7][7]) begin
                find = 1'b1;
                EOB = 8'd56;
            end
            else begin
                find = 1'b0;
                EOB = 8'hff;
            end
        end
        4'd2 : begin    //55-48
            if (bin[6][0]) begin
                find = 1'b1;
                EOB = 8'd55;
            end
            else if (bin[6][1]) begin
                find = 1'b1;
                EOB = 8'd54;
            end
            else if (bin[6][2]) begin
                find = 1'b1;
                EOB = 8'd53;
            end
            else if (bin[6][3]) begin
                find = 1'b1;
                EOB = 8'd52;
            end
            else if (bin[6][4]) begin
                find = 1'b1;
                EOB = 8'd51;
            end
            else if (bin[6][5]) begin
                find = 1'b1;
                EOB = 8'd50;
            end
            else if (bin[6][6]) begin
                find = 1'b1;
                EOB = 8'd49;
            end
            else if (bin[6][7]) begin
                find = 1'b1;
                EOB = 8'd48;
            end
            else begin
                find = 1'b0;
                EOB = 8'hff;
            end
        end
        4'd3: begin  //47-40
            if (bin[5][0]) begin
                find = 1'b1;
                EOB = 8'd47;
            end
            else if (bin[5][1]) begin
                find = 1'b1;
                EOB = 8'd46;
            end
            else if (bin[5][2]) begin
                find = 1'b1;
                EOB = 8'd45;
            end
            else if (bin[5][3]) begin
                find = 1'b1;
                EOB = 8'd44;
            end
            else if (bin[5][4]) begin
                find = 1'b1;
                EOB = 8'd43;
            end
            else if (bin[5][5]) begin
                find = 1'b1;
                EOB = 8'd42;
            end
            else if (bin[5][6]) begin
                find = 1'b1;
                EOB = 8'd41;
            end
            else if (bin[5][7]) begin
                find = 1'b1;
                EOB = 8'd40;
            end
            else begin
                find = 1'b0;
                EOB = 8'hff;
            end
        end
        4'd4: begin     //39-32
            if (bin[4][0]) begin
                find = 1'b1;
                EOB = 8'd39;
            end
            else if (bin[4][1]) begin
                find = 1'b1;
                EOB = 8'd38;
            end
            else if (bin[4][2]) begin
                find = 1'b1;
                EOB = 8'd37;
            end
            else if (bin[4][3]) begin
                find = 1'b1;
                EOB = 8'd36;
            end
            else if (bin[4][4]) begin
                find = 1'b1;
                EOB = 8'd35;
            end
            else if (bin[4][5]) begin
                find = 1'b1;
                EOB = 8'd34;
            end
            else if (bin[4][6]) begin
                find = 1'b1;
                EOB = 8'd33;
            end
            else if (bin[4][7]) begin
                find = 1'b1;
                EOB = 8'd32;
            end
            else begin
                find = 1'b0;
                EOB = 8'hff;
            end
        end
        4'd5: begin     //31-24
            if (bin[3][0]) begin
                find = 1'b1;
                EOB = 8'd31;
            end
            else if (bin[3][1]) begin
                find = 1'b1;
                EOB = 8'd30;
            end
            else if (bin[3][2]) begin
                find = 1'b1;
                EOB = 8'd29;
            end
            else if (bin[3][3]) begin
                find = 1'b1;
                EOB = 8'd28;
            end
            else if (bin[3][4]) begin
                find = 1'b1;
                EOB = 8'd27;
            end
            else if (bin[3][5]) begin
                find = 1'b1;
                EOB = 8'd26;
            end
            else if (bin[3][6]) begin
                find = 1'b1;
                EOB = 8'd25;
            end
            else if (bin[3][7]) begin
                find = 1'b1;
                EOB = 8'd24;
            end
            else begin
                find = 1'b0;
                EOB = 8'hff;
            end
        end
        4'd6: begin     //23-16
            if (bin[2][0]) begin
                find = 1'b1;
                EOB = 8'd23;
            end
            else if (bin[2][1]) begin
                find = 1'b1;
                EOB = 8'd22;
            end
            else if (bin[2][2]) begin
                find = 1'b1;
                EOB = 8'd21;
            end
            else if (bin[2][3]) begin
                find = 1'b1;
                EOB = 8'd20;
            end
            else if (bin[2][4]) begin
                find = 1'b1;
                EOB = 8'd19;
            end
            else if (bin[2][5]) begin
                find = 1'b1;
                EOB = 8'd18;
            end
            else if (bin[2][6]) begin
                find = 1'b1;
                EOB = 8'd17;
            end
            else if (bin[2][7]) begin
                find = 1'b1;
                EOB = 8'd16;
            end
            else begin
                find = 1'b0;
                EOB = 8'hff;
            end
        end
        4'd7: begin     //15-8
            if (bin[1][0]) begin
                find = 1'b1;
                EOB = 8'd15;
            end
            else if (bin[1][1]) begin
                find = 1'b1;
                EOB = 8'd14;
            end
            else if (bin[1][2]) begin
                find = 1'b1;
                EOB = 8'd13;
            end
            else if (bin[1][3]) begin
                find = 1'b1;
                EOB = 8'd12;
            end
            else if (bin[1][4]) begin
                find = 1'b1;
                EOB = 8'd11;
            end
            else if (bin[1][5]) begin
                find = 1'b1;
                EOB = 8'd10;
            end
            else if (bin[1][6]) begin
                find = 1'b1;
                EOB = 8'd9;
            end
            else if (bin[1][7]) begin
                find = 1'b1;
                EOB = 8'd8;
            end
            else begin
                find = 1'b0;
                EOB = 8'hff;
            end
        end
        4'd8: begin     //7-1
            if (bin[0][0]) begin
                find = 1'b1;
                EOB = 8'd7;
            end
            else if (bin[0][1]) begin
                find = 1'b1;
                EOB = 8'd6;
            end
            else if (bin[0][2]) begin
                find = 1'b1;
                EOB = 8'd5;
            end
            else if (bin[0][3]) begin
                find = 1'b1;
                EOB = 8'd4;
            end
            else if (bin[0][4]) begin
                find = 1'b1;
                EOB = 8'd3;
            end
            else if (bin[0][5]) begin
                find = 1'b1;
                EOB = 8'd2;
            end
            else if (bin[0][6]) begin
                find = 1'b1;
                EOB = 8'd1;
            end
            else begin
                find = 1'b1;
                EOB = 8'd1;
            end
        end
        4'd15 : begin
            find = 1'b0;
            EOB = EOB_reg;
        end
        default : begin
            find = 1'b0;
            EOB = 8'hff;
        end
    endcase
end
//registers
always_ff @(posedge clk or posedge rst) begin
    if (rst) EOB_reg <= 8'b0;
    else if (((cs==2'b0)&&(start==1'b1)) || last) EOB_reg <= 8'hff;
    else if (find) EOB_reg <= EOB;
    else EOB_reg <= EOB_reg;
end


endmodule