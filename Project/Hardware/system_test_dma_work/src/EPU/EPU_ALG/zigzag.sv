module zigzag
#(
    parameter N=8
)
(
    input        [N-1:0] in [7:0][7:0],
    output logic [N-1:0] out[7:0][7:0]
);
//zig zag combinational block
always_comb begin
    out[0][7] = in[0][7];
    out[0][6] = in[0][6];
    out[0][5] = in[1][7];
    out[0][4] = in[2][7];
    out[0][3] = in[1][6];
    out[0][2] = in[0][5];
    out[0][1] = in[0][4];
    out[0][0] = in[1][5];

    out[1][7] = in[2][6];
    out[1][6] = in[3][7];
    out[1][5] = in[4][7];
    out[1][4] = in[3][6];
    out[1][3] = in[2][5];
    out[1][2] = in[1][4];
    out[1][1] = in[0][3];
    out[1][0] = in[0][2];

    out[2][7] = in[1][3];
    out[2][6] = in[2][4];
    out[2][5] = in[3][5];
    out[2][4] = in[4][6];
    out[2][3] = in[5][7];
    out[2][2] = in[6][7];
    out[2][1] = in[5][6];
    out[2][0] = in[4][5];

    out[3][7] = in[3][4];
    out[3][6] = in[2][3];
    out[3][5] = in[1][2];
    out[3][4] = in[0][1];
    out[3][3] = in[0][0];
    out[3][2] = in[1][1];
    out[3][1] = in[2][2];
    out[3][0] = in[3][3];

    out[4][7] = in[4][4];
    out[4][6] = in[5][5];
    out[4][5] = in[6][6];
    out[4][4] = in[7][7];
    out[4][3] = in[7][6];
    out[4][2] = in[6][5];
    out[4][1] = in[5][4];
    out[4][0] = in[4][3];

    out[5][7] = in[3][2];
    out[5][6] = in[2][1];
    out[5][5] = in[1][0];
    out[5][4] = in[2][0];
    out[5][3] = in[3][1];
    out[5][2] = in[4][2];
    out[5][1] = in[5][3];
    out[5][0] = in[6][4];

    out[6][7] = in[7][5];
    out[6][6] = in[7][4];
    out[6][5] = in[6][3];
    out[6][4] = in[5][2];
    out[6][3] = in[4][1];
    out[6][2] = in[3][0];
    out[6][1] = in[4][0];
    out[6][0] = in[5][1];
    
    out[7][7] = in[6][2];
    out[7][6] = in[7][3];
    out[7][5] = in[7][2];
    out[7][4] = in[6][1];
    out[7][3] = in[5][0];
    out[7][2] = in[6][0];
    out[7][1] = in[7][1];
    out[7][0] = in[7][0];
end


endmodule