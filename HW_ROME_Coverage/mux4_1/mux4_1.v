module mux4_1(input [1:0] sel, input [3:0] in, output out);
    wire w0, w1;
    mux2_1 mux0 (.in1(in[0]), .in2(in[1]), .select(sel[0]), .out(w0));
    mux2_1 mux1 (.in1(in[2]), .in2(in[3]), .select(sel[0]), .out(w1));
    mux2_1 mux2 (.in1(w0), .in2(w1), .select(sel[1]), .out(out));
endmodule
