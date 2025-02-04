`timescale 1ps/1ps
module tb_button_sync();

    //variables
    logic clk;
    logic [3:0] in;
    logic [3:0] out;

    //instantiation
    /*button_sync(
        //inputs
        input logic clk, 
        input logic[3:0] in_button, 
        //outputs
        output logic[3:0] out_button
        );*/
    button_sync DUT(
        .clk(clk),
        .in(in),
        .out(out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        in = 4'b1010;
        @(posedge clk) @(negedge clk)

        in = 4'b0101;
        @(posedge clk) @(negedge clk)
        assert(out === 4'b1010) else $stop;


        in = 4'b0000;
        @(posedge clk) @(negedge clk)
        assert(out === 4'b0101) else $stop;

        in = 4'b1111;
        @(posedge clk) @(negedge clk)
        assert(out === 4'b0000) else $stop;

        @(posedge clk) @(negedge clk)
        assert(out === 4'b1111) else $stop;


        $display("Finished at time %t", $time);
        $stop;

    end

endmodule: tb_button_sync