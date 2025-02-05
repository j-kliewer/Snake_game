create_clock -name clk -period 20 [get_ports {CLOCK_50}]
derive_pll_clocks


#Constrain the inputs

#only constraining the max_delay as I want the path to be within reasonable length, but the inputs are truly asynch to fpga clock

#Constrain asynch path from SW[9] to its synchronizing register in debounce circuit
set_max_delay -from [get_ports {SW[9]}] -to [get_registers {switch_debounce:sw_debounce_u0|syn[0]}] 20
set_false_path -from [get_ports {SW[9]}] -hold

#Constrain asynch paths from KEY[3:0] to their button synch register
set_max_delay -from [get_ports {KEY[0]}] -to [get_registers {button_sync:button_sync_uo|b0[0]}] 20
set_max_delay -from [get_ports {KEY[1]}] -to [get_registers {button_sync:button_sync_uo|b1[0]}] 20
set_max_delay -from [get_ports {KEY[2]}] -to [get_registers {button_sync:button_sync_uo|b2[0]}] 20
set_max_delay -from [get_ports {KEY[3]}] -to [get_registers {button_sync:button_sync_uo|b3[0]}] 20
set_false_path -from [get_ports {KEY[0]}] -hold
set_false_path -from [get_ports {KEY[1]}] -hold
set_false_path -from [get_ports {KEY[2]}] -hold
set_false_path -from [get_ports {KEY[3]}] -hold




#Constrain the Outputs


#Constrain The VGA Outputs
#VGA_X, VGA_Y, and VGA_PLOT are launched by 50MHz clock, latched by 25 MHz clock
#VGA_R, VGA_G, VGA_B, VGA_VS, VGA_HS, VGA_CLK are launched by 25MHz clock, latched by 25 MHz clock

#Create Virtual Clock for VGA DAC on DE1SoC Board
#This is the clock created by the pll for VGA
create_clock -name clk_v_vga -period 40;


#Assuming there is no clock skew

# Specify the maximum external clock delay to the FPGA
set CLKs_max 0
# Specify the minimum external clock delay to the FPGA
set CLKs_min 0

#estimating by bout 
# Specify the maximum board delay
set BD_max 0.13
# Specify the minimum board delay
set BD_min 0.13

# Specify the maximum setup time of the external device
set tSU 0.68
# Specify the minimum setup time of the external device
set tH 2.9

# Specify the maximum external clock delay to the external device
set CLKd_max 0
# Specify the minimum external clock delay to the external device
set CLKd_min 0

# Create the output maximum delay for the data output from the FPGA that accounts for all delays specified
set_output_delay -clock { clk_v_vga } -max [expr $CLKs_max + $BD_max + $tSU - $CLKd_min] [get_ports {VGA_*}]
# Create the output minimum delay for the data output from the FPGA that accounts for all delays specified
set_output_delay -clock { clk_v_vga } -min [expr $CLKs_min + $BD_min - $tH - $CLKd_max] [get_ports {VGA_*}]



#Constrain the Hex Outputs
#Setting max delay to keep path a reasonable length
set_max_delay -to [get_ports {HEX*}] 20
set_false_path -to [get_ports {HEX*}] -hold

