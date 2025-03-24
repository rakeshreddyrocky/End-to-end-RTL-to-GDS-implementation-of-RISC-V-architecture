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
add wave -noupdate /top/result
add wave -noupdate /top/result_valid
add wave -noupdate /top/address
add wave -noupdate /top/read_enable
add wave -noupdate /top/read_data
add wave -noupdate /top/read_ack
add wave -noupdate /top/write_enable
add wave -noupdate /top/write_byte_enable
add wave -noupdate /top/write_data
add wave -noupdate /top/write_ack
add wave -noupdate /top/expected_result
add wave -noupdate /top/errors
add wave -noupdate /top/i
add wave -noupdate -divider {Memory Controller}
add wave -noupdate /top/u_mcu/clk
add wave -noupdate /top/u_mcu/rst
add wave -noupdate /top/u_mcu/instr
add wave -noupdate /top/u_mcu/op1
add wave -noupdate /top/u_mcu/op2
add wave -noupdate /top/u_mcu/op3
add wave -noupdate /top/u_mcu/enable
add wave -noupdate /top/u_mcu/result
add wave -noupdate /top/u_mcu/result_valid
add wave -noupdate /top/u_mcu/address
add wave -noupdate /top/u_mcu/read_enable
add wave -noupdate /top/u_mcu/read_data
add wave -noupdate /top/u_mcu/read_ack
add wave -noupdate /top/u_mcu/write_enable
add wave -noupdate /top/u_mcu/write_byte_enable
add wave -noupdate /top/u_mcu/write_data
add wave -noupdate /top/u_mcu/write_ack
add wave -noupdate /top/u_mcu/state
add wave -noupdate /top/u_mcu/next_state
add wave -noupdate /top/u_mcu/read_op
add wave -noupdate /top/u_mcu/write_op
add wave -noupdate /top/u_mcu/read_instr
add wave -noupdate /top/u_mcu/write_instr
add wave -noupdate /top/u_mcu/sign_ex
add wave -noupdate /top/u_mcu/offset
add wave -noupdate /top/u_mcu/size
add wave -noupdate /top/u_mcu/wdata
add wave -noupdate /top/u_mcu/result_reg
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
