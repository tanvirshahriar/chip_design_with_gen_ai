
module sat_adder8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] sum,
    output wire       sat
);
    wire [8:0] raw;
    assign raw = {1'b0, a} + {1'b0, b};   // 9-bit sum, up to 510
    assign sat = raw[8];                   // bit 8 set == we exceeded 255
    assign sum = raw[8] ? 8'hFF : raw[7:0];  // clamp on overflow, else pass through
endmodule
