module lfsr(
    input clk,
    input reset_n,
    output reg [7:0] data
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Active-low reset: set initial state to 10001010
            data <= 8'b10001010;
        end else begin
            // Taps at bit positions 1, 4, 6, 7 (LSB = bit 0)
            wire feedback = data[1] ^ data[4] ^ data[6] ^ data[7];
            // Shift right, inserting feedback into the MSB
            data <= {feedback, data[7:1]};
        end
    end
endmodule
