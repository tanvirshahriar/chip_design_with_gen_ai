module binary_to_bcd_converter(
    input  [4:0] binary_input,
    output reg [7:0] bcd_output
);
    // Internal registers for tens and ones (each 4‑bit)
    reg [3:0] tens;
    reg [3:0] ones;

    // Combinational logic: compute tens = value/10, ones = value%10
    always @* begin
        tens = binary_input / 5'd10;   // integer division by 10
        ones = binary_input % 5'd10;   // remainder after division by 10
        bcd_output = {tens, ones};     // concatenate tens (high nibble) and ones (low nibble)
    end
endmodule
