`timescale 1ns/10ps
`define CYCLE 10
`include "ROM.v"

module test;

  parameter word_size = 32;
  parameter addr_size = 12;

  logic CK;
  logic CS;
  logic OE;
  logic [addr_size-1:0] A;
  logic [word_size-1:0] DO;


  ROM ROM1(
    .CK(CK),
    .CS(CS),
    .OE(OE),
    .A(A),
    .DO(DO)
  );

  always #(`CYCLE/2) CK = ~CK;

  initial begin
    for (int i=0; i<50; i++) begin
	ROM1.Memory_byte0[i] = i*1;
	ROM1.Memory_byte1[i] = i*2;
	ROM1.Memory_byte2[i] = i*3;
	ROM1.Memory_byte3[i] = i*4;
    end
    CK = 0;
    CS = 1; OE = 0;
    A = 0;
    #(`CYCLE*2) OE = 1;
    #(`CYCLE*2) A = 5;
    #(`CYCLE*2) A = 6;
    #(`CYCLE*2) $finish;
  end

  initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, test);
  end
endmodule
