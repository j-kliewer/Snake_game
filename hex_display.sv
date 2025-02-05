module hex_display #(parameter NUM_HEX = 3) 
                            (input logic clk, input logic rst_n, input logic [(NUM_HEX<<2)-1:0] num,
                            output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
                            output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5);
    /*
    //parameters
    NUM_HEX = number of hex displays to use
    //inputs 
    clk
    rst_n
    [(NUM_HEX<<2)-1:0] num //need to multiply by 4 since 4 bits per hex
    //outputs
    [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
    */

    //expects 4 bits supplied per hex used

    //make a function to return the corresponding 7-segment hex sequence
    function logic [6:0] num2hexdisplay( logic [3:0] number);
        case(number)
            4'h0: return 7'b1000000; //0
            4'h1: return 7'b1111001; //1
            4'h2: return 7'b0100100; //2
            4'h3: return 7'b0110000; //3
            4'h4: return 7'b0011001; //4
            4'h5: return 7'b0010010; //5
            4'h6: return 7'b0000010; //6
            4'h7: return 7'b1111000; //7
            4'h8: return 7'b0000000; //8
            4'h9: return 7'b0010000; //9
            4'hA: return 7'b0001000; //A
            4'hB: return 7'b0000011; //b
            4'hC: return 7'b1000110; //C
            4'hD: return 7'b0100001; //d
            4'hE: return 7'b0000110; //E
            4'hF: return 7'b0001110; //F
            default: return 7'b0111111; //-
        endcase
    endfunction

    always_comb begin
        if(NUM_HEX >= 1) begin //if this hex is being used, give it the number
            HEX0 = num2hexdisplay(num[3:0]);
        end
        else begin
            HEX0 = 7'b1111111; //if not used, make it blank
        end

        if(NUM_HEX >= 2) begin
            HEX1 = num2hexdisplay(num[7:4]);
        end
        else begin
            HEX1 = 7'b1111111;
        end

        if(NUM_HEX >= 3) begin
            HEX2 = num2hexdisplay(num[11:8]);
        end
        else begin
            HEX2 = 7'b1111111;
        end

        if(NUM_HEX >= 4) begin
            HEX3 = num2hexdisplay(num[15:12]);
        end
        else begin
            HEX3 = 7'b1111111;
        end

        if(NUM_HEX >= 5) begin
            HEX4 = num2hexdisplay(num[19:16]);
        end
        else begin
            HEX4 = 7'b1111111;
        end

        if(NUM_HEX >= 6) begin
            HEX5 = num2hexdisplay(num[23:20]);
        end
        else begin
            HEX5 = 7'b1111111;
        end


    end





endmodule: hex_display