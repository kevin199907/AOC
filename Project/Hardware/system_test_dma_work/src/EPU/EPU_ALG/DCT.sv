//DCT 3 cycle
//12/29, 15:25
module DCT
#(
    parameter  V = 14
) 
(
    input                 clk, 
    input                 rst,
    input                 start,
    input                 hold_end,
    input  [7:0]          in[7:0][7:0],
    output logic [V-1:0]  out[7:0][7:0],
    output logic          finish
);
//define
logic        [3:0]  cs, ns;
logic signed [15:0] dct_in [7:0][7:0];
logic signed [15:0] tmp    [24:0][7:0];
logic signed [15:0] dct_out[7:0][7:0];
logic signed [15:0] dct_tr [7:0][7:0];
logic signed [15:0] dct_tr_shift [7:0][7:0];
//state
always_ff @(posedge clk or posedge rst) begin
    if (rst) cs <= 4'b0;
    else cs <= ns;
end
//state output
always_comb begin
    case (cs)
        4'd0 : begin
            ns = (start==1'b1)? 4'd1 : 4'd0;
            finish = 1'b0;
        end
        4'd1  : begin
            ns = 4'd2;
            finish = 1'b0;
        end
        4'd2 : begin
            ns = 4'd3;
            finish = 1'b1;
        end
        4'd3 : begin
            ns = (hold_end)? 4'd0 : 4'd3;
            finish = /*(hold_end)? 1'b0 :*/ 1'b0;//***************
        end
        default : begin
            ns = 4'b0;
            finish = 1'b0;
        end
    endcase
end
//dct input
always_comb begin
    for (int a=0; a<8; a=a+1) begin
        for (int b=0; b<8; b=b+1) begin
            dct_in[a][b] = (cs==4'd0)? {{8{in[a][b][7]}}, in[a][b]} : dct_tr[a][b];
        end
    end
end
//DCT combinatinal block
always_comb begin
    for (int i=0; i<8; i=i+1) begin
        //stage0
        tmp[0][i]  = ( dct_in[0][i] + dct_in[7][i] );                       //tmp0 = x0 + x7
        tmp[1][i]  = ( dct_in[1][i] + dct_in[6][i] );                       //tmp1 = x1 + x6
        tmp[2][i]  = ( dct_in[2][i] + dct_in[5][i] );                       //tmp2 = x2 + x5
        tmp[3][i]  = ( dct_in[3][i] + dct_in[4][i] );                       //tmp3 = x3 + x4
        tmp[4][i]  = ( dct_in[3][i] - dct_in[4][i] );                       //tmp4 = x3 - x4
        tmp[5][i]  = ( dct_in[2][i] - dct_in[5][i] );                       //tmp5 = x2 - x5
        tmp[6][i]  = ( dct_in[1][i] - dct_in[6][i] );                       //tmp6 = x1 - x6
        tmp[7][i]  = ( dct_in[0][i] - dct_in[7][i] );                       //tmp7 = x0 - x7
        //stage1
        tmp[8][i]  = ( (tmp[5][i]>>>2) + (tmp[5][i]>>>3) + tmp[6][i] );     //tmp8 = 3/8*tmp5 + tmp6
        tmp[9][i]  = ( (tmp[8][i]>>>1) + (tmp[8][i]>>>3) - tmp[5][i] );     //tmp9 = -tmp5 + 5/8*tmp6
        tmp[10][i] = ( tmp[0][i] + tmp[3][i] );                             //tmp10 = tmp0 + tmp3
        tmp[11][i] = ( tmp[1][i] + tmp[2][i] );                             //tmp11 = tmp1 + tmp2
        tmp[12][i] = ( tmp[1][i] - tmp[2][i] );                             //tmp12 = tmp1 - tmp2
        tmp[13][i] = ( tmp[0][i] - tmp[3][i] );                             //tmp13 = tmp0 - tmp3
        //stage2
        tmp[14][i] = ( tmp[10][i] + tmp[11][i] );                           //tmp14 = tmp10 + tmp11
        tmp[15][i] = ( (tmp[14][i]>>>1) - tmp[11][i] );                     //tmp15 = 1/2*tmp14 - tmp11
        tmp[16][i] = ( tmp[12][i] - (tmp[13][i]>>>2) - (tmp[13][i]>>>3) );  //tmp16 = tmp12 - 3/8*tmp13
        tmp[17][i] = ( tmp[13][i] + (tmp[16][i]>>>2) + (tmp[16][i]>>>3) );  //tmp17 = tmp13 + 3/8*tmp16
        tmp[18][i] = ( tmp[4][i] + tmp[9][i] );                             //tmp18 = tmp4 + tmp9
        tmp[19][i] = ( tmp[4][i] - tmp[9][i] );                             //tmp19 = tmp4 - tmp9
        tmp[20][i] = ( tmp[7][i] - tmp[8][i] );                             //tmp20 = tmp7 - tmp8
        tmp[21][i] = ( tmp[8][i] + tmp[7][i] );                             //tmp21 = tmp7 + tmp8
        //stage3
        tmp[22][i] = ( tmp[18][i] - (tmp[21][i]>>>3) );                     //tmp22 = tmp18 - 1/8*tmp21
        tmp[23][i] = ( tmp[19][i] + tmp[20][i] - (tmp[20][i]>>>3) );        //tmp23 = tmp19 + 7/8*tmp20
        tmp[24][i] = ( tmp[20][i] - ((tmp[23][i])>>>1) );                   //tmp24 = tmp20 - 1/2*tmp23
        //out
        dct_out[0][i] = tmp[14][i];
        dct_out[4][i] = tmp[15][i];
        dct_out[6][i] = tmp[16][i];
        dct_out[2][i] = tmp[17][i];
        dct_out[7][i] = tmp[22][i];
        dct_out[5][i] = tmp[23][i];
        dct_out[3][i] = tmp[24][i];
        dct_out[1][i] = tmp[21][i];
    end
end
//transform metrix
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int j=0; j<8; j=j+1) begin
            for (int k=0; k<8; k=k+1) begin
                dct_tr[j][k] <= 16'b0;
            end
        end
    end
    else if ((cs==4'd3)||(cs==4'd2)) begin
        for (int r=0;r<8;r++) begin
            for (int s=0;s<8;s++) begin
                dct_tr[r][s] <= dct_tr[r][s];
            end
        end
    end
    else begin
        for (int l=0; l<8; l=l+1) begin
            for (int m=0; m<8; m=m+1) begin
                dct_tr[l][m] <= dct_out[-m+7][-l+7];
            end
        end
    end
end
//shift
always_comb begin
    for (int p=0; p<8; p=p+1) begin
        for (int q=0; q<8; q=q+1) begin
            dct_tr_shift[p][q] = (dct_tr[p][q] /*>>> 2*/);  //divide4//**********************************************************
        end
    end
end
//output
always_comb begin
    for (int n=0; n<8; n=n+1) begin
        for (int o=0; o<8; o=o+1) begin
            out[n][o] = ((cs==4'd2)||(cs==4'd3))? (dct_tr_shift[n][o][V-1:0]) : (14'b0);
        end
    end
end

endmodule