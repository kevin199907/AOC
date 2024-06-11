module ROM(
  CK,
  CS,
  OE,
  A,
  DO
);

  parameter addr_size = 12;
  parameter mem_size  = (1 << addr_size);
  parameter  Bits     = 8;
  parameter  Bytes    = 4;

  input CK;
  input CS;
  input OE;
  input [addr_size-1:0] A;
  output reg [Bytes*Bits-1:0] DO;

  reg [Bits-1:0]       Memory_byte0 [mem_size-1:0];
  reg [Bits-1:0]       Memory_byte1 [mem_size-1:0];
  reg [Bits-1:0]       Memory_byte2 [mem_size-1:0];
  reg [Bits-1:0]       Memory_byte3 [mem_size-1:0];
  reg [Bytes*Bits-1:0] latched_DO;


  always@(posedge CK)
  begin
    if (CS)
    begin
      latched_DO[0*Bits+:Bits] <= Memory_byte0[A];
      latched_DO[1*Bits+:Bits] <= Memory_byte1[A];
      latched_DO[2*Bits+:Bits] <= Memory_byte2[A];
      latched_DO[3*Bits+:Bits] <= Memory_byte3[A];
    end
  end

  always@(*)
  begin
    DO = (OE)? latched_DO: {(Bytes*Bits){1'bz}};
  end
endmodule
