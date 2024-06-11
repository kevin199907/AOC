module tag_array (A0,A1,A2,A3,A4,A5,DO0,DO1,DO2,DO3,DO4,DO5,DO6,DO7,DO8,DO9,DO10,DO11,DO12,DO13,DO14,DO15,DO16,DO17,DO18,DO19,DO20,DO21,DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DI8,DI9,DI10,DI11,DI12,DI13,DI14,DI15,DI16,DI17,DI18,DI19,DI20,DI21,CK,WEB,OE,CS);
 
  output     DO0,DO1,DO2,DO3,DO4,DO5,DO6,DO7,DO8,
             DO9,DO10,DO11,DO12,DO13,DO14,DO15,DO16,DO17,DO18,DO19,DO20,DO21;
  input      DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DI8,
             DI9,DI10,DI11,DI12,DI13,DI14,DI15,DI16,DI17,DI18,DI19,DI20,DI21;
  input      A0,A1,A2,A3,A4,A5;
  input      WEB;                                     
  input      CK;                                      
  input      CS;                                      
  input      OE;                                      

	parameter  AddressSize          = 6;                
  parameter  Bits                 = 22;               
  parameter  Words                = 64;               
  parameter  Bytes                = 1;                
  
  logic      [Bits-1:0]           Memory [Words-1:0];    
  logic      [Bytes*Bits-1:0]     DI;                
  logic      [Bytes*Bits-1:0]     DO;                
  logic      [Bytes*Bits-1:0]     latched_DO;                
  logic      [AddressSize-1:0]    A;                 

  assign     DO0                  = DO[0];
  assign     DO1                  = DO[1];
  assign     DO2                  = DO[2];
  assign     DO3                  = DO[3];
  assign     DO4                  = DO[4];
  assign     DO5                  = DO[5];
  assign     DO6                  = DO[6];
  assign     DO7                  = DO[7];
  assign     DO8                  = DO[8];
  assign     DO9                  = DO[9];
  assign     DO10                 = DO[10];
  assign     DO11                 = DO[11];
  assign     DO12                 = DO[12];
  assign     DO13                 = DO[13];
  assign     DO14                 = DO[14];
  assign     DO15                 = DO[15];
  assign     DO16                 = DO[16];
  assign     DO17                 = DO[17];
  assign     DO18                 = DO[18];
  assign     DO19                 = DO[19];
  assign     DO20                 = DO[20];
  assign     DO21                 = DO[21];
 
  assign     DI[0]                = DI0;
  assign     DI[1]                = DI1;
  assign     DI[2]                = DI2;
  assign     DI[3]                = DI3;
  assign     DI[4]                = DI4;
  assign     DI[5]                = DI5;
  assign     DI[6]                = DI6;
  assign     DI[7]                = DI7;
  assign     DI[8]                = DI8;
  assign     DI[9]                = DI9;
  assign     DI[10]               = DI10;
  assign     DI[11]               = DI11;
  assign     DI[12]               = DI12;
  assign     DI[13]               = DI13;
  assign     DI[14]               = DI14;
  assign     DI[15]               = DI15;
  assign     DI[16]               = DI16;
  assign     DI[17]               = DI17;
  assign     DI[18]               = DI18;
  assign     DI[19]               = DI19;
  assign     DI[20]               = DI20;
  assign     DI[21]               = DI21;

  assign     A[0]                 = A0;
  assign     A[1]                 = A1;
  assign     A[2]                 = A2;
  assign     A[3]                 = A3;
  assign     A[4]                 = A4;
  assign     A[5]                 = A5;
 
  always_ff @(posedge CK)
  begin
    if (CS)
    begin
      if (~WEB)
      begin
        Memory[A] <= DI[0*Bits+:Bits];
        latched_DO[0*Bits+:Bits] <= DI[0*Bits+:Bits];
      end
      else
      begin
        latched_DO[0*Bits+:Bits] <= Memory[A];
      end
    end 
  end

  always_comb
  begin
    DO = (OE)? latched_DO: {(Bytes*Bits){1'bz}};
  end

endmodule
