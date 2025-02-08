# Snake_game
Snake game implemented on the DE1-SoC

## Table of Contents
- [Objectives](#objectives)
- [Introduction](#introduction)
- [Top Snake Game](#top-snake-game---top_snake_gamesv)
- [Switch Debounce](#switch-debounce---switch_debouncesv)
- [Button Sync](#button-sync---button_syncsv)
- [Init Screen](#init-screen---init_screensv)
- [Game Path](#game-path---game_pathsv)
  - [Simple Dual Port RAM](#simple-dual-port-ram---simple_dual_port_ramsv)
  - [Main State Machine](#main-state-machine)
  - [Last Pushed Direction](#last-pushed-direction)
  - [Linear Feedback Shift Register](#linear-feedback-shift-register)
- [Game Plot](#game-plot---game_plotsv)
- [Hex Display](#hex-display---hex_displaysv)
- [VGA IP](#hex-display---hex_displaysv)
- [Timing Closure](#timing-closure)

## Objectives

- Gain experience with System Verilog design and verification
- Research and Implement Clock Domain Crossing techniques
- Integrate external IP into a project
- Learn about Timing Constraints and achieve Timing Closure
- Gain experience Inferring Memory blocks within HDL code 
- Explore and implement Randomization in hardware
- Improve project skills from beginning to end:
  - Idea creation
  - Design and implementation
  - Research
  - Verification
  - Iteration
  - Technical writeup and presentation

## Introduction

This project was created to implement a snake game in hardware on the [De1-SoC development board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=205&No=836&PartNo=1#contents).

**<ins>Description of the Snake Game:</ins>**

  **Mechanics:** A snake that moves on a grid. The direction the snake moves is controlled by the player. At each time step, the head moves forward one square and the tail follows one square. 

  **Objective:** The objective of the game is to collect a Point on the grid. If the snake runs into the Point, the length of the snake increases by one square, and a new Point is plotted at random.

  **Challenge:** The snake must avoid both the walls of the grid and the snake tail that is trailing behind the snake head. If the snake collides with either, the game is over.

  //insert photo of snake game

The file structure of the project is as follows:

![Code Hierarchy Image](supplemental/code_hierarchy.png)


## Top Snake Game - top_snake_game.sv

A basic flow structure of Top Snake Game is as follows:

![Snake Game Diagram](supplemental/snake_game_diagram.png)

A diagram of the state machine is as follows:

//insert state machine diagram

## Switch Debounce - switch_debounce.sv

The Switch Debounce module is created to first synchronize the input from SW[9] on the DE1-SoC board and then debounce the output of the synchronizer. This signal is used as a reset to the entire system. Note: SW[9] is completely asynchronous.

The synchronizer is implemented using two flip flops in series. The debounce circuit is implemented using a counter to enable a final flip flop. This enable is turned on when the counter is greater than or equal to a value specified as a parameter passed to this module.

The counter is only triggered when the output of the synchronizer and the output of the debounce flip flop are not equal. 

Since the switch is driven by human control, it will be much slower than the clock speed of the FPGA and there is no concern about loss of data. 

A diagram of the Switch Debounce Circuit can be seen below:

![Switch Debounce Diagram](supplemental/switch_debounce_diagram.png)

## Button Sync - button_sync.sv

The Button Sync module implements synchronizers for each of the 4 buttons on the DE1-SoC board which are used to control the direction of the snake and the game. These 4 buttons are completely asynchronous. 

Technically there could be issues with these input 'data packets' of the buttons crossing into the FPGA clock domain, i.e. the 'data packet' of sampled buttons at the input of the synchronizer may not all appear on the output of the synchronizer at the same time due to potential metastability and subsequent settling. This, however, is not a concern as these buttons are human controlled and the difference of one single 20 ns clock cycle is negligible compared to the human reaction speed of 250 ms.

Also note that these inputs are not debounced as they have already been debounced externally by a Schmitt Trigger on the board.

A diagram of the Button Sync circuit can be see below:

![Button Sync Diagram](supplemental/button_sync_diagram.png)

## Init Screen - init_screen.sv

The purpose of Init Screen is to drive the VGA to plot the background of the Snake Game.

Init Screen follows a waitrequest protocol. When waitrequest is high, init screen is unable to process a start command. Once waitrequest is low, it is able to process a start command. Once it receives the start command, it will begin outputting data to drive the VGA, and will set its waitrequest high again.

The protocol can be seen in detail with waveforms below:

![Init Screen Waitrequest Protocol](supplemental/init_screen_waitreq.PNG)

The way that Init Screen works is it cycles x and y coordinates through (0,0) to (159,119) (all of the pixels on the VGA) and uses comparators to determine if the pixel should be black (background) or white (border of game grid). A code snippet of the comparators is shown below:

```systemverilog
                //to set up outline, set up a width of the outline as 6 pixels
                // x axis: [26-31] left outline and [128-133] right outline
                // y axis: [6-11] top outline and [108-113] bottom outline
                if( x >= 8'd26 && x <= 8'd133 && y >= 7'd6 && y <= 7'd113) begin
                    if( x >= 8'd32 && x <= 8'd127 && y >= 7'd12 && y <= 7'd107) begin
                        //inside colour
                        vga_colour = 3'b000;
                    end
                    else begin
                        //outline colour
                        vga_colour = 3'b111;
                    end
                end
                else begin
                    //outside colour
                    vga_colour = 3'b000;
                end
```

The final product of a properly displayed background can be seen below:

//insert picture of background of game

The flow of data in Init Screen can be seen in the diagram below:

![Init Screen Diagram](supplemental/init_screen_diagram.png)

The State Machine of Init Screen is shown below:

//insert init_screen_statemachine


## Game Path - game_path.sv

### Simple Dual Port RAM - simple_dual_port_ram.sv

### Main State Machine

### Last Pushed Direction

### Linear Feedback Shift Register

## Game Plot - game_plot.sv

Game Plot translates the plotting requests by Game Path into coordinates that the VGA can plot.

Game Path thinks in logic terms of a 16x16 grid for its game logic, and its outputs aimed to drive the VGA are also in this 16x16 grid format. Game Plot's goal is to translate this 16x16 grid format to the actual VGA coordinates on screen.

Game Path's 16x16 grid is represented with 96x96 VGA pixels, where each square of Game Path's grid is made up of 6x6 VGA pixels.

Game Plot follows a waitrequest protocol. This is the same protocol as displayed in Init Screen.

Game Plot's data flow can be seen below:

![Game Plot Diagram](supplemental/game_plot_diagram.png)

Game Plot's state machine can be seen below:

//game_plot_statemachine

## Hex Display - hex_display.sv

Hex Display's aim is to display the score of a player while playing the game in Hexadecimal format. 

Hex Display can be used to display an inputed number on the boards' 7 segment hex display in hexadecimal format. This instantiation leaves four of the board's 7-segment hex's blank and displays on just two of them as the maximum attainable score of 254 can be represented with just two hexadecimal numbers.

This module is purely combinational.

Please note that although the module is written to be able to display on all 6 7-segment hex displays, the Parameter given in this project's instantiation specifies that only two of the displays will be used, and thus the other 4 will be hard coded to be blank.

Hex Display's data flow diagram can be seen below:

![Hex Display Diagram](supplemental/hex_display_diagram.png)

## VGA IP

The VGA core used in this project was developed at the University of Toronto. This core was introduced to me in the CPEN 311 course at the University of British Columbia. The original website can be found here: [https://www.eecg.utoronto.ca/~jayar/ece241_07F/vga/](https://www.eecg.utoronto.ca/~jayar/ece241_07F/vga/).

The files necessary for this VGA IP are:
- vga_adapter.sv
- vga_address_translator.sv
- vga_controller.sv
- vga_pll.sv

The Black Box diagram of the VGA IP can be seen below:

![VGA Black Box](supplemental/VGA_blackbox.PNG)


## Timing Closure



