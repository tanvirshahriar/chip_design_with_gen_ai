module lfsr(
    input        clk,
    input        reset_n,
    output reg [7:0] data
);
    // Feedback computed from taps at bit positions 1, 4, 6, 7 (LSB = bit 0)
    wire feedback = data[1] ^ data[4] ^ data[6] ^ data[7];

    // Synchronous reset (active low) and shift-left LFSR update
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            data <= 8'b10001010;   // Initial state
        else
            data <= {data[6:0], feedback}; // Shift left, insert feedback at LSB
    end
endmodule
