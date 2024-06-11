`timescale 1ns/10ps
`define CYCLE 10
`include "DRAM.sv"

module test;

    parameter word_size = 32;       //Word Size
    parameter addr_size = 11;        //Address Size    
    logic CK;
    logic [word_size-1:0] Q;   //Data Output
    logic RST;
    logic CSn;                   //Chip Select
    logic [3:0] WEn;                  //Write Enable
    logic RASn;                  //Row Address Select
    logic CASn;                  //Column Address Select
    logic [addr_size-1:0] A;    //Address
    logic [word_size-1:0] D;    //Data Input
    logic VALID; //Output Data Valid

  DRAM M1 (
    .CK(CK),  
    .Q(Q),
    .RST(RST),
    .CSn(CSn),
    .WEn(WEn),
    .RASn(RASn),
    .CASn(CASn),
    .A(A),
    .D(D),
    .VALID(VALID)
  );

  always #(`CYCLE/2) CK = ~CK;  
  
  
  initial begin
    CK = 0;
    RST = 1;
    CSn = 0; WEn = 4'b1111;
    RASn = 1; CASn = 1;
    A = 0; D = 0;
    #(`CYCLE*2) RST = 0;
    #(`CYCLE*10) RASn = 0; A = 5; // Row Address
    #(`CYCLE) RASn = 1;
	#(`CYCLE*3);
    #(`CYCLE) CASn = 0; WEn = 4'b0000; A = 10; D = 10; // Column Address / Write
    #(`CYCLE) CASn = 1; WEn = 4'b1111;
	
	#(`CYCLE*3);
    #(`CYCLE) CASn = 0; WEn = 4'b0000; A = 11;	D = 11; // Column Address / Write
    #(`CYCLE) CASn = 1; WEn = 4'b1111;

	#(`CYCLE*6);
    #(`CYCLE) CASn = 0; A = 10; // Column Address / Read
	#(`CYCLE) CASn = 1;

	#(`CYCLE*3);
    #(`CYCLE) CASn = 0; A = 11; // Column Address / Read
	#(`CYCLE) CASn = 1;

	#(`CYCLE*10) RASn = 0; WEn = 4'b0000; A = 5; // Precharge
    #(`CYCLE) RASn = 1; WEn = 4'b1111;
	#(`CYCLE*3);
    #(`CYCLE) RASn = 0; A = 8; // Row Address
    #(`CYCLE) RASn = 1;
	#(`CYCLE*7);
    #(`CYCLE) CASn = 0; WEn = 4'b0000; A = 10; D = 12; // Column Address / Write
    #(`CYCLE) CASn = 1; WEn = 4'b1111;
	
	#(`CYCLE*3);
    #(`CYCLE) CASn = 0; WEn = 4'b0000; A = 11;	D = 13; // Column Address / Write
    #(`CYCLE) CASn = 1; WEn = 4'b1111;

	#(`CYCLE*10) RASn = 0; WEn = 4'b0000; A = 8; // Precharge
    #(`CYCLE) RASn = 1; WEn = 4'b1111;
	#(`CYCLE*3);
    #(`CYCLE) RASn = 0; A = 9; // Row Address
    #(`CYCLE) RASn = 1;
	#(`CYCLE*7);
    #(`CYCLE) CASn = 0; WEn = 4'b0000; A = 10; D = 14; // Column Address / Write
    #(`CYCLE) CASn = 1; WEn = 4'b1111;

	// -------- CL violation -------- //
	#(`CYCLE*10) RASn = 0; WEn = 4'b0000; A = 9; // Precharge
    #(`CYCLE) RASn = 1; WEn = 4'b1111;
	#(`CYCLE*3);
    #(`CYCLE) RASn = 0; A = 8; // Row Address
    #(`CYCLE) RASn = 1;
	#(`CYCLE*7);
    #(`CYCLE) CASn = 0; A = 10; // Column Address / Read
    #(`CYCLE) CASn = 1;
	
	#(`CYCLE*2);
    #(`CYCLE) CASn = 0; A = 11; // Column Address / Read
    #(`CYCLE) CASn = 1;

	// -------- tRCD violation -------- //
	#(`CYCLE*10) RASn = 0; WEn = 4'b0000; A = 8; // Precharge
    #(`CYCLE) RASn = 1; WEn = 4'b1111;
	#(`CYCLE*3);
    #(`CYCLE) RASn = 0; A = 9; // Row Address
    #(`CYCLE) RASn = 1;
	#(`CYCLE);
    #(`CYCLE) CASn = 0; A = 10; // Column Address / Read
    #(`CYCLE) CASn = 1;
	
	#(`CYCLE*3);
    #(`CYCLE) CASn = 0; A = 11; // Column Address / Read
    #(`CYCLE) CASn = 1;

	// -------- stable row addr violation -------- //
	#(`CYCLE*10) RASn = 0; WEn = 4'b0000; A = 8; // Precharge
    #(`CYCLE) RASn = 1; WEn = 4'b1111;
	#(`CYCLE*3);
    #(`CYCLE) RASn = 0; A = 9; // Row Address
    #(`CYCLE) RASn = 1;
	#(`CYCLE*3);
    #(`CYCLE) CASn = 0; A = 10; // Column Address / Read
    #(`CYCLE) CASn = 1;
	
	#(`CYCLE*3);
    #(`CYCLE) CASn = 0; A = 11; // Column Address / Read
    #(`CYCLE) CASn = 1;


		
	
    #(`CYCLE*30) $finish;
  end

  initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, test);
  end
endmodule
