module ycrcb_mem 
(
    input              clk,
    input              rst,
    input              load,
    input              finish,
    input        [7:0] data_ycrcb[3:0],
    output logic [7:0] ycrcb_mem[7:0][7:0],
    output logic       full
);
//define
logic [1:0] cs, ns;
logic [7:0] counter;
logic [2:0] counter_next;//0~7
logic hold;
//state
always_ff @(posedge clk or posedge rst) begin
    if (rst) cs <= 2'b0;
    else cs <= ns;
end
//next state
always_comb begin
    case (cs)
        2'b0 : ns = (load)? 2'd1 : 2'b0;    //IDLE
        2'd1 : ns = (hold)? 2'd3 : (load)? 2'd2 : 2'd1;    //load_right in4*1=>mem[3]~[0]
        2'd2 : ns = (load)? 2'd1 : 2'd2;    //load_left  in4*1=>mem[7]~[4]
        2'd3 : ns = (finish)? 2'd0 : 2'd3;    //hold
    endcase
end
//counter
always_ff @(posedge clk or posedge rst) begin
    if (rst) counter <= 8'b0;
    else if (finish==1'b1) counter <= 8'b0;
    else if (((cs==2'd0)||(cs==2'd2)) && (load==1'b1)) counter <= counter;
    else if ((cs==2'd1)&&(load==1'b1)) counter <= counter+8'd1;
    else if (counter==8'd8) counter <= 8'b0;
    else counter <= counter;
end
//hold
assign hold = ((counter==8'd7)&&(cs==2'd1))? 1'b1 : 1'b0;//counter=7
assign full = (counter==8'd8)? 1'b1 : 1'b0;              //counter=8
//counter
assign counter_next = (counter[3]==1'b0)? counter[2:0] : 3'b0;
//YCrCb reg
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i=0;i<8;i++) begin
            for (int j=0;j<8;j++) begin
                ycrcb_mem[i][j] <= 8'b0;
            end
        end
    end
    else if (((cs==2'd0)||(cs==2'd2)) && (load==1'b1)) begin
        for (int m=0;m<4;m++) begin
            ycrcb_mem[counter_next][m+4] <= data_ycrcb[m];
        end
    end
    else if ((cs==2'd1)&&(load==1'b1)) begin
        for (int n=0;n<4;n++) begin
            ycrcb_mem[counter_next][n] <= data_ycrcb[n];
        end
    end
    else begin
        for (int k=0;k<8;k++) begin
            for (int l=0;l<8;l++) begin
                ycrcb_mem[k][l] <= ycrcb_mem[k][l];
            end
        end
    end
end

endmodule