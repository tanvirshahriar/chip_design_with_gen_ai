module shift_register(
    input clk,
    input reset_n,
    input data_in,
    input shift_enable,
    output [7:0] data_out
);
    // 8‑bit shift register
    reg [7:0] shift_reg;

    // Asynchronous active‑low reset, synchronous shift
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg <= 8'b0;           // reset to zero
        end
        else if (shift_enable) begin
            // Shift left: MSB discarded, LSB gets data_in
            shift_reg <= {shift_reg[6:0], data_in};
        end
        // If shift_enable is low, hold current value (no change)
    end

    // Output the current register contents
    assign data_out = shift_reg;
endmodule
