
module binary_to_bcd_converter (
    input  wire [4:0] binary_input,   // 5‑bit binary input
    output wire [7:0] bcd_output      // 8‑bit BCD: [7:4] tens, [3:0] ones
);

    // Internal decimal digits
    wire [3:0] tens;
    wire [3:0] ones;

    // Compute tens and ones using division / remainder
    assign tens  = binary_input / 5'd10;
    assign ones  = binary_input % 5'd10;

    // Pack the two nibbles into the BCD output
    assign bcd_output = {tens, ones};

endmodule
