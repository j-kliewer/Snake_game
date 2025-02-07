# Snake_game
Snake game implemented on the DE1-SoC

## Introduction

This project was created to implement a snake game in hardware on the [De1-SoC development board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=205&No=836&PartNo=1#contents).

**<ins>Description of the Snake Game:</ins>**

  **Mechanics:** A snake that moves on a grid. The direction the snake moves is controlled by the player. At each time step, the head moves forward one square and the tail follows one square. 

  **Objective:** The objective of the game is to collect a Point on the grid. If the snake runs into the Point, the length of the snake increases by one square, and a new Point is plotted at random.

  **Challenge:** The snake must avoid both the walls of the grid and the snake tail that is trailing behind the snake head. If the snake collides with either, the game is over.

  //insert photo of snake game

The file structure of the project is as follows:

//insert code_hierarchy.png


## Top Snake Game - top_snake_game.sv

A basic flow structure of Top Snake Game is as follows:

//insert snake_game_diagram

A diagram of the state machine is as follows:

//insert state machine diagram

## Switch Debounce - switch_debounce.sv

The Switch Debounce module is created to first synchronize the input from SW[9] on the DE1-SoC board and then debounce the output of the synchronizer. Note: SW[9] is completely asynchronous.

The synchronizer is implemented using two flip flops in series. The debounce circuit is implemented using a counter to enable a final flip flop. This enable is turned on when the counter is greater than or equal to a value specified as a parameter passed to this module.

The counter is only triggered when the output of the synchronizer and the output of the debounce flip flop are not equal. 

Since the switch is driven by human control, it will be much slower than the clock speed of the FPGA and there is no concern about loss of data. 

From a higher level viewpoint of the design, the output of this switch debounce circuit is used as a reset signal for the entire design.

//insert switch_debounce_diagram

## Button Sync - button_sync.sv

The Button Sync module implements synchronizers for each of the 4 buttons on the DE1-SoC board which are used to control the direction of the snake and the game. These 4 buttons are completely asynchronous. 

Technically there could be issues with these input 'data packets' of the buttons crossing into the FPGA clock domain, i.e. the 'data packet' of sampled buttons at the input of the synchronizer may not all appear on the output of the synchronizer at the same time. This, however, is not a concern as these buttons are human controlled and the difference of one single 20 ns clock cycle is negligible compared to the human reaction speed of 250 ms.

Also note that these inputs are not debounced as they have already been debounced externally by a Schmitt Trigger on the board.

//insert button_sync_diagram

## Init Screen - init_screen.sv

## Game Path - game_path.sv

### Simple Dual Port RAM - simple_dual_port_ram.sv

### Main State Machine

### Last Pushed Direction

### Linear Feedback Shift Register

## Game Plot - game_plot.sv

## Hex Display - hex_display.sv

## VGA IP

The VGA core used in this project was developed at the University of Toronto. This core was introduced to me in the CPEN 311 course at the University of British Columbia. The original website can be found here: [https://www.eecg.utoronto.ca/~jayar/ece241_07F/vga/](https://www.eecg.utoronto.ca/~jayar/ece241_07F/vga/).

The files necessary for this VGA_IP are:
- vga_adapter.sv
- vga_address_translator.sv
- vga_controller.sv
- vga_pll.sv




