module simple_dual_port_ram(
    input clk,
    input we,
    input [7:0] d,
    input [7:0] write_address, read_address,
    output reg [7:0] q
);

    //should use an M10K block
    //when reading from the same address as a write, the new value will be read

    (* ramstyle = "M10K" *) reg [7:0] mem [255:0];

    always @ (posedge clk) begin
        if (we)
            mem[write_address] = d;
        q = mem[read_address]; // q does get d in this clock 
                               // cycle if we is high
    end
endmodule