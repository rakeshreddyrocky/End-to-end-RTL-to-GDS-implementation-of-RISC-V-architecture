
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
	@echo "   - sim "
	@echo "   - gui "
	@echo "   - fib  = run fibonacci program "
	@echo "   - mem_test = run memory test "
	@echo " "

gui: compile riscv_iss.so 
	$(VSIM) -do run_gui.do cpu_tb -sv_lib riscv_iss

sim: compile riscv_iss.so
	$(VSIM) -c -do run.do cpu_tb -sv_lib riscv_iss

fib: compile riscv_iss.so
	$(VSIM) -do run_gui.do cpu_tb -g testname="fibonacci" -sv_lib riscv_iss

mem_test: compile riscv_iss.so
	$(VSIM) -do run_gui.do cpu_tb -g testname="memory_test" -sv_lib riscv_iss

compile: clean 
	rm -rf ./work

	$(VLIB) ./work
	$(VMAP) work ./work

	$(VLOG) $(HW)/opcode_pkg.sv
	$(VLOG) $(HW)/alu.sv
	$(VLOG) $(HW)/decoder.sv
	$(VLOG) $(HW)/branch_ctrl.sv
	$(VLOG) $(HW)/memory_ctrl.sv
	$(VLOG) $(HW)/ssram.sv
	$(VLOG) $(HW)/riscv_rv32i.sv
	$(VLOG) $(HW)/cpu_design.sv
	$(VLOG) $(TB)/iss_pkg.sv
	$(VLOG) $(TB)/cpu_tb.sv

riscv_iss.so: riscv_iss.c
	gcc -m32 -o riscv_iss.so -shared -fPIC -std=c99 riscv_iss.c 

CRUFT  = transcript
CRUFT += *.wlf
CRUFT += work
CRUFT += modelsim.ini

clean:
	rm -rf $(CRUFT)
