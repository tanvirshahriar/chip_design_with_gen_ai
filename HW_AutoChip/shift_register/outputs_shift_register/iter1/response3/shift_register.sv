module shift_register(
    input  clk,
    input  reset_n,   // active‑low reset
    input  data_in,
    input  shift_enable,
    output reg [7:0] data_out
);

    // Synchronous active‑low reset and right‑shift logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 8'b0;               // reset to zero
        end
        else if (shift_enable) begin
            // Shift right: insert data_in into MSB, discard LSB
            data_out <= {data_in, data_out[7:1]};
        end
        // If shift_enable is low, hold the current value (no change)
    end

endmodule
