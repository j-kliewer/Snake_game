`timescale 1ps/1ps
module tb_game_plot();

    //instantiation
    //inputs
    logic clk;
    logic rst_n;
    logic game_plot;
    logic [3:0] game_x, game_y;
    logic [2:0] game_colour;
    //outputs
    logic waitrequest;
    logic vga_plot;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;

    /* game_plot( input logic clk, input logic rst_n,
                 input logic game_plot, input logic [3:0] game_x,
                 input logic [3:0] game_y, input logic [2:0] game_colour,
                 output logic waitrequest, 
                 output logic vga_plot, output logic [7:0] vga_x, 
                 output logic [6:0] vga_y, output logic [2:0] vga_colour);*/
    
    game_plot DUT(.*);

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    /*always@(posedge clk) begin
        if(waitrequest) begin

        end
    end*/

    //assign loop bounds for check_plot
    int test_x;
    int test_y;
    int i;
    int j;

    task check_plot();
        test_x = game_x*6 + 32;
        test_y = game_y*6 + 12;

        //make sure plot goes through all pixels correctly
        for(i = test_x; i <= test_x + 5; i = i+1) begin
            for(j = test_y; j <= test_y + 5; j = j+1) begin
                @(posedge clk); @(negedge clk);
                $display("vga_x is %d, vga_y is %d, vga_colour is %3b, vga_plot is %b", vga_x, vga_y, vga_colour, vga_plot);
                assert(vga_x === i) else begin $display("x is %d, should be %d", vga_x, i); $stop; end
                assert(vga_y === j) else begin $display("y is %d, should be %d", vga_y, j); $stop; end
                assert(vga_colour === game_colour) else begin $display("colour is %3b, should be %3b", vga_colour, game_colour); $stop; end
                assert(vga_plot === 1'b1) else begin $display("vga_plot != 1"); $stop; end
                assert(waitrequest === 1'b1) else begin $display("waitrequest on error"); $stop; end
            end
        end
        @(posedge clk); @(negedge clk); 
        assert(waitrequest === 1'b0) $display("all tests passed"); else begin $display("waitrequest off error"); $stop; end 
    endtask


    //main test loop
    initial begin
        #5;

        //reset
        @(negedge clk); rst_n = 1'b0;
        @(posedge clk); @(negedge clk); rst_n = 1'b1;

        game_x = 4'd0;
        game_y = 4'd0;
        game_colour = 3'b000;
        game_plot = 1'b1;
        check_plot();

        game_plot = 1'b0;
        @(posedge clk); @(negedge clk);
        game_x = 4'd5;
        game_y = 4'd8;
        game_colour = 3'b001;
        game_plot = 1'b1;
        check_plot();

        game_plot = 1'b0;
        @(posedge clk); @(negedge clk);
        game_x = 4'd0;
        game_y = 4'd15;
        game_colour = 3'b010;
        game_plot = 1'b1;
        check_plot();
        game_plot = 1'b0;

        game_plot = 1'b0;
        @(posedge clk); @(negedge clk);
        game_x = 4'd15;
        game_y = 4'd15;
        game_colour = 3'b111;
        game_plot = 1'b1;
        check_plot();
        game_plot = 1'b0;


        //make sure it does not plot outside given area
        //note x and y are 4 bit, so cannot exceed 16x16 area
        /*game_plot = 1'b0;
        @(posedge clk); @(negedge clk);
        game_x = 4'd16;
        game_y = 4'd16;
        game_colour = 3'b100;
        game_plot = 1'b1;
        @(posedge clk); @(negedge clk);
        assert(waitrequest === 1'b0) else $stop;
        assert(vga_plot === 1'b0) else $stop;
        @(posedge clk); @(negedge clk);
        assert(vga_plot === 1'b0) else $stop;
        game_plot = 1'b0;*/


        $display("Finished at time %t", $time);
        $stop;
    end

endmodule: tb_game_plot