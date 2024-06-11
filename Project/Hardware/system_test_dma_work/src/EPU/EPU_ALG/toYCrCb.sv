//v1, add mode sel
//1/4 00:48
module toYCrCb
#(
    data_num = 4
)
(
    input              clk,
    input              rst,
    input              start,
    input        [7:0] in_R[data_num-1:0],
    input        [7:0] in_G[data_num-1:0],
    input        [7:0] in_B[data_num-1:0],
    input        [1:0] mode,
    output logic       finish,
    output logic [7:0] out[data_num-1:0]
);
//define
logic signed [8:0]  R[data_num-1:0];
logic signed [8:0]  G[data_num-1:0];
logic signed [8:0]  B[data_num-1:0];
logic signed [7:0]  mul[2:0];       //+127~-128
logic signed [16:0] mul_out[data_num-1:0];   //9+8=17
logic signed [16:0] mul_out_next[data_num-1:0];
logic signed [16:0] constant;
//signed input
always_comb begin
    for (int i=0; i<data_num; i++) begin
        R[i] = {1'b0, in_R[i]};
        G[i] = {1'b0, in_G[i]};
        B[i] = {1'b0, in_B[i]};
    end
end
//mode sel,2'b00: IDLE, 2'b01: Y, 2'b10: Cb, 2'b11: Cr
always_comb begin
    case (mode)
        2'b01 : begin   //Y
            mul[2] = 8'h26; //38
            mul[1] = 8'h4b; //75
            mul[0] = 8'h0e; //14
            constant = 17'd128;
        end
        2'b10 : begin   //Cr
            mul[2] = 8'h40; //64
            mul[1] = 8'hcb; //-53
            mul[0] = 8'hf6; //-10
            constant = 17'b0;
        end
        2'b11 : begin   //Cb
            mul[2] = 8'heb; //-21
            mul[1] = 8'hd6; //-42
            mul[0] = 8'h40; //64
            constant = 17'b0;
        end
        default : begin
            mul[2] = 8'b0;
            mul[1] = 8'b0;
            mul[0] = 8'b0;
            constant = 17'b0;
        end
    endcase
end
//finish
always_ff @(posedge clk or posedge rst) begin
    if (rst) finish <= 1'b0;
    else if (start==1'b1) finish <=1'b1;
    else finish <= 1'b0;
end
//mul and shift
always_comb begin
    for (int j=0; j<data_num; j++) begin
        mul_out[j]      = (R[j]*mul[2] + G[j]*mul[1] + B[j]*mul[0]);
        mul_out_next[j] = ((mul_out[j]) >>> 7) - constant;
    end
end
//out
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int k=0; k<data_num; k++) begin
            out[k] <= 8'b0;
        end
    end
    else begin
        for (int l=0; l<data_num; l++) begin
            out[l] <= mul_out_next[l][7:0];
        end
    end
end

endmodule