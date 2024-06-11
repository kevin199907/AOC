/*******************************************************************************

             Synchronous High Speed Single Port SRAM Compiler 

                   UMC 0.18um GenericII Logic Process
   __________________________________________________________________________


       (C) Copyright 2002-2009 Faraday Technology Corp. All Rights Reserved.

     This source code is an unpublished work belongs to Faraday Technology
     Corp.  It is considered a trade secret and is not to be divulged or
     used by parties who have not received written authorization from
     Faraday Technology Corp.

     Faraday's home page can be found at:
     http://www.faraday-tech.com/
    
________________________________________________________________________________

      Module Name       :  INPUT_SRAM  
      Word              :  1024        
      Bit               :  32          
      Byte              :  4           
      Mux               :  1           
      Power Ring Type   :  port        
      Power Ring Width  :  2 (um)      
      Output Loading    :  0.01 (pf)   
      Input Data Slew   :  0.02 (ns)   
      Input Clock Slew  :  0.02 (ns)   

________________________________________________________________________________

      Library          : FSA0M_A
      Memaker          : 200901.2.1
      Date             : 2024/01/07 02:39:57

________________________________________________________________________________


   Notice on usage: Fixed delay or timing data are given in this model.
                    It supports SDF back-annotation, please generate SDF file
                    by EDA tools to get the accurate timing.

 |-----------------------------------------------------------------------------|

   Warning : If customer's design viloate the set-up time or hold time criteria 
   of synchronous SRAM, it's possible to hit the meta-stable point of 
   latch circuit in the decoder and cause the data loss in the memory bitcell.
   So please follow the memory IP's spec to design your product.

 |-----------------------------------------------------------------------------|

                Library          : FSA0M_A
                Memaker          : 200901.2.1
                Date             : 2024/01/07 02:39:57

 *******************************************************************************/

`resetall
`timescale 10ps/1ps


