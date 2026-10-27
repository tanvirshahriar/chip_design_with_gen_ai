module mux2_1(input wire in1, input wire in2, input wire select, output wire out);
    assign out = select ? in2 : in1;
endmodule
module mux4_1(input [1:0] sel, input [3:0] in, output reg out);
    always @(*) out = in[sel];
endmodule
module mux8_1(input [2:0] sel, input [7:0] in, output reg out);
    wire [1:0] stage1;
    assign stage1[0] = sel[1] ? (sel[0] ? in[3] : in[2]) : (sel[0] ? in[1] : in[0]);
    assign stage1[1] = sel[1] ? (sel[0] ? in[7] : in[6]) : (sel[0] ? in[5] : in[4]);
    always @* out = sel[2] ? stage1[1] : stage1[0];
endmodule
