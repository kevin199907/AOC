`timescale 1ns / 1ps
//
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/22 00:27:44
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//


module test;
parameter DATA_WIDTH = 32;
parameter FIFO_DEPTH = 32;
logic wr_en_r;
logic rd_en_r;
logic clk;
logic rst;
logic wr_en;
logic rd_en;
logic [DATA_WIDTH-1:0] wdata;
logic [DATA_WIDTH-1:0] rdata;
logic empty;
logic full;
logic error;
logic [DATA_WIDTH-1:0] ref_data;
logic data_valid;
//data_valid
always@(posedge clk,posedge rst)
if(rst)
   data_valid<=0;
else
   data_valid<=(rd_en&&~empty);
//ref_data
always@(posedge clk,posedge rst)
if(rst)
   ref_data<=0;
else if(data_valid)
   ref_data<=ref_data+1;
//error
assign error=(data_valid&&(ref_data!=rdata))?1'b1:1'b0;
//wr_en,rd_en
assign wr_en=(~full)?wr_en_r:1'b0;
assign rd_en=(~empty)?rd_en_r:1'b0;
//clk
initial begin
    clk=0;
    forever begin
        #5 clk=~clk;
    end
end
//rst
initial
begin
    rst=1;
    #20
    rst=0;
end
//wdata
always_ff@(posedge clk,posedge rst)
if(rst)
    wdata<=0;
else if(wr_en&&~full)                //每写入一个数据，加1
    wdata<=wdata+1;
//wr_en
always_ff@(posedge clk,posedge rst)
if(rst)
    wr_en_r<=0;
else if($random%100<60)               //有60%的几率写数据,衡量数据写入速率
    wr_en_r<=1'b1;
else
    wr_en_r<=1'b0;
//rd_en
always_ff@(posedge clk,posedge rst)
if(rst)
    rd_en_r<=0;
else if($random%100<40)                //有40%的几率读数据，衡量数据读出速率
    rd_en_r<=1'b1;
else 
    rd_en_r<=1'b0;
//inst
sync_fifo
#(
.DATA_WIDTH(32),
.FIFO_DEPTH(32)
)
U
(.*);
// input logic clk,
// input logic rst,
// input logic wr_en,
// input logic [DATA_WIDTH-1:0] wdata,
// input logic rd_en,
// output logic [DATA_WIDTH-1:0] rdata,
// output logic full,
// empty
endmodule



