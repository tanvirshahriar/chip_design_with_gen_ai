module lfsr(
    input clk,
    input reset_n,
    output reg [7:0] data
);

    // Asynchronous active-low reset, synchronous update on clock edge
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Load initial state: 10001010
            data <= 8'b10001010;
        end else begin
            // Tap positions: bits 1, 4, 6, 7 (0-indexed, LSB = bit 0)
            wire feedback = data[1] ^ data[4] ^ data[6] ^ data[7];
            // Shift left, inserting feedback into the LSB
            data <= {data[6:0], feedback};
        end
    end

endmodule
