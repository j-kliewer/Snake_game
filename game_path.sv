module game_path(input logic clk, input logic rst_n, input logic start, input logic in_left, 
                 input logic in_right, input logic in_up, input logic in_down, output logic waitrequest,
                 //for game_plot
                 input logic game_plot_waitrequest, output logic game_plot,
                 output logic [3:0] game_x, output logic [3:0] game_y, output logic [2:0] game_colour
                );
    /*
    //inputs//
    clk
    rst_n
    start
    in_left
    in_right
    in_up
    in_down

    //outputs//
    waitrequest

    //game_plot//
    //game_plot//inputs//
    game_plot_waitrequest

    //game_plot//outputs//
    game_plot
    [3:0] game_x
    [3:0] game_y
    [2:0] game_colour
    */

    //utilize waitrequest protocol
    //aim is to create a module which will run one iteration of a snake game from start to end
    //waitrequest will go low when game is ready to start ie at beginning or after a death

    //for plotting I only need to track location of head, tail, and fruit,
    //will also have signal new_fruit to signify tail stays and new fruit must be plotted
    //should only need to update 2 game pixels max (head and tail or head and new fruit)

    //idea: if the snake has a striped pattern, could swap the values of each color each time it moves

    //for the game, I need to keep track of each body segment
    //head and tail will be fifo more or less, adding a new memory entry when reaching a fruit
    //making the square 16x16, the memory will have to be 256 bits

    //16x16 pixels will be much too small, vga output size is 120x160
    //if each game pixel is made as 6x6, we get 96x96 size.
    //thus game_plot is implemented so that this module can think in 16x16 logic, while the actual
    //game will be plotted in a reasonable fashion


    //constants for colour
    localparam [2:0] BLACK = 3'b000;
    localparam [2:0] RED = 3'b100;
    localparam [2:0] YELLOW = 3'b110;
    localparam [2:0] GREEN = 3'b010;
    localparam [2:0] CYAN = 3'b011;
    localparam [2:0] BLUE = 3'b001;
    localparam [2:0] MAGENTA = 3'b101;
    localparam [2:0] WHITE = 3'b111;

    //variables

    logic [7:0] new_head, head, last_tail, apple; //[7:4] y coord, [3:0] x coord
    logic [7:0] length; //holds length of snake
    logic [26:0] count, stall_num; //used to stall for user to see the new game state(take a turn)
    logic out_of_bounds_flag; //used to look for collision/death

    logic [255:0] simple_mem; //used to hold which points the snake occupies
    
    logic [7:0] rd_ptr, wr_ptr; //used to make inferred SRAM memory FIFO

    logic [7:0] rand_apple; //

    //variables for Linear Feedback Shift Register(lfsr)
    //seed based on clock cycles the start button is held (makes random)
    logic seed_count_flag;
    //most presses will be around 300 ms aka 15,000,000 clks which needs 24 bits,
    //thus a looping 10 bits will be quite random
    logic [10:0] seed_count; 
    logic [10:0] lfsr; //10 bits so we have 256 random 8 bit numbers aka 2^8*2^3 = 2^11 random numbers
    logic [3:0] lfsr_count;


    //instantiate memory
    //memory is used in FIFO fashion to keep track of order of pixels down snake body from head to tail
    //will need to keep a read and write pointer to indicate game_pixel of tail and game_pixel of head respectively
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

    ////////////////////////////////////////////////////////////////////
    //Latch User input of last pressed direction
    ////////////////////////////////////////////////////////////////////

    enum logic [1:0] {LEFT, RIGHT, UP, DOWN} last_direction, direction;
    //sequential
    //synchronous reset
    //drives last_direction
    always_ff@(posedge clk) begin
        //does not allow change in direction by 180 degrees

        //need to make sure button used to start game does not change default starting direction as down
        /*if(state == IDLE) begin //only uses button to start game in IDLE, keeps
        end*/
        //maybe tweak default list / how key presses are processed

        //else begin
        if(!rst_n || (in_down && direction != UP))
            last_direction <= DOWN;
        else if(in_left && direction != RIGHT)
            last_direction <= LEFT;
        else if(in_right && direction != LEFT)
            last_direction <= RIGHT;
        else if(in_up && direction != DOWN)
            last_direction <= UP;
        
    end

    //combinational
    //drive new_head, out_of_bounds_flag
    //based on direction which only updates once per cycle
    always_comb begin
        case(direction)
            LEFT: begin
                if(head[3:0] == 4'b0000) begin
                    out_of_bounds_flag = 1'b1;
                end
                else begin
                    out_of_bounds_flag = 1'b0;
                end
                new_head = head - 8'b0000_0001;
            end
            RIGHT: begin
                if(head[3:0] == 4'b1111) begin
                    out_of_bounds_flag = 1'b1;
                end
                else begin
                    out_of_bounds_flag = 1'b0;
                end
                new_head = head + 8'b0000_0001;
            end
            UP: begin
                if(head[7:4] == 4'b0000) begin
                    out_of_bounds_flag = 1'b1;
                end
                else begin
                    out_of_bounds_flag = 1'b0;
                end
                new_head = head - 8'b0001_0000;
            end
            DOWN: begin
                if(head[7:4] == 4'b1111) begin
                    out_of_bounds_flag = 1'b1;
                end
                else begin
                    out_of_bounds_flag = 1'b0;
                end
                new_head = head + 8'b0001_0000;
            end
            default: begin
                out_of_bounds_flag = 1'b0;
                new_head = head;
            end
        endcase
    end


    ////////////////////////////////////////////////////////////////////
    //Drive main state machine sequence
    ////////////////////////////////////////////////////////////////////

    enum logic [3:0] {IDLE, INIT_APPLE, INIT_HEAD, INIT_TAIL, STALL, COLLISION, HEAD, HEAD_PLOT, TAIL, TAIL_PLOT, APPLE, APPLE_PLOT, DEATH_STALL, DEATH, DEATH_END} state;
    //sequential
    //synchronous reset
    //drives we, wr_addr, wr_data, rd_addr for SRAM FIFO memory
    //drives game_plot, game_x, game_y, game_colour for game_plot outputs
    //drives head, direction, last_tail, and apple for internal use
    //drives wr_ptr and rd_ptr to keep track of SRAM memory to use as FIFO
    //drives simple_mem to keep track of snake body cells internally
    //drives count and stall_num for internal use stalling time per turn
    always_ff@(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //testing make stall shorter
            //stall_num <= 26'd40;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //synthesizable
            stall_num <= 26'd25_000_000;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //define so above combinational logic is always defined
            direction <= DOWN;
            head <= 8'b0001_0111; //(7,1)
            simple_mem <= 256'd0;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start && (in_left || in_up || in_down || in_right )) begin
                        //change state
                        state <= INIT_APPLE;

                        //setup head, last_tail, apple, direction
                        head <= 8'b0001_0111; //(7,1)
                        last_tail <= 8'b0000_0111; //(7,0)
                        apple <= 8'b1000_1000; //(8,8)
                        direction <= DOWN;

                        //init length
                        length <= 8'd2;

                        //write head to FIFO, only need to include head since tail is held in last_tail
                        we <= 1'b1;
                        wr_addr <= 8'd0;
                        wr_data <= 8'b0001_0111; //(7,1)

                        //set up pointers
                        wr_ptr <= 8'd1; //point to one pixel before head
                        rd_ptr <= 8'd0; //points to one pixel before tail, in this case the head

                        //setup simple_mem with head, dont include tail so that tail is not considered for collision
                        simple_mem[8'b0001_0111] <= 1'b1; //(7,1)

                        //plot Apple red
                        game_plot <= 1'b1;
                        game_x <= 4'b1000; //8
                        game_y <= 4'b1000; //8
                        game_colour <= RED; //red
                    end
                end
                INIT_APPLE: begin
                    //turn off write to SRAM
                    we <= 1'b0;
                    if(!game_plot_waitrequest) begin //once accepted, give next request to plot head
                        state <= INIT_HEAD;
                        //plot head
                        game_plot <= 1'b1;
                        game_x <= head[3:0]; //7
                        game_y <= head[7:4]; //1
                        game_colour <= WHITE; //white
                    end
                end
                INIT_HEAD: begin
                    if(!game_plot_waitrequest) begin //once accepted, give next request to plot tail
                        state <= INIT_TAIL;
                        //plot tail
                        game_plot <= 1'b1;
                        game_x <= last_tail[3:0]; //7
                        game_y <= last_tail[7:4]; //0
                        game_colour <= WHITE; //white
                    end
                end
                INIT_TAIL: begin
                    if(!game_plot_waitrequest) begin //once accepted, continue to main game loop
                        //turn off plots
                        game_plot <= 1'b0;
                        //go to stall state
                        state <= STALL;
                        count <= 26'd0;
                    end
                end
                STALL: begin
                    if(count >= stall_num)begin
                        state <= COLLISION;
                        direction <= last_direction; //sample last_direction once per turn
                    end
                    count <= count + 26'd1;
                end
                COLLISION: begin
                    if(out_of_bounds_flag || simple_mem[new_head]) begin //check if turn should result in death
                        state <= DEATH_STALL; //may add state indicating death and showing error
                        //adding extra stall state so that this read has a chance to complete and the user can see the collision in game
                        //read the next cell up from last_tail
                        rd_addr <= rd_ptr;
                        rd_ptr <= rd_ptr + 1'b1;
                        //increase length by one to know to erase apple (implemented by not decreasing length while covering last_tail)
                    end
                    else begin
                        state <= HEAD;
                        //update head
                        head <= new_head;
                        //read tail from FIFO, will update (tail_ptr) rd_ptr later if tail needs to move
                        rd_addr <= rd_ptr;
                    end
                end
                HEAD: begin
                    state <= HEAD_PLOT;
                    //write head to FIFO
                    we <= 1'b1;
                    wr_addr <= wr_ptr;
                    wr_data <= head;
                    wr_ptr <= wr_ptr + 8'd1;
                    //update simple_mem
                    simple_mem[head] <= 1'b1;
                    //plot head white
                    game_plot <= 1'b1;
                    game_x <= head[3:0];
                    game_y <= head[7:4];
                    game_colour <= WHITE;
                end
                HEAD_PLOT: begin
                    //turn off write to FIFO
                    we <= 1'b0;
                    if(!game_plot_waitrequest) begin //move on once plot is underway
                        game_plot <= 1'b0;
                        if(head == apple) begin //if head has eaten apple, plot new apple (tail can stay same as length increases)
                            state <= APPLE;
                            rand_apple <= lfsr[7:0]; //taken from random apple generator
                            length <= length + 8'd1;
                        end
                        else begin //if no apple is eaten, update tail as usual
                            state <= TAIL; 
                        end
                    end
                end
                TAIL: begin //last_tail is still white, but not included in simple_mem, rd_data holds body segment one up from current plotted tail
                    state <= TAIL_PLOT;
                    //receive and save new last tail
                    last_tail <= rd_data;
                    //update tail pointer to not include new last_tail
                    rd_ptr <= rd_ptr + 1'b1;
                    //update simple_mem to not include 'new' last_tail
                    simple_mem[rd_data] <= 1'b0;
                    if(last_tail != head) begin //if the head does not replace the last_tail plot it (cover it with black)
                        //plot last tail black, note using past value as tail is kept ahead of plotted one for collision calculation
                        //ie the head can replace where the tail used to be in one cycle
                        game_plot <= 1'b1;
                        game_x <= last_tail[3:0];
                        game_y <= last_tail[7:4];
                        game_colour <= BLACK;
                    end
                    else begin //if the head replaces the last_tail, go straight to stall
                        //go to stall
                        state <= STALL;
                        count <= 26'd0;
                    end
                end
                TAIL_PLOT: begin
                    if(!game_plot_waitrequest) begin //move on once plot is underway
                        game_plot <= 1'b0;
                        //go to stall
                        state <= STALL;
                        count <= 26'd0;
                    end
                end
                APPLE: begin
                    //calculate new suitable space for apple and plot it
                    //if rand_apple from lfsr is already used, increment until the space is open
                    if(simple_mem[rand_apple] || rand_apple == last_tail) begin //need to be cautious of last tail as it is not in simple_mem, but is still plotted as white
                        rand_apple <= rand_apple + 8'd7; //7 chosen for unlikelihood to collide with snake again, max 256 cycles to go through all spaces
                    end
                    else begin//rand_apple space is free, plot it
                        state <= APPLE_PLOT;
                        //update apple
                        apple <= rand_apple;
                        //plot apple
                        game_plot <= 1'b1;
                        game_x <= rand_apple[3:0];
                        game_y <= rand_apple[7:4];
                        game_colour <= RED;
                    end
                end
                APPLE_PLOT: begin
                    if(!game_plot_waitrequest) begin //move on once plot is underway, note this is where lfsr is triggered to update
                        game_plot <= 1'b0;
                        //go to stall
                        state <= STALL;
                        //decrease stall_num to make game faster after each apple
                        //stall_num begins at 25_000_000 (half a second assumming clock = 50 MHZ)
                        //after eating max possible apples (256) want stall_num = 15_000_000 = 300 ms = quickest human reaction time(assuming clock = 50MHz)
                        //need to decrease by 10_000_000 in 256 apples = 39_062.5 / apple = roughly 39_000
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                        //Synthesize only, for testing comment out
                        stall_num <= stall_num - 26'd39_000;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                        count <= 26'd0;
                    end
                end
                DEATH_STALL: begin
                    //wait for user input before clearing screen, allows for user to see error and collision
                    if(in_left || in_up || in_down || in_right ) begin
                        //continue to Death state
                        state <= DEATH;
                        //cover the last_tail
                        game_plot <= 1'b1;
                        game_x <= last_tail[3:0];
                        game_y <= last_tail[7:4];
                        game_colour <= BLACK;
                    end
                end

                ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //Noticing failure to clear each and every block of worm, thinking it is related to game_plot_waitrequest and timing issue
                //Currently researching timing constraints cdc etc
                ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                DEATH: begin //fastest way to cover the worm is to read its location from memory
                    if(length > 8'd1) begin //need to cover all lengths of worm, length was not decreased while covering last_tail to account for apple needing to be covered as well
                        if(!game_plot_waitrequest) begin //once accepted, give next request to cover worm
                        //cover read segment
                        game_plot <= 1'b1;
                        game_x <= rd_data[3:0];
                        game_y <= rd_data[7:4]; 
                        game_colour <= BLACK; 
                        //one less cell to cover once accepted
                        length <= length - 8'd1;
                        //read the next segment up
                        rd_addr <= rd_ptr;
                        rd_ptr <= rd_ptr + 1'b1;
                        end
                    end
                    else if (length == 8'd1) begin //need to cover apple aka length = 1 left since not decreased while covering last_tail
                        if(!game_plot_waitrequest) begin //once accepted, give next request to cover apple
                            //cover read segment
                            game_plot <= 1'b1;
                            game_x <= apple[3:0];
                            game_y <= apple[7:4]; 
                            game_colour <= BLACK; 
                            //one less cell to cover once accepted
                            length <= length - 8'd1;
                        end
                    end
                    else begin
                        if(!game_plot_waitrequest) begin //once accepted, go back to idle
                            game_plot <= 1'b0;
                            state <= DEATH_END;
                        end
                    end
                end
                DEATH_END: begin
                    //wait for user to release button before going to idle so new game is not started
                    if(!(in_left || in_up || in_down || in_right ))begin 
                        state <= IDLE;
                        //make sure the screen resets before new game
                        simple_mem <= 256'd0;
                    end
                end
            endcase
        end
    end


    //combinational
    //drive waitrequest
    always_comb begin
        //defaults
        waitrequest = 1'b1;
        case(state)
            IDLE: begin
                waitrequest = 1'b0;
            end
            INIT_APPLE: begin 
            end
            INIT_HEAD: begin
            end
            INIT_TAIL: begin
            end
            STALL: begin
            end
            COLLISION: begin
            end
            HEAD: begin
            end
            HEAD_PLOT: begin
            end
            TAIL: begin
            end
            TAIL_PLOT: begin
            end
            APPLE: begin
            end
            APPLE_PLOT: begin
            end
            DEATH_STALL: begin
            end
            DEATH: begin
            end
            DEATH_END: begin
            end
        endcase
    end


    ////////////////////////////////////////////////////////////////////
    //Random Apple location generation using Linear Feedback Shift Register
    ////////////////////////////////////////////////////////////////////

    //drive lfsr, updating once per new apple
    always_ff@(posedge clk) begin
        if(!rst_n) begin
            seed_count <= 11'd0;
            lfsr <= 11'd0; //seed
        end
        else begin
            //Creating random seed once per game
                //wait for first button push out of idle to start counting
                if (state == IDLE && start) begin  //skip as soon as state is out of IDLE
                    seed_count_flag <= 1'b1;
                    seed_count <= 11'd0;
                end
                else if (seed_count_flag) begin
                    if(in_left || in_up || in_down || in_right ) begin
                        seed_count <= seed_count + 11'd1; //if initial press is still ongoing, count
                    end
                    else begin //get here once no button is being pushed, keep seed_count by turning off flag
                        seed_count_flag <= 1'b0; //if initial press is released, stop counting, seed has been generated 'randomly'
                        if(seed_count == 11'b111_1111_1111) begin //cannot use all 1's for xnor lfsr
                            lfsr <= 11'd0;
                        end
                        else begin
                            lfsr <= seed_count;
                        end
                    end
                end

            //shifting 8 bits per time hiting apple (only shifting one bit  per new apple fave not very random results, low number stayed low)
            //since we want lfsr to cycle through 256 8-bit numbers we need (2^11) random numbers to get this before repeating
            //only get 2^11 - 1 random numbers since all ones will never be hit
            if(state == APPLE_PLOT && !game_plot_waitrequest) begin //used as this only occurs for one clk cycle in apple loop
                lfsr_count <= 4'd0;
            end
            if(lfsr_count < 4'd8) begin //cycle through 8 times
                lfsr <= {lfsr[9:0],~(lfsr[10] ^ lfsr[8])}; //shift and xnor for the new bit
                lfsr_count <= lfsr_count + 4'd1;
            end
            
        end
    end


endmodule: game_path