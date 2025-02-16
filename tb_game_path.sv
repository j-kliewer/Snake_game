`timescale 1ps/1ps

module tb_game_path();

    //constants for colour
    parameter [2:0] BLACK = 3'b000;
    parameter [2:0] RED = 3'b100;
    parameter [2:0] YELLOW = 3'b110;
    parameter [2:0] GREEN = 3'b010;
    parameter [2:0] CYAN = 3'b011;
    parameter [2:0] BLUE = 3'b001;
    parameter [2:0] MAGENTA = 3'b101;
    parameter [2:0] WHITE = 3'b111;

    //variables
    logic clk;
    logic rst_n;
    logic start;
    logic LEFT, RIGHT, UP, DOWN;
    logic waitrequest;
    logic gplot_waitrequest;
    logic game_plot;
    logic [3:0] game_x, game_y;
    logic [2:0] game_colour;
    logic [7:0] hex_points;

    //instantitations
        /* game_path#(
            //parameters
            parameter [25:0] STALL_BASE = 26'd25_000_000,
            parameter [25:0] STALL_DECR = 26'd39_000
            )(
            //inputs
            input logic clk, 
            input logic rst_n, 
            input logic start, 
            input logic in_left, 
            input logic in_right, 
            input logic in_up, 
            input logic in_down,
            //outputs 
            output logic waitrequest,
            //for game_plot
            //game_plot inputs
            input logic game_plot_waitrequest, 
            //game_plot outputs
            output logic game_plot,
            output logic [3:0] game_x, 
            output logic [3:0] game_y, 
            output logic [2:0] game_colour
            //hex_display outputs
            output logic [7:0] hex_points
        );*/
        game_path #(.STALL_BASE(26'd40), .STALL_DECR(26'd0)) DUT(
            //inputs
            .clk(clk),
            .rst_n(rst_n),
            .start(start),
            .in_left(LEFT),
            .in_right(RIGHT),
            .in_up(UP),
            .in_down(DOWN),
            //outputs
            .waitrequest(waitrequest),
            //inputs for game_plot
            .game_plot_waitrequest(gplot_waitrequest),
            //outputs for game_plot
            .game_plot(game_plot),
            .game_x(game_x),
            .game_y(game_y),
            .game_colour(game_colour),
            //outputs for hex_display
            .hex_points(hex_points)
        );

        //tb variables
        logic print;

        initial begin
            clk = 1'b0;
            forever #5 clk = ~clk;
        end


        //set inputs to DUT
        /*
            rst_n = ;

            start = ;

            LEFT = ;
            RIGHT = ;
            UP = ;
            DOWN = ;
            gplot_waitrequest = ;

        */
        //check outputs from DUT
        /*
            assert(waitrequest === 1'b0) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(game_x === ) else $stop;
            assert(game_y === ) else $stop;
            assert(game_colour === ) else $stop;
            assert(hex_points === ) else $stop;
        */

        task automatic print_screen(ref clk, ref print); 
            @(negedge clk);
            print = 1;
            @(posedge clk); @(negedge clk);
            print = 0;
        endtask: print_screen
    
        //exp format: 8'hx_y
        //need to get to associated state before utilizing task
        task automatic check_head(ref clk, ref game_plot, ref [3:0] game_x, ref [3:0] game_y, ref[2:0] game_colour,
                                  ref gplot_waitrequest, input [7:0] exp_head);
            
            assert(game_plot === 1'b1) else begin $display("Error in Head game_plot"); $stop; end
            assert(game_x === exp_head[7:4]) else begin $display("Expected Head X: %d ; Actual Head X: %d",exp_head[7:4],game_x); $stop; end
            assert(game_y === exp_head[3:0]) else begin $display("Expected Head Y: %d ; Actual Head Y: %d",exp_head[3:0],game_y); $stop; end
            assert(game_colour === GREEN) else begin $display("Expected Head Colour, game_colour = %b",GREEN,game_colour); $stop; end
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;
        endtask: check_head

        task automatic check_neck(ref clk, ref game_plot, ref [3:0] game_x, ref [3:0] game_y, ref[2:0] game_colour,
                                  ref gplot_waitrequest, input [7:0] exp_neck);
            assert(game_plot === 1'b1) else begin $display("Error in Neck game_plot"); $stop; end
            assert(game_x === exp_neck[7:4]) else begin $display("Expected Neck X: %d ; Actual Neck X: %d",exp_neck[7:4],game_x); $stop; end
            assert(game_y === exp_neck[3:0]) else begin $display("Expected Neck Y: %d ; Actual Neck Y: %d",exp_neck[3:0],game_x); $stop; end
            assert(game_colour === WHITE) else begin $display("Expected Neck Colour: %b, game_colour = %b",WHITE,game_colour); $stop; end
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;
        endtask: check_neck

        task automatic check_tail(ref clk, ref game_plot, ref [3:0] game_x, ref [3:0] game_y, ref[2:0] game_colour,
                                  ref gplot_waitrequest, input [7:0] exp_tail);
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === exp_tail[7:4]) else begin $display("Expected Tail X: %d ; Actual Tail X: %d",exp_tail[7:4],game_x); $stop; end
            assert(game_y === exp_tail[3:0]) else begin $display("Expected Tail Y: %d ; Actual Tail Y: %d",exp_tail[3:0],game_x); $stop; end
            assert(game_colour === BLACK) else begin $display("Expected Tail Colour: %b, game_colour = %b",BLACK,game_colour); $stop; end
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;
        endtask: check_tail

        //MAIN TESTING BLOCK
        initial begin

            #5

            //set initial inputs
            start = 0;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            gplot_waitrequest = 0;

            #5; @(negedge clk); rst_n = 1'b0; @(posedge clk); @(negedge clk); rst_n = 1'b1;

            //IDLE
            //wait for state
            wait(DUT.state === DUT.IDLE);
            //check outputs
            assert(waitrequest === 1'b0) else $stop;
            assert(game_plot === 1'b0) else $stop;
            @(negedge clk)
            start = 1'b1;
            {LEFT, UP, DOWN, RIGHT} = 4'b1_0_0_0;
            gplot_waitrequest = 1;
            @(posedge clk); @(negedge clk);

            //INIT_APPLE
            wait(DUT.state === DUT.INIT_APPLE) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 8) else $stop;
            assert(game_colour === RED) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //INIT_HEAD
            wait(DUT.state === DUT.INIT_HEAD) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 7) else $stop;
            assert(game_y === 1) else $stop;
            assert(game_colour === GREEN) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //INIT_TAIL
            wait(DUT.state === DUT.INIT_TAIL) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 7) else $stop;
            assert(game_y === 0) else $stop;
            assert(game_colour === WHITE) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            //wait to release initial button
            #40;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button
            //put waitrequest back up for default
            @(posedge clk); @(negedge clk);
            $display("LFSR SEED = %b\n", DUT.seed_count);
            assert(DUT.seed_count === 11'b00000001001) else $stop;
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (7,1) (7,0)
            //point: (8,8)
            wait(DUT.state === DUT.STALL) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            //fork //fork so print happens in parallel in background
            //fork doesnt work in modelsim, use print_screen during STALL
                print_screen(clk, print);
            //join_none

            //make sure stall is for correct length
            #390; //40(given by parameter in instantiation) * 10 + 10 = 410 -> -20 for print_scren
            @(negedge clk);
            assert(DUT.state === DUT.COLLISION) else $stop;

            //COLLISION
            wait(DUT.state === DUT.COLLISION) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;

            //HEAD
            wait(DUT.state === DUT.HEAD) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 7) else $stop;
            assert(game_y === 2) else $stop;
            assert(game_colour === GREEN) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //NECK
            wait(DUT.state === DUT.NECK) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 7) else $stop;
            assert(game_y === 1) else $stop;
            assert(game_colour === WHITE) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //TAIL
            wait(DUT.state === DUT.TAIL) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 7) else $stop;
            assert(game_y === 0) else $stop;
            assert(game_colour === BLACK) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (7,2) (7,1)
            //point: (8,8)
            wait(DUT.state === DUT.STALL) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_1;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //COLLISION
            wait(DUT.state === DUT.COLLISION) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;

            //HEAD
            wait(DUT.state === DUT.HEAD) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 2) else $stop;
            assert(game_colour === GREEN) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //NECK
            wait(DUT.state === DUT.NECK) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 7) else $stop;
            assert(game_y === 2) else $stop;
            assert(game_colour === WHITE) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //TAIL
            wait(DUT.state === DUT.TAIL) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 7) else $stop;
            assert(game_y === 1) else $stop;
            assert(game_colour === BLACK) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (8,2) (7,2)
            //point: (8,8)
            wait(DUT.state === DUT.STALL) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_1_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //COLLISION
            wait(DUT.state === DUT.COLLISION) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;

            //HEAD
            wait(DUT.state === DUT.HEAD) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 3) else $stop;
            assert(game_colour === GREEN) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //NECK
            wait(DUT.state === DUT.NECK) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 2) else $stop;
            assert(game_colour === WHITE) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //TAIL
            wait(DUT.state === DUT.TAIL) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 0) else $stop;
            gplot_waitrequest = 1;

            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 7) else $stop;
            assert(game_y === 2) else $stop;
            assert(game_colour === BLACK) else $stop;
            assert(hex_points === 0) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (8,3) (8,2)
            //point: (8,8)
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 0) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //COLLISION
            wait(DUT.state === DUT.COLLISION) #2;

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 4) else $stop;
            assert(game_colour === GREEN) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 3) else $stop;
            assert(game_colour === WHITE) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 2) else $stop;
            assert(game_colour === BLACK) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (8,4) (8,3)
            //point: (8,8)
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 0) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //COLLISION
            wait(DUT.state === DUT.COLLISION) #2;

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 5) else $stop;
            assert(game_colour === GREEN) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 4) else $stop;
            assert(game_colour === WHITE) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 3) else $stop;
            assert(game_colour === BLACK) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (8,5) (8,4)
            //point: (8,8)
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 0) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //COLLISION
            wait(DUT.state === DUT.COLLISION) #2;

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 6) else $stop;
            assert(game_colour === GREEN) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 5) else $stop;
            assert(game_colour === WHITE) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 4) else $stop;
            assert(game_colour === BLACK) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (8,6) (8,5)
            //point: (8,8)
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 0) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //COLLISION
            wait(DUT.state === DUT.COLLISION) #2;

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 7) else $stop;
            assert(game_colour === GREEN) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 6) else $stop;
            assert(game_colour === WHITE) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 5) else $stop;
            assert(game_colour === BLACK) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (8,7) (8,6)
            //point: (8,8)
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 0) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //COLLISION
            wait(DUT.state === DUT.COLLISION) #2;

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 8) else $stop;
            assert(game_colour === GREEN) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 8) else $stop;
            assert(game_y === 7) else $stop;
            assert(game_colour === WHITE) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //APPLE
            wait(DUT.state === DUT.APPLE) #2;
            assert(waitrequest === 1'b1) else $stop;
            assert(game_plot === 1'b0) else $stop;
            assert(hex_points === 1) else $stop;
            gplot_waitrequest = 1;
            //new apple:
            //000_0000_1001
            //y = 0, x = 9

            //APPLE_PLOT
            wait(DUT.state === DUT.APPLE_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 9) else $stop;
            assert(game_y === 0) else $stop;
            assert(game_colour === RED) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (8,8) (8,7) (8,6)
            //point: (9,0)
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b1_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h7_8); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h8_8); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h8_6); //TAIL


            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (7,8) (8,8) (8,7)
            //point: (9,0)
            //last direction: left
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_1_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h7_7); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h7_8); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h8_7); //TAIL


            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (7,7) (7,8) (8,8)
            //point: (9,0)
            //last direction: up
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_1;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h8_7); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h7_7); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h8_8); //TAIL



            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (8,7) (7,7) (7,8)
            //point: (9,0)
            //last direction: right
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_7); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h8_7); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h7_8); //TAIL

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (9,7) (8,7) (7,7)
            //point: (9,0)
            //last direction: right
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_1_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_6); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_7); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h7_7); //TAIL

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (9,6) (9,7) (8,7)
            //point: (9,0)
            //last direction: right
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_1_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_5); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_6); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h8_7); //TAIL

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (9,5) (9,6) (9,7)
            //point: (9,0)
            //last direction: up
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_4); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_5); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_7); //TAIL

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (9,4) (9,5) (9,6)
            //point: (9,0)
            //last direction: up
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_3); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_4); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_6); //TAIL

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (9,3) (9,4) (9,5)
            //point: (9,0)
            //last direction: up
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_2); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_3); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_5); //TAIL

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (9,2) (9,3) (9,4)
            //point: (9,0)
            //last direction: up
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_1); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_2); //NECK
            //TAIL_PLOT
            wait(DUT.state === DUT.TAIL_PLOT) #2;
            check_tail(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_4); //TAIL

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (9,1) (9,2) (9,3)
            //point: (9,0)
            //last direction: up
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 1) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            //HEAD_PLOT
            wait(DUT.state === DUT.HEAD_PLOT) #2;
            check_head(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_0); //HEAD
            //NECK_PLOT
            wait(DUT.state === DUT.NECK_PLOT) #2;
            check_neck(clk, game_plot, game_x, game_y, game_colour, gplot_waitrequest, 8'h9_1); //NECK

            //APPLE
            //new apple:
            //000_0000_1001
            //00000010011 //1
            //00000100111 //2
            //00001001111 //3
            //00010011111 //4
            //00100111111 //5
            //01001111110 //6
            //10011111101 //7
            //001_1111_1010 //8

            //y = 15, x = 10

            //APPLE_PLOT
            wait(DUT.state === DUT.APPLE_PLOT) #2;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 10) else $stop;
            assert(game_y === 15) else $stop;
            assert(game_colour === RED) else $stop;
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;

            //STALL///////////////////////////////////////////////////////////////////////////////////////////////////////////
            //snake: (9,0) (9,1) (9,2)
            //point: (10,15)
            //last direction: up
            wait(DUT.state === DUT.STALL) #2;
            assert(hex_points === 2) else $stop;
            print_screen(clk, print);

            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
            #10;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0; //release button

            wait(DUT.state === DUT.COLLISION) #2;

            wait(DUT.state === DUT.DEATH_STALL) #2;
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_1;

            wait(DUT.state === DUT.DEATH) #2;

            //cover snake from tail to head
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 9) else $stop;
            assert(game_y === 2) else $stop;
            assert(game_colour === BLACK) else $stop;

            //cover snake from tail to head
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 9) else $stop;
            assert(game_y === 1) else $stop;
            assert(game_colour === BLACK) else $stop;

            //cover snake from tail to head
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 9) else $stop;
            assert(game_y === 0) else $stop;
            assert(game_colour === BLACK) else $stop;

            //cover apple
            @(negedge clk);
            gplot_waitrequest = 0;
            @(posedge clk); @(negedge clk);
            gplot_waitrequest = 1;
            assert(game_plot === 1'b1) else $stop;
            assert(game_x === 10) else $stop;
            assert(game_y === 15) else $stop;
            assert(game_colour === BLACK) else $stop;
            #10;
            gplot_waitrequest = 0;

            #30;
            assert(DUT.state === DUT.DEATH) else $stop;
            @(negedge clk);
            {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;

            #10;
            assert(DUT.state === DUT.IDLE) else $stop;
            assert(hex_points === 2) else $stop;
            print_screen(clk, print);

            #30;
            $display("Finished at time %t", $time);
            $stop;

        end

        simple_game_adapter game_adapter(
            // inputs
            .rst_n(rst_n), .clk(clk), .plot(game_plot), .x(game_x), .y(game_y), .colour(game_colour), .print(print)
        );

endmodule: tb_game_path



module simple_game_adapter(
    input logic rst_n,
    input logic clk,
    input logic plot,
    input logic [3:0] x,
    input logic [3:0] y,
    input logic [2:0] colour,
    input logic print
    );
    parameter XLIM = 16;
    parameter YLIM = 16;
    logic [XLIM-1:0][YLIM-1:0][7:0] ascii_array;
    int i,j;

    initial clear_array();

    always@(posedge clk) begin
        if(~rst_n) clear_array();
        else if(print) print_array();
        else if(plot) begin
            if(x<=XLIM-1 && y<=YLIM-1)
            case(colour)
                3'b000: ascii_array[x][y] = "-";//black
                3'b100: ascii_array[x][y] = "R";//red
                3'b110: ascii_array[x][y] = "Y";//yellow
                3'b010: ascii_array[x][y] = "G";//green
                3'b011: ascii_array[x][y] = "C";//cyan
                3'b001: ascii_array[x][y] = "B";//blue
                3'b101: ascii_array[x][y] = "M";//magenta
                3'b111: ascii_array[x][y] = "W";//white
                default: ascii_array[x][y] = "X";
            endcase
        end
    end

    task print_array();
        $write("X \t ");
        for(i=0;i<=XLIM-1;i++) if(i<10) $write(" %0d ",i); else $write(" %0d",i);
        $write("\n\t "); for(i=0; i<=XLIM-1;i++) $write("---"); $write("\n");
        for(j=0;j<=YLIM-1;j++) begin
            $write("%0d \t|",j);
            for(i=0;i<=XLIM-1;i++) $write(" %0s ", ascii_array[i][j]);
            $write("|\n");
        end
        $write("\t "); for(i=0; i<=XLIM-1;i++) $write("---"); $write("\n\n");
    endtask

    task clear_array();
        for(j=0;j<=YLIM-1;j++) begin
            for(i=0;i<=XLIM-1;i++) begin
                ascii_array[i][j] = "-";
            end
        end
    endtask

endmodule: simple_game_adapter



