`include "monitor.sv"
`include "CYCLE_MAX.sv"

`timescale 1ns/10ps
// clock define (don't modify)
`define DRAM_CYCLE    30.4
`define ROM_CYCLE     50.2
`define SRAM_CYCLE    11.0
`define AXI_CYCLE     25.0 // 40Mhz



`ifdef SYN
`include "top_syn.v"
`include "INPUT_SRAM/INPUT_SRAM.v"
`include "OUTPUT_SRAM/OUTPUT_SRAM.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`include "SRAM/SRAM.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib.src"
`elsif PR
`include "top_pr.v"
`include "SRAM/SRAM.v"
`include "INPUT_SRAM/INPUT_SRAM.v"
`include "OUTPUT_SRAM/OUTPUT_SRAM.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib.src"
`else
`include "top.sv"
`include "INPUT_SRAM/INPUT_SRAM_rtl.sv"
`include "OUTPUT_SRAM/OUTPUT_SRAM_rtl.sv"
`include "SRAM/SRAM_rtl.sv"
`include "data_array/data_array_rtl.sv"
`include "tag_array/tag_array_rtl.sv"
`endif

`include "sensor_ctrl.sv"
`include "ROM/ROM.v"
`include "DRAM/DRAM.sv"

`define ismem_word(addr) \
  {TOP.IM1.i_SRAM.Memory_byte3[addr], \
  TOP.IM1.i_SRAM.Memory_byte2[addr], \
  TOP.IM1.i_SRAM.Memory_byte1[addr], \
  TOP.IM1.i_SRAM.Memory_byte0[addr]}

`define mem_word(addr) \
  {TOP.DM1.i_SRAM.Memory_byte3[addr], \
  TOP.DM1.i_SRAM.Memory_byte2[addr], \
  TOP.DM1.i_SRAM.Memory_byte1[addr], \
  TOP.DM1.i_SRAM.Memory_byte0[addr]}

