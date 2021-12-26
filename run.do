vlib work

vsim -voptargs="+acc" -msgmode both ahb_arbiter_tb

add wave -divider signals
add wave sim:/ahb_arbiter_tb/HGRANTx
add wave sim:/ahb_arbiter_tb/HBUSREQx
add wave sim:/ahb_arbiter_tb/HLOCKx

add wave sim:/ahb_arbiter_tb/HRESETn
add wave sim:/ahb_arbiter_tb/HCLK
add wave sim:/ahb_arbiter_tb/HREADY
add wave sim:/ahb_arbiter_tb/HMASTLOCK

add wave -divider MASTER_0
add wave sim:/ahb_arbiter_tb/HBUSREQx(0)
add wave sim:/ahb_arbiter_tb/HLOCKx(0)
add wave sim:/ahb_arbiter_tb/HGRANTx(0)
add wave sim:/ahb_arbiter_tb/ready_indiv(0)

add wave -divider MASTER_1
add wave sim:/ahb_arbiter_tb/HBUSREQx(1)
add wave sim:/ahb_arbiter_tb/HLOCKx(1)
add wave sim:/ahb_arbiter_tb/HGRANTx(1)
add wave sim:/ahb_arbiter_tb/ready_indiv(1)

add wave -divider MASTER_2
add wave sim:/ahb_arbiter_tb/HBUSREQx(2)
add wave sim:/ahb_arbiter_tb/HLOCKx(2)
add wave sim:/ahb_arbiter_tb/HGRANTx(2)
add wave sim:/ahb_arbiter_tb/ready_indiv(2)

add wave -divider MASTER_3
add wave sim:/ahb_arbiter_tb/HBUSREQx(3)
add wave sim:/ahb_arbiter_tb/HLOCKx(3)
add wave sim:/ahb_arbiter_tb/HGRANTx(3)
add wave sim:/ahb_arbiter_tb/ready_indiv(3)

add wave -divider MASTER_4
add wave sim:/ahb_arbiter_tb/HBUSREQx(4)
add wave sim:/ahb_arbiter_tb/HLOCKx(4)
add wave sim:/ahb_arbiter_tb/HGRANTx(4)
add wave sim:/ahb_arbiter_tb/ready_indiv(4)

restart -f

run 2 us;
