🚀 ECE_593_Team7 - RISC-V RV32I Core Verification

📝 Project Overview
This project implements and verifies a RISC-V RV32I core, focusing on executing arithmetic, logic, load/store, and branch instructions. The core is designed using Harvard architecture and follows a state-machine-based execution model. The project does not include pipelining, caches, or privilege modes, keeping the design simple and modular for verification.

![WhatsApp Image 2025-01-31 at 20 23 49_56f27c75](https://github.com/user-attachments/assets/2ef604e1-2773-44d2-88d1-07e3870e5216)

🎯 Verification Objectives

Unit Testing for key modules: ALU, Memory Controller, Branch Controller
Functional Verification of RV32I instruction execution
Coverage-Driven Testing to measure test effectiveness
System-Level Testing using short programs on the core

🛠️ Key Components

Module	Description
ALU	Performs arithmetic and logic operations
Memory Controller	Handles data memory access (load/store operations)
Branch Controller	Manages program control flow (jumps and branches)
Decoder	Decodes RISC-V instructions and extracts operands
Opcode Package	Defines instruction encodings and opcode mappings
CPU Design	Integrates all components into an executable RISC-V core
Register File	Stores general-purpose registers
State Machine	Controls instruction execution flow

✅ Verification Strategy

Unit Tests (Module-Level Testing)
✔ Decoder Test: Verified correct opcode decoding and operand extraction
✔ ALU Test: Verified arithmetic and logic operations using class-based testbenches
✔ Memory Controller Test: Ensured correct memory reads/writes using conventional testbenches
✔ Branch Controller Test: Confirmed execution of branch/jump operations using class-based testbenches


Core-Level Tests (Integration Testing)
✔ Opcode Tests: Validated individual instruction execution
✔ Multiple Instruction Sequences: Ensured correct instruction sequencing
✔ Randomized Tests: Stressed the core with randomized execution patterns

UVM-Based Verification
A UVM testbench was developed for the entire RISC-V core to ensure structured and reusable verification.
Functional coverage reports are included in the tests directory to track verification completeness.


📂 File Structure

ECE_593_Team7/
│── design_rtl/          # RTL design files  
│   ├── alu.sv  
│   ├── branch_ctrl.sv  
│   ├── cpu_design.sv  
│   ├── decoder.sv  
│   ├── memory_ctrl.sv  
│   ├── opcode_pkg.sv  
│   ├── riscv_rv32i.sv  
│   ├── ssram.sv  
│  
│── tests/               # Contains testbenches  
│   ├── alu_class_based/     # ALU verification using class-based TB  
│   ├── alu/conv_tests/      # ALU conventional testbench  
│   ├── branch_ctrl/         # Branch Controller verification  
│   ├── cpu/conv_tests/      # CPU opcode-level testing  
│   ├── decoder/             # Decoder verification  
│   ├── memory_ctrl/         # Memory Controller verification  
│  
│── uvm/                # UVM testbench for full RISC-V core  
│  
│── Makefile            # Build automation script  
│── README.md           # Project overview and documentation  
│── run.do              # Testbench run script  
│── testbench.sv        # Top-level testbench for simulation  


🏗️ Building and Running the Design

To run and verify individual components, use the provided Makefile:

make alu_test          # Runs ALU unit test  
make mem_test          # Runs Memory Controller unit test  
make jump_test         # Runs Branch Controller unit test  

To simulate the entire RISC-V core using UVM-based verification, navigate to the uvm/ directory and run:

make sim               # Runs the full UVM testbench  
make coverage          # Generates coverage report  

📌 Current Project Status
All core components have been implemented and verified.
Class-based SystemVerilog testbenches have been written for ALU, Branch Controller, Decoder and CPU.
Functional coverage reports have been generated.
UVM-based verification has been successfully conducted for the full RISC-V core.

🔍 Key Findings & Observations
ALU and Memory Controller were independently verified before integration.
Directed and randomized tests confirmed correct execution of all instructions.
Functional coverage metrics indicate full verification of instruction paths.

📢 Conclusion
This project successfully implemented and verified a RISC-V RV32I core using module-level and core-level testing. The verification strategy ensures that the core meets functional correctness, and the UVM testbench enables structured and reusable testing.

🚀 The core is now fully verified and ready for further optimizations!
