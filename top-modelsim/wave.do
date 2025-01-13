onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider DUT
add wave -noupdate /tb_top_snake_game/DUT/CLOCK_50
add wave -noupdate -expand /tb_top_snake_game/DUT/KEY
add wave -noupdate /tb_top_snake_game/DUT/SW
add wave -noupdate /tb_top_snake_game/DUT/LEDR
add wave -noupdate /tb_top_snake_game/DUT/HEX0
add wave -noupdate /tb_top_snake_game/DUT/HEX1
add wave -noupdate /tb_top_snake_game/DUT/HEX2
add wave -noupdate /tb_top_snake_game/DUT/HEX3
add wave -noupdate /tb_top_snake_game/DUT/HEX4
add wave -noupdate /tb_top_snake_game/DUT/HEX5
add wave -noupdate /tb_top_snake_game/DUT/VGA_R
add wave -noupdate /tb_top_snake_game/DUT/VGA_G
add wave -noupdate /tb_top_snake_game/DUT/VGA_B
add wave -noupdate /tb_top_snake_game/DUT/VGA_HS
add wave -noupdate /tb_top_snake_game/DUT/VGA_VS
add wave -noupdate /tb_top_snake_game/DUT/VGA_CLK
add wave -noupdate /tb_top_snake_game/DUT/VGA_X
add wave -noupdate /tb_top_snake_game/DUT/VGA_Y
add wave -noupdate /tb_top_snake_game/DUT/VGA_COLOUR
add wave -noupdate /tb_top_snake_game/DUT/VGA_PLOT
add wave -noupdate /tb_top_snake_game/DUT/rst_n
add wave -noupdate /tb_top_snake_game/DUT/LEFT
add wave -noupdate /tb_top_snake_game/DUT/UP
add wave -noupdate /tb_top_snake_game/DUT/DOWN
add wave -noupdate /tb_top_snake_game/DUT/RIGHT
add wave -noupdate /tb_top_snake_game/DUT/is_start
add wave -noupdate /tb_top_snake_game/DUT/is_waitrequest
add wave -noupdate /tb_top_snake_game/DUT/is_vga_plot
add wave -noupdate /tb_top_snake_game/DUT/is_vga_x
add wave -noupdate /tb_top_snake_game/DUT/is_vga_y
add wave -noupdate /tb_top_snake_game/DUT/is_vga_colour
add wave -noupdate /tb_top_snake_game/DUT/gplot_game_plot
add wave -noupdate /tb_top_snake_game/DUT/gplot_game_x
add wave -noupdate /tb_top_snake_game/DUT/gplot_game_y
add wave -noupdate /tb_top_snake_game/DUT/gplot_game_colour
add wave -noupdate /tb_top_snake_game/DUT/gplot_waitrequest
add wave -noupdate /tb_top_snake_game/DUT/gplot_vga_plot
add wave -noupdate /tb_top_snake_game/DUT/gplot_vga_x
add wave -noupdate /tb_top_snake_game/DUT/gplot_vga_y
add wave -noupdate /tb_top_snake_game/DUT/gplot_vga_colour
add wave -noupdate /tb_top_snake_game/DUT/gpath_start
add wave -noupdate /tb_top_snake_game/DUT/gpath_waitrequest
add wave -noupdate /tb_top_snake_game/DUT/VGA_R_10
add wave -noupdate /tb_top_snake_game/DUT/VGA_G_10
add wave -noupdate /tb_top_snake_game/DUT/VGA_B_10
add wave -noupdate /tb_top_snake_game/DUT/VGA_BLANK
add wave -noupdate /tb_top_snake_game/DUT/VGA_SYNC
add wave -noupdate /tb_top_snake_game/DUT/state
add wave -noupdate -divider -height 50 {INIT SCREEN}
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/clk
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/rst_n
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/start
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/waitrequest
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/vga_plot
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/vga_x
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/vga_y
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/vga_colour
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/x
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/y
add wave -noupdate /tb_top_snake_game/DUT/init_screen_u0/state
add wave -noupdate -divider -height 50 {GAME PATH}
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/clk
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/rst_n
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/start
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/in_left
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/in_right
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/in_up
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/in_down
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/waitrequest
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/game_plot_waitrequest
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/game_plot
add wave -noupdate -radix unsigned /tb_top_snake_game/DUT/game_path_u0/game_x
add wave -noupdate -radix unsigned /tb_top_snake_game/DUT/game_path_u0/game_y
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/game_colour
add wave -noupdate -radix hexadecimal /tb_top_snake_game/DUT/game_path_u0/new_head
add wave -noupdate -radix hexadecimal /tb_top_snake_game/DUT/game_path_u0/head
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/last_tail
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/apple
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/count
add wave -noupdate -radix unsigned /tb_top_snake_game/DUT/game_path_u0/stall_num
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/out_of_bounds_flag
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/simple_mem
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/rd_ptr
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/wr_ptr
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/we
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/wr_data
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/wr_addr
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/rd_addr
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/rd_data
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/last_direction
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/direction
add wave -noupdate /tb_top_snake_game/DUT/game_path_u0/state
add wave -noupdate -divider -height 50 {GAME PLOT}
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/clk
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/rst_n
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/game_plot
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/game_x
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/game_y
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/game_colour
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/waitrequest
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/vga_plot
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/vga_x
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/vga_y
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/vga_colour
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/temp_colour
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/base_x
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/base_y
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/x
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/y
add wave -noupdate /tb_top_snake_game/DUT/game_plot_u0/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12282 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 343
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
configure wave -timelineunits ps
update
WaveRestoreZoom {12094 ps} {13090 ps}
