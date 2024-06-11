`timescale 1ns/10ps
module DRAM(
    CK,
    Q,
    RST,
    CSn,
    WEn,
    RASn,
    CASn,
    A,
    D,
    VALID
);

  parameter word_size       = 32;                                        // Word Size
  parameter row_size        = 11;                                        // Row Size
  parameter col_size        = 10;                                        // Column Size
  parameter addr_size       = (row_size > col_size)? row_size: col_size; // Address Size
  parameter addr_size_total = (row_size + col_size );                    // Total Address Size
  parameter mem_size        = (1 << addr_size_total);                    // Memory Size
  parameter Hi_Z_pattern    = {word_size{1'bz}};
  parameter dont_care       = {word_size{1'bx}};
  parameter Bits            = 8;
  parameter Words           = 16384;

  output logic [word_size-1:0] Q;
  output logic VALID;
  //Data Output
  input                 CK;
  input                 RST;
  input                 CSn;    //Chip Select
  input [3:0]           WEn;    //Write Enable
  input                 RASn;   //Row Address Select
  input                 CASn;   //Column Address Select
  input [addr_size-1:0] A;      //Address
  input [word_size-1:0] D;      //Data Input
  integer               i;

  logic [Bits-1:0]  Memory_byte0 [mem_size-1:0];
  logic [Bits-1:0]  Memory_byte1 [mem_size-1:0];
  logic [Bits-1:0]  Memory_byte2 [mem_size-1:0];
  logic [Bits-1:0]  Memory_byte3 [mem_size-1:0];
  logic [2:0]       column_delay;
  logic [3:0]       row_delay;
  logic [2:0]       precharge;
  logic [3:0]       latched_WEn;
  logic             wait_act;

  logic [row_size-1:0] row_l;
  logic [row_size-1:0] row_pre;
  logic [addr_size_total-1:0]addr;



  always_ff@(posedge RST or posedge CK)begin
    if(RST)begin
      precharge <= 3'd5;
      row_pre   <= 0;
    end
    else if (row_delay == 4'd1)
      precharge <= 3'd0;
    else if((precharge > 3'd0) && (precharge < 3'd5))
      precharge <= precharge + 3'd1;
    else if ((~CSn) && ((~RASn)&&(CASn)&&(WEn == 4'h0))) begin
      precharge <= 3'd1;
      row_pre <= A[row_size-1:0];
    end
  end

  always_ff@(posedge RST or posedge CK)begin
    if(RST)begin
      row_l     <= 0;
      row_delay <= 4'd0;
    end
    else if((row_delay > 4'd0) && (row_delay < 4'd5))
      row_delay <= row_delay + 4'd1;
    else if ((~CSn) && ((~RASn)&&(CASn)&&(WEn == 4'hf)) && (precharge == 3'd5)) begin
      row_l     <= A[row_size-1:0];
      row_delay <= 4'd1;
    end
  end

  always_ff@(posedge RST or posedge CK)begin
    if(RST)begin
      addr         <= 0;
      column_delay <= 3'd0;
      latched_WEn  <= 4'hf;
    end
    else if(column_delay > 3'd3)
      column_delay <= 3'd0;
    else if(column_delay > 3'd0)
      column_delay <= column_delay + 3'd1;
    else if ((~CSn) && ((RASn)&&(~CASn)) && (row_delay == 4'd5))begin
      addr         <= {row_l, A[col_size-1:0]};
      latched_WEn  <= WEn;
      column_delay <= 3'd1;
    end
  end


  always/*_ff*/@(posedge RST or posedge CK)begin
    if(RST)begin
      for (i=0;i<mem_size;i=i+1) begin
        Memory_byte0 [i] <=0;
        Memory_byte1 [i] <=0;
        Memory_byte2 [i] <=0;
        Memory_byte3 [i] <=0;
      end
    end
    else if(~CSn) begin
      if (column_delay == 3'd4 && ~latched_WEn[0])
        Memory_byte0[addr] <= D[0*Bits+:Bits];
      if (column_delay == 3'd4 && ~latched_WEn[1])
        Memory_byte1[addr] <= D[1*Bits+:Bits];
      if (column_delay == 3'd4 && ~latched_WEn[2])
        Memory_byte2[addr] <= D[2*Bits+:Bits];
      if (column_delay == 3'd4 && ~latched_WEn[3])
        Memory_byte3[addr] <= D[3*Bits+:Bits];
    end
  end

  always@(posedge RST or posedge CK) begin
    if (RST) begin
      Q       <= Hi_Z_pattern;
      VALID   <= 1'b0;
    end
    else if ((~CSn) && (column_delay == 3'd4) && (latched_WEn == 4'hf)) begin
      #1
      Q[0*Bits+:Bits] <=  Memory_byte0[addr];
      Q[1*Bits+:Bits] <=  Memory_byte1[addr];
      Q[2*Bits+:Bits] <=  Memory_byte2[addr];
      Q[3*Bits+:Bits] <=  Memory_byte3[addr];
      VALID           <=  1'b1;
    end
    else begin
      #1
      Q       <= Hi_Z_pattern;
      VALID   <= 1'b0;
    end
  end

  // -------------------- Timing Specifications -------------------- //
  always_ff@(posedge RST or posedge CK)begin
    if(RST)
      wait_act  <= 1'b0;
    else if ((~CSn) && ((~RASn)&&(CASn)&&(WEn == 4'hf)) && (precharge == 3'd5))
      wait_act  <=  1'b0;
    else if ((~CSn) && ((~RASn)&&(CASn)&&(WEn == 4'h0))) 
      wait_act  <= 1'b1;
  end
  CL_check : assert property (@(posedge CK) disable iff(RST) ((!CASn)|-> (##1(CASn) [*4])))
  else $error("\n *** CL Violation ! CASn should have more than 5 cycles interval ***\n");

  tRCD_check : assert property (@(posedge CK) disable iff(RST) ((!RASn)|-> (##1(CASn) [*4])))
  else $error("\n *** tRCD Violation ! RASn and CASn should have more than 5 cycles interval ***\n");

  tRC_sim_check : assert property (@(posedge CK) disable iff(RST) ((!RASn)|-> CASn))
  else $error("\n *** tRCD Violation ! RASn and CASn cannot be trigger simultaneously ***\n");

  tRP_check : assert property (@(posedge CK) disable iff(RST) ((!RASn && (WEn == 4'h0))|-> (##1(RASn && (WEn == 4'hf)) [*4])))
  else $error("\n *** tRP Violation ! Precharge and Activation state should have more than 5 cycles interval ***\n");

  stable_row_addr : assert property (@(posedge CK) disable iff(RST) ((precharge == 3'd1)|-> (row_l == row_pre)))
  else $fatal(1,"\n *** Violation ! Row address in precharge should be same as the activated row address ***\n");

  write_unknown_value : assert property (@(posedge CK) disable iff (RST) !$isunknown(A) )
  else $error("\n *** DRAM write unknown value A ***\n");

  // --------------------------------------------------------------- //

endmodule
