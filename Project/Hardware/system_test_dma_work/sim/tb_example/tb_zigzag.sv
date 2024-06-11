`timescale	1ns/100ps
`include 	"zigzag.sv"
`define PAT1 "pat_zigzag1.pat"
`define GOLD1 "gold_zigzag1.pat"
module tb_zigzag();
//parameter
localparam N = 8;
localparam cycle = 10ns;
//top module port
logic		  clk;
logic [N-1:0] in [7:0][7:0];
logic [N-1:0] out[7:0][7:0];
//
logic [N-1:0] pat1[7:0][7:0];
logic start;
//============ Module Import =============
zigzag #(8) zigzag
(
	.in(in), 	
	.out(out)
);
// Variable Control
initial begin
	clk = 1'b0;
    start = 1'b0;
	#10
    start = 1'b1;
    for (int i=0; i<8; i++) begin
        for (int j=0; j<8; j++) begin
            in[i][j] = pat1[i][-j+7];
        end
    end
    #10	$finish;
end
	//============ FSDB Generation ============
initial begin
    $readmemh(`PAT1, pat1);
    $fsdbDumpfile("zigzag.fsdb");
	$fsdbDumpvars;
    $fsdbDumpMDA();
    
end
always begin
    @(posedge clk) begin
        $displayh("\n");
        $displayh("====================== simulation start =====================");
        $displayh("=========================== input ===========================");
        $displayh( pat1[0][0]," ", pat1[0][1]," ", pat1[0][2]," ", pat1[0][3]," ", pat1[0][4]," ", pat1[0][5]," ", pat1[0][6]," ", pat1[0][7], );
        $displayh( pat1[1][0]," ", pat1[1][1]," ", pat1[1][2]," ", pat1[1][3]," ", pat1[1][4]," ", pat1[1][5]," ", pat1[1][6]," ", pat1[1][7], );
        $displayh( pat1[2][0]," ", pat1[2][1]," ", pat1[2][2]," ", pat1[2][3]," ", pat1[2][4]," ", pat1[2][5]," ", pat1[2][6]," ", pat1[2][7], );
        $displayh( pat1[3][0]," ", pat1[3][1]," ", pat1[3][2]," ", pat1[3][3]," ", pat1[3][4]," ", pat1[3][5]," ", pat1[3][6]," ", pat1[3][7], );
        $displayh( pat1[4][0]," ", pat1[4][1]," ", pat1[4][2]," ", pat1[4][3]," ", pat1[4][4]," ", pat1[4][5]," ", pat1[4][6]," ", pat1[4][7], );
        $displayh( pat1[5][0]," ", pat1[5][1]," ", pat1[5][2]," ", pat1[5][3]," ", pat1[5][4]," ", pat1[5][5]," ", pat1[5][6]," ", pat1[5][7], );
        $displayh( pat1[6][0]," ", pat1[6][1]," ", pat1[6][2]," ", pat1[6][3]," ", pat1[6][4]," ", pat1[6][5]," ", pat1[6][6]," ", pat1[6][7], );
        $displayh( pat1[7][0]," ", pat1[7][1]," ", pat1[7][2]," ", pat1[7][3]," ", pat1[7][4]," ", pat1[7][5]," ", pat1[7][6]," ", pat1[7][7],"\n");
        $displayh("=========================== output ===========================");
        $displayh( out[0][7]," ", out[0][6]," ", out[0][5]," ", out[0][4]," ", out[0][3]," ", out[0][2]," ", out[0][1]," ", out[0][0], );
        $displayh( out[1][7]," ", out[1][6]," ", out[1][5]," ", out[1][4]," ", out[1][3]," ", out[1][2]," ", out[1][1]," ", out[1][0], );
        $displayh( out[2][7]," ", out[2][6]," ", out[2][5]," ", out[2][4]," ", out[2][3]," ", out[2][2]," ", out[2][1]," ", out[2][0], );
        $displayh( out[3][7]," ", out[3][6]," ", out[3][5]," ", out[3][4]," ", out[3][3]," ", out[3][2]," ", out[3][1]," ", out[3][0], );
        $displayh( out[4][7]," ", out[4][6]," ", out[4][5]," ", out[4][4]," ", out[4][3]," ", out[4][2]," ", out[4][1]," ", out[4][0], );
        $displayh( out[5][7]," ", out[5][6]," ", out[5][5]," ", out[5][4]," ", out[5][3]," ", out[5][2]," ", out[5][1]," ", out[5][0], );
        $displayh( out[6][7]," ", out[6][6]," ", out[6][5]," ", out[6][4]," ", out[6][3]," ", out[6][2]," ", out[6][1]," ", out[6][0], );
        $displayh( out[7][7]," ", out[7][6]," ", out[7][5]," ", out[7][4]," ", out[7][3]," ", out[7][2]," ", out[7][1]," ", out[7][0],"\n");
        $display("**************************************************************");
        $display("        **************************               ");
        $display("        *                        *       |\__||  ");
        $display("        *  Congratulations !!    *      / O.O  | ");
        $display("        *                        *    /_____   | ");
        $display("        *  Simulation PASS!!     *   /^ ^ ^ \\  |");
        $display("        *                        *  |^ ^ ^ ^ |w| ");
        $display("        **************************   \\m___m__|_|");
        $display("**************************************************************");
    end
end
//clk
always begin
    #(cycle/2) clk = !clk;
end

endmodule