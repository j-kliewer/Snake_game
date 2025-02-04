module button_sync(input logic clk, input logic[3:0] in, output logic[3:0] out);
//uses two registers to syncronize the inputs from user buttons to the clock
//note due to settling nature of metastability, these inputs will not necessarily be output on the same clock as each other
//one clk cycle however will not be significant for user induced input on a 50MHz clk

logic [1:0] b0, b1, b2, b3;

assign out = {b3[1],b2[1],b1[1],b0[1]};

//shift the bit up (to next reg) each clk
always_ff@(posedge clk) begin
    b0 <= {b0[0], in[0]};
    b1 <= {b1[0], in[1]};
    b2 <= {b2[0], in[2]};
    b3 <= {b3[0], in[3]};
end


endmodule: button_sync