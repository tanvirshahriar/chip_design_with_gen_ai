module shift_register (
    input        clk,
    input        reset_n,
    input        data_in,
    input        shift_enable,
    output [7:0] data_out
);

    // 8‑bit storage register
    reg [7:0] shift_reg;

    // Synchronous active‑low reset and shift logic
    always @(posedge clk) begin
        if (!reset_n) begin
            // Reset to zero when reset_n is low
            shift_reg <= 8'b0;
        end else if (shift_enable) begin
            // Shift left: data_in enters the LSB
            shift_reg <= {shift_reg[6:0], data_in};
        end else begin
            // Hold current value when shift is disabled
            shift_reg <= shift_reg;
        end
    end

    // Parallel output
    assign data_out = shift_reg;

endmodule
