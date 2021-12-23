vlib work

vsim -voptargs="+acc" -msgmode both ahb_arbiter_tb

add wave sim:/ahb_arbiter_tb/HRESETn
add wave sim:/ahb_arbiter_tb/HCLK

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


restart -f

run 2 us;
