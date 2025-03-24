
QUESTA_HOME = /pkgs/mentor/questa/2024.2/questasim/
QUESTA_HOME = /u/release/questa/2024.2/questasim/

HW   = ./

VLIB = $(QUESTA_HOME)/bin/vlib
VMAP = $(QUESTA_HOME)/bin/vmap
VLOG = $(QUESTA_HOME)/bin/vlog -lint +acc=all -work work 
VOPT = $(QUESTA_HOME)/bin/vopt 
VSIM = $(QUESTA_HOME)/bin/vsim -voptargs=+acc -work work 

.PHONY: all compile sim gui clean

all: 
	@echo " "
	@echo " make targets are: "
	@echo "   - alu_test "
	@echo "   - alu_test_gui "
	@echo "   - mem_test "
	@echo "   - mem_test_gui "
	@echo "   - jump_test "
	@echo "   - jump_test_gui "
	@echo " "

gui: compile
	$(VSIM) -do run_gui.do top

sim: compile
	$(VSIM) -c -do run.do top

mem_test: compile
	$(VSIM) -c -do run.do memory_ctrl_unit_test

mem_test_gui: compile
	$(VSIM) -do run.do memory_ctrl_unit_test
	
alu_oo_test: compile
	$(VSIM) -c -do run.do alu_oo_tb

alu_oo_gui: compile
	$(VSIM) -do run.do alu_oo_tb

mem_oo_test: compile
	$(VSIM) -c -do run.do mem_oo_tb 
	#$(VSIM) -c -do run.do mem_oo_tb -g BROKEN=1

mem_oo_gui: compile
	$(VSIM) -do run.do mem_oo_tb

alu_test: compile
	$(VSIM) -c -do run.do alu_unit_test

alu_test_gui: compile
	$(VSIM) -do run.do alu_unit_test

jump_test: compile
	$(VSIM) -c -do run.do jump_unit_test

jump_test_gui: compile
	$(VSIM) -do run.do jump_unit_test

compile: clean
	rm -rf ./work

	$(VLIB) ./work
	$(VMAP) work ./work

	$(VLOG) $(HW)/opcode_pkg.sv
	#$(VLOG) $(HW)/testbench.sv
	$(VLOG) $(HW)/alu.sv
	$(VLOG) $(HW)/branch_ctrl.sv
	$(VLOG) $(HW)/memory_ctrl.sv
	$(VLOG) $(HW)/ssram.sv
	$(VLOG) $(HW)/alu_unit_test.sv
	$(VLOG) $(HW)/memory_ctrl_unit_test.sv
	$(VLOG) $(HW)/jump_unit_test.sv

	$(VLOG) $(HW)/alu_oo_tb.sv
	$(VLOG) $(HW)/mem_oo_tb.sv

CRUFT  = transcript
CRUFT += *.wlf
CRUFT += work
CRUFT += modelsim.ini

clean:
	rm -rf $(CRUFT)
