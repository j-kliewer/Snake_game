module switch_debounce #(parameter DEBOUNCE_TIME = 10'd1000)(input logic clk, input logic in_sw, output logic out_sw);
//synchronize and debounce the switch input


logic [1:0] syn;

logic [9:0] counter;

//synchronizer, stable output is on syn[1]
always_ff@(posedge clk) begin
    syn <= {syn[0],in_sw}; //introduces two flip flops as synchronizer
end

//debouncer, looking for 20ms of stability: 50MHz clk: 1 clk = 20 ns, so 20 ms = 1000 clk cycles (covered by 10 bit 1024)
always_ff@(posedge clk) begin
    //drive the output to change if the change has been held for long enough
    if(counter >= DEBOUNCE_TIME) begin
        out_sw <= syn[1];
    end

    //drive the counter to count if the synchronized input (syn[1]) is different from output (out_sw), otherwise reset counter to 0
    if(syn[1] != out_sw) begin
        counter <= counter + 10'd1;
    end
    else begin
        counter <= 10'd0;
    end
end

endmodule: switch_debounce