module lfsr(
    input clk,
    input reset_n,
    output reg [7:0] data
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            data <= 8'b10001010; // initial state
        else
            // shift left, feedback from taps at locations 1,4,6,7 (1-indexed from LSB)
            data <= {data[6:0], data[0] ^ data[3] ^ data[5] ^ data[6]};
    end
endmodule
