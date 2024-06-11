`timescale	1ns/1ns
`include 	 "./EPU_ALG.sv"
`define PAT1 "./pat1.pat"

module tb_EPU_ALG();
//parameter
localparam cycle = 10ns;
localparam block_num = 64;
//top module port
logic         clk;
logic         rst;
logic         start;
logic [127:0] data_read;
logic         read;
logic [11:0]  addr;
//pat
logic [127:0] pat1[(16*block_num-1):0];
//top modle
EPU_ALG #(block_num) epu_alg0
(
    .clk                (clk),
    .rst                (rst),
    .start              (start),
    .data_read          (data_read),
    .read               (read),
    .addr               (addr)
);
//generate fsdb and read pattern file
initial begin
    $fsdbDumpfile("EPU_ALG.fsdb");
	$fsdbDumpvars;
    $fsdbDumpMDA();
    $readmemh(`PAT1, pat1);
end
always begin
    @(posedge clk)
        data_read = (read)? pat1[addr] : 128'b0;
end
//sim
initial begin
    clk = 1'b0;
    rst = 1'b1;
    start = 1'b0;
    #20 rst = 1'b0;
    #100 start = 1'b1;
    #10 start = 1'b0;

    #600000 $finish;
end
//clk
always begin
    #(cycle/2) clk = !clk;
end


endmodule