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



    //make a function to return value related to the corresponding 7-segment hex sequence
    function logic [3:0] hexdisplay2num( logic [7:0] hex);
        case(hex)
            7'b1000000: return 4'h0; //0
            7'b1111001: return 4'h1; //1
            7'b0100100: return 4'h2; //2
            7'b0110000: return 4'h3; //3
            7'b0011001: return 4'h4; //4
            7'b0010010: return 4'h5; //5
            7'b0000010: return 4'h6; //6
            7'b1111000: return 4'h7; //7
            7'b0000000: return 4'h8; //8
            7'b0010000: return 4'h9; //9
            7'b0001000: return 4'hA; //A
            7'b0000011: return 4'hB; //b
            7'b1000110: return 4'hC; //C
            7'b0100001: return 4'hD; //d
            7'b0000110: return 4'hE; //E
            7'b0001110: return 4'hF; //F
            7'b0111111: return 4'hz; //-
            default: return 4'hx;
        endcase
    endfunction

    logic [3:0] hex0eq, hex1eq, hex2eq, hex3eq, hex4eq, hex5eq;
    always_comb begin
        hex0eq = hexdisplay2num(HEX0);
        hex1eq = hexdisplay2num(HEX1);
        hex2eq = hexdisplay2num(HEX2);
        hex3eq = hexdisplay2num(HEX3);
        hex4eq = hexdisplay2num(HEX4);
        hex5eq = hexdisplay2num(HEX5);
    end


    

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