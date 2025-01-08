`timescale 1ps/1ps
module tb_game_path_ram();


    //instantiation
    logic clk;
    logic we;
    logic [7:0] wr_data;
    logic [7:0] wr_addr, rd_addr;
    logic [7:0] rd_data;
    /* simple_dual_port_ram(
        input clk,
        input we,
        input [7:0] d,
        input [7:0] write_address, read_address,
        output reg [7:0] q,
    );*/
    simple_dual_port_ram DUT(
        .clk(clk),
        .we(we),
        .d(wr_data),
        .write_address(wr_addr),
        .read_address(rd_addr),
        .q(rd_data)
    );


    //setup clk
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    //test
    initial begin

        @(posedge clk)@(negedge clk)
        we = 1'b1;
        wr_addr = 8'd212;
        wr_data = 8'd222;
        rd_addr = 8'd212;
        @(posedge clk)@(negedge clk)
        assert(rd_data === wr_data)else $stop;

        we = 1'b1;
        wr_addr = 8'd200;
        wr_data = 8'd111;
        rd_addr = 8'd212;
        @(posedge clk)@(negedge clk)
        assert(rd_data === 8'd222)else $stop;

        
        we = 1'b1;
        wr_addr = 8'd255;
        wr_data = 8'd255;
        rd_addr = 8'd200;
        @(posedge clk)@(negedge clk)
        assert(rd_data === 8'd111)else $stop;

        we = 1'b0;
        wr_addr = 8'd255;
        wr_data = 8'd0;
        rd_addr = 8'd255;
        @(posedge clk)@(negedge clk)
        assert(rd_data === 8'd255)else $stop;

        we = 1'b1;
        wr_addr = 8'd255;
        wr_data = 8'd0;
        rd_addr = 8'd255;
        @(posedge clk)@(negedge clk)
        assert(rd_data === 8'd0)else $stop;

        we = 1'b1;
        wr_addr = 8'd0;
        wr_data = 8'd0;
        rd_addr = 8'd212;
        @(posedge clk)@(negedge clk)
        assert(rd_data === 8'd222)else $stop;

        we = 1'b0;
        wr_addr = 8'd255;
        wr_data = 8'd0;
        rd_addr = 8'd0;
        @(posedge clk)@(negedge clk)
        assert(rd_data === 8'd0)else $stop;

        $display("Finished at time: %t", $time);
        $stop;



    end
endmodule: tb_game_path_ram