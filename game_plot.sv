module game_plot( input logic clk, input logic rst_n,
                 input logic game_plot, input logic [3:0] game_x,
                 input logic [3:0] game_y, input logic [2:0] game_colour,
                 output logic waitrequest, 
                 output logic vga_plot, output logic [7:0] vga_x, 
                 output logic [6:0] vga_y, output logic [2:0] vga_colour);

    // utilizes waitrequest protocol
    // expects input to be held until waitrequest == 0, meaning the request is being processed
    /*
    //inputs//
    clk
    rst_n
    game_plot
    [3:0] game_x
    [3:0] game_y
    [2:0] game_colour

    //outputs//
    waitrequest
    vga_plot
    [7:0] vga_x
    [6:0] vga_y
    [2:0] vga_colour
    */

    //the game path will think in only 16x16 grid
    //16x16 pixels however will be too small, so this will magnify the game_pixels to 6x6
    //the square will be 96x96

    //x axis: 160-96 = 64: [0-31] outisde square, [32-127] inside square, [128-159] outside square
    //y axis: 120-96 = 24: [0-11] outside square, [12-107] inside square, [108-119] outside square

    //to find start of 6x6 pixel, multiply x and y by 6 and add to top left pixel location
    //then loop for[x=0;x<=5;x++]{ for[y=0;y<=5;y++] } to plot each pixel


    //variables

    //save colour at beginning of loop
    logic [2:0] temp_colour;


    //base for loop, and loop variables
    logic [7:0] base_x;
    logic [6:0] base_y;
    logic [2:0] x, y; 

    //FSM
    //sequential
    //synchronous reset
    //outputs:
    //drive 
    //in module:
    //drive base_x, base_y, x, y, temp_colour
    enum logic {IDLE, PLOT} state;
    always_ff@(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    if(game_plot) begin
                        state <= PLOT;
                        temp_colour <= game_colour;
                        base_x <= 4'd6 * game_x; //4 bits * 4 bits = 8 bits
                        base_y <= 3'd6 * game_y; //3 bits * 4 bits = 7 bits
                        x <= 3'd0;
                        y <= 3'd0;
                    end

                end
                PLOT: begin
                    if (x == 3'd5 && y == 3'd5) begin //exit loop
                        state <= IDLE;
                    end
                    else if(y == 3'd5) begin //increase x
                        x <= x + 3'd1;
                        y <= 3'd0;
                    end
                    else begin //increase y
                        y <= y + 3'd1;
                    end
                end
            endcase
        end
    end

    //combinational
    //drive vga_x, vga_y, vga_colour
    assign vga_x = 8'd32 + base_x + x;
    assign vga_y = 7'd12 + base_y + y;
    assign vga_colour = temp_colour;

    //combinational
    //drive vga_plot, waitrequest
    always_comb begin
        //defaults
        vga_plot = 1'b0;
        waitrequest = 1'b0;

        //assignments
        case(state)
            IDLE: begin
            end
            PLOT: begin
                vga_plot = 1'b1;
                waitrequest = 1'b1;
            end
        endcase
    end

endmodule: game_plot