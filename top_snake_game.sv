module top_snake_game(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);


    //variables

    //assign inputs from board
    logic rst_n;
    assign rst_n = ~SW[9]; //restart if pushed up?

    logic LEFT, UP, DOWN, RIGHT;
    assign {LEFT, UP, DOWN, RIGHT} = ~KEY[3:0]; //inverted as keys are active low



    //instantiations

    //For init_screen
    logic is_start;
    logic is_waitrequest;
    logic is_vga_plot;
    logic [7:0] is_vga_x;
    logic [6:0] is_vga_y;
    logic [2:0] is_vga_colour;

    /* init_screen( 
        //inputs
        input logic clk, 
        input logic rst_n, 
        input logic start, 
        //outputs
        output logic waitrequest, 
        output logic vga_plot,
        output logic [7:0] vga_x, 
        output logic [6:0] vga_y, 
        output logic [2:0] vga_colour
    );*/
    init_screen init_screen_u0(
        //inputs
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .start(is_start),
        //outputs
        .waitrequest(is_waitrequest),
        .vga_plot(is_vga_plot),
        .vga_x(is_vga_x),
        .vga_y(is_vga_y),
        .vga_colour(is_vga_colour)
    );



    //For game_plot
    logic gplot_game_plot;
    logic [3:0] gplot_game_x;
    logic [3:0] gplot_game_y;
    logic [2:0] gplot_game_colour;
    logic gplot_waitrequest;
    logic gplot_vga_plot;
    logic [7:0] gplot_vga_x;
    logic [6:0] gplot_vga_y;
    logic [2:0] gplot_vga_colour;

    /* game_plot( 
        //inputs
        input logic clk, 
        input logic rst_n,
        input logic game_plot, 
        input logic [3:0] game_x,
        input logic [3:0] game_y, 
        input logic [2:0] game_colour,
        //outputs
        output logic waitrequest, 
        output logic vga_plot, 
        output logic [7:0] vga_x, 
        output logic [6:0] vga_y, 
        output logic [2:0] vga_colour
    );*/
    game_plot game_plot_u0(
        //inputs
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .game_plot(gplot_game_plot),
        .game_x(gplot_game_x),
        .game_y(gplot_game_y),
        .game_colour(gplot_game_colour),
        //outputs
        .waitrequest(gplot_waitrequest),
        .vga_plot(gplot_vga_plot),
        .vga_x(gplot_vga_x),
        .vga_y(gplot_vga_y),
        .vga_colour(gplot_vga_colour)
    );


    //for game_path
    logic gpath_start;
    //assign gpath_start = ~(KEY[0] && KEY[1] && KEY[2] && KEY[3]); //all are active low, if any go low it will trigger start
    logic gpath_waitrequest;

    /* game_path(
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
                );*/
    game_path game_path_u0(
        //inputs
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .start(gpath_start),
        .in_left(LEFT),
        .in_right(RIGHT),
        .in_up(UP),
        .in_down(DOWN),
        //outputs
        .waitrequest(gpath_waitrequest),
        //inputs for game_plot
        .game_plot_waitrequest(gplot_waitrequest),
        //outputs for game_plot
        .game_plot(gplot_game_plot),
        .game_x(gplot_game_x),
        .game_y(gplot_game_y),
        .game_colour(gplot_game_colour)
    );

    /*Initiated within game_path
    //For on chip memory
    logic ram_we;
    logic [7:0] ram_wr_data;
    logic [7:0] ram_wr_addr;
    logic [7:0] ram_rd_addr;
    logic [7:0] ram_rd_data;

    /* simple_dual_port_ram(
        //inputs
        input clk,
        input we,
        input [7:0] d,
        input [7:0] write_address, read_address,
        //outputs
        output reg [7:0] q
    );
    simple_dual_port_ram ram_u0(
        .clk(CLOCK_50),
        .we(ram_we),
        .d(ram_wr_data),
        .write_address(ram_wr_addr),
        .read_address(ram_rd_addr),
        .q(ram_rd_data)
    );*/

    //For VGA
    //create 10 bit VGA_RGB for VGA module output, assign 8 bit VGA_RGB for output to DE1_SOC
    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;

    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];

    /* vga_adapter(
            //inputs
			resetn,
			clock,
			[2:0] colour,
			[7:0] x, 
            [6:0] y, 
            plot,
			//Signals for the DAC to drive the monitor.
            //outputs
			[9:0] VGA_R,
			[9:0] VGA_G,
			[9:0] VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK
    );*/
    vga_adapter#(.RESOLUTION("160x120")) vga_u0(
        //inputs
        .resetn(rst_n),
        .clock(CLOCK_50), 
        .colour(VGA_COLOUR),
        .x(VGA_X), 
        .y(VGA_Y), 
        .plot(VGA_PLOT),
        //ouputs
        .VGA_R(VGA_R_10), 
        .VGA_G(VGA_G_10), 
        .VGA_B(VGA_B_10),
        .*
        /*.VGA_HS(),
        .VGA_VS(),
        .VGA_BLANK(),
        .VGA_SYNC(),
        .VGA_CLK()*/
    );

    enum logic [2:0] {IDLE, INIT_SCREEN, INIT_SCREEN_2, GAME_PATH} state;
    //sequential
    //synchronous reset
    always_ff@(posedge CLOCK_50) begin
        if(!rst_n) begin
            state <= IDLE;
            is_start <= 1'b0;
            gpath_start <= 1'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    //for testing only
                    state <= GAME_PATH;
                    gpath_start <= 1'b1;
                    /*
                    state <= INIT_SCREEN;
                    is_start <= 1'b1;
                    */
                end
                INIT_SCREEN: begin
                    if(!is_waitrequest) begin
                        //turn off start once command is accepted
                        is_start <= 1'b0;
                        state <= INIT_SCREEN_2;
                    end
                end
                INIT_SCREEN_2: begin
                    if(!is_waitrequest) begin
                        //continue once init screen is finished
                        state <= GAME_PATH;
                        gpath_start <= 1'b1;
                    end
                end
                GAME_PATH: begin
                    //stays in state, allows game_plot to drive vga, game_plot is driven by game_path
                    //state depends on user input to start games with button press
                end

            endcase
        end
    end


    //combinational
    //drive VGA_PLOT, VGA_X, VGA_Y, VGA_COLOUR
    always_comb begin
        //defaults
        VGA_PLOT = 1'b0;
        VGA_X = 8'd0;
        VGA_Y = 7'd0;
        VGA_COLOUR = 3'd0;
        case(state)
            IDLE: begin
            end
            INIT_SCREEN: begin
            end
            INIT_SCREEN_2: begin
                VGA_PLOT = is_vga_plot;
                VGA_X = is_vga_x;
                VGA_Y = is_vga_y;
                VGA_COLOUR = is_vga_colour;
            end
            GAME_PATH: begin
                VGA_PLOT = gplot_vga_plot;
                VGA_X = gplot_vga_x;
                VGA_Y = gplot_vga_y;
                VGA_COLOUR = gplot_vga_colour;
            end
        endcase
    end
    


endmodule: top_snake_game