module INPUT_SRAM (A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,DO0,DO1,DO2,DO3,DO4,
                   DO5,DO6,DO7,DO8,DO9,DO10,DO11,DO12,DO13,DO14,
                   DO15,DO16,DO17,DO18,DO19,DO20,DO21,DO22,
                   DO23,DO24,DO25,DO26,DO27,DO28,DO29,DO30,
                   DO31,DO32,DO33,DO34,DO35,DO36,DO37,DO38,
                   DO39,DO40,DO41,DO42,DO43,DO44,DO45,DO46,
                   DO47,DO48,DO49,DO50,DO51,DO52,DO53,DO54,
                   DO55,DO56,DO57,DO58,DO59,DO60,DO61,DO62,
                   DO63,DO64,DO65,DO66,DO67,DO68,DO69,DO70,
                   DO71,DO72,DO73,DO74,DO75,DO76,DO77,DO78,
                   DO79,DO80,DO81,DO82,DO83,DO84,DO85,DO86,
                   DO87,DO88,DO89,DO90,DO91,DO92,DO93,DO94,
                   DO95,DO96,DO97,DO98,DO99,DO100,DO101,DO102,
                   DO103,DO104,DO105,DO106,DO107,DO108,DO109,
                   DO110,DO111,DO112,DO113,DO114,DO115,DO116,
                   DO117,DO118,DO119,DO120,DO121,DO122,DO123,
                   DO124,DO125,DO126,DO127,DI0,DI1,DI2,
                   DI3,DI4,DI5,DI6,DI7,DI8,DI9,DI10,DI11,DI12,
                   DI13,DI14,DI15,DI16,DI17,DI18,DI19,DI20,
                   DI21,DI22,DI23,DI24,DI25,DI26,DI27,DI28,
                   DI29,DI30,DI31,DI32,DI33,DI34,DI35,DI36,
                   DI37,DI38,DI39,DI40,DI41,DI42,DI43,DI44,
                   DI45,DI46,DI47,DI48,DI49,DI50,DI51,DI52,
                   DI53,DI54,DI55,DI56,DI57,DI58,DI59,DI60,
                   DI61,DI62,DI63,DI64,DI65,DI66,DI67,DI68,
                   DI69,DI70,DI71,DI72,DI73,DI74,DI75,DI76,
                   DI77,DI78,DI79,DI80,DI81,DI82,DI83,DI84,
                   DI85,DI86,DI87,DI88,DI89,DI90,DI91,DI92,
                   DI93,DI94,DI95,DI96,DI97,DI98,DI99,DI100,
                   DI101,DI102,DI103,DI104,DI105,DI106,DI107,
                   DI108,DI109,DI110,DI111,DI112,DI113,DI114,
                   DI115,DI116,DI117,DI118,DI119,DI120,DI121,
                   DI122,DI123,DI124,DI125,DI126,DI127,CK,WEB0,
                   WEB1,WEB2,WEB3,OE, CS);

  `define    TRUE                 (1'b1)              
  `define    FALSE                (1'b0)              

  parameter  SYN_CS               = `TRUE;            
  parameter  NO_SER_TOH           = `TRUE;            
  parameter  AddressSize          = 10;               
  parameter  Bits                 = 32;               
  parameter  Words                = 1024;             
  parameter  Bytes                = 4;                
  parameter  AspectRatio          = 1;                
  parameter  TOH                  = (89:129:213);     

  output     DO0,DO1,DO2,DO3,DO4,DO5,DO6,DO7,DO8,
             DO9,DO10,DO11,DO12,DO13,DO14,DO15,DO16,DO17,DO18,
             DO19,DO20,DO21,DO22,DO23,DO24,DO25,DO26,DO27,DO28,
             DO29,DO30,DO31,DO32,DO33,DO34,DO35,DO36,DO37,DO38,
             DO39,DO40,DO41,DO42,DO43,DO44,DO45,DO46,DO47,DO48,
             DO49,DO50,DO51,DO52,DO53,DO54,DO55,DO56,DO57,DO58,
             DO59,DO60,DO61,DO62,DO63,DO64,DO65,DO66,DO67,DO68,
             DO69,DO70,DO71,DO72,DO73,DO74,DO75,DO76,DO77,DO78,
             DO79,DO80,DO81,DO82,DO83,DO84,DO85,DO86,DO87,DO88,
             DO89,DO90,DO91,DO92,DO93,DO94,DO95,DO96,DO97,DO98,
             DO99,DO100,DO101,DO102,DO103,DO104,DO105,DO106,DO107,DO108,
             DO109,DO110,DO111,DO112,DO113,DO114,DO115,DO116,DO117,DO118,
             DO119,DO120,DO121,DO122,DO123,DO124,DO125,DO126,DO127;
  input      DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DI8,
             DI9,DI10,DI11,DI12,DI13,DI14,DI15,DI16,DI17,DI18,
             DI19,DI20,DI21,DI22,DI23,DI24,DI25,DI26,DI27,DI28,
             DI29,DI30,DI31,DI32,DI33,DI34,DI35,DI36,DI37,DI38,
             DI39,DI40,DI41,DI42,DI43,DI44,DI45,DI46,DI47,DI48,
             DI49,DI50,DI51,DI52,DI53,DI54,DI55,DI56,DI57,DI58,
             DI59,DI60,DI61,DI62,DI63,DI64,DI65,DI66,DI67,DI68,
             DI69,DI70,DI71,DI72,DI73,DI74,DI75,DI76,DI77,DI78,
             DI79,DI80,DI81,DI82,DI83,DI84,DI85,DI86,DI87,DI88,
             DI89,DI90,DI91,DI92,DI93,DI94,DI95,DI96,DI97,DI98,
             DI99,DI100,DI101,DI102,DI103,DI104,DI105,DI106,DI107,DI108,
             DI109,DI110,DI111,DI112,DI113,DI114,DI115,DI116,DI117,DI118,
             DI119,DI120,DI121,DI122,DI123,DI124,DI125,DI126,DI127;
  input      A0,A1,A2,A3,A4,A5,A6,A7,A8,
             A9;
  input      WEB0;                                    
  input      WEB1;                                    
  input      WEB2;                                    
  input      WEB3;                                    
  input      CK;                                      
  input      CS;                                      
  input      OE;                                      

`protect
  reg        [Bits-1:0]           Memory_byte0 [Words-1:0];     
  reg        [Bits-1:0]           Memory_byte1 [Words-1:0];     
  reg        [Bits-1:0]           Memory_byte2 [Words-1:0];     
  reg        [Bits-1:0]           Memory_byte3 [Words-1:0];     


  wire       [Bytes*Bits-1:0]     DO_;                
  wire       [AddressSize-1:0]    A_;                 
  wire                            OE_;                
  wire       [Bits-1:0]           DI_byte0_;          
  wire       [Bits-1:0]           DI_byte1_;          
  wire       [Bits-1:0]           DI_byte2_;          
  wire       [Bits-1:0]           DI_byte3_;          
  wire                            WEB0_;              
  wire                            WEB1_;              
  wire                            WEB2_;              
  wire                            WEB3_;              
  wire                            CK_;                
  wire                            CS_;                


  wire                            con_A;              
  wire                            con_DI_byte0;       
  wire                            con_DI_byte1;       
  wire                            con_DI_byte2;       
  wire                            con_DI_byte3;       
  wire                            con_CK;             
  wire                            con_WEB0;           
  wire                            con_WEB1;           
  wire                            con_WEB2;           
  wire                            con_WEB3;           

  reg        [AddressSize-1:0]    Latch_A;            
  reg        [Bits-1:0]           Latch_DI_byte0;     
  reg        [Bits-1:0]           Latch_DI_byte1;     
  reg        [Bits-1:0]           Latch_DI_byte2;     
  reg        [Bits-1:0]           Latch_DI_byte3;     
  reg                             Latch_WEB0;         
  reg                             Latch_WEB1;         
  reg                             Latch_WEB2;         
  reg                             Latch_WEB3;         
  reg                             Latch_CS;           


  reg        [AddressSize-1:0]    A_i;                
  reg        [Bits-1:0]           DI_byte0_i;         
  reg        [Bits-1:0]           DI_byte1_i;         
  reg        [Bits-1:0]           DI_byte2_i;         
  reg        [Bits-1:0]           DI_byte3_i;         
  reg                             WEB0_i;             
  reg                             WEB1_i;             
  reg                             WEB2_i;             
  reg                             WEB3_i;             
  reg                             CS_i;               

  reg                             n_flag_A0;          
  reg                             n_flag_A1;          
  reg                             n_flag_A2;          
  reg                             n_flag_A3;          
  reg                             n_flag_A4;          
  reg                             n_flag_A5;          
  reg                             n_flag_A6;          
  reg                             n_flag_A7;          
  reg                             n_flag_A8;          
  reg                             n_flag_A9;          
  reg                             n_flag_DI0;         
  reg                             n_flag_DI1;         
  reg                             n_flag_DI2;         
  reg                             n_flag_DI3;         
  reg                             n_flag_DI4;         
  reg                             n_flag_DI5;         
  reg                             n_flag_DI6;         
  reg                             n_flag_DI7;         
  reg                             n_flag_DI8;         
  reg                             n_flag_DI9;         
  reg                             n_flag_DI10;        
  reg                             n_flag_DI11;        
  reg                             n_flag_DI12;        
  reg                             n_flag_DI13;        
  reg                             n_flag_DI14;        
  reg                             n_flag_DI15;        
  reg                             n_flag_DI16;        
  reg                             n_flag_DI17;        
  reg                             n_flag_DI18;        
  reg                             n_flag_DI19;        
  reg                             n_flag_DI20;        
  reg                             n_flag_DI21;        
  reg                             n_flag_DI22;        
  reg                             n_flag_DI23;        
  reg                             n_flag_DI24;        
  reg                             n_flag_DI25;        
  reg                             n_flag_DI26;        
  reg                             n_flag_DI27;        
  reg                             n_flag_DI28;        
  reg                             n_flag_DI29;        
  reg                             n_flag_DI30;        
  reg                             n_flag_DI31;        
  reg                             n_flag_DI32;        
  reg                             n_flag_DI33;        
  reg                             n_flag_DI34;        
  reg                             n_flag_DI35;        
  reg                             n_flag_DI36;        
  reg                             n_flag_DI37;        
  reg                             n_flag_DI38;        
  reg                             n_flag_DI39;        
  reg                             n_flag_DI40;        
  reg                             n_flag_DI41;        
  reg                             n_flag_DI42;        
  reg                             n_flag_DI43;        
  reg                             n_flag_DI44;        
  reg                             n_flag_DI45;        
  reg                             n_flag_DI46;        
  reg                             n_flag_DI47;        
  reg                             n_flag_DI48;        
  reg                             n_flag_DI49;        
  reg                             n_flag_DI50;        
  reg                             n_flag_DI51;        
  reg                             n_flag_DI52;        
  reg                             n_flag_DI53;        
  reg                             n_flag_DI54;        
  reg                             n_flag_DI55;        
  reg                             n_flag_DI56;        
  reg                             n_flag_DI57;        
  reg                             n_flag_DI58;        
  reg                             n_flag_DI59;        
  reg                             n_flag_DI60;        
  reg                             n_flag_DI61;        
  reg                             n_flag_DI62;        
  reg                             n_flag_DI63;        
  reg                             n_flag_DI64;        
  reg                             n_flag_DI65;        
  reg                             n_flag_DI66;        
  reg                             n_flag_DI67;        
  reg                             n_flag_DI68;        
  reg                             n_flag_DI69;        
  reg                             n_flag_DI70;        
  reg                             n_flag_DI71;        
  reg                             n_flag_DI72;        
  reg                             n_flag_DI73;        
  reg                             n_flag_DI74;        
  reg                             n_flag_DI75;        
  reg                             n_flag_DI76;        
  reg                             n_flag_DI77;        
  reg                             n_flag_DI78;        
  reg                             n_flag_DI79;        
  reg                             n_flag_DI80;        
  reg                             n_flag_DI81;        
  reg                             n_flag_DI82;        
  reg                             n_flag_DI83;        
  reg                             n_flag_DI84;        
  reg                             n_flag_DI85;        
  reg                             n_flag_DI86;        
  reg                             n_flag_DI87;        
  reg                             n_flag_DI88;        
  reg                             n_flag_DI89;        
  reg                             n_flag_DI90;        
  reg                             n_flag_DI91;        
  reg                             n_flag_DI92;        
  reg                             n_flag_DI93;        
  reg                             n_flag_DI94;        
  reg                             n_flag_DI95;        
  reg                             n_flag_DI96;        
  reg                             n_flag_DI97;        
  reg                             n_flag_DI98;        
  reg                             n_flag_DI99;        
  reg                             n_flag_DI100;       
  reg                             n_flag_DI101;       
  reg                             n_flag_DI102;       
  reg                             n_flag_DI103;       
  reg                             n_flag_DI104;       
  reg                             n_flag_DI105;       
  reg                             n_flag_DI106;       
  reg                             n_flag_DI107;       
  reg                             n_flag_DI108;       
  reg                             n_flag_DI109;       
  reg                             n_flag_DI110;       
  reg                             n_flag_DI111;       
  reg                             n_flag_DI112;       
  reg                             n_flag_DI113;       
  reg                             n_flag_DI114;       
  reg                             n_flag_DI115;       
  reg                             n_flag_DI116;       
  reg                             n_flag_DI117;       
  reg                             n_flag_DI118;       
  reg                             n_flag_DI119;       
  reg                             n_flag_DI120;       
  reg                             n_flag_DI121;       
  reg                             n_flag_DI122;       
  reg                             n_flag_DI123;       
  reg                             n_flag_DI124;       
  reg                             n_flag_DI125;       
  reg                             n_flag_DI126;       
  reg                             n_flag_DI127;       
  reg                             n_flag_WEB0;        
  reg                             n_flag_WEB1;        
  reg                             n_flag_WEB2;        
  reg                             n_flag_WEB3;        
  reg                             n_flag_CS;          
  reg                             n_flag_CK_PER;      
  reg                             n_flag_CK_MINH;     
  reg                             n_flag_CK_MINL;     
  reg                             LAST_n_flag_WEB0;   
  reg                             LAST_n_flag_WEB1;   
  reg                             LAST_n_flag_WEB2;   
  reg                             LAST_n_flag_WEB3;   
  reg                             LAST_n_flag_CS;     
  reg                             LAST_n_flag_CK_PER; 
  reg                             LAST_n_flag_CK_MINH;
  reg                             LAST_n_flag_CK_MINL;
  reg        [AddressSize-1:0]    NOT_BUS_A;          
  reg        [AddressSize-1:0]    LAST_NOT_BUS_A;     
  reg        [Bits-1:0]           NOT_BUS_DI_byte0;   
  reg        [Bits-1:0]           LAST_NOT_BUS_DI_byte0;
  reg        [Bits-1:0]           NOT_BUS_DI_byte1;   
  reg        [Bits-1:0]           LAST_NOT_BUS_DI_byte1;
  reg        [Bits-1:0]           NOT_BUS_DI_byte2;   
  reg        [Bits-1:0]           LAST_NOT_BUS_DI_byte2;
  reg        [Bits-1:0]           NOT_BUS_DI_byte3;   
  reg        [Bits-1:0]           LAST_NOT_BUS_DI_byte3;

  reg        [AddressSize-1:0]    last_A;             
  reg        [AddressSize-1:0]    latch_last_A;       

  reg        [Bits-1:0]           last_DI_byte0;      
  reg        [Bits-1:0]           latch_last_DI_byte0;
  reg        [Bits-1:0]           last_DI_byte1;      
  reg        [Bits-1:0]           latch_last_DI_byte1;
  reg        [Bits-1:0]           last_DI_byte2;      
  reg        [Bits-1:0]           latch_last_DI_byte2;
  reg        [Bits-1:0]           last_DI_byte3;      
  reg        [Bits-1:0]           latch_last_DI_byte3;

  reg        [Bits-1:0]           DO_byte0_i;         
  reg        [Bits-1:0]           DO_byte1_i;         
  reg        [Bits-1:0]           DO_byte2_i;         
  reg        [Bits-1:0]           DO_byte3_i;         

  reg                             LastClkEdge;        

  reg                             flag_A_x;           
  reg                             flag_CS_x;          

  reg                             NODELAY0;           
  reg                             NODELAY1;           
  reg                             NODELAY2;           
  reg                             NODELAY3;           
  reg        [Bits-1:0]           DO_byte0_tmp;       
  event                           EventTOHDO_byte0;   
  reg        [Bits-1:0]           DO_byte1_tmp;       
  event                           EventTOHDO_byte1;   
  reg        [Bits-1:0]           DO_byte2_tmp;       
  event                           EventTOHDO_byte2;   
  reg        [Bits-1:0]           DO_byte3_tmp;       
  event                           EventTOHDO_byte3;   
  event                           EventNegCS;         

  assign     DO_                  = {DO_byte3_i,DO_byte2_i,DO_byte1_i,DO_byte0_i};
  assign     con_A                = CS_;
  assign     con_DI_byte0         = CS_ & (!WEB0_);
  assign     con_DI_byte1         = CS_ & (!WEB1_);
  assign     con_DI_byte2         = CS_ & (!WEB2_);
  assign     con_DI_byte3         = CS_ & (!WEB3_);
  assign     con_WEB0             = CS_;
  assign     con_WEB1             = CS_;
  assign     con_WEB2             = CS_;
  assign     con_WEB3             = CS_;
  assign     con_CK               = CS_;

  bufif1     ido0            (DO0, DO_[0], OE_);           
  bufif1     ido1            (DO1, DO_[1], OE_);           
  bufif1     ido2            (DO2, DO_[2], OE_);           
  bufif1     ido3            (DO3, DO_[3], OE_);           
  bufif1     ido4            (DO4, DO_[4], OE_);           
  bufif1     ido5            (DO5, DO_[5], OE_);           
  bufif1     ido6            (DO6, DO_[6], OE_);           
  bufif1     ido7            (DO7, DO_[7], OE_);           
  bufif1     ido8            (DO8, DO_[8], OE_);           
  bufif1     ido9            (DO9, DO_[9], OE_);           
  bufif1     ido10           (DO10, DO_[10], OE_);         
  bufif1     ido11           (DO11, DO_[11], OE_);         
  bufif1     ido12           (DO12, DO_[12], OE_);         
  bufif1     ido13           (DO13, DO_[13], OE_);         
  bufif1     ido14           (DO14, DO_[14], OE_);         
  bufif1     ido15           (DO15, DO_[15], OE_);         
  bufif1     ido16           (DO16, DO_[16], OE_);         
  bufif1     ido17           (DO17, DO_[17], OE_);         
  bufif1     ido18           (DO18, DO_[18], OE_);         
  bufif1     ido19           (DO19, DO_[19], OE_);         
  bufif1     ido20           (DO20, DO_[20], OE_);         
  bufif1     ido21           (DO21, DO_[21], OE_);         
  bufif1     ido22           (DO22, DO_[22], OE_);         
  bufif1     ido23           (DO23, DO_[23], OE_);         
  bufif1     ido24           (DO24, DO_[24], OE_);         
  bufif1     ido25           (DO25, DO_[25], OE_);         
  bufif1     ido26           (DO26, DO_[26], OE_);         
  bufif1     ido27           (DO27, DO_[27], OE_);         
  bufif1     ido28           (DO28, DO_[28], OE_);         
  bufif1     ido29           (DO29, DO_[29], OE_);         
  bufif1     ido30           (DO30, DO_[30], OE_);         
  bufif1     ido31           (DO31, DO_[31], OE_);         
  bufif1     ido32           (DO32, DO_[32], OE_);         
  bufif1     ido33           (DO33, DO_[33], OE_);         
  bufif1     ido34           (DO34, DO_[34], OE_);         
  bufif1     ido35           (DO35, DO_[35], OE_);         
  bufif1     ido36           (DO36, DO_[36], OE_);         
  bufif1     ido37           (DO37, DO_[37], OE_);         
  bufif1     ido38           (DO38, DO_[38], OE_);         
  bufif1     ido39           (DO39, DO_[39], OE_);         
  bufif1     ido40           (DO40, DO_[40], OE_);         
  bufif1     ido41           (DO41, DO_[41], OE_);         
  bufif1     ido42           (DO42, DO_[42], OE_);         
  bufif1     ido43           (DO43, DO_[43], OE_);         
  bufif1     ido44           (DO44, DO_[44], OE_);         
  bufif1     ido45           (DO45, DO_[45], OE_);         
  bufif1     ido46           (DO46, DO_[46], OE_);         
  bufif1     ido47           (DO47, DO_[47], OE_);         
  bufif1     ido48           (DO48, DO_[48], OE_);         
  bufif1     ido49           (DO49, DO_[49], OE_);         
  bufif1     ido50           (DO50, DO_[50], OE_);         
  bufif1     ido51           (DO51, DO_[51], OE_);         
  bufif1     ido52           (DO52, DO_[52], OE_);         
  bufif1     ido53           (DO53, DO_[53], OE_);         
  bufif1     ido54           (DO54, DO_[54], OE_);         
  bufif1     ido55           (DO55, DO_[55], OE_);         
  bufif1     ido56           (DO56, DO_[56], OE_);         
  bufif1     ido57           (DO57, DO_[57], OE_);         
  bufif1     ido58           (DO58, DO_[58], OE_);         
  bufif1     ido59           (DO59, DO_[59], OE_);         
  bufif1     ido60           (DO60, DO_[60], OE_);         
  bufif1     ido61           (DO61, DO_[61], OE_);         
  bufif1     ido62           (DO62, DO_[62], OE_);         
  bufif1     ido63           (DO63, DO_[63], OE_);         
  bufif1     ido64           (DO64, DO_[64], OE_);         
  bufif1     ido65           (DO65, DO_[65], OE_);         
  bufif1     ido66           (DO66, DO_[66], OE_);         
  bufif1     ido67           (DO67, DO_[67], OE_);         
  bufif1     ido68           (DO68, DO_[68], OE_);         
  bufif1     ido69           (DO69, DO_[69], OE_);         
  bufif1     ido70           (DO70, DO_[70], OE_);         
  bufif1     ido71           (DO71, DO_[71], OE_);         
  bufif1     ido72           (DO72, DO_[72], OE_);         
  bufif1     ido73           (DO73, DO_[73], OE_);         
  bufif1     ido74           (DO74, DO_[74], OE_);         
  bufif1     ido75           (DO75, DO_[75], OE_);         
  bufif1     ido76           (DO76, DO_[76], OE_);         
  bufif1     ido77           (DO77, DO_[77], OE_);         
  bufif1     ido78           (DO78, DO_[78], OE_);         
  bufif1     ido79           (DO79, DO_[79], OE_);         
  bufif1     ido80           (DO80, DO_[80], OE_);         
  bufif1     ido81           (DO81, DO_[81], OE_);         
  bufif1     ido82           (DO82, DO_[82], OE_);         
  bufif1     ido83           (DO83, DO_[83], OE_);         
  bufif1     ido84           (DO84, DO_[84], OE_);         
  bufif1     ido85           (DO85, DO_[85], OE_);         
  bufif1     ido86           (DO86, DO_[86], OE_);         
  bufif1     ido87           (DO87, DO_[87], OE_);         
  bufif1     ido88           (DO88, DO_[88], OE_);         
  bufif1     ido89           (DO89, DO_[89], OE_);         
  bufif1     ido90           (DO90, DO_[90], OE_);         
  bufif1     ido91           (DO91, DO_[91], OE_);         
  bufif1     ido92           (DO92, DO_[92], OE_);         
  bufif1     ido93           (DO93, DO_[93], OE_);         
  bufif1     ido94           (DO94, DO_[94], OE_);         
  bufif1     ido95           (DO95, DO_[95], OE_);         
  bufif1     ido96           (DO96, DO_[96], OE_);         
  bufif1     ido97           (DO97, DO_[97], OE_);         
  bufif1     ido98           (DO98, DO_[98], OE_);         
  bufif1     ido99           (DO99, DO_[99], OE_);         
  bufif1     ido100          (DO100, DO_[100], OE_);       
  bufif1     ido101          (DO101, DO_[101], OE_);       
  bufif1     ido102          (DO102, DO_[102], OE_);       
  bufif1     ido103          (DO103, DO_[103], OE_);       
  bufif1     ido104          (DO104, DO_[104], OE_);       
  bufif1     ido105          (DO105, DO_[105], OE_);       
  bufif1     ido106          (DO106, DO_[106], OE_);       
  bufif1     ido107          (DO107, DO_[107], OE_);       
  bufif1     ido108          (DO108, DO_[108], OE_);       
  bufif1     ido109          (DO109, DO_[109], OE_);       
  bufif1     ido110          (DO110, DO_[110], OE_);       
  bufif1     ido111          (DO111, DO_[111], OE_);       
  bufif1     ido112          (DO112, DO_[112], OE_);       
  bufif1     ido113          (DO113, DO_[113], OE_);       
  bufif1     ido114          (DO114, DO_[114], OE_);       
  bufif1     ido115          (DO115, DO_[115], OE_);       
  bufif1     ido116          (DO116, DO_[116], OE_);       
  bufif1     ido117          (DO117, DO_[117], OE_);       
  bufif1     ido118          (DO118, DO_[118], OE_);       
  bufif1     ido119          (DO119, DO_[119], OE_);       
  bufif1     ido120          (DO120, DO_[120], OE_);       
  bufif1     ido121          (DO121, DO_[121], OE_);       
  bufif1     ido122          (DO122, DO_[122], OE_);       
  bufif1     ido123          (DO123, DO_[123], OE_);       
  bufif1     ido124          (DO124, DO_[124], OE_);       
  bufif1     ido125          (DO125, DO_[125], OE_);       
  bufif1     ido126          (DO126, DO_[126], OE_);       
  bufif1     ido127          (DO127, DO_[127], OE_);       
  buf        ick0            (CK_, CK);                    
  buf        ia0             (A_[0], A0);                  
  buf        ia1             (A_[1], A1);                  
  buf        ia2             (A_[2], A2);                  
  buf        ia3             (A_[3], A3);                  
  buf        ia4             (A_[4], A4);                  
  buf        ia5             (A_[5], A5);                  
  buf        ia6             (A_[6], A6);                  
  buf        ia7             (A_[7], A7);                  
  buf        ia8             (A_[8], A8);                  
  buf        ia9             (A_[9], A9);                  
  buf        idi_byte0_0     (DI_byte0_[0], DI0);          
  buf        idi_byte0_1     (DI_byte0_[1], DI1);          
  buf        idi_byte0_2     (DI_byte0_[2], DI2);          
  buf        idi_byte0_3     (DI_byte0_[3], DI3);          
  buf        idi_byte0_4     (DI_byte0_[4], DI4);          
  buf        idi_byte0_5     (DI_byte0_[5], DI5);          
  buf        idi_byte0_6     (DI_byte0_[6], DI6);          
  buf        idi_byte0_7     (DI_byte0_[7], DI7);          
  buf        idi_byte0_8     (DI_byte0_[8], DI8);          
  buf        idi_byte0_9     (DI_byte0_[9], DI9);          
  buf        idi_byte0_10    (DI_byte0_[10], DI10);        
  buf        idi_byte0_11    (DI_byte0_[11], DI11);        
  buf        idi_byte0_12    (DI_byte0_[12], DI12);        
  buf        idi_byte0_13    (DI_byte0_[13], DI13);        
  buf        idi_byte0_14    (DI_byte0_[14], DI14);        
  buf        idi_byte0_15    (DI_byte0_[15], DI15);        
  buf        idi_byte0_16    (DI_byte0_[16], DI16);        
  buf        idi_byte0_17    (DI_byte0_[17], DI17);        
  buf        idi_byte0_18    (DI_byte0_[18], DI18);        
  buf        idi_byte0_19    (DI_byte0_[19], DI19);        
  buf        idi_byte0_20    (DI_byte0_[20], DI20);        
  buf        idi_byte0_21    (DI_byte0_[21], DI21);        
  buf        idi_byte0_22    (DI_byte0_[22], DI22);        
  buf        idi_byte0_23    (DI_byte0_[23], DI23);        
  buf        idi_byte0_24    (DI_byte0_[24], DI24);        
  buf        idi_byte0_25    (DI_byte0_[25], DI25);        
  buf        idi_byte0_26    (DI_byte0_[26], DI26);        
  buf        idi_byte0_27    (DI_byte0_[27], DI27);        
  buf        idi_byte0_28    (DI_byte0_[28], DI28);        
  buf        idi_byte0_29    (DI_byte0_[29], DI29);        
  buf        idi_byte0_30    (DI_byte0_[30], DI30);        
  buf        idi_byte0_31    (DI_byte0_[31], DI31);        
  buf        idi_byte1_0     (DI_byte1_[0], DI32);         
  buf        idi_byte1_1     (DI_byte1_[1], DI33);         
  buf        idi_byte1_2     (DI_byte1_[2], DI34);         
  buf        idi_byte1_3     (DI_byte1_[3], DI35);         
  buf        idi_byte1_4     (DI_byte1_[4], DI36);         
  buf        idi_byte1_5     (DI_byte1_[5], DI37);         
  buf        idi_byte1_6     (DI_byte1_[6], DI38);         
  buf        idi_byte1_7     (DI_byte1_[7], DI39);         
  buf        idi_byte1_8     (DI_byte1_[8], DI40);         
  buf        idi_byte1_9     (DI_byte1_[9], DI41);         
  buf        idi_byte1_10    (DI_byte1_[10], DI42);        
  buf        idi_byte1_11    (DI_byte1_[11], DI43);        
  buf        idi_byte1_12    (DI_byte1_[12], DI44);        
  buf        idi_byte1_13    (DI_byte1_[13], DI45);        
  buf        idi_byte1_14    (DI_byte1_[14], DI46);        
  buf        idi_byte1_15    (DI_byte1_[15], DI47);        
  buf        idi_byte1_16    (DI_byte1_[16], DI48);        
  buf        idi_byte1_17    (DI_byte1_[17], DI49);        
  buf        idi_byte1_18    (DI_byte1_[18], DI50);        
  buf        idi_byte1_19    (DI_byte1_[19], DI51);        
  buf        idi_byte1_20    (DI_byte1_[20], DI52);        
  buf        idi_byte1_21    (DI_byte1_[21], DI53);        
  buf        idi_byte1_22    (DI_byte1_[22], DI54);        
  buf        idi_byte1_23    (DI_byte1_[23], DI55);        
  buf        idi_byte1_24    (DI_byte1_[24], DI56);        
  buf        idi_byte1_25    (DI_byte1_[25], DI57);        
  buf        idi_byte1_26    (DI_byte1_[26], DI58);        
  buf        idi_byte1_27    (DI_byte1_[27], DI59);        
  buf        idi_byte1_28    (DI_byte1_[28], DI60);        
  buf        idi_byte1_29    (DI_byte1_[29], DI61);        
  buf        idi_byte1_30    (DI_byte1_[30], DI62);        
  buf        idi_byte1_31    (DI_byte1_[31], DI63);        
  buf        idi_byte2_0     (DI_byte2_[0], DI64);         
  buf        idi_byte2_1     (DI_byte2_[1], DI65);         
  buf        idi_byte2_2     (DI_byte2_[2], DI66);         
  buf        idi_byte2_3     (DI_byte2_[3], DI67);         
  buf        idi_byte2_4     (DI_byte2_[4], DI68);         
  buf        idi_byte2_5     (DI_byte2_[5], DI69);         
  buf        idi_byte2_6     (DI_byte2_[6], DI70);         
  buf        idi_byte2_7     (DI_byte2_[7], DI71);         
  buf        idi_byte2_8     (DI_byte2_[8], DI72);         
  buf        idi_byte2_9     (DI_byte2_[9], DI73);         
  buf        idi_byte2_10    (DI_byte2_[10], DI74);        
  buf        idi_byte2_11    (DI_byte2_[11], DI75);        
  buf        idi_byte2_12    (DI_byte2_[12], DI76);        
  buf        idi_byte2_13    (DI_byte2_[13], DI77);        
  buf        idi_byte2_14    (DI_byte2_[14], DI78);        
  buf        idi_byte2_15    (DI_byte2_[15], DI79);        
  buf        idi_byte2_16    (DI_byte2_[16], DI80);        
  buf        idi_byte2_17    (DI_byte2_[17], DI81);        
  buf        idi_byte2_18    (DI_byte2_[18], DI82);        
  buf        idi_byte2_19    (DI_byte2_[19], DI83);        
  buf        idi_byte2_20    (DI_byte2_[20], DI84);        
  buf        idi_byte2_21    (DI_byte2_[21], DI85);        
  buf        idi_byte2_22    (DI_byte2_[22], DI86);        
  buf        idi_byte2_23    (DI_byte2_[23], DI87);        
  buf        idi_byte2_24    (DI_byte2_[24], DI88);        
  buf        idi_byte2_25    (DI_byte2_[25], DI89);        
  buf        idi_byte2_26    (DI_byte2_[26], DI90);        
  buf        idi_byte2_27    (DI_byte2_[27], DI91);        
  buf        idi_byte2_28    (DI_byte2_[28], DI92);        
  buf        idi_byte2_29    (DI_byte2_[29], DI93);        
  buf        idi_byte2_30    (DI_byte2_[30], DI94);        
  buf        idi_byte2_31    (DI_byte2_[31], DI95);        
  buf        idi_byte3_0     (DI_byte3_[0], DI96);         
  buf        idi_byte3_1     (DI_byte3_[1], DI97);         
  buf        idi_byte3_2     (DI_byte3_[2], DI98);         
  buf        idi_byte3_3     (DI_byte3_[3], DI99);         
  buf        idi_byte3_4     (DI_byte3_[4], DI100);        
  buf        idi_byte3_5     (DI_byte3_[5], DI101);        
  buf        idi_byte3_6     (DI_byte3_[6], DI102);        
  buf        idi_byte3_7     (DI_byte3_[7], DI103);        
  buf        idi_byte3_8     (DI_byte3_[8], DI104);        
  buf        idi_byte3_9     (DI_byte3_[9], DI105);        
  buf        idi_byte3_10    (DI_byte3_[10], DI106);       
  buf        idi_byte3_11    (DI_byte3_[11], DI107);       
  buf        idi_byte3_12    (DI_byte3_[12], DI108);       
  buf        idi_byte3_13    (DI_byte3_[13], DI109);       
  buf        idi_byte3_14    (DI_byte3_[14], DI110);       
  buf        idi_byte3_15    (DI_byte3_[15], DI111);       
  buf        idi_byte3_16    (DI_byte3_[16], DI112);       
  buf        idi_byte3_17    (DI_byte3_[17], DI113);       
  buf        idi_byte3_18    (DI_byte3_[18], DI114);       
  buf        idi_byte3_19    (DI_byte3_[19], DI115);       
  buf        idi_byte3_20    (DI_byte3_[20], DI116);       
  buf        idi_byte3_21    (DI_byte3_[21], DI117);       
  buf        idi_byte3_22    (DI_byte3_[22], DI118);       
  buf        idi_byte3_23    (DI_byte3_[23], DI119);       
  buf        idi_byte3_24    (DI_byte3_[24], DI120);       
  buf        idi_byte3_25    (DI_byte3_[25], DI121);       
  buf        idi_byte3_26    (DI_byte3_[26], DI122);       
  buf        idi_byte3_27    (DI_byte3_[27], DI123);       
  buf        idi_byte3_28    (DI_byte3_[28], DI124);       
  buf        idi_byte3_29    (DI_byte3_[29], DI125);       
  buf        idi_byte3_30    (DI_byte3_[30], DI126);       
  buf        idi_byte3_31    (DI_byte3_[31], DI127);       
  buf        ics0            (CS_, CS);                    
  buf        ioe0            (OE_, OE);                    
  buf        iweb0           (WEB0_, WEB0);                
  buf        iweb1           (WEB1_, WEB1);                
  buf        iweb2           (WEB2_, WEB2);                
  buf        iweb3           (WEB3_, WEB3);                

  initial begin
    $timeformat (-12, 0, " ps", 20);
    flag_A_x = `FALSE;
    NODELAY0 = 1'b0;
    NODELAY1 = 1'b0;
    NODELAY2 = 1'b0;
    NODELAY3 = 1'b0;
  end

  always @(negedge CS_) begin
    if (SYN_CS == `FALSE) begin
       ->EventNegCS;
    end
  end
  always @(posedge CS_) begin
    if (SYN_CS == `FALSE) begin
       disable NegCS;
    end
  end

  always @(CK_) begin
    casez ({LastClkEdge,CK_})
      2'b01:
         begin
           last_A = latch_last_A;
           last_DI_byte0 = latch_last_DI_byte0;
           last_DI_byte1 = latch_last_DI_byte1;
           last_DI_byte2 = latch_last_DI_byte2;
           last_DI_byte3 = latch_last_DI_byte3;
           CS_monitor;
           pre_latch_data;
           memory_function;
           latch_last_A = A_;
           latch_last_DI_byte0 = DI_byte0_;
           latch_last_DI_byte1 = DI_byte1_;
           latch_last_DI_byte2 = DI_byte2_;
           latch_last_DI_byte3 = DI_byte3_;
         end
      2'b?x:
         begin
           ErrorMessage(0);
           if (CS_ !== 0) begin
              if (WEB0_ !== 1'b1) begin
                 all_core_x(0,1);
              end else begin
                 #0 disable TOHDO_byte0;
                 NODELAY0 = 1'b1;
                 DO_byte0_i = {Bits{1'bX}};
              end
              if (WEB1_ !== 1'b1) begin
                 all_core_x(1,1);
              end else begin
                 #0 disable TOHDO_byte1;
                 NODELAY1 = 1'b1;
                 DO_byte1_i = {Bits{1'bX}};
              end
              if (WEB2_ !== 1'b1) begin
                 all_core_x(2,1);
              end else begin
                 #0 disable TOHDO_byte2;
                 NODELAY2 = 1'b1;
                 DO_byte2_i = {Bits{1'bX}};
              end
              if (WEB3_ !== 1'b1) begin
                 all_core_x(3,1);
              end else begin
                 #0 disable TOHDO_byte3;
                 NODELAY3 = 1'b1;
                 DO_byte3_i = {Bits{1'bX}};
              end
           end
         end
    endcase
    LastClkEdge = CK_;
  end

  always @(
           n_flag_A0 or
           n_flag_A1 or
           n_flag_A2 or
           n_flag_A3 or
           n_flag_A4 or
           n_flag_A5 or
           n_flag_A6 or
           n_flag_A7 or
           n_flag_A8 or
           n_flag_A9 or
           n_flag_DI0 or
           n_flag_DI1 or
           n_flag_DI2 or
           n_flag_DI3 or
           n_flag_DI4 or
           n_flag_DI5 or
           n_flag_DI6 or
           n_flag_DI7 or
           n_flag_DI8 or
           n_flag_DI9 or
           n_flag_DI10 or
           n_flag_DI11 or
           n_flag_DI12 or
           n_flag_DI13 or
           n_flag_DI14 or
           n_flag_DI15 or
           n_flag_DI16 or
           n_flag_DI17 or
           n_flag_DI18 or
           n_flag_DI19 or
           n_flag_DI20 or
           n_flag_DI21 or
           n_flag_DI22 or
           n_flag_DI23 or
           n_flag_DI24 or
           n_flag_DI25 or
           n_flag_DI26 or
           n_flag_DI27 or
           n_flag_DI28 or
           n_flag_DI29 or
           n_flag_DI30 or
           n_flag_DI31 or
           n_flag_DI32 or
           n_flag_DI33 or
           n_flag_DI34 or
           n_flag_DI35 or
           n_flag_DI36 or
           n_flag_DI37 or
           n_flag_DI38 or
           n_flag_DI39 or
           n_flag_DI40 or
           n_flag_DI41 or
           n_flag_DI42 or
           n_flag_DI43 or
           n_flag_DI44 or
           n_flag_DI45 or
           n_flag_DI46 or
           n_flag_DI47 or
           n_flag_DI48 or
           n_flag_DI49 or
           n_flag_DI50 or
           n_flag_DI51 or
           n_flag_DI52 or
           n_flag_DI53 or
           n_flag_DI54 or
           n_flag_DI55 or
           n_flag_DI56 or
           n_flag_DI57 or
           n_flag_DI58 or
           n_flag_DI59 or
           n_flag_DI60 or
           n_flag_DI61 or
           n_flag_DI62 or
           n_flag_DI63 or
           n_flag_DI64 or
           n_flag_DI65 or
           n_flag_DI66 or
           n_flag_DI67 or
           n_flag_DI68 or
           n_flag_DI69 or
           n_flag_DI70 or
           n_flag_DI71 or
           n_flag_DI72 or
           n_flag_DI73 or
           n_flag_DI74 or
           n_flag_DI75 or
           n_flag_DI76 or
           n_flag_DI77 or
           n_flag_DI78 or
           n_flag_DI79 or
           n_flag_DI80 or
           n_flag_DI81 or
           n_flag_DI82 or
           n_flag_DI83 or
           n_flag_DI84 or
           n_flag_DI85 or
           n_flag_DI86 or
           n_flag_DI87 or
           n_flag_DI88 or
           n_flag_DI89 or
           n_flag_DI90 or
           n_flag_DI91 or
           n_flag_DI92 or
           n_flag_DI93 or
           n_flag_DI94 or
           n_flag_DI95 or
           n_flag_DI96 or
           n_flag_DI97 or
           n_flag_DI98 or
           n_flag_DI99 or
           n_flag_DI100 or
           n_flag_DI101 or
           n_flag_DI102 or
           n_flag_DI103 or
           n_flag_DI104 or
           n_flag_DI105 or
           n_flag_DI106 or
           n_flag_DI107 or
           n_flag_DI108 or
           n_flag_DI109 or
           n_flag_DI110 or
           n_flag_DI111 or
           n_flag_DI112 or
           n_flag_DI113 or
           n_flag_DI114 or
           n_flag_DI115 or
           n_flag_DI116 or
           n_flag_DI117 or
           n_flag_DI118 or
           n_flag_DI119 or
           n_flag_DI120 or
           n_flag_DI121 or
           n_flag_DI122 or
           n_flag_DI123 or
           n_flag_DI124 or
           n_flag_DI125 or
           n_flag_DI126 or
           n_flag_DI127 or
           n_flag_WEB0 or
           n_flag_WEB1 or
           n_flag_WEB2 or
           n_flag_WEB3 or
           n_flag_CS or
           n_flag_CK_PER or
           n_flag_CK_MINH or
           n_flag_CK_MINL 
          )
     begin
       timingcheck_violation;
     end


  always @(EventTOHDO_byte0) 
    begin:TOHDO_byte0 
      #TOH 
      NODELAY0 <= 1'b0; 
      DO_byte0_i              =  {Bits{1'bX}}; 
      DO_byte0_i              <= DO_byte0_tmp; 
  end 

  always @(EventTOHDO_byte1) 
    begin:TOHDO_byte1 
      #TOH 
      NODELAY1 <= 1'b0; 
      DO_byte1_i              =  {Bits{1'bX}}; 
      DO_byte1_i              <= DO_byte1_tmp; 
  end 

  always @(EventTOHDO_byte2) 
    begin:TOHDO_byte2 
      #TOH 
      NODELAY2 <= 1'b0; 
      DO_byte2_i              =  {Bits{1'bX}}; 
      DO_byte2_i              <= DO_byte2_tmp; 
  end 

  always @(EventTOHDO_byte3) 
    begin:TOHDO_byte3 
      #TOH 
      NODELAY3 <= 1'b0; 
      DO_byte3_i              =  {Bits{1'bX}}; 
      DO_byte3_i              <= DO_byte3_tmp; 
  end 

  always @(EventNegCS) 
    begin:NegCS
      #TOH 
      disable TOHDO_byte0;
      NODELAY0 = 1'b0; 
      DO_byte0_i              =  {Bits{1'bX}}; 
      disable TOHDO_byte1;
      NODELAY1 = 1'b0; 
      DO_byte1_i              =  {Bits{1'bX}}; 
      disable TOHDO_byte2;
      NODELAY2 = 1'b0; 
      DO_byte2_i              =  {Bits{1'bX}}; 
      disable TOHDO_byte3;
      NODELAY3 = 1'b0; 
      DO_byte3_i              =  {Bits{1'bX}}; 
  end 

  task timingcheck_violation;
    integer i;
    begin
      if ((n_flag_CK_PER  !== LAST_n_flag_CK_PER)  ||
          (n_flag_CK_MINH !== LAST_n_flag_CK_MINH) ||
          (n_flag_CK_MINL !== LAST_n_flag_CK_MINL)) begin
          if (CS_ !== 1'b0) begin
             if (WEB0_ !== 1'b1) begin
                all_core_x(0,1);
             end
             else begin
                #0 disable TOHDO_byte0;
                NODELAY0 = 1'b1;
                DO_byte0_i = {Bits{1'bX}};
             end
             if (WEB1_ !== 1'b1) begin
                all_core_x(1,1);
             end
             else begin
                #0 disable TOHDO_byte1;
                NODELAY1 = 1'b1;
                DO_byte1_i = {Bits{1'bX}};
             end
             if (WEB2_ !== 1'b1) begin
                all_core_x(2,1);
             end
             else begin
                #0 disable TOHDO_byte2;
                NODELAY2 = 1'b1;
                DO_byte2_i = {Bits{1'bX}};
             end
             if (WEB3_ !== 1'b1) begin
                all_core_x(3,1);
             end
             else begin
                #0 disable TOHDO_byte3;
                NODELAY3 = 1'b1;
                DO_byte3_i = {Bits{1'bX}};
             end
          end
      end
      else begin
          NOT_BUS_A  = {
                         n_flag_A9,
                         n_flag_A8,
                         n_flag_A7,
                         n_flag_A6,
                         n_flag_A5,
                         n_flag_A4,
                         n_flag_A3,
                         n_flag_A2,
                         n_flag_A1,
                         n_flag_A0};

          NOT_BUS_DI_byte0  = {
                         n_flag_DI31,
                         n_flag_DI30,
                         n_flag_DI29,
                         n_flag_DI28,
                         n_flag_DI27,
                         n_flag_DI26,
                         n_flag_DI25,
                         n_flag_DI24,
                         n_flag_DI23,
                         n_flag_DI22,
                         n_flag_DI21,
                         n_flag_DI20,
                         n_flag_DI19,
                         n_flag_DI18,
                         n_flag_DI17,
                         n_flag_DI16,
                         n_flag_DI15,
                         n_flag_DI14,
                         n_flag_DI13,
                         n_flag_DI12,
                         n_flag_DI11,
                         n_flag_DI10,
                         n_flag_DI9,
                         n_flag_DI8,
                         n_flag_DI7,
                         n_flag_DI6,
                         n_flag_DI5,
                         n_flag_DI4,
                         n_flag_DI3,
                         n_flag_DI2,
                         n_flag_DI1,
                         n_flag_DI0};

          NOT_BUS_DI_byte1  = {
                         n_flag_DI63,
                         n_flag_DI62,
                         n_flag_DI61,
                         n_flag_DI60,
                         n_flag_DI59,
                         n_flag_DI58,
                         n_flag_DI57,
                         n_flag_DI56,
                         n_flag_DI55,
                         n_flag_DI54,
                         n_flag_DI53,
                         n_flag_DI52,
                         n_flag_DI51,
                         n_flag_DI50,
                         n_flag_DI49,
                         n_flag_DI48,
                         n_flag_DI47,
                         n_flag_DI46,
                         n_flag_DI45,
                         n_flag_DI44,
                         n_flag_DI43,
                         n_flag_DI42,
                         n_flag_DI41,
                         n_flag_DI40,
                         n_flag_DI39,
                         n_flag_DI38,
                         n_flag_DI37,
                         n_flag_DI36,
                         n_flag_DI35,
                         n_flag_DI34,
                         n_flag_DI33,
                         n_flag_DI32};

          NOT_BUS_DI_byte2  = {
                         n_flag_DI95,
                         n_flag_DI94,
                         n_flag_DI93,
                         n_flag_DI92,
                         n_flag_DI91,
                         n_flag_DI90,
                         n_flag_DI89,
                         n_flag_DI88,
                         n_flag_DI87,
                         n_flag_DI86,
                         n_flag_DI85,
                         n_flag_DI84,
                         n_flag_DI83,
                         n_flag_DI82,
                         n_flag_DI81,
                         n_flag_DI80,
                         n_flag_DI79,
                         n_flag_DI78,
                         n_flag_DI77,
                         n_flag_DI76,
                         n_flag_DI75,
                         n_flag_DI74,
                         n_flag_DI73,
                         n_flag_DI72,
                         n_flag_DI71,
                         n_flag_DI70,
                         n_flag_DI69,
                         n_flag_DI68,
                         n_flag_DI67,
                         n_flag_DI66,
                         n_flag_DI65,
                         n_flag_DI64};

          NOT_BUS_DI_byte3  = {
                         n_flag_DI127,
                         n_flag_DI126,
                         n_flag_DI125,
                         n_flag_DI124,
                         n_flag_DI123,
                         n_flag_DI122,
                         n_flag_DI121,
                         n_flag_DI120,
                         n_flag_DI119,
                         n_flag_DI118,
                         n_flag_DI117,
                         n_flag_DI116,
                         n_flag_DI115,
                         n_flag_DI114,
                         n_flag_DI113,
                         n_flag_DI112,
                         n_flag_DI111,
                         n_flag_DI110,
                         n_flag_DI109,
                         n_flag_DI108,
                         n_flag_DI107,
                         n_flag_DI106,
                         n_flag_DI105,
                         n_flag_DI104,
                         n_flag_DI103,
                         n_flag_DI102,
                         n_flag_DI101,
                         n_flag_DI100,
                         n_flag_DI99,
                         n_flag_DI98,
                         n_flag_DI97,
                         n_flag_DI96};

          for (i=0; i<AddressSize; i=i+1) begin
             Latch_A[i] = (NOT_BUS_A[i] !== LAST_NOT_BUS_A[i]) ? 1'bx : Latch_A[i];
          end
          for (i=0; i<Bits; i=i+1) begin
             Latch_DI_byte0[i] = (NOT_BUS_DI_byte0[i] !== LAST_NOT_BUS_DI_byte0[i]) ? 1'bx : Latch_DI_byte0[i];
             Latch_DI_byte1[i] = (NOT_BUS_DI_byte1[i] !== LAST_NOT_BUS_DI_byte1[i]) ? 1'bx : Latch_DI_byte1[i];
             Latch_DI_byte2[i] = (NOT_BUS_DI_byte2[i] !== LAST_NOT_BUS_DI_byte2[i]) ? 1'bx : Latch_DI_byte2[i];
             Latch_DI_byte3[i] = (NOT_BUS_DI_byte3[i] !== LAST_NOT_BUS_DI_byte3[i]) ? 1'bx : Latch_DI_byte3[i];
          end
          Latch_CS  =  (n_flag_CS  !== LAST_n_flag_CS)  ? 1'bx : Latch_CS;
          Latch_WEB0 = (n_flag_WEB0 !== LAST_n_flag_WEB0)  ? 1'bx : Latch_WEB0;
          Latch_WEB1 = (n_flag_WEB1 !== LAST_n_flag_WEB1)  ? 1'bx : Latch_WEB1;
          Latch_WEB2 = (n_flag_WEB2 !== LAST_n_flag_WEB2)  ? 1'bx : Latch_WEB2;
          Latch_WEB3 = (n_flag_WEB3 !== LAST_n_flag_WEB3)  ? 1'bx : Latch_WEB3;
          memory_function;
      end

      LAST_NOT_BUS_A                 = NOT_BUS_A;
      LAST_NOT_BUS_DI_byte0          = NOT_BUS_DI_byte0;
      LAST_NOT_BUS_DI_byte1          = NOT_BUS_DI_byte1;
      LAST_NOT_BUS_DI_byte2          = NOT_BUS_DI_byte2;
      LAST_NOT_BUS_DI_byte3          = NOT_BUS_DI_byte3;
      LAST_n_flag_WEB0               = n_flag_WEB0;
      LAST_n_flag_WEB1               = n_flag_WEB1;
      LAST_n_flag_WEB2               = n_flag_WEB2;
      LAST_n_flag_WEB3               = n_flag_WEB3;
      LAST_n_flag_CS                 = n_flag_CS;
      LAST_n_flag_CK_PER             = n_flag_CK_PER;
      LAST_n_flag_CK_MINH            = n_flag_CK_MINH;
      LAST_n_flag_CK_MINL            = n_flag_CK_MINL;
    end
  endtask // end timingcheck_violation;

  task pre_latch_data;
    begin
      Latch_A                        = A_;
      Latch_DI_byte0                 = DI_byte0_;
      Latch_DI_byte1                 = DI_byte1_;
      Latch_DI_byte2                 = DI_byte2_;
      Latch_DI_byte3                 = DI_byte3_;
      Latch_WEB0                     = WEB0_;
      Latch_WEB1                     = WEB1_;
      Latch_WEB2                     = WEB2_;
      Latch_WEB3                     = WEB3_;
      Latch_CS                       = CS_;
    end
  endtask //end pre_latch_data
  task memory_function;
    begin
      A_i                            = Latch_A;
      DI_byte0_i                     = Latch_DI_byte0;
      DI_byte1_i                     = Latch_DI_byte1;
      DI_byte2_i                     = Latch_DI_byte2;
      DI_byte3_i                     = Latch_DI_byte3;
      WEB0_i                         = Latch_WEB0;
      WEB1_i                         = Latch_WEB1;
      WEB2_i                         = Latch_WEB2;
      WEB3_i                         = Latch_WEB3;
      CS_i                           = Latch_CS;

      if (CS_ == 1'b1) A_monitor;


      casez({WEB0_i,CS_i})
        2'b11: begin
           if (AddressRangeCheck(A_i)) begin
             if (NO_SER_TOH == `TRUE) begin
               if (A_i !== last_A) begin
                 DO_byte0_tmp = Memory_byte0[A_i];
                 NODELAY0 = 1'b1;
                 ->EventTOHDO_byte0;
               end else begin
                 NODELAY0 = 1'b0;
                 DO_byte0_tmp = Memory_byte0[A_i];
                 DO_byte0_i = DO_byte0_tmp;
               end
             end else begin
                DO_byte0_tmp = Memory_byte0[A_i];
                NODELAY0 = 1'b1;
                ->EventTOHDO_byte0;
             end
           end
           else begin
                #0 disable TOHDO_byte0;
                NODELAY0 = 1'b1;
                DO_byte0_i = {Bits{1'bX}};
           end
           end
        2'b01: begin
           if (AddressRangeCheck(A_i)) begin
                Memory_byte0[A_i] = DI_byte0_i;
                NODELAY0 = 1'b1;
                DO_byte0_tmp = Memory_byte0[A_i];
                if (NO_SER_TOH == `TRUE) begin
                  if (A_i !== last_A) begin
                     NODELAY0 = 1'b1;
                     ->EventTOHDO_byte0;
                  end else begin
                    if (DI_byte0_i !== last_DI_byte0) begin
                       NODELAY0 = 1'b1;
                       ->EventTOHDO_byte0;
                    end else begin
                      NODELAY0 = 1'b0;
                      DO_byte0_i = DO_byte0_tmp;
                    end
                  end
                end else begin
                  NODELAY0 = 1'b1;
                  ->EventTOHDO_byte0;
                end
           end else begin
                all_core_x(0,1);
           end
        end
        2'b1x: begin
           #0 disable TOHDO_byte0;
           NODELAY0 = 1'b1;
           DO_byte0_i = {Bits{1'bX}};
        end
        2'b0x,
        2'bx1,
        2'bxx: begin
           if (AddressRangeCheck(A_i)) begin
                Memory_byte0[A_i] = {Bits{1'bX}};
                #0 disable TOHDO_byte0;
                NODELAY0 = 1'b1;
                DO_byte0_i = {Bits{1'bX}};
           end else begin
                all_core_x(0,1);
           end
        end
      endcase

      casez({WEB1_i,CS_i})
        2'b11: begin
           if (AddressRangeCheck(A_i)) begin
             if (NO_SER_TOH == `TRUE) begin
               if (A_i !== last_A) begin
                 DO_byte1_tmp = Memory_byte1[A_i];
                 NODELAY1 = 1'b1;
                 ->EventTOHDO_byte1;
               end else begin
                 NODELAY1 = 1'b0;
                 DO_byte1_tmp = Memory_byte1[A_i];
                 DO_byte1_i = DO_byte1_tmp;
               end
             end else begin
                DO_byte1_tmp = Memory_byte1[A_i];
                NODELAY1 = 1'b1;
                ->EventTOHDO_byte1;
             end
           end
           else begin
                #0 disable TOHDO_byte1;
                NODELAY1 = 1'b1;
                DO_byte1_i = {Bits{1'bX}};
           end
           end
        2'b01: begin
           if (AddressRangeCheck(A_i)) begin
                Memory_byte1[A_i] = DI_byte1_i;
                NODELAY1 = 1'b1;
                DO_byte1_tmp = Memory_byte1[A_i];
                if (NO_SER_TOH == `TRUE) begin
                  if (A_i !== last_A) begin
                     NODELAY1 = 1'b1;
                     ->EventTOHDO_byte1;
                  end else begin
                    if (DI_byte1_i !== last_DI_byte1) begin
                       NODELAY1 = 1'b1;
                       ->EventTOHDO_byte1;
                    end else begin
                      NODELAY1 = 1'b0;
                      DO_byte1_i = DO_byte1_tmp;
                    end
                  end
                end else begin
                  NODELAY1 = 1'b1;
                  ->EventTOHDO_byte1;
                end
           end else begin
                all_core_x(1,1);
           end
        end
        2'b1x: begin
           #0 disable TOHDO_byte1;
           NODELAY1 = 1'b1;
           DO_byte1_i = {Bits{1'bX}};
        end
        2'b0x,
        2'bx1,
        2'bxx: begin
           if (AddressRangeCheck(A_i)) begin
                Memory_byte1[A_i] = {Bits{1'bX}};
                #0 disable TOHDO_byte1;
                NODELAY1 = 1'b1;
                DO_byte1_i = {Bits{1'bX}};
           end else begin
                all_core_x(1,1);
           end
        end
      endcase

      casez({WEB2_i,CS_i})
        2'b11: begin
           if (AddressRangeCheck(A_i)) begin
             if (NO_SER_TOH == `TRUE) begin
               if (A_i !== last_A) begin
                 DO_byte2_tmp = Memory_byte2[A_i];
                 NODELAY2 = 1'b1;
                 ->EventTOHDO_byte2;
               end else begin
                 NODELAY2 = 1'b0;
                 DO_byte2_tmp = Memory_byte2[A_i];
                 DO_byte2_i = DO_byte2_tmp;
               end
             end else begin
                DO_byte2_tmp = Memory_byte2[A_i];
                NODELAY2 = 1'b1;
                ->EventTOHDO_byte2;
             end
           end
           else begin
                #0 disable TOHDO_byte2;
                NODELAY2 = 1'b1;
                DO_byte2_i = {Bits{1'bX}};
           end
           end
        2'b01: begin
           if (AddressRangeCheck(A_i)) begin
                Memory_byte2[A_i] = DI_byte2_i;
                NODELAY2 = 1'b1;
                DO_byte2_tmp = Memory_byte2[A_i];
                if (NO_SER_TOH == `TRUE) begin
                  if (A_i !== last_A) begin
                     NODELAY2 = 1'b1;
                     ->EventTOHDO_byte2;
                  end else begin
                    if (DI_byte2_i !== last_DI_byte2) begin
                       NODELAY2 = 1'b1;
                       ->EventTOHDO_byte2;
                    end else begin
                      NODELAY2 = 1'b0;
                      DO_byte2_i = DO_byte2_tmp;
                    end
                  end
                end else begin
                  NODELAY2 = 1'b1;
                  ->EventTOHDO_byte2;
                end
           end else begin
                all_core_x(2,1);
           end
        end
        2'b1x: begin
           #0 disable TOHDO_byte2;
           NODELAY2 = 1'b1;
           DO_byte2_i = {Bits{1'bX}};
        end
        2'b0x,
        2'bx1,
        2'bxx: begin
           if (AddressRangeCheck(A_i)) begin
                Memory_byte2[A_i] = {Bits{1'bX}};
                #0 disable TOHDO_byte2;
                NODELAY2 = 1'b1;
                DO_byte2_i = {Bits{1'bX}};
           end else begin
                all_core_x(2,1);
           end
        end
      endcase

      casez({WEB3_i,CS_i})
        2'b11: begin
           if (AddressRangeCheck(A_i)) begin
             if (NO_SER_TOH == `TRUE) begin
               if (A_i !== last_A) begin
                 DO_byte3_tmp = Memory_byte3[A_i];
                 NODELAY3 = 1'b1;
                 ->EventTOHDO_byte3;
               end else begin
                 NODELAY3 = 1'b0;
                 DO_byte3_tmp = Memory_byte3[A_i];
                 DO_byte3_i = DO_byte3_tmp;
               end
             end else begin
                DO_byte3_tmp = Memory_byte3[A_i];
                NODELAY3 = 1'b1;
                ->EventTOHDO_byte3;
             end
           end
           else begin
                #0 disable TOHDO_byte3;
                NODELAY3 = 1'b1;
                DO_byte3_i = {Bits{1'bX}};
           end
           end
        2'b01: begin
           if (AddressRangeCheck(A_i)) begin
                Memory_byte3[A_i] = DI_byte3_i;
                NODELAY3 = 1'b1;
                DO_byte3_tmp = Memory_byte3[A_i];
                if (NO_SER_TOH == `TRUE) begin
                  if (A_i !== last_A) begin
                     NODELAY3 = 1'b1;
                     ->EventTOHDO_byte3;
                  end else begin
                    if (DI_byte3_i !== last_DI_byte3) begin
                       NODELAY3 = 1'b1;
                       ->EventTOHDO_byte3;
                    end else begin
                      NODELAY3 = 1'b0;
                      DO_byte3_i = DO_byte3_tmp;
                    end
                  end
                end else begin
                  NODELAY3 = 1'b1;
                  ->EventTOHDO_byte3;
                end
           end else begin
                all_core_x(3,1);
           end
        end
        2'b1x: begin
           #0 disable TOHDO_byte3;
           NODELAY3 = 1'b1;
           DO_byte3_i = {Bits{1'bX}};
        end
        2'b0x,
        2'bx1,
        2'bxx: begin
           if (AddressRangeCheck(A_i)) begin
                Memory_byte3[A_i] = {Bits{1'bX}};
                #0 disable TOHDO_byte3;
                NODELAY3 = 1'b1;
                DO_byte3_i = {Bits{1'bX}};
           end else begin
                all_core_x(3,1);
           end
        end
      endcase
  end
  endtask //memory_function;

  task all_core_x;
     input byte_num;
     input do_x;

     integer byte_num;
     integer do_x;
     integer LoopCount_Address;
     begin
       LoopCount_Address=Words-1;
       while(LoopCount_Address >=0) begin
          case (byte_num)
             0       : begin
                         Memory_byte0[LoopCount_Address]={Bits{1'bX}};
                         if (do_x == 1) begin
                            #0 disable TOHDO_byte0;
                            NODELAY0 = 1'b1;
                            DO_byte0_i = {Bits{1'bX}};
                         end
                       end
             1       : begin
                         Memory_byte1[LoopCount_Address]={Bits{1'bX}};
                         if (do_x == 1) begin
                            #0 disable TOHDO_byte1;
                            NODELAY1 = 1'b1;
                            DO_byte1_i = {Bits{1'bX}};
                         end
                       end
             2       : begin
                         Memory_byte2[LoopCount_Address]={Bits{1'bX}};
                         if (do_x == 1) begin
                            #0 disable TOHDO_byte2;
                            NODELAY2 = 1'b1;
                            DO_byte2_i = {Bits{1'bX}};
                         end
                       end
             3       : begin
                         Memory_byte3[LoopCount_Address]={Bits{1'bX}};
                         if (do_x == 1) begin
                            #0 disable TOHDO_byte3;
                            NODELAY3 = 1'b1;
                            DO_byte3_i = {Bits{1'bX}};
                         end
                       end
             default : begin
                         Memory_byte0[LoopCount_Address]={Bits{1'bX}};
                         if (do_x == 1) begin
                            #0 disable TOHDO_byte0;
                            NODELAY0 = 1'b1;
                            DO_byte0_i = {Bits{1'bX}};
                         end
                         Memory_byte1[LoopCount_Address]={Bits{1'bX}};
                         if (do_x == 1) begin
                            #0 disable TOHDO_byte1;
                            NODELAY1 = 1'b1;
                            DO_byte1_i = {Bits{1'bX}};
                         end
                         Memory_byte2[LoopCount_Address]={Bits{1'bX}};
                         if (do_x == 1) begin
                            #0 disable TOHDO_byte2;
                            NODELAY2 = 1'b1;
                            DO_byte2_i = {Bits{1'bX}};
                         end
                         Memory_byte3[LoopCount_Address]={Bits{1'bX}};
                         if (do_x == 1) begin
                            #0 disable TOHDO_byte3;
                            NODELAY3 = 1'b1;
                            DO_byte3_i = {Bits{1'bX}};
                         end
                       end
         endcase
         LoopCount_Address=LoopCount_Address-1;
      end
    end
  endtask //end all_core_x;

  task A_monitor;
     begin
       if (^(A_) !== 1'bX) begin
          flag_A_x = `FALSE;
       end
       else begin
          if (flag_A_x == `FALSE) begin
              flag_A_x = `TRUE;
              ErrorMessage(2);
          end
       end
     end
  endtask //end A_monitor;

  task CS_monitor;
     begin
       if (^(CS_) !== 1'bX) begin
          flag_CS_x = `FALSE;
       end
       else begin
          if (flag_CS_x == `FALSE) begin
              flag_CS_x = `TRUE;
              ErrorMessage(3);
          end
       end
     end
  endtask //end CS_monitor;

  task ErrorMessage;
     input error_type;
     integer error_type;

     begin
       case (error_type)
         0: $display("** MEM_Error: Abnormal transition occurred (%t) in Clock of %m",$time);
         1: $display("** MEM_Error: Read and Write the same Address, DO is unknown (%t) in clock of %m",$time);
         2: $display("** MEM_Error: Unknown value occurred (%t) in Address of %m",$time);
         3: $display("** MEM_Error: Unknown value occurred (%t) in ChipSelect of %m",$time);
         4: $display("** MEM_Error: Port A and B write the same Address, core is unknown (%t) in clock of %m",$time);
         5: $display("** MEM_Error: Clear all memory core to unknown (%t) in clock of %m",$time);
       endcase
     end
  endtask

  function AddressRangeCheck;
      input  [AddressSize-1:0] AddressItem;
      reg    UnaryResult;
      begin
        UnaryResult = ^AddressItem;
        if(UnaryResult!==1'bX) begin
           if (AddressItem >= Words) begin
              $display("** MEM_Error: Out of range occurred (%t) in Address of %m",$time);
              AddressRangeCheck = `FALSE;
           end else begin
              AddressRangeCheck = `TRUE;
           end
        end
        else begin
           AddressRangeCheck = `FALSE;
        end
      end
  endfunction //end AddressRangeCheck;

   specify
      specparam TAA  = (163:228:364);
      specparam TWDV = (122:171:273);
      specparam TRC  = (183:259:414);
      specparam THPW = (25:36:59);
      specparam TLPW = (25:36:59);
      specparam TAS  = (32:52:94);
      specparam TAH  = (10:11:16);
      specparam TWS  = (13:25:48);
      specparam TWH  = (10:10:10);
      specparam TDS  = (32:50:85);
      specparam TDH  = (10:10:10);
      specparam TCSS = (41:65:118);
      specparam TCSH = (9:14:23);
      specparam TOE      = (34:48:78);
      specparam TOZ      = (45:62:95);

      $setuphold ( posedge CK &&& con_A,          posedge A0, TAS,     TAH,     n_flag_A0      );
      $setuphold ( posedge CK &&& con_A,          negedge A0, TAS,     TAH,     n_flag_A0      );
      $setuphold ( posedge CK &&& con_A,          posedge A1, TAS,     TAH,     n_flag_A1      );
      $setuphold ( posedge CK &&& con_A,          negedge A1, TAS,     TAH,     n_flag_A1      );
      $setuphold ( posedge CK &&& con_A,          posedge A2, TAS,     TAH,     n_flag_A2      );
      $setuphold ( posedge CK &&& con_A,          negedge A2, TAS,     TAH,     n_flag_A2      );
      $setuphold ( posedge CK &&& con_A,          posedge A3, TAS,     TAH,     n_flag_A3      );
      $setuphold ( posedge CK &&& con_A,          negedge A3, TAS,     TAH,     n_flag_A3      );
      $setuphold ( posedge CK &&& con_A,          posedge A4, TAS,     TAH,     n_flag_A4      );
      $setuphold ( posedge CK &&& con_A,          negedge A4, TAS,     TAH,     n_flag_A4      );
      $setuphold ( posedge CK &&& con_A,          posedge A5, TAS,     TAH,     n_flag_A5      );
      $setuphold ( posedge CK &&& con_A,          negedge A5, TAS,     TAH,     n_flag_A5      );
      $setuphold ( posedge CK &&& con_A,          posedge A6, TAS,     TAH,     n_flag_A6      );
      $setuphold ( posedge CK &&& con_A,          negedge A6, TAS,     TAH,     n_flag_A6      );
      $setuphold ( posedge CK &&& con_A,          posedge A7, TAS,     TAH,     n_flag_A7      );
      $setuphold ( posedge CK &&& con_A,          negedge A7, TAS,     TAH,     n_flag_A7      );
      $setuphold ( posedge CK &&& con_A,          posedge A8, TAS,     TAH,     n_flag_A8      );
      $setuphold ( posedge CK &&& con_A,          negedge A8, TAS,     TAH,     n_flag_A8      );
      $setuphold ( posedge CK &&& con_A,          posedge A9, TAS,     TAH,     n_flag_A9      );
      $setuphold ( posedge CK &&& con_A,          negedge A9, TAS,     TAH,     n_flag_A9      );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI0, TDS,     TDH,     n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI0, TDS,     TDH,     n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI1, TDS,     TDH,     n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI1, TDS,     TDH,     n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI2, TDS,     TDH,     n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI2, TDS,     TDH,     n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI3, TDS,     TDH,     n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI3, TDS,     TDH,     n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI4, TDS,     TDH,     n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI4, TDS,     TDH,     n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI5, TDS,     TDH,     n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI5, TDS,     TDH,     n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI6, TDS,     TDH,     n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI6, TDS,     TDH,     n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI7, TDS,     TDH,     n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI7, TDS,     TDH,     n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI8, TDS,     TDH,     n_flag_DI8     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI8, TDS,     TDH,     n_flag_DI8     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI9, TDS,     TDH,     n_flag_DI9     );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI9, TDS,     TDH,     n_flag_DI9     );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI10, TDS,     TDH,     n_flag_DI10    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI10, TDS,     TDH,     n_flag_DI10    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI11, TDS,     TDH,     n_flag_DI11    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI11, TDS,     TDH,     n_flag_DI11    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI12, TDS,     TDH,     n_flag_DI12    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI12, TDS,     TDH,     n_flag_DI12    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI13, TDS,     TDH,     n_flag_DI13    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI13, TDS,     TDH,     n_flag_DI13    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI14, TDS,     TDH,     n_flag_DI14    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI14, TDS,     TDH,     n_flag_DI14    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI15, TDS,     TDH,     n_flag_DI15    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI15, TDS,     TDH,     n_flag_DI15    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI16, TDS,     TDH,     n_flag_DI16    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI16, TDS,     TDH,     n_flag_DI16    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI17, TDS,     TDH,     n_flag_DI17    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI17, TDS,     TDH,     n_flag_DI17    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI18, TDS,     TDH,     n_flag_DI18    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI18, TDS,     TDH,     n_flag_DI18    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI19, TDS,     TDH,     n_flag_DI19    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI19, TDS,     TDH,     n_flag_DI19    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI20, TDS,     TDH,     n_flag_DI20    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI20, TDS,     TDH,     n_flag_DI20    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI21, TDS,     TDH,     n_flag_DI21    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI21, TDS,     TDH,     n_flag_DI21    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI22, TDS,     TDH,     n_flag_DI22    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI22, TDS,     TDH,     n_flag_DI22    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI23, TDS,     TDH,     n_flag_DI23    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI23, TDS,     TDH,     n_flag_DI23    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI24, TDS,     TDH,     n_flag_DI24    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI24, TDS,     TDH,     n_flag_DI24    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI25, TDS,     TDH,     n_flag_DI25    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI25, TDS,     TDH,     n_flag_DI25    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI26, TDS,     TDH,     n_flag_DI26    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI26, TDS,     TDH,     n_flag_DI26    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI27, TDS,     TDH,     n_flag_DI27    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI27, TDS,     TDH,     n_flag_DI27    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI28, TDS,     TDH,     n_flag_DI28    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI28, TDS,     TDH,     n_flag_DI28    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI29, TDS,     TDH,     n_flag_DI29    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI29, TDS,     TDH,     n_flag_DI29    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI30, TDS,     TDH,     n_flag_DI30    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI30, TDS,     TDH,     n_flag_DI30    );
      $setuphold ( posedge CK &&& con_DI_byte0,   posedge DI31, TDS,     TDH,     n_flag_DI31    );
      $setuphold ( posedge CK &&& con_DI_byte0,   negedge DI31, TDS,     TDH,     n_flag_DI31    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI32, TDS,     TDH,     n_flag_DI32    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI32, TDS,     TDH,     n_flag_DI32    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI33, TDS,     TDH,     n_flag_DI33    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI33, TDS,     TDH,     n_flag_DI33    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI34, TDS,     TDH,     n_flag_DI34    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI34, TDS,     TDH,     n_flag_DI34    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI35, TDS,     TDH,     n_flag_DI35    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI35, TDS,     TDH,     n_flag_DI35    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI36, TDS,     TDH,     n_flag_DI36    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI36, TDS,     TDH,     n_flag_DI36    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI37, TDS,     TDH,     n_flag_DI37    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI37, TDS,     TDH,     n_flag_DI37    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI38, TDS,     TDH,     n_flag_DI38    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI38, TDS,     TDH,     n_flag_DI38    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI39, TDS,     TDH,     n_flag_DI39    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI39, TDS,     TDH,     n_flag_DI39    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI40, TDS,     TDH,     n_flag_DI40    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI40, TDS,     TDH,     n_flag_DI40    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI41, TDS,     TDH,     n_flag_DI41    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI41, TDS,     TDH,     n_flag_DI41    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI42, TDS,     TDH,     n_flag_DI42    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI42, TDS,     TDH,     n_flag_DI42    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI43, TDS,     TDH,     n_flag_DI43    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI43, TDS,     TDH,     n_flag_DI43    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI44, TDS,     TDH,     n_flag_DI44    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI44, TDS,     TDH,     n_flag_DI44    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI45, TDS,     TDH,     n_flag_DI45    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI45, TDS,     TDH,     n_flag_DI45    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI46, TDS,     TDH,     n_flag_DI46    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI46, TDS,     TDH,     n_flag_DI46    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI47, TDS,     TDH,     n_flag_DI47    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI47, TDS,     TDH,     n_flag_DI47    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI48, TDS,     TDH,     n_flag_DI48    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI48, TDS,     TDH,     n_flag_DI48    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI49, TDS,     TDH,     n_flag_DI49    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI49, TDS,     TDH,     n_flag_DI49    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI50, TDS,     TDH,     n_flag_DI50    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI50, TDS,     TDH,     n_flag_DI50    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI51, TDS,     TDH,     n_flag_DI51    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI51, TDS,     TDH,     n_flag_DI51    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI52, TDS,     TDH,     n_flag_DI52    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI52, TDS,     TDH,     n_flag_DI52    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI53, TDS,     TDH,     n_flag_DI53    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI53, TDS,     TDH,     n_flag_DI53    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI54, TDS,     TDH,     n_flag_DI54    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI54, TDS,     TDH,     n_flag_DI54    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI55, TDS,     TDH,     n_flag_DI55    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI55, TDS,     TDH,     n_flag_DI55    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI56, TDS,     TDH,     n_flag_DI56    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI56, TDS,     TDH,     n_flag_DI56    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI57, TDS,     TDH,     n_flag_DI57    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI57, TDS,     TDH,     n_flag_DI57    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI58, TDS,     TDH,     n_flag_DI58    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI58, TDS,     TDH,     n_flag_DI58    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI59, TDS,     TDH,     n_flag_DI59    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI59, TDS,     TDH,     n_flag_DI59    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI60, TDS,     TDH,     n_flag_DI60    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI60, TDS,     TDH,     n_flag_DI60    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI61, TDS,     TDH,     n_flag_DI61    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI61, TDS,     TDH,     n_flag_DI61    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI62, TDS,     TDH,     n_flag_DI62    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI62, TDS,     TDH,     n_flag_DI62    );
      $setuphold ( posedge CK &&& con_DI_byte1,   posedge DI63, TDS,     TDH,     n_flag_DI63    );
      $setuphold ( posedge CK &&& con_DI_byte1,   negedge DI63, TDS,     TDH,     n_flag_DI63    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI64, TDS,     TDH,     n_flag_DI64    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI64, TDS,     TDH,     n_flag_DI64    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI65, TDS,     TDH,     n_flag_DI65    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI65, TDS,     TDH,     n_flag_DI65    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI66, TDS,     TDH,     n_flag_DI66    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI66, TDS,     TDH,     n_flag_DI66    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI67, TDS,     TDH,     n_flag_DI67    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI67, TDS,     TDH,     n_flag_DI67    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI68, TDS,     TDH,     n_flag_DI68    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI68, TDS,     TDH,     n_flag_DI68    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI69, TDS,     TDH,     n_flag_DI69    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI69, TDS,     TDH,     n_flag_DI69    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI70, TDS,     TDH,     n_flag_DI70    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI70, TDS,     TDH,     n_flag_DI70    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI71, TDS,     TDH,     n_flag_DI71    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI71, TDS,     TDH,     n_flag_DI71    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI72, TDS,     TDH,     n_flag_DI72    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI72, TDS,     TDH,     n_flag_DI72    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI73, TDS,     TDH,     n_flag_DI73    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI73, TDS,     TDH,     n_flag_DI73    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI74, TDS,     TDH,     n_flag_DI74    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI74, TDS,     TDH,     n_flag_DI74    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI75, TDS,     TDH,     n_flag_DI75    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI75, TDS,     TDH,     n_flag_DI75    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI76, TDS,     TDH,     n_flag_DI76    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI76, TDS,     TDH,     n_flag_DI76    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI77, TDS,     TDH,     n_flag_DI77    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI77, TDS,     TDH,     n_flag_DI77    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI78, TDS,     TDH,     n_flag_DI78    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI78, TDS,     TDH,     n_flag_DI78    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI79, TDS,     TDH,     n_flag_DI79    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI79, TDS,     TDH,     n_flag_DI79    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI80, TDS,     TDH,     n_flag_DI80    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI80, TDS,     TDH,     n_flag_DI80    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI81, TDS,     TDH,     n_flag_DI81    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI81, TDS,     TDH,     n_flag_DI81    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI82, TDS,     TDH,     n_flag_DI82    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI82, TDS,     TDH,     n_flag_DI82    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI83, TDS,     TDH,     n_flag_DI83    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI83, TDS,     TDH,     n_flag_DI83    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI84, TDS,     TDH,     n_flag_DI84    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI84, TDS,     TDH,     n_flag_DI84    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI85, TDS,     TDH,     n_flag_DI85    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI85, TDS,     TDH,     n_flag_DI85    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI86, TDS,     TDH,     n_flag_DI86    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI86, TDS,     TDH,     n_flag_DI86    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI87, TDS,     TDH,     n_flag_DI87    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI87, TDS,     TDH,     n_flag_DI87    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI88, TDS,     TDH,     n_flag_DI88    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI88, TDS,     TDH,     n_flag_DI88    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI89, TDS,     TDH,     n_flag_DI89    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI89, TDS,     TDH,     n_flag_DI89    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI90, TDS,     TDH,     n_flag_DI90    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI90, TDS,     TDH,     n_flag_DI90    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI91, TDS,     TDH,     n_flag_DI91    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI91, TDS,     TDH,     n_flag_DI91    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI92, TDS,     TDH,     n_flag_DI92    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI92, TDS,     TDH,     n_flag_DI92    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI93, TDS,     TDH,     n_flag_DI93    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI93, TDS,     TDH,     n_flag_DI93    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI94, TDS,     TDH,     n_flag_DI94    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI94, TDS,     TDH,     n_flag_DI94    );
      $setuphold ( posedge CK &&& con_DI_byte2,   posedge DI95, TDS,     TDH,     n_flag_DI95    );
      $setuphold ( posedge CK &&& con_DI_byte2,   negedge DI95, TDS,     TDH,     n_flag_DI95    );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI96, TDS,     TDH,     n_flag_DI96    );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI96, TDS,     TDH,     n_flag_DI96    );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI97, TDS,     TDH,     n_flag_DI97    );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI97, TDS,     TDH,     n_flag_DI97    );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI98, TDS,     TDH,     n_flag_DI98    );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI98, TDS,     TDH,     n_flag_DI98    );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI99, TDS,     TDH,     n_flag_DI99    );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI99, TDS,     TDH,     n_flag_DI99    );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI100, TDS,     TDH,     n_flag_DI100   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI100, TDS,     TDH,     n_flag_DI100   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI101, TDS,     TDH,     n_flag_DI101   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI101, TDS,     TDH,     n_flag_DI101   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI102, TDS,     TDH,     n_flag_DI102   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI102, TDS,     TDH,     n_flag_DI102   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI103, TDS,     TDH,     n_flag_DI103   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI103, TDS,     TDH,     n_flag_DI103   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI104, TDS,     TDH,     n_flag_DI104   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI104, TDS,     TDH,     n_flag_DI104   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI105, TDS,     TDH,     n_flag_DI105   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI105, TDS,     TDH,     n_flag_DI105   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI106, TDS,     TDH,     n_flag_DI106   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI106, TDS,     TDH,     n_flag_DI106   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI107, TDS,     TDH,     n_flag_DI107   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI107, TDS,     TDH,     n_flag_DI107   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI108, TDS,     TDH,     n_flag_DI108   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI108, TDS,     TDH,     n_flag_DI108   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI109, TDS,     TDH,     n_flag_DI109   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI109, TDS,     TDH,     n_flag_DI109   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI110, TDS,     TDH,     n_flag_DI110   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI110, TDS,     TDH,     n_flag_DI110   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI111, TDS,     TDH,     n_flag_DI111   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI111, TDS,     TDH,     n_flag_DI111   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI112, TDS,     TDH,     n_flag_DI112   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI112, TDS,     TDH,     n_flag_DI112   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI113, TDS,     TDH,     n_flag_DI113   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI113, TDS,     TDH,     n_flag_DI113   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI114, TDS,     TDH,     n_flag_DI114   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI114, TDS,     TDH,     n_flag_DI114   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI115, TDS,     TDH,     n_flag_DI115   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI115, TDS,     TDH,     n_flag_DI115   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI116, TDS,     TDH,     n_flag_DI116   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI116, TDS,     TDH,     n_flag_DI116   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI117, TDS,     TDH,     n_flag_DI117   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI117, TDS,     TDH,     n_flag_DI117   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI118, TDS,     TDH,     n_flag_DI118   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI118, TDS,     TDH,     n_flag_DI118   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI119, TDS,     TDH,     n_flag_DI119   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI119, TDS,     TDH,     n_flag_DI119   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI120, TDS,     TDH,     n_flag_DI120   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI120, TDS,     TDH,     n_flag_DI120   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI121, TDS,     TDH,     n_flag_DI121   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI121, TDS,     TDH,     n_flag_DI121   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI122, TDS,     TDH,     n_flag_DI122   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI122, TDS,     TDH,     n_flag_DI122   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI123, TDS,     TDH,     n_flag_DI123   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI123, TDS,     TDH,     n_flag_DI123   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI124, TDS,     TDH,     n_flag_DI124   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI124, TDS,     TDH,     n_flag_DI124   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI125, TDS,     TDH,     n_flag_DI125   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI125, TDS,     TDH,     n_flag_DI125   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI126, TDS,     TDH,     n_flag_DI126   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI126, TDS,     TDH,     n_flag_DI126   );
      $setuphold ( posedge CK &&& con_DI_byte3,   posedge DI127, TDS,     TDH,     n_flag_DI127   );
      $setuphold ( posedge CK &&& con_DI_byte3,   negedge DI127, TDS,     TDH,     n_flag_DI127   );
      $setuphold ( posedge CK &&& con_WEB0,       posedge WEB0, TWS,     TWH,     n_flag_WEB0    );
      $setuphold ( posedge CK &&& con_WEB0,       negedge WEB0, TWS,     TWH,     n_flag_WEB0    );
      $setuphold ( posedge CK &&& con_WEB1,       posedge WEB1, TWS,     TWH,     n_flag_WEB1    );
      $setuphold ( posedge CK &&& con_WEB1,       negedge WEB1, TWS,     TWH,     n_flag_WEB1    );
      $setuphold ( posedge CK &&& con_WEB2,       posedge WEB2, TWS,     TWH,     n_flag_WEB2    );
      $setuphold ( posedge CK &&& con_WEB2,       negedge WEB2, TWS,     TWH,     n_flag_WEB2    );
      $setuphold ( posedge CK &&& con_WEB3,       posedge WEB3, TWS,     TWH,     n_flag_WEB3    );
      $setuphold ( posedge CK &&& con_WEB3,       negedge WEB3, TWS,     TWH,     n_flag_WEB3    );
      $setuphold ( posedge CK,                    posedge CS, TCSS,    TCSH,    n_flag_CS      );
      $setuphold ( posedge CK,                    negedge CS, TCSS,    TCSH,    n_flag_CS      );
      $period    ( posedge CK &&& con_CK,         TRC,                       n_flag_CK_PER  );
      $width     ( posedge CK &&& con_CK,         THPW,    0,                n_flag_CK_MINH );
      $width     ( negedge CK &&& con_CK,         TLPW,    0,                n_flag_CK_MINL );
      if (NODELAY0 == 0)  (posedge CK => (DO0 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO1 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO2 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO3 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO4 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO5 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO6 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO7 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO8 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO9 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO10 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO11 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO12 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO13 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO14 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO15 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO16 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO17 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO18 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO19 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO20 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO21 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO22 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO23 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO24 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO25 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO26 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO27 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO28 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO29 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO30 :1'bx)) = TAA  ;
      if (NODELAY0 == 0)  (posedge CK => (DO31 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO32 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO33 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO34 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO35 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO36 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO37 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO38 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO39 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO40 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO41 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO42 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO43 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO44 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO45 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO46 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO47 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO48 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO49 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO50 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO51 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO52 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO53 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO54 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO55 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO56 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO57 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO58 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO59 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO60 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO61 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO62 :1'bx)) = TAA  ;
      if (NODELAY1 == 0)  (posedge CK => (DO63 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO64 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO65 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO66 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO67 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO68 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO69 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO70 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO71 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO72 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO73 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO74 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO75 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO76 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO77 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO78 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO79 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO80 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO81 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO82 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO83 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO84 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO85 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO86 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO87 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO88 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO89 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO90 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO91 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO92 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO93 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO94 :1'bx)) = TAA  ;
      if (NODELAY2 == 0)  (posedge CK => (DO95 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO96 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO97 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO98 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO99 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO100 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO101 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO102 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO103 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO104 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO105 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO106 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO107 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO108 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO109 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO110 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO111 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO112 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO113 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO114 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO115 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO116 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO117 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO118 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO119 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO120 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO121 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO122 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO123 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO124 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO125 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO126 :1'bx)) = TAA  ;
      if (NODELAY3 == 0)  (posedge CK => (DO127 :1'bx)) = TAA  ;


      (OE => DO0) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO1) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO2) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO3) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO4) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO5) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO6) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO7) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO8) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO9) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO10) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO11) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO12) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO13) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO14) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO15) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO16) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO17) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO18) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO19) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO20) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO21) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO22) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO23) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO24) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO25) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO26) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO27) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO28) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO29) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO30) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO31) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO32) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO33) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO34) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO35) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO36) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO37) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO38) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO39) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO40) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO41) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO42) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO43) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO44) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO45) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO46) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO47) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO48) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO49) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO50) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO51) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO52) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO53) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO54) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO55) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO56) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO57) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO58) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO59) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO60) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO61) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO62) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO63) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO64) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO65) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO66) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO67) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO68) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO69) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO70) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO71) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO72) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO73) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO74) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO75) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO76) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO77) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO78) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO79) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO80) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO81) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO82) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO83) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO84) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO85) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO86) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO87) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO88) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO89) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO90) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO91) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO92) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO93) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO94) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO95) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO96) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO97) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO98) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO99) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO100) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO101) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO102) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO103) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO104) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO105) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO106) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO107) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO108) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO109) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO110) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO111) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO112) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO113) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO114) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO115) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO116) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO117) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO118) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO119) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO120) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO121) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO122) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO123) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO124) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO125) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO126) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO127) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
   endspecify

`endprotect
endmodule


