`timescale	1ns/100ps
`include 	 "./RLE.sv"
`define PAT1 "./pat_rle1.pat"
`define GOLD1 "./gold_rle1.pat"
//`define PAT2 "./patt_rle2.pat"
//`define PAT3 "./patt_rle3.pat"

module tb_RLE();
//parameter
localparam N = 12;
localparam cycle = 10ns;
//top module port
reg              clk;
reg              rst;
reg              stall;
reg              start;
reg  [N-1:0]     in[7:0][7:0];
wire [N+3:0]     data_dc, data_ac;
wire             dc_done, done, last;
//testbench pattern
reg [N-1:0] pat1 [7:0][7:0];
reg [N+3:0] gold1 [18:0];
reg [7:0]   gold1_cnt = 8'd0;
//reg [N-1:0] pat2 [7:0][7:0];
//reg [N-1:0] pat3 [7:0][7:0];
//top module
RLE #(N) rle
(
    .clk        (clk    ),
    .rst        (rst    ),
    .start      (start  ),
    .stall      (stall  ),
    .rle_in     (in     ),
    .data_dc    (data_dc),
    .data_ac    (data_ac),
    .dc_done    (dc_done),
    .done       (done   ),
    .last       (last   )
);
//generate fsdb and read pattern file
initial begin
    $fsdbDumpfile("RLE.fsdb");
	$fsdbDumpvars;
    $fsdbDumpMDA();
    $readmemh(`PAT1, pat1);
    $readmemh(`GOLD1, gold1);
    //$readmemh(`PAT2, pat2);
    //$readmemh(`PAT2, pat2);
end
initial begin
    @(posedge start) begin
        $displayh("\n");
        $displayh("********************** simulation start *************************","\n");
        $displayh("**************************************************************");
        $displayh("*************************** input ****************************");
        $displayh( pat1[0][0]," ", pat1[0][1]," ", pat1[0][2]," ", pat1[0][3]," ", pat1[0][4]," ", pat1[0][5]," ", pat1[0][6]," ", pat1[0][7], );
        $displayh( pat1[1][0]," ", pat1[1][1]," ", pat1[1][2]," ", pat1[1][3]," ", pat1[1][4]," ", pat1[1][5]," ", pat1[1][6]," ", pat1[1][7], );
        $displayh( pat1[2][0]," ", pat1[2][1]," ", pat1[2][2]," ", pat1[2][3]," ", pat1[2][4]," ", pat1[2][5]," ", pat1[2][6]," ", pat1[2][7], );
        $displayh( pat1[3][0]," ", pat1[3][1]," ", pat1[3][2]," ", pat1[3][3]," ", pat1[3][4]," ", pat1[3][5]," ", pat1[3][6]," ", pat1[3][7], );
        $displayh( pat1[4][0]," ", pat1[4][1]," ", pat1[4][2]," ", pat1[4][3]," ", pat1[4][4]," ", pat1[4][5]," ", pat1[4][6]," ", pat1[4][7], );
        $displayh( pat1[5][0]," ", pat1[5][1]," ", pat1[5][2]," ", pat1[5][3]," ", pat1[5][4]," ", pat1[5][5]," ", pat1[5][6]," ", pat1[5][7], );
        $displayh( pat1[6][0]," ", pat1[6][1]," ", pat1[6][2]," ", pat1[6][3]," ", pat1[6][4]," ", pat1[6][5]," ", pat1[6][6]," ", pat1[6][7], );
        $displayh( pat1[7][0]," ", pat1[7][1]," ", pat1[7][2]," ", pat1[7][3]," ", pat1[7][4]," ", pat1[7][5]," ", pat1[7][6]," ", pat1[7][7], "\n");
        $displayh("**************************************************************");
        $displayh("*************************** output ***************************");
    end
end
always begin
    @(posedge clk) begin
    if (dc_done) begin
        if (data_dc==gold1[gold1_cnt]) $displayh("pass, ","dc out=",data_dc," ,expect=",gold1[gold1_cnt]);
        else $displayh("out=",data_dc," ,expect=",gold1[gold1_cnt]);
        gold1_cnt <= gold1_cnt + 8'd1;
    end
    else if (last) begin
        if (done) begin
            if (data_ac==gold1[gold1_cnt]) begin
                $displayh("pass, ","ac out=",data_ac," ,last"," ,expect=",gold1[gold1_cnt]," ,last","\n");
                $displayh("**************************************************************");
                $display("        **************************               ");
                $display("        *                        *       |\__||  ");
                $display("        *  Congratulations !!    *      / O.O  | ");
                $display("        *                        *    /_____   | ");
                $display("        *  Simulation PASS!!     *   /^ ^ ^ \\  |");
                $display("        *                        *  |^ ^ ^ ^ |w| ");
                $display("        **************************   \\m___m__|_|");
                $displayh("**************************************************************");
            end
            else $displayh("out=",data_ac," ,last"," ,expect=",gold1[gold1_cnt]," ,last");
            gold1_cnt <= gold1_cnt + 8'd1;
        end
    end
    else begin
        if (done) begin
            if (data_ac==gold1[gold1_cnt]) $displayh("pass, ","ac out=",data_ac," ,expect=",gold1[gold1_cnt]);
            else $displayh("out=",data_ac," ,expect=",gold1[gold1_cnt]);
            gold1_cnt <= gold1_cnt + 8'd1;
        end
    end
end
end  
//simulation
initial begin
    clk = 1'b0;
    rst = 1'b1;
    start = 1'b0;
    stall = 1'b0;
    #20;
    rst = 1'b0;
    start = 1'b1;
    for (int i=0; i<8; i++) begin
        for (int j=0; j<8; j++) begin
            in[i][j] = pat1[i][-j+7];
        end
    end
    #10 stall = 1'b1;
    #10 stall = 1'b0;
    #30 stall = 1'b1;
    #10 stall = 1'b0;
    #10 start = 1'b0;
    /*
    #700
    start = 1'b1;
    for (int k=0; k<8; k++) begin
        for (int l=0; l<8; l++) begin
            in[k][l] = pat2[k][-l+7];
        end
    end
    #10 start = 1'b0;
    #1000
    start = 1'b1;
    for (int m=0; m<8; m++) begin
        for (int n=0; n<8; n++) begin
            in[m][n] = pat3[m][-n+7];
        end
    end
    */
    #70 stall = 1'b1;
    #10 stall = 1'b0;
    //#10 start = 1'b0;
    #1000 $finish;
end
//clk
always begin
    #(cycle/2) clk = !clk;
end

endmodule