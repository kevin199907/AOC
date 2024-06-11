module INPUT_SRAM (A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,DO0,DO1,DO2,DO3,DO4,DO5,DO6,
                   DO7,DO8,DO9,DO10,DO11,DO12,DO13,DO14,DO15,
                   DO16,DO17,DO18,DO19,DO20,DO21,DO22,DO23,
                   DO24,DO25,DO26,DO27,DO28,DO29,DO30,DO31,
                   DO32,DO33,DO34,DO35,DO36,DO37,DO38,DO39,
                   DO40,DO41,DO42,DO43,DO44,DO45,DO46,DO47,
                   DO48,DO49,DO50,DO51,DO52,DO53,DO54,DO55,
                   DO56,DO57,DO58,DO59,DO60,DO61,DO62,DO63,
                   DO64,DO65,DO66,DO67,DO68,DO69,DO70,DO71,
                   DO72,DO73,DO74,DO75,DO76,DO77,DO78,DO79,
                   DO80,DO81,DO82,DO83,DO84,DO85,DO86,DO87,
                   DO88,DO89,DO90,DO91,DO92,DO93,DO94,DO95,
                   DO96,DO97,DO98,DO99,DO100,DO101,DO102,DO103,
                   DO104,DO105,DO106,DO107,DO108,DO109,DO110,
                   DO111,DO112,DO113,DO114,DO115,DO116,DO117,
                   DO118,DO119,DO120,DO121,DO122,DO123,DO124,
                   DO125,DO126,DO127,DI0,DI1,DI2,DI3,DI4,
                   DI5,DI6,DI7,DI8,DI9,DI10,DI11,DI12,DI13,DI14,
                   DI15,DI16,DI17,DI18,DI19,DI20,DI21,DI22,
                   DI23,DI24,DI25,DI26,DI27,DI28,DI29,DI30,
                   DI31,DI32,DI33,DI34,DI35,DI36,DI37,DI38,
                   DI39,DI40,DI41,DI42,DI43,DI44,DI45,DI46,
                   DI47,DI48,DI49,DI50,DI51,DI52,DI53,DI54,
                   DI55,DI56,DI57,DI58,DI59,DI60,DI61,DI62,
                   DI63,DI64,DI65,DI66,DI67,DI68,DI69,DI70,
                   DI71,DI72,DI73,DI74,DI75,DI76,DI77,DI78,
                   DI79,DI80,DI81,DI82,DI83,DI84,DI85,DI86,
                   DI87,DI88,DI89,DI90,DI91,DI92,DI93,DI94,
                   DI95,DI96,DI97,DI98,DI99,DI100,DI101,DI102,
                   DI103,DI104,DI105,DI106,DI107,DI108,DI109,
                   DI110,DI111,DI112,DI113,DI114,DI115,DI116,
                   DI117,DI118,DI119,DI120,DI121,DI122,DI123,
                   DI124,DI125,DI126,DI127,CK,WEB0,WEB1,
                   WEB2,WEB3,OE, CS);

  output     DO0,DO1,DO2,DO3,DO4,DO5,DO6,
             DO7,DO8,DO9,DO10,DO11,DO12,DO13,DO14,DO15,
             DO16,DO17,DO18,DO19,DO20,DO21,DO22,DO23,
             DO24,DO25,DO26,DO27,DO28,DO29,DO30,DO31,
             DO32,DO33,DO34,DO35,DO36,DO37,DO38,DO39,
             DO40,DO41,DO42,DO43,DO44,DO45,DO46,DO47,
             DO48,DO49,DO50,DO51,DO52,DO53,DO54,DO55,
             DO56,DO57,DO58,DO59,DO60,DO61,DO62,DO63,
             DO64,DO65,DO66,DO67,DO68,DO69,DO70,DO71,
             DO72,DO73,DO74,DO75,DO76,DO77,DO78,DO79,
             DO80,DO81,DO82,DO83,DO84,DO85,DO86,DO87,
             DO88,DO89,DO90,DO91,DO92,DO93,DO94,DO95,
             DO96,DO97,DO98,DO99,DO100,DO101,DO102,DO103,
             DO104,DO105,DO106,DO107,DO108,DO109,DO110,
             DO111,DO112,DO113,DO114,DO115,DO116,DO117,
             DO118,DO119,DO120,DO121,DO122,DO123,DO124,
             DO125,DO126,DO127;
  input      DI0,DI1,DI2,DI3,DI4,
             DI5,DI6,DI7,DI8,DI9,DI10,DI11,DI12,DI13,DI14,
             DI15,DI16,DI17,DI18,DI19,DI20,DI21,DI22,
             DI23,DI24,DI25,DI26,DI27,DI28,DI29,DI30,
             DI31,DI32,DI33,DI34,DI35,DI36,DI37,DI38,
             DI39,DI40,DI41,DI42,DI43,DI44,DI45,DI46,
             DI47,DI48,DI49,DI50,DI51,DI52,DI53,DI54,
             DI55,DI56,DI57,DI58,DI59,DI60,DI61,DI62,
             DI63,DI64,DI65,DI66,DI67,DI68,DI69,DI70,
             DI71,DI72,DI73,DI74,DI75,DI76,DI77,DI78,
             DI79,DI80,DI81,DI82,DI83,DI84,DI85,DI86,
             DI87,DI88,DI89,DI90,DI91,DI92,DI93,DI94,
             DI95,DI96,DI97,DI98,DI99,DI100,DI101,DI102,
             DI103,DI104,DI105,DI106,DI107,DI108,DI109,
             DI110,DI111,DI112,DI113,DI114,DI115,DI116,
             DI117,DI118,DI119,DI120,DI121,DI122,DI123,
             DI124,DI125,DI126,DI127;
  input      A0,A1,A2,A3,A4,A5,A6,A7,A8,A9;
  input      WEB0;                                    
  input      WEB1;                                    
  input      WEB2;                                    
  input      WEB3;                                    
  input      CK;                                      
  input      CS;                                      
  input      OE;                                      
  parameter  AddressSize          = 10;               
  parameter  Bits                 = 32;                
  parameter  Words                = 1024;            
  parameter  Bytes                = 4;                
  logic      [Bits-1:0]           Memory_byte0 [Words-1:0];     
  logic      [Bits-1:0]           Memory_byte1 [Words-1:0];     
  logic      [Bits-1:0]           Memory_byte2 [Words-1:0];     
  logic      [Bits-1:0]           Memory_byte3 [Words-1:0];     

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
  assign     DO10                  = DO[10];
  assign     DO11                  = DO[11];
  assign     DO12                  = DO[12];
  assign     DO13                  = DO[13];
  assign     DO14                  = DO[14];
  assign     DO15                  = DO[15];
  assign     DO16                  = DO[16];
  assign     DO17                  = DO[17];
  assign     DO18                  = DO[18];
  assign     DO19                  = DO[19];
  assign     DO20                  = DO[20];
  assign     DO21                  = DO[21];
  assign     DO22                  = DO[22];
  assign     DO23                  = DO[23];
  assign     DO24                  = DO[24];
  assign     DO25                  = DO[25];
  assign     DO26                  = DO[26];
  assign     DO27                  = DO[27];
  assign     DO28                  = DO[28];
  assign     DO29                  = DO[29];
  assign     DO30                  = DO[30];
  assign     DO31                  = DO[31];
  assign     DO32                  = DO[32];
  assign     DO33                  = DO[33];
  assign     DO34                  = DO[34];
  assign     DO35                  = DO[35];
  assign     DO36                  = DO[36];
  assign     DO37                  = DO[37];
  assign     DO38                  = DO[38];
  assign     DO39                  = DO[39];
  assign     DO40                  = DO[40];
  assign     DO41                  = DO[41];
  assign     DO42                  = DO[42];
  assign     DO43                  = DO[43];
  assign     DO44                  = DO[44];
  assign     DO45                  = DO[45];
  assign     DO46                  = DO[46];
  assign     DO47                  = DO[47];
  assign     DO48                  = DO[48];
  assign     DO49                  = DO[49];
  assign     DO50                  = DO[50];
  assign     DO51                  = DO[51];
  assign     DO52                  = DO[52];
  assign     DO53                  = DO[53];
  assign     DO54                  = DO[54];
  assign     DO55                  = DO[55];
  assign     DO56                  = DO[56];
  assign     DO57                  = DO[57];
  assign     DO58                  = DO[58];
  assign     DO59                  = DO[59];
  assign     DO60                  = DO[60];
  assign     DO61                  = DO[61];
  assign     DO62                  = DO[62];
  assign     DO63                  = DO[63];
  assign     DO64                  = DO[64];
  assign     DO65                  = DO[65];
  assign     DO66                  = DO[66];
  assign     DO67                  = DO[67];
  assign     DO68                  = DO[68];
  assign     DO69                  = DO[69];
  assign     DO70                  = DO[70];
  assign     DO71                  = DO[71];
  assign     DO72                  = DO[72];
  assign     DO73                  = DO[73];
  assign     DO74                  = DO[74];
  assign     DO75                  = DO[75];
  assign     DO76                  = DO[76];
  assign     DO77                  = DO[77];
  assign     DO78                  = DO[78];
  assign     DO79                  = DO[79];
  assign     DO80                  = DO[80];
  assign     DO81                  = DO[81];
  assign     DO82                  = DO[82];
  assign     DO83                  = DO[83];
  assign     DO84                  = DO[84];
  assign     DO85                  = DO[85];
  assign     DO86                  = DO[86];
  assign     DO87                  = DO[87];
  assign     DO88                  = DO[88];
  assign     DO89                  = DO[89];
  assign     DO90                  = DO[90];
  assign     DO91                  = DO[91];
  assign     DO92                  = DO[92];
  assign     DO93                  = DO[93];
  assign     DO94                  = DO[94];
  assign     DO95                  = DO[95];
  assign     DO96                  = DO[96];
  assign     DO97                  = DO[97];
  assign     DO98                  = DO[98];
  assign     DO99                  = DO[99];
  assign     DO100                  = DO[100];
  assign     DO101                  = DO[101];
  assign     DO102                  = DO[102];
  assign     DO103                  = DO[103];
  assign     DO104                  = DO[104];
  assign     DO105                  = DO[105];
  assign     DO106                  = DO[106];
  assign     DO107                  = DO[107];
  assign     DO108                  = DO[108];
  assign     DO109                  = DO[109];
  assign     DO110                  = DO[110];
  assign     DO111                  = DO[111];
  assign     DO112                  = DO[112];
  assign     DO113                  = DO[113];
  assign     DO114                  = DO[114];
  assign     DO115                  = DO[115];
  assign     DO116                  = DO[116];
  assign     DO117                  = DO[117];
  assign     DO118                  = DO[118];
  assign     DO119                  = DO[119];
  assign     DO120                  = DO[120];
  assign     DO121                  = DO[121];
  assign     DO122                  = DO[122];
  assign     DO123                  = DO[123];
  assign     DO124                  = DO[124];
  assign     DO125                  = DO[125];
  assign     DO126                  = DO[126];
  assign     DO127                  = DO[127];
  assign     DI[0]           =       DI0  ;
  assign     DI[1]           =       DI1  ;
  assign     DI[2]           =       DI2  ;
  assign     DI[3]           =       DI3  ;
  assign     DI[4]           =       DI4  ;
  assign     DI[5]           =       DI5  ;
  assign     DI[6]           =       DI6  ;
  assign     DI[7]           =       DI7  ;
  assign     DI[8]           =       DI8  ;
  assign     DI[9]           =       DI9  ;
  assign     DI[10]     =     DI10 ;
  assign     DI[11]     =     DI11 ;
  assign     DI[12]     =     DI12 ;
  assign     DI[13]     =     DI13 ;
  assign     DI[14]     =     DI14 ;
  assign     DI[15]     =     DI15 ;
  assign     DI[16]     =     DI16 ;
  assign     DI[17]     =     DI17 ;
  assign     DI[18]     =     DI18 ;
  assign     DI[19]     =     DI19 ;
  assign     DI[20]     =     DI20 ;
  assign     DI[21]     =     DI21 ;
  assign     DI[22]     =     DI22 ;
  assign     DI[23]     =     DI23 ;
  assign     DI[24]     =     DI24 ;
  assign     DI[25]     =     DI25 ;
  assign     DI[26]     =     DI26 ;
  assign     DI[27]     =     DI27 ;
  assign     DI[28]     =     DI28 ;
  assign     DI[29]     =     DI29 ;
  assign     DI[30]     =     DI30 ;
  assign     DI[31]     =     DI31 ;
  assign     DI[32]     =     DI32 ;
  assign     DI[33]     =     DI33 ;
  assign     DI[34]     =     DI34 ;
  assign     DI[35]     =     DI35 ;
  assign     DI[36]     =     DI36 ;
  assign     DI[37]     =     DI37 ;
  assign     DI[38]     =     DI38 ;
  assign     DI[39]     =     DI39 ;
  assign     DI[40]     =     DI40 ;
  assign     DI[41]     =     DI41 ;
  assign     DI[42]     =     DI42 ;
  assign     DI[43]     =     DI43 ;
  assign     DI[44]     =     DI44 ;
  assign     DI[45]     =     DI45 ;
  assign     DI[46]     =     DI46 ;
  assign     DI[47]     =     DI47 ;
  assign     DI[48]     =     DI48 ;
  assign     DI[49]     =     DI49 ;
  assign     DI[50]     =     DI50 ;
  assign     DI[51]     =     DI51 ;
  assign     DI[52]     =     DI52 ;
  assign     DI[53]     =     DI53 ;
  assign     DI[54]     =     DI54 ;
  assign     DI[55]     =     DI55 ;
  assign     DI[56]     =     DI56 ;
  assign     DI[57]     =     DI57 ;
  assign     DI[58]     =     DI58 ;
  assign     DI[59]     =     DI59 ;
  assign     DI[60]     =     DI60 ;
  assign     DI[61]     =     DI61 ;
  assign     DI[62]     =     DI62 ;
  assign     DI[63]     =     DI63 ;
  assign     DI[64]     =     DI64 ;
  assign     DI[65]     =     DI65 ;
  assign     DI[66]     =     DI66 ;
  assign     DI[67]     =     DI67 ;
  assign     DI[68]     =     DI68 ;
  assign     DI[69]     =     DI69 ;
  assign     DI[70]     =     DI70 ;
  assign     DI[71]     =     DI71 ;
  assign     DI[72]     =     DI72 ;
  assign     DI[73]     =     DI73 ;
  assign     DI[74]     =     DI74 ;
  assign     DI[75]     =     DI75 ;
  assign     DI[76]     =     DI76 ;
  assign     DI[77]     =     DI77 ;
  assign     DI[78]     =     DI78 ;
  assign     DI[79]     =     DI79 ;
  assign     DI[80]     =     DI80 ;
  assign     DI[81]     =     DI81 ;
  assign     DI[82]     =     DI82 ;
  assign     DI[83]     =     DI83 ;
  assign     DI[84]     =     DI84 ;
  assign     DI[85]     =     DI85 ;
  assign     DI[86]     =     DI86 ;
  assign     DI[87]     =     DI87 ;
  assign     DI[88]     =     DI88 ;
  assign     DI[89]     =     DI89 ;
  assign     DI[90]     =     DI90 ;
  assign     DI[91]     =     DI91 ;
  assign     DI[92]     =     DI92 ;
  assign     DI[93]     =     DI93 ;
  assign     DI[94]     =     DI94 ;
  assign     DI[95]     =     DI95 ;
  assign     DI[96]     =     DI96 ;
  assign     DI[97]     =     DI97 ;
  assign     DI[98]     =     DI98 ;
  assign     DI[99]     =     DI99 ;
  assign      DI[100]  =   DI100;  
  assign      DI[101]  =   DI101;  
  assign      DI[102]  =   DI102;  
  assign      DI[103]  =   DI103;  
  assign      DI[104]  =   DI104;  
  assign      DI[105]  =   DI105;  
  assign      DI[106]  =   DI106;  
  assign      DI[107]  =   DI107;  
  assign      DI[108]  =   DI108;  
  assign      DI[109]  =   DI109;  
  assign      DI[110]  =   DI110;  
  assign      DI[111]  =   DI111;  
  assign      DI[112]  =   DI112;  
  assign      DI[113]  =   DI113;  
  assign      DI[114]  =   DI114;  
  assign      DI[115]  =   DI115;  
  assign      DI[116]  =   DI116;  
  assign      DI[117]  =   DI117;  
  assign      DI[118]  =   DI118;  
  assign      DI[119]  =   DI119;  
  assign      DI[120]  =   DI120;  
  assign      DI[121]  =   DI121;  
  assign      DI[122]  =   DI122;  
  assign      DI[123]  =   DI123;  
  assign      DI[124]  =   DI124;  
  assign      DI[125]  =   DI125;  
  assign      DI[126]  =   DI126;  
  assign      DI[127]  =   DI127;  

  assign     A[0]                 = A0;
  assign     A[1]                 = A1;
  assign     A[2]                 = A2;
  assign     A[3]                 = A3;
  assign     A[4]                 = A4;
  assign     A[5]                 = A5;
  assign     A[6]                 = A6;
  assign     A[7]                 = A7;
  assign     A[8]                 = A8;
  assign     A[9]                 = A9;

  always/*_ff*/ @(posedge CK)
  begin
    if (CS)
    begin
      if (~WEB0)
      begin
        Memory_byte0[A] <= DI[0*Bits+:Bits];
        latched_DO[0*Bits+:Bits] <= DI[0*Bits+:Bits];
      end
      else
      begin
        latched_DO[0*Bits+:Bits] <= Memory_byte0[A];
      end
      if (~WEB1)
      begin
        Memory_byte1[A] <= DI[1*Bits+:Bits];
        latched_DO[1*Bits+:Bits] <= DI[1*Bits+:Bits];
      end
      else
      begin
        latched_DO[1*Bits+:Bits] <= Memory_byte1[A];
      end
      if (~WEB2)
      begin
        Memory_byte2[A] <= DI[2*Bits+:Bits];
        latched_DO[2*Bits+:Bits] <= DI[2*Bits+:Bits];
      end
      else
      begin
        latched_DO[2*Bits+:Bits] <= Memory_byte2[A];
      end
      if (~WEB3)
      begin
        Memory_byte3[A] <= DI[3*Bits+:Bits];
        latched_DO[3*Bits+:Bits] <= DI[3*Bits+:Bits];
      end
      else
      begin
        latched_DO[3*Bits+:Bits] <= Memory_byte3[A];
      end
    end
  end

  always_comb
  begin
    DO = (OE)? latched_DO: {(Bytes*Bits){1'bz}};
  end

endmodule
