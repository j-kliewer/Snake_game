module init_screen( input logic clk, input logic rst_n, input logic start, 
                    output logic waitrequest, output logic vga_plot,
                    output logic [7:0] vga_x, output logic [6:0] vga_y,  output logic [2:0] vga_colour);

    
    //utilizes waitrequest protocol, expects start to only go high if waitrequest is low

    /*
    //inputs//
    clk
    rst_n
    start

    //outputs//
    waitrequest
    vga_plot
    [7:0] vga_x
    [6:0] vga_y
    [2:0] vga_colour

    */

    //set up a white outline of the game square, all other pixels black
    //square is from     
        //x axis: 160-96 = 64: [0-31] outisde square, [32-127] inside square, [128-159] outside square
        //y axis: 120-96 = 24: [0-11] outside square, [12-107] inside square, [108-119] outside square

    //to set up outline, set up a width of the outline as 6 pixels
    // x axis: [26-31] left outline and [128-133] right outline
    // y axis: [6-11] top outline and [108-113] bottom outline

    //variables
    logic [7:0] x;
    logic [6:0] y;
    assign vga_x = x;
    assign vga_y = y;

    //fill the outside of a 16x16 grid with 
    enum logic {IDLE, FILL} state;
    //sequential
    //synchronous reset
    //drive internal x,y which drive outputs vga_x, vga_y
    always_ff@(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start) begin
                        state <= FILL;
                        x <= 8'd0;
                        y <= 7'd0;
                    end
                end
                FILL: begin
                    if(x == 8'd159 && y == 7'd119) begin
                        state <= IDLE;
                    end
                    else if(y == 7'd119) begin
                        x <= x + 8'd1;
                        y <= 7'd0;
                    end
                    else begin
                        y <= y + 7'd1;
                    end
                end
            endcase
        end
    end

    //combinational
    //drive waitrequest, vga_plot, vga_colour
    always_comb begin
        //defualts
        waitrequest = 1'b0;
        vga_plot= 1'b0;
        vga_colour = 3'b000; 

        case (state)
            IDLE: begin
            end
            FILL: begin
                waitrequest = 1'b1;
                vga_plot = 1'b1;
                //to set up outline, set up a width of the outline as 6 pixels
                // x axis: [26-31] left outline and [128-133] right outline
                // y axis: [6-11] top outline and [108-113] bottom outline
                if( x >= 8'd26 && x <= 8'd133 && y >= 7'd6 && y <= 7'd113) begin
                    if( x >= 8'd32 && x <= 8'd127 && y >= 7'd12 && y <= 7'd107) begin
                        //inside colour
                        vga_colour = 3'b000;
                    end
                    else begin
                        //outline colour
                        vga_colour = 3'b111;
                    end
                end
                else begin
                    //outside colour
                    vga_colour = 3'b000;
                end
            end
        endcase
    end



endmodule: init_screen