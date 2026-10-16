module lfsr(
    input clk,
    input reset_n,
    output reg [7:0] data
);
    // Synchronous active-low reset; initial state 10001010
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            data <= 8'b10001010;
        else
            // Taps at locations 1,4,6,7 (bit indices: data[1], data[4], data[6], data[7])
            data <= {data[6:0], data[7] ^ data[6] ^ data[4] ^ data[1]};
    end
endmodule
