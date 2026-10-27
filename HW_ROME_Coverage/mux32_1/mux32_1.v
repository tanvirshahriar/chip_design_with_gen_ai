module mux32_1(input [4:0] sel, input [31:0] in, output reg out);
    always @(*) begin
        out = in[sel];
    end
endmodule
