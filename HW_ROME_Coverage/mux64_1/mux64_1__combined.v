module mux2_1(input wire in1, input wire in2, input wire select, output wire out);
    assign out = select ? in2 : in1;
endmodule
module mux4_1(input [1:0] sel, input [3:0] in, output out);
    wire w0, w1;
    mux2_1 mux0 (.in1(in[0]), .in2(in[1]), .select(sel[0]), .out(w0));
    mux2_1 mux1 (.in1(in[2]), .in2(in[3]), .select(sel[0]), .out(w1));
    mux2_1 mux2 (.in1(w0), .in2(w1), .select(sel[1]), .out(out));
endmodule
module mux8_1(input [2:0] sel, input [7:0] in, output out);
    assign out = in[sel];
endmodule
module mux16_1(input [3:0] sel, input [15:0] in, output out);

wire lower_out, upper_out;

mux8_1 lower_mux (
    .sel(sel[2:0]),
    .in(in[7:0]),
    .out(lower_out)
);

mux8_1 upper_mux (
    .sel(sel[2:0]),
    .in(in[15:8]),
    .out(upper_out)
);

mux2_1 final_mux (
    .in1(lower_out),
    .in2(upper_out),
    .select(sel[3]),
    .out(out)
);

endmodule
module mux32_1(input [4:0] sel, input [31:0] in, output reg out);
    always @(*) begin
        out = in[sel];
    end
endmodule
module mux64_1(input [5:0] sel, input [63:0] in, output out);

  wire out_low, out_high;

  mux32_1 mux_low (
    .sel(sel[4:0]),
    .in (in[31:0]),
    .out(out_low)
  );

  mux32_1 mux_high (
    .sel(sel[4:0]),
    .in (in[63:32]),
    .out(out_high)
  );

  mux2_1 mux_final (
    .in1   (out_low),
    .in2   (out_high),
    .select(sel[5]),
    .out   (out)
  );

endmodule
