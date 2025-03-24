
QUESTA_HOME = /pkgs/mentor/questa/2024.2/questasim/
ifdef MENTOR
  QUESTA_HOME = /u/release/questa/2024.2/questasim/
endif

HW   = ../../../design_rtl
TB   = ./

VLIB = $(QUESTA_HOME)/bin/vlib
VMAP = $(QUESTA_HOME)/bin/vmap
VLOG = $(QUESTA_HOME)/bin/vlog -lint +acc=all -work work 
VOPT = $(QUESTA_HOME)/bin/vopt 
VSIM = $(QUESTA_HOME)/bin/vsim -voptargs=+acc -work work 

.PHONY: all compile sim gui clean

all: 
	@echo " "
	@echo " make targets are: "
	@echo "   - sim    = run command line"
	@echo "   - gui    = run with GUI"	
	@echo "   - coverage = run with coverage enabled"
	@echo "   - random = run with random transaction generator"
	@echo "   - broken = runs with induced errors"
	@echo " "

gui: compile
	$(VSIM) -do run_gui.do top

sim: compile
	$(VSIM) -c -do run.do top

random: compile
	$(VSIM) -c -do run.do top -g TEST_NO=1

broken: compile
	$(VSIM) -c -do run.do top -g BROKEN=1

coverage: compile
	$(VSIM) -do run_gui.do top -coverage -g TEST_NO=1

compile: clean
	rm -rf ./work

	$(VLIB) ./work
	$(VMAP) work ./work

	$(VLOG) $(HW)/opcode_pkg.sv
	$(VLOG) $(TB)/decoder_oo_tb_pkg.sv
	$(VLOG) $(TB)/decoder_interface.sv
	$(VLOG) $(HW)/decoder.sv +cover
	$(VLOG) $(HW)/ssram.sv
	$(VLOG) $(TB)/top.sv

CRUFT  = transcript
CRUFT += *.wlf
CRUFT += work
CRUFT += modelsim.ini

clean:
	rm -rf $(CRUFT)
