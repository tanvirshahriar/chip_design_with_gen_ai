module mux16_1(input [3:0] sel, input [15:0] in, output reg out);
    always @(*) begin
        out = in[sel];
    end
endmodule
