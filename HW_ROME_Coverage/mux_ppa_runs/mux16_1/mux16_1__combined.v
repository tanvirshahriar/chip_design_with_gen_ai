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
    wire [7:0] l0;
    wire [3:0] l1;
    wire [1:0] l2;
    wire       l3;

    genvar i;
    // Level 0: 8 2-to-1 muxes using sel[0]
    generate
        for (i = 0; i < 8; i = i + 1) begin : g_l0
            assign l0[i] = sel[0] ? in[2*i+1] : in[2*i];
        end
    endgenerate

    // Level 1: 4 2-to-1 muxes using sel[1]
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_l1
            assign l1[i] = sel[1] ? l0[2*i+1] : l0[2*i];
        end
    endgenerate

    // Level 2: 2 2-to-1 muxes using sel[2]
    generate
        for (i = 0; i < 2; i = i + 1) begin : g_l2
            assign l2[i] = sel[2] ? l1[2*i+1] : l1[2*i];
        end
    endgenerate

    // Level 3: 1 2-to-1 mux using sel[3]
    assign l3 = sel[3] ? l2[1] : l2[0];

    always @(*) begin
        out = l3;
    end
endmodule
