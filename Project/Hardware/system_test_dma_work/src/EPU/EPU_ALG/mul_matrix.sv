module mul_matrix
#(
    parameter Z=14
)
(
    input                clk              ,
    input                rst              ,
    input                start            ,
    input signed [Z-1:0] in     [7:0][7:0],
    input        [1:0]   mode             ,
    output logic [Z-3:0] out    [7:0][7:0],
    output logic         finish
);
//define
logic        [Z-3:0]  out_1[7:0][7:0];
logic signed [Z-1:0]  in_signed     [7:0][7:0];
logic signed [11:0]   mul           [7:0][7:0];
logic signed [Z+11:0] mul_out       [7:0][7:0];
logic signed [Z+11:0] mul_out_shift [7:0][7:0];
logic signed [11:0]   c             [7:0][7:0];
logic signed [11:0]   y             [7:0][7:0];
logic signed [Z-3:0]  next_mul_out  [7:0][7:0];
//signal
always_ff @(posedge clk or posedge rst) begin
    if (rst) finish <= 1'b0;
    else finish <= start;
end
assign in_signed = in;
//mode sel
always_comb begin
    for (int d=0; d<8; d++) begin
        for (int e=0;e<8;e++) begin
            case(mode)
                2'b01  : mul[d][e] = y[d][e];
                2'b10  : mul[d][e] = c[d][e];
                2'b11  : mul[d][e] = c[d][e];
                default: mul[d][e] = y[d][e];
            endcase
        end
    end
end
//mul matrix combinational block
always_comb begin
    for (int i=0; i<8; i++) begin
        for (int j=0; j<8; j++) begin
            mul_out[i][j] = in_signed[i][j] * mul[i][j];
        end
    end
end
//next_mul_out
always_comb begin
    for (int a=0;a<8;a++) begin
        for (int b=0;b<8;b++) begin
            mul_out_shift[a][b] = ((mul_out[a][b])>>>12);
            next_mul_out[a][b] = mul_out_shift[a][b][Z-3:0];
        end
    end
