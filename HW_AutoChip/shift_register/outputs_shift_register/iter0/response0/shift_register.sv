module shift_register (
    input        clk,
    input        reset_n,   // active-low reset
    input        data_in,   // serial data input
    input        shift_enable, // enable shifting
    output reg [7:0] data_out // parallel 8-bit output
);
    // Asynchronous active-low reset, synchronous shift
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 8'b0;          // reset all bits to 0
        end else if (shift_enable) begin
            // Shift left: LSB gets new data_in, MSB is discarded
            data_out <= {data_out[6:0], data_in};
        end
        // If shift_enable is low, hold current value
    end
endmodule
