
QUESTA_HOME = /pkgs/mentor/questa/2024.2/questasim/
QUESTA_HOME = /u/release/questa/2024.2/questasim/

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
	@echo "   - sim     = run command line "
	@echo "   - gui     = run with GUI "
	@echo " "

gui: compile
	$(VSIM) -do run_gui.do top

sim: compile
	$(VSIM) -c -do run.do top

compile: clean
	rm -rf ./work

	$(VLIB) ./work
	$(VMAP) work ./work

	$(VLOG) $(HW)/opcode_pkg.sv
	$(VLOG) $(HW)/alu.sv
	$(VLOG) $(TB)/alu_unit_test.sv

CRUFT  = transcript
CRUFT += *.wlf
CRUFT += work
CRUFT += modelsim.ini

clean:
	rm -rf $(CRUFT)
