`timescale 1ns/1ps

module tb_adder4bit;

    // Inputs
    reg [3:0] a;
    reg [3:0] b;

    // Outputs
    wire [3:0] sum;
    wire carry;

    // Instantiate the Unit Under Test (UUT)
    adder4bit dut (
        .a(a),
        .b(b),
        .sum(sum),
        .carry(carry)
    );

    initial begin
        // Test 1
        a = 4'b0000; b = 4'b0000;
        $display("Test 1: a=%b b=%b", a, b);
        #10;
        // Test 2
        a = 4'b1111; b = 4'b0000;
        $display("Test 2: a=%b b=%b", a, b);
        #10;
        // Test 3
        a = 4'b0000; b = 4'b1111;
        $display("Test 3: a=%b b=%b", a, b);
        #10;
        // Test 4
        a = 4'b1111; b = 4'b1111;
        $display("Test 4: a=%b b=%b", a, b);
        #10;
        // Test 5
        a = 4'b1000; b = 4'b1000;
        $display("Test 5: a=%b b=%b", a, b);
        #10;
        // Test 6
        a = 4'b1000; b = 4'b0111;
        $display("Test 6: a=%b b=%b", a, b);
        #10;
        // Test 7
        a = 4'b0111; b = 4'b0111;
        $display("Test 7: a=%b b=%b", a, b);
        #10;
        // Test 8
        a = 4'b0001; b = 4'b1110;
        $display("Test 8: a=%b b=%b", a, b);
        #10;
        // Test 9
        a = 4'b0011; b = 4'b0101;
        $display("Test 9: a=%b b=%b", a, b);
        #10;
        // Test 10
        a = 4'b0010; b = 4'b1101;
        $display("Test 10: a=%b b=%b", a, b);
        #10;
        // Test 11
        a = 4'b1001; b = 4'b0110;
        $display("Test 11: a=%b b=%b", a, b);
        #10;
        // Test 12
        a = 4'b0100; b = 4'b1011;
        $display("Test 12: a=%b b=%b", a, b);
        #10;
        // Test 13
        a = 4'b1100; b = 4'b0011;
        $display("Test 13: a=%b b=%b", a, b);
        #10;
        // Test 14
        a = 4'b0101; b = 4'b1010;
        $display("Test 14: a=%b b=%b", a, b);
        #10;
        // Test 15
        a = 4'b0000; b = 4'b0111;
        $display("Test 15: a=%b b=%b", a, b);
        #10;
        // Test 16
        a = 4'b1111; b = 4'b0001;
        $display("Test 16: a=%b b=%b", a, b);
        #10;
        // Test 17
        a = 4'b0110; b = 4'b1001;
        $display("Test 17: a=%b b=%b", a, b);
        #10;
        // Test 18
        a = 4'b1110; b = 4'b0010;
        $display("Test 18: a=%b b=%b", a, b);
        #10;
        // Test 19
        a = 4'b1011; b = 4'b0100;
        $display("Test 19: a=%b b=%b", a, b);
        #10;
        // Test 20
        a = 4'b1101; b = 4'b0000;
        $display("Test 20: a=%b b=%b", a, b);
        #10;

        $finish;
    end

endmodule