`timescale 1ps/1ps

module tb_hex_display();

    //variables
    logic [23:0] num;

    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    //instantiation

    /*hex_display 
    #(parameter NUM_HEX = 3) (
    //inputs

    input logic [(NUM_HEX<<2)-1:0] num,
    //outputs
    output logic [6:0] HEX0, 
    output logic [6:0] HEX1, 
    output logic [6:0] HEX2,
    output logic [6:0] HEX3, 
    output logic [6:0] HEX4, 
    output logic [6:0] HEX5
    );*/
    hex_display #(.NUM_HEX(6)) DUT(
        //inputs
        .num(num),
        //outputs
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );


    initial begin

        num = 24'h123456;
        #5
        assert(HEX5 === 7'b1111001) else $stop; //1
        assert(HEX4 === 7'b0100100) else $stop; //2
        assert(HEX3 === 7'b0110000) else $stop; //3
        assert(HEX2 === 7'b0011001) else $stop; //4
        assert(HEX1 === 7'b0010010) else $stop; //5
        assert(HEX0 === 7'b0000010) else $stop; //6

        #20
        num = 24'hFEDCBA;
        #5
        assert(HEX5 === 7'b0001110) else $stop; //F
        assert(HEX4 === 7'b0000110) else $stop; //E
        assert(HEX3 === 7'b0100001) else $stop; //d
        assert(HEX2 === 7'b1000110) else $stop; //C
        assert(HEX1 === 7'b0000011) else $stop; //b
        assert(HEX0 === 7'b0001000) else $stop; //A

        #20
        num = 24'h789CBA;
        #5
        assert(HEX5 === 7'b1111000) else $stop; //7
        assert(HEX4 === 7'b0000000) else $stop; //8
        assert(HEX3 === 7'b0010000) else $stop; //9
        assert(HEX2 === 7'b1000110) else $stop; //C
        assert(HEX1 === 7'b0000011) else $stop; //b
        assert(HEX0 === 7'b0001000) else $stop; //A

        #10
        $display("Finished at time %t", $time);
        $stop;


    end

endmodule: tb_hex_display