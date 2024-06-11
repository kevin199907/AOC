#####CLK PERIOD CAN BE ADJUSTED UP TO 20.0 IF SYNTHESIS GOES WRONG#####
create_clock -name cpu_clk  -period 10.0  [get_ports cpu_clk]
create_clock -name axi_clk  -period 25.0  [get_ports axi_clk]
create_clock -name rom_clk  -period 50.2  [get_ports rom_clk]
create_clock -name dram_clk -period 30.4  [get_ports dram_clk]
create_clock -name sram_clk -period 11.0  [get_ports sram_clk]
set_clock_groups -asynchronous -group {cpu_clk} -group {axi_clk} -group {rom_clk} -group {dram_clk} -group {sram_clk}

set_dont_touch_network      [all_clocks]
set_fix_hold                [all_clocks]
set_clock_uncertainty  0.1  [all_clocks]
set_clock_latency      1.0  [all_clocks]
set_ideal_network           [get_ports {cpu_clk axi_clk rom_clk dram_clk sram_clk}]

set_multicycle_path -setup 2 -to [get_pins cpu/cpu/reg_exe_mem/mul]
set_multicycle_path -hold  1 -to [get_pins cpu/cpu/reg_exe_mem/mul]

#####REMEMBER TO SET THIS MAX DELAY TO 1/2 CLK PERIOD#####
# cpu_clk
set_input_delay  -max 5.0  -clock cpu_clk [remove_from_collection [all_inputs] [get_ports {cpu_clk}]]
set_input_delay  -min 0.0  -clock cpu_clk [remove_from_collection [all_inputs] [get_ports {cpu_clk}]]
set_output_delay -max 5.0  -clock cpu_clk [all_outputs]
set_output_delay -min 0.0  -clock cpu_clk [all_outputs]

# axi_clk
set_input_delay  -max 5.0 -clock axi_clk [remove_from_collection [all_inputs] [get_ports {axi_clk}]]
set_input_delay  -min 0.0 -clock axi_clk [remove_from_collection [all_inputs] [get_ports {axi_clk}]]
set_output_delay -max 5.0 -clock axi_clk [all_outputs]
set_output_delay -min 0.0 -clock axi_clk [all_outputs]

# rom_clk
set_input_delay  -max 5.0 -clock rom_clk [remove_from_collection [all_inputs] [get_ports {rom_clk}]]
set_input_delay  -min 0.0 -clock rom_clk [remove_from_collection [all_inputs] [get_ports {rom_clk}]]
set_output_delay -max 5.0 -clock rom_clk [all_outputs]
set_output_delay -min 0.0 -clock rom_clk [all_outputs]

# dram_clk
set_input_delay  -max 5.0 -clock dram_clk [remove_from_collection [all_inputs] [get_ports {dram_clk}]]
set_input_delay  -min 0.0 -clock dram_clk [remove_from_collection [all_inputs] [get_ports {dram_clk}]]
set_output_delay -max 5.0 -clock dram_clk [all_outputs]
set_output_delay -min 0.0 -clock dram_clk [all_outputs]

# sram_clk
set_input_delay  -max 5.0 -clock sram_clk [remove_from_collection [all_inputs] [get_ports {sram_clk}]]
set_input_delay  -min 0.0 -clock sram_clk [remove_from_collection [all_inputs] [get_ports {sram_clk}]]
set_output_delay -max 5.0 -clock sram_clk [all_outputs]
set_output_delay -min 0.0 -clock sram_clk [all_outputs]


set_driving_cell -library fsa0m_a_t33_generic_io_ss1p62v125c -lib_cell XMD -pin {O} [all_inputs]
#set_drive 0.1  [all_inputs]
set_load  0.05 [all_outputs]

set_operating_conditions -max_library fsa0m_a_generic_core_ss1p62v125c -max WCCOM -min_library fsa0m_a_generic_core_ff1p98vm40c -min BCCOM
set auto_wire_load_selection

set_max_fanout 6 [all_inputs]

####Naming Rule#######
#change_names -hierarchy -rules verilog
#define_name_rules name_rule -allowed "A-Z a-z 0-9 _" -max_length 255 -type cell
#define_name_rules name_rule -allowed "A-Z a-z 0-9 _[]" -max_length 255 -type net
#define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
#define_name_rules name_rule -case_insensitive
#change_names -hierarchy -rules name_rule