`define dram_word(addr) \
  {i_DRAM.Memory_byte3[addr], \
  i_DRAM.Memory_byte2[addr], \
  i_DRAM.Memory_byte1[addr], \
  i_DRAM.Memory_byte0[addr]}

`define SIM_END 'h3fff
`define SIM_END_CODE -32'd1
`define TEST_START 'h40000
`define BOOT_END 'h40002	//DRAM
`define BOOT_END_CODE -32'd1 //flag
`define FOR_LOOP_ADDR 'h153 //SRAM 1054C
`define FOR_LOOP_DEAD_LOOP 'h6f
`define FOR_LOOP_COUNT_INIT 'ha00793

module top_tb;

  logic cpu_clk;
  logic axi_clk;
  logic dram_clk;
  logic rom_clk;
  logic sram_clk;
  logic rst;
  logic [31:0] GOLDEN[4096];
  logic [7:0] Memory_byte0[32768];
  logic [7:0] Memory_byte1[32768];
  logic [7:0] Memory_byte2[32768];
  logic [7:0] Memory_byte3[32768];
  //HW4
  logic [31:0] ROM_out;
  logic sensor_ready;
  logic [31:0] sensor_out;
  logic [31:0] DRAM_Q;
  logic ROM_enable;
  logic ROM_read;
  logic [31:0] ROM_address;
  logic sensor_en;
  logic DRAM_CSn;
  logic [3:0]DRAM_WEn;
  logic DRAM_RASn;
  logic DRAM_CASn;
  logic [10:0] DRAM_A;
  logic [31:0] DRAM_D; 
  logic DRAM_valid;

  logic [31:0] sensor_mem [0:4095];  
  logic [11:0] sensor_counter;
  logic [3:0] data_counter;  
  //HW4
  integer gf, i, num,delay_c;
  logic [31:0] temp;
  integer err;
  string prog_path;
  logic cpu_rst ;
  logic axi_rst ;
  logic rom_rst ;
  logic dram_rst;
  logic sram_rst;
  logic	[31:0]	sctrl_out;
  logic	sctrl_en, sctrl_clear, sctrl_interrupt;
  logic   [11:0]	sctrl_addr;
  
  always #(`CPU_CYCLE/2)    cpu_clk     = ~cpu_clk;
  always #(`AXI_CYCLE/2)    axi_clk     = ~axi_clk;
  always #(`DRAM_CYCLE/2)   dram_clk    = ~dram_clk;
  always #(`ROM_CYCLE/2)    rom_clk     = ~rom_clk;
  always #(`SRAM_CYCLE/2)   sram_clk    = ~sram_clk;

  // initial begin
  //   sctrl_interrupt=0;
  // end
  
  initial begin
    // no timing delay
    
    

    
    // with timing delay
    `ifdef prog4
      cpu_clk = 0;
      #(`CPU_CYCLE/2);
      cpu_clk = 1;
      while(1) begin
        #(0.01);
        for(delay_c = 0; delay_c < 8; delay_c++) begin
          #(`CPU_CYCLE/2) cpu_clk = ~cpu_clk;
        end
      end
    `endif
  end


  top TOP(
    .cpu_clk		    (cpu_clk      ), // CPU CLOCK DOMAIN
    .axi_clk		    (axi_clk      ),
    .rom_clk        (rom_clk      ),
    .dram_clk       (dram_clk     ),
    .sram_clk       (sram_clk     ),
    .cpu_rst		    (cpu_rst      ),
    .axi_rst		    (axi_rst      ),
    .rom_rst        (rom_rst      ),
    .dram_rst       (dram_rst     ),
    .sram_rst       (sram_rst     ),
    .ROM_out        (ROM_out      ),
    // .sensor_ready   (sensor_ready ),
    // .sensor_out     (sensor_out   ),
    .DRAM_valid     (DRAM_valid   ),
    .DRAM_Q         (DRAM_Q       ),
    .ROM_read       (ROM_read     ),
    .ROM_enable     (ROM_enable   ),
    .ROM_address    (ROM_address  ),
    // .sensor_en      (sensor_en    ),
    .DRAM_CSn       (DRAM_CSn     ),
    .DRAM_WEn       (DRAM_WEn     ),
    .DRAM_RASn      (DRAM_RASn    ),
    .DRAM_CASn      (DRAM_CASn    ),
    .DRAM_A         (DRAM_A       ),
    .DRAM_D         (DRAM_D       ),
    .data_counter   (data_counter ),

    // Core inputs
    .sctrl_en         (sctrl_en),
    .sctrl_clear      (sctrl_clear),
    .sctrl_addr       (sctrl_addr),
    // Sensor inputs
    //.sensor_ready     (sensor_ready),
    //.sensor_out       (sensor_out),
    // Core outputs
    .sctrl_interrupt  (sctrl_interrupt),
    .sctrl_out        (sctrl_out)
    // Sensor outputs
    //.sensor_en        (sensor_en)
  );

  sensor_ctrl Sensor_Controller(
  .clk              (dram_clk),
  .rstn             (~dram_rst),
  // Core inputs
  .sctrl_en         (sctrl_en),
  .sctrl_clear      (sctrl_clear),
  .sctrl_addr       (sctrl_addr),
  // Sensor inputs
  .sensor_ready     (sensor_ready),
  .sensor_out       (sensor_out),
  // Core outputs
  .sctrl_interrupt  (sctrl_interrupt),
  .sctrl_out        (sctrl_out),
  // Sensor outputs
  .sensor_en        (sensor_en)
  );

  ROM i_ROM(
    .CK             (rom_clk      ), // ROM CLOCK DOMAIN
    .CS             (ROM_enable   ),
    .OE             (ROM_read     ),
    .A              (ROM_address  ),
    .DO             (ROM_out      )
  );

   DRAM i_DRAM(
    .CK             (dram_clk     ), // DRAM CLOCK DOMAIN
    .Q              (DRAM_Q       ),
    .RST            (dram_rst     ),
    .CSn            (DRAM_CSn     ),
    .WEn            (DRAM_WEn     ),
    .RASn           (DRAM_RASn    ),
    .CASn           (DRAM_CASn    ),
    .A              (DRAM_A       ),
    .D              (DRAM_D       ),
    .VALID          (DRAM_valid   )
  );
  
  initial begin
    int boot_end_flag = 0;
    int only_pose1 = 0;
    int only_pose2 = 0;
    int cycle_number = 0;
    while (1) begin
      #(`CPU_CYCLE)
      if (`dram_word(`TEST_START) != only_pose1 && `dram_word(`TEST_START) == `BOOT_END_CODE && boot_end_flag == 0) begin
        $display("`dram_word(`TEST_START) = %x, cycle_number = %d",`dram_word(`TEST_START),cycle_number);
        boot_end_flag = 1;
        `ismem_word(`FOR_LOOP_ADDR) = `FOR_LOOP_DEAD_LOOP;
        $display("`ismem_word(`FOR_LOOP_ADDR) = %x",`ismem_word(`FOR_LOOP_ADDR));
        $display($time);
      end else if (`dram_word(`TEST_START) != only_pose1 && `dram_word(`TEST_START) == `BOOT_END_CODE && boot_end_flag == 1) begin
        $display("`dram_word(`TEST_START)2 = %x, cycle_number = %d",`dram_word(`TEST_START),cycle_number);
        boot_end_flag = 2;
        `ismem_word(`FOR_LOOP_ADDR) = `FOR_LOOP_COUNT_INIT;
        $display($time);
      end
      cycle_number = cycle_number + 1;
      only_pose1 = `dram_word(`TEST_START);
    end
  end
  
  // reset release sequence (DRAM -> ROM -> SRAM -> AXI -> CPU)
  initial begin
    dram_rst = 1;
    rom_rst  = 1;
    sram_rst = 1;
    axi_rst  = 1;
    cpu_rst  = 1;
    @(posedge dram_clk)
    #(2); // small number 
    dram_rst = 0;
    @(posedge rom_clk)
    #(2); // small number 
    rom_rst = 0;
    @(posedge sram_clk)
    #(2); // small number 
    sram_rst = 0;
    @(posedge axi_clk)
    #(2); // small number 
    axi_rst = 0;
    @(posedge cpu_clk)
    #(2); // small number 
    cpu_rst = 0;
  end
  
  initial
  begin
    // reset
    axi_clk         = 0;
    dram_clk        = 0;
    rom_clk         = 0;
    sram_clk        = 0;
    cpu_clk         = 0;
    sensor_counter  = 0; 
    data_counter    = 0;
    $value$plusargs("prog_path=%s", prog_path);
    // wait for dram reset = 0 
    wait(dram_rst)
    wait(~dram_rst)
    $readmemh({prog_path, "/rom0.hex"}, i_ROM.Memory_byte0);
    $readmemh({prog_path, "/rom1.hex"}, i_ROM.Memory_byte1);
    $readmemh({prog_path, "/rom2.hex"}, i_ROM.Memory_byte2);
    $readmemh({prog_path, "/rom3.hex"}, i_ROM.Memory_byte3);
    $readmemh({prog_path, "/dram0.hex"}, i_DRAM.Memory_byte0);
    $readmemh({prog_path, "/dram1.hex"}, i_DRAM.Memory_byte1);
    $readmemh({prog_path, "/dram2.hex"}, i_DRAM.Memory_byte2);
    $readmemh({prog_path, "/dram3.hex"}, i_DRAM.Memory_byte3);

    num = 0;
    gf = $fopen({prog_path, "/golden.hex"}, "r");
    while (!$feof(gf)) begin
      $fscanf(gf, "%h\n", GOLDEN[num]);
      num++;
    end
    $fclose(gf);
    $readmemh({prog_path, "/Sensor_data.dat"}, sensor_mem);
    

    while (1) begin
      @(negedge dram_clk)
      if (`mem_word(`SIM_END) == `SIM_END_CODE)
      begin
        break; 
      end
      if (sensor_en) begin
        if (data_counter == 4'hf) begin
          sensor_out = sensor_mem[sensor_counter];
          sensor_counter ++;
          sensor_ready = 1'b1;
        end else begin
          sensor_out = 32'hxxxx_xxxx;
          sensor_ready = 1'b0;
        end
        data_counter ++;
      end
    end	
    $display("\nDone\n");
    err = 0;

    for (i = 0; i < num; i++) begin
      if (`dram_word(`TEST_START + i) !== GOLDEN[i]) begin
        $display("DRAM[%4d] = %h, expect = %h", `TEST_START + i, `dram_word(`TEST_START + i), GOLDEN[i]);
        err = err + 1;
      end else begin
        $display("DRAM[%4d] = %h, pass", `TEST_START + i, `dram_word(`TEST_START + i));
      end
    end
    result(err, num);
    mem_monitor; // get memory value
    $finish;
  end

  `ifdef SYN
    initial $sdf_annotate("../syn/top_syn.sdf", TOP);
  `elsif PR
    initial $sdf_annotate("../pr/top_pr.sdf", TOP);
  `endif

  initial begin
    `ifdef FSDB
      $fsdbDumpfile("top.fsdb");
      //$fsdbDumpvars(0, TOP);
    $fsdbDumpvars;
    `elsif FSDB_ALL
      $fsdbDumpfile("top.fsdb");
      $fsdbDumpvars("+struct", "+mda", TOP);
      $fsdbDumpvars("+struct", "+mda", i_ROM);
      // $fsdbDumpvars("+struct", "+mda", Sensor_Controller);
      // $fsdbDumpvars("+struct", "+mda", sensor_ctrl);
      // $fsdbDumpvars("+struct", "+mda", data_counter);
      

      // $fsdbDumpvars("+struct", "+mda", i_DRAM);
      // $fsdbDumpvars("+struct", i_DRAM);
    `endif
    // if reach maximum simulation time
    #(`CPU_CYCLE*`MAX)
    for (i = 0; i < num; i++) begin
      if (`dram_word(`TEST_START + i) !== GOLDEN[i]) begin
        $display("DRAM[%4d] = %h, expect = %h", `TEST_START + i, `dram_word(`TEST_START + i), GOLDEN[i]);
        err=err+1;
      end else begin
        $display("DRAM[%4d] = %h, pass", `TEST_START + i, `dram_word(`TEST_START + i));
      end
    end
    $display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `dram_word(`SIM_END), `SIM_END_CODE);
    result(num, num);
    mem_monitor; // get memory value
    $finish;
  end
  
  task result;
    input integer err;
    input integer num;
    integer rf;
    begin
      `ifdef SYN
        rf = $fopen({prog_path, "/result_syn.txt"}, "w");
      `elsif PR
        rf = $fopen({prog_path, "/result_pr.txt"}, "w");
      `else
        rf = $fopen({prog_path, "/result_rtl.txt"}, "w");
      `endif
      $fdisplay(rf, "%d,%d", num - err, num);
      if (err === 0) begin
        $display("\n");
        $display("\n");
        $display("        **************************               ");
        $display("        *                        *       |\__||  ");
        $display("        *  Congratulations !!    *      / O.O  | ");
        $display("        *                        *    /_____   | ");
        $display("        *  Simulation PASS!!     *   /^ ^ ^ \\  |");
        $display("        *                        *  |^ ^ ^ ^ |w| ");
        $display("        **************************   \\m___m__|_|");
        $display("\n");
      end else begin
        $display("\n");
        $display("\n");
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
      $display("                  %10s %10s", "CYCLE", "FREQ");
      $display("        DRAM    : %10f %10f", `DRAM_CYCLE, (1000/`DRAM_CYCLE));
      $display("        ROM     : %10f %10f", `ROM_CYCLE, (1000/`ROM_CYCLE));
      $display("        SRAM    : %10f %10f", `SRAM_CYCLE, (1000/`SRAM_CYCLE));
      $display("        CPU     : %10f %10f", `CPU_CYCLE, (1000/`CPU_CYCLE));
      $display("        AXI     : %10f %10f", `AXI_CYCLE, (1000/`AXI_CYCLE));
    end
  endtask
  
  int unsigned fo_ROM, fo_DRAM, fo_IM, fo_DM;
  initial begin
    fo_ROM   = $fopen("ROM.txt", "w");
    fo_DRAM  = $fopen("DRAM.txt", "w");
    fo_IM    = $fopen("IM.txt", "w");
    fo_DM    = $fopen("DM.txt", "w");
  end
  
  // get memory value
  task mem_monitor;
    begin
      `DUMP_MEM(fo_ROM,   i_ROM.Memory_byte,          0, 2**15-1, %h) // ./build/ROM.txt
      `DUMP_MEM(fo_DRAM,  i_DRAM.Memory_byte,         0, 2**15-1, %h) // ./build/DRAM.txt
      `DUMP_MEM(fo_IM,    TOP.IM1.i_SRAM.Memory_byte, 0, 16384-1, %h) // ./build/IM.txt
      `DUMP_MEM(fo_DM,    TOP.DM1.i_SRAM.Memory_byte, 0, 16384-1, %h) // ./build/DM.txt
    end
  endtask
  
endmodule
