`timescale 1ps/1ps
module tb_init_screen();

//instantiation
/* init_screen( 
    logic input clk,
    logic input rst_n,
    logic input start,
    logic output waitrequest,
    logic output vga_plot,
    logic [7:0] output vga_x,
    logic [6:0] output vga_y,
    logic output [2:0] vga_colour);*/

//input
logic clk;
logic rst_n;
logic start;
//outputs
logic waitrequest;
logic vga_plot;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;

init_screen DUT(.*);

//set up clk
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

always@(posedge clk) begin
    if (vga_plot) begin
        if(vga_x >= 26 && vga_x <= 133 && vga_y >= 6 && vga_y <= 113) begin
            if(vga_x >= 32 && vga_x <= 127 && vga_y >= 12 && vga_y <= 107) begin
                assert(vga_colour === 3'b000) else $stop; //inside square, expecting black
            end
            else begin
                assert(vga_colour === 3'b111) else $stop; //outline of square, expecting white
            end
        end
        else begin
            assert(vga_colour === 3'b000) else $stop; //outside square, expecting black
        end
    end
end

//initializing startloop
initial begin

    #5;

    //reset
    @(negedge clk); rst_n = 1'b0;
    @(posedge clk); @(negedge clk); rst_n = 1'b1;

    assert(waitrequest === 1'b0) else $stop;

    @(negedge clk)
    start = 1'b1;
    #10; assert(waitrequest === 1'b1);
    #192000;

    assert(waitrequest === 1'b0);

    $display("Finished at time: %t", $time);
    $stop;

end
endmodule: tb_init_screen


module simple_vga(
    //input
    input logic clk,
    input logic rst_n,
    input logic vga_plot,
    input logic [7:0] vga_x,
    input logic [6:0] vga_y,
    input logic [2:0] vga_colour,
    input logic simple_plot
    );


    //plot the (26,6) to (139,119)



endmodule: simple_vga