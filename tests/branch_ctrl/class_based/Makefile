QUESTA_HOME = /pkgs/mentor/questa/2024.2/questasim/
#QUESTA_HOME = /u/release/questa/2024.2/questasim/

# Since all files are in the same folder, set HW and TB to the current directory.
HW = .
TB = .

VLIB  = $(QUESTA_HOME)/bin/vlib
VMAP  = $(QUESTA_HOME)/bin/vmap
VLOG  = $(QUESTA_HOME)/bin/vlog -lint +acc=all -work work 
VSIM  = $(QUESTA_HOME)/bin/vsim -voptargs=+acc -work work 

.PHONY: all compile sim gui clean

all: 
	@echo " "
	@echo " Make targets are: "
	@echo "   sim      = run simulation in command line mode"
	@echo "   gui      = run simulation with GUI"
	@echo "   random   = run with random transaction generator"
	@echo "   coverage = run with coverage"
	@echo "   broken   = run with induced errors"
	@echo " "

gui: compile
	$(VSIM) -do "add wave sim:*; run -all" tb

sim: compile
	$(VSIM) -c -do "run -all" tb

random: compile
	$(VSIM) -c -do "run -all" top -g TEST_NO=1

coverage: compile
	$(VSIM) -do "run -all" top -coverage

broken: compile
	$(VSIM) -c -do "run -all" top -g BROKEN=1

compile: clean
	rm -rf ./work

	$(VLIB) ./work
	$(VMAP) work ./work

	$(VLOG) $(HW)/opcode_pkg.sv
	$(VLOG) $(HW)/branch_ctrl.sv
	$(VLOG) $(HW)/transaction.sv
	$(VLOG) $(HW)/interface.sv
	$(VLOG) $(HW)/generator.sv
	$(VLOG) $(HW)/driver.sv
	$(VLOG) $(HW)/monitor.sv
	$(VLOG) $(HW)/scoreboard.sv
	$(VLOG) $(HW)/env.sv
	$(VLOG) $(HW)/test.sv
	$(VLOG) $(HW)/top.sv +acc

CRUFT  = transcript
CRUFT += *.wlf
CRUFT += work
CRUFT += modelsim.ini

clean:
	rm -rf $(CRUFT)
