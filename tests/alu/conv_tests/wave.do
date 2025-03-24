onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clk
add wave -noupdate /top/rst
add wave -noupdate -divider {Test Bench}
add wave -noupdate /top/instr
add wave -noupdate /top/instr_exec
add wave -noupdate /top/op1
add wave -noupdate /top/op2
add wave -noupdate /top/result
add wave -noupdate /top/expected_result
add wave -noupdate /top/enable
add wave -noupdate /top/errors
add wave -noupdate -divider ALU
add wave -noupdate /top/u_alu/clk
add wave -noupdate /top/u_alu/rst
add wave -noupdate /top/u_alu/instr
add wave -noupdate /top/u_alu/op1
add wave -noupdate /top/u_alu/op2
add wave -noupdate /top/u_alu/enable
add wave -noupdate /top/u_alu/instr_exec
add wave -noupdate /top/u_alu/result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {1 us}
