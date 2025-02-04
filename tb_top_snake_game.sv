`timescale 1ps/1ps
module tb_top_snake_game();

/* top_snake_game(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);*/

    //inputs
    logic CLOCK_50; 
    logic [3:0] KEY;
    logic [9:0] SW;
    //outputs
    logic [9:0] LEDR;
    logic [6:0] HEX0; 
    logic [6:0] HEX1; 
    logic [6:0] HEX2;
    logic [6:0] HEX3; 
    logic [6:0] HEX4; 
    logic [6:0] HEX5;
    logic [7:0] VGA_R; 
    logic [7:0] VGA_G; 
    logic [7:0] VGA_B;
    logic VGA_HS; 
    logic VGA_VS; 
    logic VGA_CLK;
    logic [7:0] VGA_X; 
    logic [6:0] VGA_Y;
    logic [2:0] VGA_COLOUR; 
    logic VGA_PLOT;

    logic rst;
    assign SW[9] = rst;

    logic LEFT, UP, DOWN, RIGHT;
    assign  KEY[3:0] = ~{LEFT, UP, DOWN, RIGHT}; //active low

    logic clk;
    assign CLOCK_50 = clk;

    top_snake_game DUT(.*);

    //set up clk
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic reset(ref clk, ref rst_flag, ref rst);
        begin
            @(posedge clk) @(negedge clk)
            rst = 1'b1;
            @(posedge rst_flag) //wait for reset signal to begin (past debounce stage)
            @(posedge clk) @(negedge clk)
            rst = 1'b0;
            @(negedge rst_flag) //wait for reset signal to finish
            #5;
        end
    endtask: reset

    initial begin
        {LEFT, UP, DOWN, RIGHT} = 4'b0000;
        DUT.sw_debounce_u0.out_sw = 1'b0; //setup out_sw for comparison in block
        
        reset(clk, DUT.rst, rst);

        wait(DUT.state === DUT.GAME_PATH);
        #100;
        @(posedge clk) @(negedge clk)
        {LEFT, UP, DOWN, RIGHT} = 4'b0_0_1_0;
        #70
        @(posedge clk) @(negedge clk)
        {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;

        /*while(DUT.game_path_u0.state != DUT.game_path_u0.DEATH) begin
            if(DUT.game_path_u0.state == DUT.game_path_u0.STALL) begin
                //correct x first
                if(DUT.game_path_u0.apple[3:0] > DUT.game_path_u0.head[3:0]) begin
                    {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_1;
                end
                else if(DUT.game_path_u0.apple[3:0] < DUT.game_path_u0.head[3:0]) begin
                    {LEFT, UP, DOWN, RIGHT} = 4'b1_0_0_0;
                end
                //then correct y
                else if(DUT.game_path_u0.apple[7:4] > DUT.game_path_u0.head[7:4]) begin
                    {LEFT, UP, DOWN, RIGHT} = 4'b0_0_1_0;
                end
                else if(DUT.game_path_u0.apple[7:4] < DUT.game_path_u0.head[7:4]) begin
                    {LEFT, UP, DOWN, RIGHT} = 4'b0_1_0_0;
                end
            end
            #11;
        end*/

        wait(DUT.game_path_u0.state == DUT.game_path_u0.STALL);
        @(posedge clk) @(negedge clk)
        {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_1;
        @(posedge clk) @(negedge clk)
        #410;

        wait(DUT.game_path_u0.state == DUT.game_path_u0.STALL);
        @(posedge clk) @(negedge clk)
        {LEFT, UP, DOWN, RIGHT} = 4'b0_0_1_0;
        @(posedge clk) @(negedge clk)
        #410;

        {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;

        wait(DUT.game_path_u0.state == DUT.game_path_u0.DEATH_STALL);
        @(posedge clk) @(negedge clk)
        {LEFT, UP, DOWN, RIGHT} = 4'b0_0_1_0;
        @(posedge clk) @(negedge clk)


        wait(DUT.game_path_u0.state == DUT.game_path_u0.DEATH_END);
        @(posedge clk) @(negedge clk)
        {LEFT, UP, DOWN, RIGHT} = 4'b0_0_0_0;
        @(posedge clk) @(negedge clk)

        wait(DUT.game_path_u0.state === DUT.game_path_u0.IDLE);
        #10
        $display("Finished at time %t", $time);
        $stop;
    end

endmodule: tb_top_snake_game