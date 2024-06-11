module sync_fifo
#(parameter DATA_WIDTH=32,
  parameter FIFO_DEPTH=16)
(
input logic clk,
input logic rst,
input logic wr_en,
input logic [DATA_WIDTH-1:0] wdata,
input logic rd_en,
output logic [DATA_WIDTH-1:0] rdata,
output logic full,
output logic empty
    );
logic [$clog2(FIFO_DEPTH):0] data_count;              //当前FIFO中的数据个数
logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr;                  //指向下一个要写的地址
logic [$clog2(FIFO_DEPTH)-1:0] rd_ptr;                  //指向下一个要读的地址
//
logic [DATA_WIDTH-1:0] FIFO [0:FIFO_DEPTH-1];
//data_count
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        data_count<=0;
    else 
    begin
        case({wr_en,rd_en})
            2'b00:data_count<=data_count;
            2'b11:data_count<=data_count;
            2'b01:data_count<=data_count-1;
            2'b10:data_count<=data_count+1;            //所有情况都已经列出，无需default
        endcase
    end
end
//wr_ptr
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        wr_ptr<=0;                                    //复位时写指针为0
    else if(wr_en&&~full)                             //写使能信号有效且fifo未满
    if(wr_ptr==FIFO_DEPTH-1)
        wr_ptr<=0;
    else
        wr_ptr<=wr_ptr+1;
end
//rd_ptr
always_ff@(posedge clk or posedge rst)begin
    if(rst)
        rd_ptr<=0;
    else if(rd_en&&~empty)                            //写使能信号有效且FIFO非空
    if(rd_ptr==FIFO_DEPTH-1)
        rd_ptr<=0;
    else
        rd_ptr<=rd_ptr+1;
end
//flag
assign full=(data_count==FIFO_DEPTH)?1'b1:1'b0;
assign empty=(data_count==0)?1'b1:1'b0;
//write
always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        for (int i = 0; i < FIFO_DEPTH; i = i + 1) begin
            FIFO[i] <= 32'b0;  // Assuming FIFO elements are 8-bit wide
        end
    end
    else begin
    if(wr_en&&~full)
        FIFO[wr_ptr]<=wdata;
    end
end
//read
always_ff@(posedge clk or posedge rst)  begin        //rd_en拉高后的下一个周期读出
if(rst)
    rdata<=0;
else if(rd_en&&~empty)
    rdata<=FIFO[rd_ptr];
end
endmodule



