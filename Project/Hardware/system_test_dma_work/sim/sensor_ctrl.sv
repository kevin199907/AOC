//================================================
// Auther:      Hsieh Hsien-Hua (Henry)
// Filename:    sensor_ctrl.sv
// Description: High speed sensor controller
// Version:     0.1
//================================================
module sensor_ctrl(
  input clk,
  input rstn,
  // Core inputs
  input sctrl_en,
  input sctrl_clear,
  input [11:0] sctrl_addr,
  // Sensor inputs
  input sensor_ready,
  input [31:0] sensor_out,
  // Core outputs
  output logic sctrl_interrupt,
  output logic [31:0] sctrl_out,
  // Sensor outputs
  output logic sensor_en
);

  logic [31:0] mem[0:4095];
  logic [11:0] counter;
  logic full;

  always_ff@(posedge clk or negedge rstn)
  begin
    if (~rstn)
      counter <= 12'd0;
    else if (sctrl_clear)
      counter <= 12'd0;
    else if (sctrl_en && (~full) && sensor_ready)
      counter <= counter + 12'b1;
  end

  always_comb
  begin
    sctrl_out = mem[sctrl_addr];
    sensor_en = (sctrl_en && (~full) && (~sctrl_clear));
    sctrl_interrupt = full;
  end

  always_ff@(posedge clk or negedge rstn)
  begin
    if (~rstn)
      for (int i=0; i<4095; i++)
        mem[i] <= 32'd0;
    else if (sctrl_en && (~full) && sensor_ready)
      mem[counter] <= sensor_out;
  end

  always_ff@(posedge clk or negedge rstn)
  begin
    if (~rstn)
      full <= 1'b0;
    else if (sctrl_clear)
      full <= 1'b0;
    else if (sctrl_en && (counter == 12'd4095) && sensor_ready)
      full <= 1'b1;
  end
endmodule
