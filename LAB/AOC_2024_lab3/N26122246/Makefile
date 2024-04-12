root_dir := $(PWD)
src_dir := ./src
inc_dir := ./include
bld_dir := ./build
wave_dir := ./nWaveLog
BSSLib_dir := ./BSSLib.lib++
rc_file  := novas.rc
conf_file  := novas.conf

$(bld_dir):
	mkdir -p $(bld_dir)


tb0: | clean $(bld_dir)
	make -C $(root_dir)/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/Mul_tb0.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir) \
	+prog_path=$(root_dir) \
	+rdcycle=1
	
tb1: | clean $(bld_dir)
	make -C $(root_dir)/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/Mul_tb1.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir) \
	+prog_path=$(root_dir) \
	+rdcycle=1

tb2: | clean $(bld_dir)
	make -C $(root_dir)/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/Mul_tb2.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir) \
	+prog_path=$(root_dir) \
	+rdcycle=1

# Utilities
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave Mul.fsdb &

verdi: | $(bld_dir)
	cd $(bld_dir); \
	verdi -ssf Mul.fsdb &
 
clean: 
	rm -rf $(bld_dir); \
	rm -rf $(wave_dir); \
	rm -rf $(BSSLib_dir); \
	rm -f $(rc_file) $(conf_file) \ 
  
.PHONY: clean
