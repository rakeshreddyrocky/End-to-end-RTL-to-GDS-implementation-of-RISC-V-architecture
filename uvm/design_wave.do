onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/instr_str
add wave -noupdate -divider {Test Bench Signals}
add wave -noupdate /top/u_cpu_design/clk
add wave -noupdate /top/u_cpu_design/rst
add wave -noupdate /top/u_cpu_design/halted
add wave -noupdate /top/u_cpu_design/data_address
add wave -noupdate /top/u_cpu_design/data_write_enable
add wave -noupdate /top/u_cpu_design/data_byte_enables
add wave -noupdate /top/u_cpu_design/data_write_ack
add wave -noupdate /top/u_cpu_design/data_write_data
add wave -noupdate /top/u_cpu_design/data_read_enable
add wave -noupdate /top/u_cpu_design/data_read_ack
add wave -noupdate /top/u_cpu_design/data_read_data
add wave -noupdate /top/u_cpu_design/code_address
add wave -noupdate /top/u_cpu_design/code_write_enable
add wave -noupdate /top/u_cpu_design/code_byte_enables
add wave -noupdate /top/u_cpu_design/code_write_ack
add wave -noupdate /top/u_cpu_design/code_write_data
add wave -noupdate /top/u_cpu_design/code_read_enable
add wave -noupdate /top/u_cpu_design/code_read_ack
add wave -noupdate /top/u_cpu_design/code_read_data
add wave -noupdate -divider {CPU Signals}
add wave -noupdate /top/u_cpu_design/u_cpu/clk
add wave -noupdate /top/u_cpu_design/u_cpu/rst
add wave -noupdate /top/u_cpu_design/u_cpu/instruction_address
add wave -noupdate /top/u_cpu_design/u_cpu/instruction_enable
add wave -noupdate /top/u_cpu_design/u_cpu/instr
add wave -noupdate /top/u_cpu_design/u_cpu/data_address
add wave -noupdate /top/u_cpu_design/u_cpu/data_read_enable
add wave -noupdate /top/u_cpu_design/u_cpu/data_read_data
add wave -noupdate /top/u_cpu_design/u_cpu/data_read_rdy
add wave -noupdate /top/u_cpu_design/u_cpu/data_write_enable
add wave -noupdate /top/u_cpu_design/u_cpu/data_write_byte_enable
add wave -noupdate /top/u_cpu_design/u_cpu/data_write_data
add wave -noupdate /top/u_cpu_design/u_cpu/data_write_rdy
add wave -noupdate /top/u_cpu_design/u_cpu/halted
add wave -noupdate /top/u_cpu_design/u_cpu/fetch
add wave -noupdate /top/u_cpu_design/u_cpu/decode
add wave -noupdate /top/u_cpu_design/u_cpu/execute
add wave -noupdate /top/u_cpu_design/u_cpu/write_back
add wave -noupdate /top/u_cpu_design/u_cpu/executed
add wave -noupdate /top/u_cpu_design/u_cpu/state
add wave -noupdate /top/u_cpu_design/u_cpu/next_state
add wave -noupdate /top/u_cpu_design/u_cpu/pc
add wave -noupdate /top/u_cpu_design/u_cpu/op1
add wave -noupdate /top/u_cpu_design/u_cpu/op2
add wave -noupdate /top/u_cpu_design/u_cpu/op3
add wave -noupdate /top/u_cpu_design/u_cpu/alu_result
add wave -noupdate /top/u_cpu_design/u_cpu/mcu_result
add wave -noupdate /top/u_cpu_design/u_cpu/bcu_result
add wave -noupdate /top/u_cpu_design/u_cpu/result
add wave -noupdate /top/u_cpu_design/u_cpu/rd
add wave -noupdate /top/u_cpu_design/u_cpu/i
add wave -noupdate /top/u_cpu_design/u_cpu/chatty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {212 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 199
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
WaveRestoreZoom {0 ns} {1470 ns}
