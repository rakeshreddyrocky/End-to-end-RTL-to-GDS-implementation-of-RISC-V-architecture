onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clk
add wave -noupdate /top/rst
add wave -noupdate -divider {Test Bench}
add wave -noupdate /top/instr
add wave -noupdate /top/op1
add wave -noupdate /top/op2
add wave -noupdate /top/op3
add wave -noupdate /top/result
add wave -noupdate /top/result_valid
add wave -noupdate /top/address
add wave -noupdate /top/read_enable
add wave -noupdate /top/read_data
add wave -noupdate /top/write_enable
add wave -noupdate /top/byte_enables
add wave -noupdate /top/write_data
add wave -noupdate /top/enable
add wave -noupdate -divider {Memory Controller}
add wave -noupdate /top/DUT/clk
add wave -noupdate /top/DUT/rst
add wave -noupdate /top/DUT/instr
add wave -noupdate /top/DUT/op1
add wave -noupdate /top/DUT/op2
add wave -noupdate /top/DUT/op3
add wave -noupdate /top/DUT/enable
add wave -noupdate /top/DUT/result
add wave -noupdate /top/DUT/result_valid
add wave -noupdate /top/DUT/address
add wave -noupdate /top/DUT/read_enable
add wave -noupdate /top/DUT/read_data
add wave -noupdate /top/DUT/read_ack
add wave -noupdate /top/DUT/write_enable
add wave -noupdate /top/DUT/write_byte_enable
add wave -noupdate /top/DUT/write_data
add wave -noupdate /top/DUT/write_ack
add wave -noupdate /top/DUT/state
add wave -noupdate /top/DUT/next_state
add wave -noupdate /top/DUT/read_op
add wave -noupdate /top/DUT/write_op
add wave -noupdate /top/DUT/read_instr
add wave -noupdate /top/DUT/write_instr
add wave -noupdate /top/DUT/sign_ex
add wave -noupdate /top/DUT/offset
add wave -noupdate /top/DUT/size
add wave -noupdate /top/DUT/wdata
add wave -noupdate /top/DUT/result_reg
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
WaveRestoreZoom {0 ns} {1 us}
