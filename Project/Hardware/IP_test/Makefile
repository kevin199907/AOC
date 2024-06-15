root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
inc_dir := ./include
sim_dir := ./sim
bld_dir := ./build
FSDB_DEF :=
ifeq ($(FSDB),1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB),2)
FSDB_DEF := +FSDB_ALL
endif
CYCLE=`grep -v '^$$' $(root_dir)/sim/CYCLE`
MAX=`grep -v '^$$' $(root_dir)/sim/MAX`

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

# RTL simulation
rtl_all: clean rtl0 rtl1 rtl2 rtl3 rtl4 rtl5


	
vcs0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
	+rdcycle=1
#
#vcs_syn0: | $(bld_dir)
#	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
#		echo "Cycle time shouldn't exceed 20"; \
#		exit 1; \
#	fi; \
#	make -C $(sim_dir)/prog0/; \
#	cd $(bld_dir); \
#	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose\
#	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
#	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
#	+define+SYN+prog0$(FSDB_DEF) \
#	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
#	+rdcycle=1	

rtl0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
	+rdcycle=1

rtl1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1

vcs_Conv: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog_Conv/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog_Conv \
	+rdcycle=1
	

vcs_customized_dw: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog_customized_dw/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog_customized_dw \
	+rdcycle=1

vcs_mobile_block1_pw1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog_mobile_block1_pw1/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0$(FSDB_DEF) \
	+prog_path=$(root_dir)/$(sim_dir)/prog_mobile_block1_pw1 \
	+rdcycle=1
	
# Post-Synthesis simulation
syn_all: clean syn0 syn1 syn2 syn3 syn4 syn5

syn0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0 \
	+rdcycle=1

syn1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1


# Utilities
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

dv: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -gui -no_home_init

synthesize: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -no_home_init -f ../script/synthesis.tcl

# Check file structure
BLUE=\033[1;34m
RED=\033[1;31m
NORMAL=\033[0m

check: clean
	@if [ -f StudentID ]; then \
		STUDENTID=$$(grep -v '^$$' StudentID); \
		if [ -z "$$STUDENTID" ]; then \
			echo -e "$(RED)Student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID_LEN=$$(expr length $$STUDENTID); \
			if [ $$ID_LEN -eq 9 ]; then \
				if [[ $$STUDENTID =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	else \
		echo -e "$(RED)StudentID file is not found$(NORMAL)"; \
		exit 1; \
	fi; \
	if [ $$(ls -1 *.docx 2>/dev/null | wc -l) -eq 0 ]; then \
		echo -e "$(RED)Report file is not found$(NORMAL)"; \
		exit 1; \
	elif [ $$(ls -1 *.docx 2>/dev/null | wc -l) -gt 1 ]; then \
		echo -e "$(RED)More than one docx file is found, please delete redundant file(s)$(NORMAL)"; \
		exit 1; \
	elif [ ! -f $${STUDENTID}.docx ]; then \
		echo -e "$(RED)Report file name should be $$STUDENTID.docx$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Report file name pass$(NORMAL)"; \
	fi; \
	if [ $$(basename $(PWD)) != $$STUDENTID ]; then \
		echo -e "$(RED)Main folder name should be \"$$STUDENTID\"$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Main folder name pass$(NORMAL)"; \
	fi

tar: check
	STUDENTID=$$(basename $(PWD)); \
	cd ..; \
	tar cvf $$STUDENTID.tar $$STUDENTID

.PHONY: clean

clean:
	rm -rf $(bld_dir); \
	rm -rf $(sim_dir)/prog*/result*.txt; \
	make -C $(sim_dir)/prog0/ clean; \
	make -C $(sim_dir)/prog1/ clean; \
	make -C $(sim_dir)/prog2/ clean; \
	make -C $(sim_dir)/prog3/ clean; \
	make -C $(sim_dir)/prog4/ clean; \
	make -C $(sim_dir)/prog5/ clean;
