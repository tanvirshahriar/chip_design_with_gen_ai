module binary_to_bcd_converter(
    input  [4:0] binary_input,
    output [7:0] bcd_output
);
    // Tens and ones digits (each 4‑bits wide)
    wire [3:0] tens;
    wire [3:0] ones;

    // Compute decimal tens and ones from the binary value
    assign tens = binary_input / 10;   // integer division
    assign ones = binary_input % 10;   // remainder

    // Concatenate tens (high nibble) and ones (low nibble) to form BCD output
    assign bcd_output = {tens, ones};
endmodule
