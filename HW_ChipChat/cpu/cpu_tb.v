
`timescale 1ns/1ps
module tb_cpu();
    reg clk = 0, rst_n = 0;
    wire [7:0] acc_out;
    wire halted;
    integer i;

    cpu dut (.clk(clk), .rst_n(rst_n), .acc_out(acc_out), .halted(halted));

    always #5 clk = ~clk;

    initial begin
        for (i = 0; i < 16; i = i + 1) dut.mem[i] = 8'd0;
        // Program: M[12] = M[10] * M[11] by repeated addition
        dut.mem[0]  = {3'b000, 5'd12}; // LDA 12
        dut.mem[1]  = {3'b010, 5'd10}; // ADD 10
        dut.mem[2]  = {3'b001, 5'd12}; // STA 12
        dut.mem[3]  = {3'b000, 5'd11}; // LDA 11
        dut.mem[4]  = {3'b011, 5'd13}; // SUB 13
        dut.mem[5]  = {3'b001, 5'd11}; // STA 11
        dut.mem[6]  = {3'b110, 5'd8};  // JZ 8
        dut.mem[7]  = {3'b101, 5'd0};  // JMP 0
        dut.mem[8]  = {3'b000, 5'd12}; // LDA 12
        dut.mem[9]  = {3'b111, 5'd0};  // HLT
        dut.mem[10] = 8'd5;            // A
        dut.mem[11] = 8'd3;            // B (loop counter)
        dut.mem[13] = 8'd1;            // constant 1

        #12 rst_n = 1;
        wait (halted);
        @(posedge clk);
        if (acc_out == 8'd15 && dut.mem[12] == 8'd15)
            $display("CPU test passed: 5 * 3 = %0d", acc_out);
        else
            $display("CPU test failed: expected 15, got ACC=%0d M[12]=%0d", acc_out, dut.mem[12]);
        $finish;
    end

    initial begin
        #10000 $display("CPU test failed: timeout"); $finish;
    end
endmodule
