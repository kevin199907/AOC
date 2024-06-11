`timescale	1ns/100ps
`include     "./H_FF.sv"
`include     "./FF_SRAM.sv"
`include     "./FIFO_shift.sv"
`include     "./H_encoder.sv"
`include     "./H_color_table.sv"
`include     "./H_light_table.sv"
`include     "./H_table.sv"

module tb_HFF();
//parameter
localparam cycle = 10ns;
//top module port
reg              clk;
reg              rst;
//testbench pattern
reg              dc_done, ac_done, last_in;
reg [15:0]       data_dc, data_ac;
wire             last_to_cpu;
wire[31:0]       TO_SRAM_DATA;
wire[11:0]       sram_addr;
wire[3:0]        WE;
wire             stall;

reg[31:0]        HFF_output[4:0];
reg[31:0]        golden[4:0];
integer i;
//top module
H_FF H_FF0(
    .clk(clk),
    .rst(rst),
    .last(last_in),
    .valid(ac_done),
    .DC_valid(dc_done),
    .af_RLC_data_AC({data_ac[15:12],data_ac[7:0]}),
    .af_RLC_data_DC(data_dc),
    .mode(2'b01),
    .TO_SRAM_DATA(TO_SRAM_DATA),
    .WE(WE),
    .sram_addr(sram_addr),
	.last_to_cpu(last_to_cpu),
    .we_FULL(stall )
);

//simulation
initial begin
    clk = 1'b0;rst = 1'b1;
    dc_done = 0;ac_done = 0;last_in=0;
    data_dc=16'b0; data_ac=16'b0;
    #20;
    rst  = 1'b0;
    #10 
    dc_done = 1; data_dc=16'h0fff;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 1; data_ac=16'h0070;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 1; data_ac=16'h2070;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 1; data_ac=16'hf000;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 1; data_ac=16'h00cc;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 1; data_ac=16'hf000;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 1; data_ac=16'h8022;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 1; data_ac=16'hf000;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 1; data_ac=16'h0011;
    last_in = 1;
    #10 
    dc_done = 0; data_dc=16'h0fff;
    ac_done = 0; data_ac=16'h0011;
    last_in = 0;
    #10000 
    result;
    $finish;
    
end
integer err;
task result;
    err = 0; // important ,don't edit it.
    $display("\n");
    for(i=0;i<5;i=i+1)begin
        if(golden[i] != HFF_output[i]) begin
            $display("HFF_output[%d] = %h, expect = %h", i, HFF_output[i], golden[i]);
            err = err + 1;
        end
        else begin
            $display("HFF_output[%d] = %h, pass ", i, HFF_output[i]);
        end
    end
    if(err==0)begin
        $display("\n");
        $display("        **************************               ");
        $display("        *                        *       |\\__|| ");
        $display("        *  Congratulations !!    *      / O.O  | ");
        $display("        *                        *    /_____   | ");
        $display("        *  Simulation PASS!!     *   /^ ^ ^ \\  |");
        $display("        *                        *  |^ ^ ^ ^ |w| ");
        $display("        **************************   \\m___m__|_|");
        $display("\n");
    end
    else if(err!=0)begin
        
        $display("        **************************               ");
        $display("        *                        *       |\__||  ");
        $display("        *  OOPS!!                *      / X,X  | ");
        $display("        *                        *    /_____   | ");
        $display("        *  Simulation Failed!!   *   /^ ^ ^ \\  |");
        $display("        *                        *  |^ ^ ^ ^ |w| ");
        $display("        **************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err); 
        $display("\n");
    end
endtask
initial begin
    $fsdbDumpfile("HFF.fsdb");
	$fsdbDumpvars;
    $fsdbDumpMDA();
end
initial begin
    while (1) begin
        #10
        if(rst) begin
            for(i=0;i<5;i=i+1) HFF_output[i] = 32'b0;
            golden[0] = 32'h4f8e_1ff1;
            golden[1] = 32'h7c3f_cf82;
            golden[2] = 32'hff00_cffd;
            golden[3] = 32'hcc5f_e751;
            golden[4] = 32'h0000_0000;
        end
        else if(WE == 0) HFF_output[sram_addr] = TO_SRAM_DATA;
        else if(last_to_cpu)  break;  
    end
end
//clk
always begin
    #(cycle/2) clk = !clk;
end

endmodule