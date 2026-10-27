module mux2_1(input wire in1, input wire in2, input wire select, output wire out);
    assign out = select ? in2 : in1;
endmodule
module mux4_1(input [1:0] sel, input [3:0] in, output reg out);
    always @(*) out = in[sel];
endmodule
module mux8_1(input [2:0] sel, input [7:0] in, output reg out);
    always @* out = in[sel];
endmodule
module mux16_1(input [3:0] sel, input [15:0] in, output reg out);
    always @(*) begin
        out = in[sel];
    end
endmodule
module mux32_1(input [4:0] sel, input [31:0] in, output reg out);
    always @(*) out = in[sel];
endmodule
module mux64_1 (
    input  wire [5:0]  sel,
    input  wire [63:0] in,
    output reg         out
);

wire [63:0] level0;
wire [31:0] level1;
wire [15:0] level2;
wire [7:0]  level3;
wire [3:0]  level4;
wire [1:0]  level5;
wire        level6;

assign level0 = in;

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : g_l1
        assign level1[i] = sel[0] ? level0[2*i+1] : level0[2*i];
    end
endgenerate

generate
    for (i = 0; i < 16; i = i + 1) begin : g_l2
        assign level2[i] = sel[1] ? level1[2*i+1] : level1[2*i];
    end
endgenerate

generate
    for (i = 0; i < 8; i = i + 1) begin : g_l3
        assign level3[i] = sel[2] ? level2[2*i+1] : level2[2*i];
    end
endgenerate

generate
    for (i = 0; i < 4; i = i + 1) begin : g_l4
        assign level4[i] = sel[3] ? level3[2*i+1] : level3[2*i];
    end
endgenerate

generate
    for (i = 0; i < 2; i = i + 1) begin : g_l5
        assign level5[i] = sel[4] ? level4[2*i+1] : level4[2*i];
    end
endgenerate

assign level6 = sel[5] ? level5[1] : level5[0];

always @* begin
    out = level6;
end

endmodule
