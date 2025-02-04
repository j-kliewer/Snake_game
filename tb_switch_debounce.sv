`timescale 1ps/1ps

module tb_switch_debounce();

//variables
logic clk;
logic in_sw;
logic out_sw;

//instantiation

switch_debounce DUT(
    .clk(clk),
    .in_sw(in_sw),
    .out_sw(out_sw)
);

//set up clk
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    #3;
    DUT.out_sw <= 1'b0;
    in_sw <= 1'b1;
    #20; //2 clk for input to be present on output of synchronyzer
    assert(DUT.syn[1] === 1'b1) else begin $display("ERROR synch"); $stop; end
    #10000; //1000 clk cycles for debounce
    #10; //one more clk cycle to reach out_sw
    assert(out_sw === 1'b1) else begin $display("ERROR debounce"); $stop; end
    #3;
    //bounce the in_sw a bit
    in_sw <= 1'b0;
    #15;
    in_sw <= ~in_sw;
    #15;
    in_sw <= ~in_sw;
    #15;
    in_sw <= ~in_sw;
    #15;

    //test the entire flow again
    in_sw <= 1'b0;
    #20; //2 clk for input to be present on output of synchronyzer
    assert(DUT.syn[1] === 1'b0) else begin $display("ERROR synch 2"); $stop; end
    #10000; //1000 clk cycles for debounce
    #10; //one more clk cycle to reach out_sw
    assert(out_sw === 1'b0) else begin $display("ERROR debounce 2"); $stop; end
    #3;


    $display("Finished at time: %t", $time0);
    $stop;
end



endmodule: tb_switch_debounce