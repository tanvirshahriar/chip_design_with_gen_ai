module shift_register(
    input  clk,
    input  reset_n,   // active‑low reset
    input  data_in,
    input  shift_enable,
    output reg [7:0] data_out
);

    // Synchronous active‑low reset and shift logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 8'b0;               // reset to zero
        end
        else if (shift_enable) begin
            // Shift left: insert data_in into LSB, discard MSB
            data_out <= {data_out[6:0], data_in};
        end
        // If shift_enable is low, hold the current value (no change)
    end

endmodule