end
//otuput registers
always@(posedge clk or posedge rst) begin
    if(rst) begin
        for (int m=0; m<8; m++) begin
            for (int q=0; q<8; q++) begin
                out_1[m][q] <= {(Z-2){1'b0}};
            end
        end
    end
    else begin
        for (int k=0; k<8; k++) begin
            for (int l=0; l<8; l++) begin
                out_1[k][l] <= next_mul_out[k][l][Z-3:0];
            end
        end
    end
end
always_comb begin
    for (int s=0;s<8;s++) begin
        for (int t=0;t<8;t++) begin
            out[s][t] = (out_1[s][t]==12'hfff)? 12'b0 : out_1[s][t];
        end
    end 
end
//for c_matrix
assign c[0][7] = 12'hF0;
assign c[0][6] = 12'hE3;
assign c[0][5] = 12'hAA;
assign c[0][4] = 12'h57;
assign c[0][3] = 12'h29;
assign c[0][2] = 12'h29;
assign c[0][1] = 12'h29;
assign c[0][0] = 12'h29;

assign c[1][7] = 12'hE3;
assign c[1][6] = 12'hC3;
assign c[1][5] = 12'h9D;
assign c[1][4] = 12'h3E;
assign c[1][3] = 12'h29;
assign c[1][2] = 12'h29;
assign c[1][1] = 12'h29;
assign c[1][0] = 12'h29;

assign c[2][7] = 12'hAA;
assign c[2][6] = 12'h9D;
assign c[2][5] = 12'h49;
assign c[2][4] = 12'h29;
assign c[2][3] = 12'h29;
assign c[2][2] = 12'h29;
assign c[2][1] = 12'h29;
assign c[2][0] = 12'h29;

assign c[3][7] = 12'h57;
assign c[3][6] = 12'h3E;
assign c[3][5] = 12'h29;
assign c[3][4] = 12'h29;
assign c[3][3] = 12'h29;
assign c[3][2] = 12'h29;
assign c[3][1] = 12'h29;
assign c[3][0] = 12'h29;

assign c[4][7] = 12'h29;
assign c[4][6] = 12'h29;
assign c[4][5] = 12'h29;
assign c[4][4] = 12'h29;
assign c[4][3] = 12'h29;
assign c[4][2] = 12'h29;
assign c[4][1] = 12'h29;
assign c[4][0] = 12'h29;

assign c[5][7] = 12'h29;
assign c[5][6] = 12'h29;
assign c[5][5] = 12'h29;
assign c[5][4] = 12'h29;
assign c[5][3] = 12'h29;
assign c[5][2] = 12'h29;
assign c[5][1] = 12'h29;
assign c[5][0] = 12'h29;

assign c[6][7] = 12'h29;
assign c[6][6] = 12'h29;
assign c[6][5] = 12'h29;
assign c[6][4] = 12'h29;
assign c[6][3] = 12'h29;
assign c[6][2] = 12'h29;
assign c[6][1] = 12'h29;
assign c[6][0] = 12'h29;

assign c[7][7] = 12'h29;
assign c[7][6] = 12'h29;
assign c[7][5] = 12'h29;
assign c[7][4] = 12'h29;
assign c[7][3] = 12'h29;
assign c[7][2] = 12'h29;
assign c[7][1] = 12'h29;
assign c[7][0] = 12'h29;
//for y_matrix
assign y[0][7] = 12'h100;
assign y[0][6] = 12'h174;
assign y[0][5] = 12'h198;
assign y[0][4] = 12'h100;
assign y[0][3] = 12'hAA;
assign y[0][2] = 12'h66;
assign y[0][1] = 12'h50;
assign y[0][0] = 12'h42;

assign y[1][7] = 12'h154;
assign y[1][6] = 12'h154;
assign y[1][5] = 12'h124;
assign y[1][4] = 12'hD6;
assign y[1][3] = 12'h9C;
assign y[1][2] = 12'h46;
assign y[1][1] = 12'h44;
assign y[1][0] = 12'h4a;

assign y[2][7] = 12'h124;
assign y[2][6] = 12'h13A;
assign y[2][5] = 12'h100;
assign y[2][4] = 12'ha2;
assign y[2][3] = 12'h66;
assign y[2][2] = 12'h46;
assign y[2][1] = 12'h3A;
assign y[2][0] = 12'h48;

assign y[3][7] = 12'h124;
assign y[3][6] = 12'h13A;
assign y[3][5] = 12'h100;
assign y[3][4] = 12'ha2;
assign y[3][3] = 12'h66;
assign y[3][2] = 12'h46;
assign y[3][1] = 12'h3A;
assign y[3][0] = 12'h48;

assign y[4][7] = 12'hE2;
assign y[4][6] = 12'hBA;
assign y[4][5] = 12'h6E;
assign y[4][4] = 12'h48;
assign y[4][3] = 12'h3C;
assign y[4][2] = 12'h24;
assign y[4][1] = 12'h26;
assign y[4][0] = 12'h34;

assign y[5][7] = 12'hAA;
assign y[5][6] = 12'h74;
assign y[5][5] = 12'h4A;
assign y[5][4] = 12'h40;
assign y[5][3] = 12'h32;
assign y[5][2] = 12'h26;
assign y[5][1] = 12'h24;
assign y[5][0] = 12'h2C;

assign y[6][7] = 12'h52;
assign y[6][6] = 12'h40;
assign y[6][5] = 12'h34;
assign y[6][4] = 12'h2E;
assign y[6][3] = 12'h26;
assign y[6][2] = 12'h20;
assign y[6][1] = 12'h22;
assign y[6][0] = 12'h28;

assign y[7][7] = 12'h38;
assign y[7][6] = 12'h2C;
assign y[7][5] = 12'h2A;
assign y[7][4] = 12'h28;
assign y[7][3] = 12'h24;
assign y[7][2] = 12'h28;
assign y[7][1] = 12'h26;
assign y[7][0] = 12'h28;

endmodule