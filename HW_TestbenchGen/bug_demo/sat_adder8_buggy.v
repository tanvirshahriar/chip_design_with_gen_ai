
// BUGGY VERSION of sat_adder8.
// Injected bug: on overflow the sum wraps around instead of clamping to 8'hFF.
module sat_adder8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] sum,
    output wire       sat
);
    wire [8:0] raw;
    assign raw = {1'b0, a} + {1'b0, b};
    assign sat = raw[8];
    assign sum = raw[7:0];   // BUG
endmodule
