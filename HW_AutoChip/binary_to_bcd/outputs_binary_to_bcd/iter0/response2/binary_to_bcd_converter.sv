module binary_to_bcd_converter(
    input  [4:0] binary_input,
    output [7:0] bcd_output
);
    // Compute tens and ones digits
    wire [3:0] tens;
    wire [3:0] ones;

    assign tens = binary_input / 5'd10;   // integer division by 10
    assign ones = binary_input % 5'd10;   // remainder after division by 10

    // Pack tens (high nibble) and ones (low nibble) into 8‑bit BCD output
    assign bcd_output = {tens, ones};

endmodule
