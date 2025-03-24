onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clk
add wave -noupdate /top/rst
add wave -noupdate -divider Testbench
add wave -noupdate /top/instr
add wave -noupdate /top/op3
add wave -noupdate /top/op1
add wave -noupdate /top/op2
add wave -noupdate /top/instr_str
add wave -noupdate /top/ex_op1
add wave -noupdate /top/ex_op2
add wave -noupdate /top/ex_op3
add wave -noupdate /top/rd
add wave -noupdate /top/ex_rd
add wave -noupdate /top/enable
add wave -noupdate /top/i
add wave -noupdate /top/rs1n
add wave -noupdate /top/rs2n
add wave -noupdate /top/rdn
add wave -noupdate /top/errors
add wave -noupdate -divider {DUT (decoder)}
add wave -noupdate /top/u_decoder/instr
add wave -noupdate /top/u_decoder/enable
add wave -noupdate /top/u_decoder/register_bank
add wave -noupdate /top/u_decoder/op1
add wave -noupdate /top/u_decoder/op2
add wave -noupdate /top/u_decoder/op3
add wave -noupdate /top/u_decoder/rd
add wave -noupdate /top/u_decoder/instr_reg
add wave -noupdate /top/u_decoder/rs1
add wave -noupdate /top/u_decoder/rs2
add wave -noupdate /top/u_decoder/imm
add wave -noupdate /top/u_decoder/opcode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7361152 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 143
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
WaveRestoreZoom {0 ns} {7737542 ns}
