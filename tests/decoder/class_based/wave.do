onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clk
add wave -noupdate /top/rst
add wave -noupdate -divider {Test Bench}
add wave -noupdate /top/instr
add wave -noupdate /top/op1
add wave -noupdate /top/op2
add wave -noupdate /top/op3
add wave -noupdate /top/enable
add wave -noupdate -divider Decoder
add wave -noupdate /top/DUT/instr
add wave -noupdate /top/DUT/enable
add wave -noupdate /top/DUT/register_bank
add wave -noupdate /top/DUT/op1
add wave -noupdate /top/DUT/op2
add wave -noupdate /top/DUT/op3
add wave -noupdate /top/DUT/rd
add wave -noupdate /top/DUT/instr_reg
add wave -noupdate /top/DUT/rs1
add wave -noupdate /top/DUT/rs2
add wave -noupdate /top/DUT/imm
add wave -noupdate -expand /top/DUT/register_bank
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {106 ns} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ns} {1 us}
