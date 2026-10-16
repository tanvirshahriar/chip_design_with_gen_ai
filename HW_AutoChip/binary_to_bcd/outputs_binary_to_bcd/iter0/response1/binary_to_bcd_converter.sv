module binary_to_bcd_converter(
    input  [4:0] binary_input,
    output [7:0] bcd_output
);
    // Tens and ones digits (each 4‑bits wide)
    wire [3:0] tens;
    wire [3:0] ones;

    // Compute tens = binary_input / 10
    // Compute ones = binary_input % 10
    // For a 5‑bit input (0‑31) these operations are trivial for synthesis.
    assign tens = binary_input / 5'd10;
    assign ones = binary_input % 5'd10;

    // Pack the two BCD digits into an 8‑bit vector: [7:4] tens, [3:0] ones
    assign bcd_output = {tens, ones};
endmodule
