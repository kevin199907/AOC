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


tb0: 
	make -C $(root_dir)/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/PE_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir) \
	+define+tb0 \
	+prog_path=$(root_dir) \
	+rdcycle=1
	
tb1: 
	make -C $(root_dir)/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/PE_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir) \
	+define+tb1 \
	+prog_path=$(root_dir) \
	+rdcycle=1

tb2: 
	make -C $(root_dir)/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/PE_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir) \
	+define+tb2 \
	+prog_path=$(root_dir) \
	+rdcycle=1
 
tb3:
	make -C $(root_dir)/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/PE_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir) \
	+define+tb3 \
	+prog_path=$(root_dir) \
	+rdcycle=1

# Utilities
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave PE.fsdb &

verdi: | $(bld_dir)
	cd $(bld_dir); \
	verdi -ssf PE.fsdb &

clean: 
	rm -rf $(bld_dir); \
	rm -rf $(wave_dir); \
	rm -rf $(BSSLib_dir); \
	rm -f $(rc_file) $(conf_file) \ 

.PHONY: clean


