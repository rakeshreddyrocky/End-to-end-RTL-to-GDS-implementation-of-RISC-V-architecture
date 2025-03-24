onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/u_cpu_design/clk
add wave -noupdate /cpu_tb/u_cpu_design/rst
add wave -noupdate -divider {CPU design}
add wave -noupdate /cpu_tb/u_cpu_design/halted
add wave -noupdate /cpu_tb/u_cpu_design/data_address
add wave -noupdate /cpu_tb/u_cpu_design/data_write_enable
add wave -noupdate /cpu_tb/u_cpu_design/data_byte_enables
add wave -noupdate /cpu_tb/u_cpu_design/data_write_ack
add wave -noupdate /cpu_tb/u_cpu_design/data_write_data
add wave -noupdate /cpu_tb/u_cpu_design/data_read_enable
add wave -noupdate /cpu_tb/u_cpu_design/data_read_ack
add wave -noupdate /cpu_tb/u_cpu_design/data_read_data
add wave -noupdate /cpu_tb/u_cpu_design/code_address
add wave -noupdate /cpu_tb/u_cpu_design/code_write_enable
add wave -noupdate /cpu_tb/u_cpu_design/code_byte_enables
add wave -noupdate /cpu_tb/u_cpu_design/code_write_ack
add wave -noupdate /cpu_tb/u_cpu_design/code_write_data
add wave -noupdate /cpu_tb/u_cpu_design/code_read_enable
add wave -noupdate /cpu_tb/u_cpu_design/code_read_ack
add wave -noupdate /cpu_tb/u_cpu_design/code_read_data
add wave -noupdate -divider RISC-V
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/clk
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/rst
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/instruction_address
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/instruction_enable
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/instr
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/data_address
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/data_read_enable
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/data_read_data
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/data_read_rdy
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/data_write_enable
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/data_write_byte_enable
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/data_write_data
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/data_write_rdy
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/halted
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/fetch
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/decode
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/execute
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/write_back
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/executed
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/state
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/next_state
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/pc
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/op1
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/op2
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/op3
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/alu_result
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/mcu_result
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/bcu_result
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/result
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/rd
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/i
add wave -noupdate /cpu_tb/u_cpu_design/u_cpu/chatty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {16493 ns}
