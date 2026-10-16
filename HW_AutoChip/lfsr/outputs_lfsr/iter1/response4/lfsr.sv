module lfsr(
    input clk,
    input reset_n,
    output reg [7:0] data
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            data <= 8'b10001010;        // initial state
        else
            data <= {data[6:0], data[0] ^ data[3] ^ data[5] ^ data[6]}; // left shift with feedback from taps 1,4,6,7 (LSB-indexed)
    end
endmodule
