`timescale 1ns/1ps

module tb_sat_adder8;
    // Inputs
    reg [7:0] a;
    reg [7:0] b;
    // Outputs
    wire [7:0] sum;
    wire sat;

    // Instantiate the Unit Under Test (UUT)
    sat_adder8 uut (
        .a(a),
        .b(b),
        .sum(sum),
        .sat(sat)
    );

    initial begin
        integer passed_tests, failed_tests;
        passed_tests = 0;
        failed_tests = 0;

        // Test 1
        a = 8'b00000000; b = 8'b00000000;
        #10 $display("Test 1: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd0) begin
            $display("  ✓ sum=%b (expected 00000000)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 00000000)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 2
        a = 8'b11111111; b = 8'b00000000;
        #10 $display("Test 2: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 3
        a = 8'b00000000; b = 8'b11111111;
        #10 $display("Test 3: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 4
        a = 8'b11111111; b = 8'b11111111;
        #10 $display("Test 4: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b1) begin
            $display("  ✓ sat=%b (expected 1)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 1)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 5
        a = 8'b10000000; b = 8'b01111111;
        #10 $display("Test 5: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 6
        a = 8'b11111110; b = 8'b00000001;
        #10 $display("Test 6: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 7
        a = 8'b10000000; b = 8'b10000000;
        #10 $display("Test 7: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b1) begin
            $display("  ✓ sat=%b (expected 1)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 1)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 8
        a = 8'b11111111; b = 8'b00000001;
        #10 $display("Test 8: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b1) begin
            $display("  ✓ sat=%b (expected 1)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 1)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 9
        a = 8'b01100100; b = 8'b01100100;
        #10 $display("Test 9: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd200) begin
            $display("  ✓ sum=%b (expected 11001000)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11001000)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 10
        a = 8'b00110010; b = 8'b00110010;
        #10 $display("Test 10: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd100) begin
            $display("  ✓ sum=%b (expected 01100100)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 01100100)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 11
        a = 8'b11001000; b = 8'b00010100;
        #10 $display("Test 11: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd220) begin
            $display("  ✓ sum=%b (expected 11011100)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11011100)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 12
        a = 8'b10010110; b = 8'b01100100;
        #10 $display("Test 12: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd250) begin
            $display("  ✓ sum=%b (expected 11111010)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111010)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 13
        a = 8'b10010110; b = 8'b01101110;
        #10 $display("Test 13: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b1) begin
            $display("  ✓ sat=%b (expected 1)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 1)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 14
        a = 8'b11001000; b = 8'b01100100;
        #10 $display("Test 14: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b1) begin
            $display("  ✓ sat=%b (expected 1)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 1)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 15
        a = 8'b00001010; b = 8'b11110000;
        #10 $display("Test 15: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd250) begin
            $display("  ✓ sum=%b (expected 11111010)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111010)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 16
        a = 8'b00001010; b = 8'b11111010;
        #10 $display("Test 16: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b1) begin
            $display("  ✓ sat=%b (expected 1)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 1)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 17
        a = 8'b01111111; b = 8'b01111111;
        #10 $display("Test 17: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd254) begin
            $display("  ✓ sum=%b (expected 11111110)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111110)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 18
        a = 8'b01111111; b = 8'b10000000;
        #10 $display("Test 18: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 19
        a = 8'b01000000; b = 8'b11000000;
        #10 $display("Test 19: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b1) begin
            $display("  ✓ sat=%b (expected 1)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 1)", sat);
            failed_tests = failed_tests + 1;
        end

        // Test 20
        a = 8'b11001000; b = 8'b00110111;
        #10 $display("Test 20: a=%b b=%b", a, b);
        #10;
        if (sum === 8'd255) begin
            $display("  ✓ sum=%b (expected 11111111)", sum);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sum=%b (expected 11111111)", sum);
            failed_tests = failed_tests + 1;
        end
        if (sat === 1'b0) begin
            $display("  ✓ sat=%b (expected 0)", sat);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ sat=%b (expected 0)", sat);
            failed_tests = failed_tests + 1;
        end

        #10 $finish;
        $display("Test Summary: %0d passed, %0d failed, %0d total", passed_tests, failed_tests, passed_tests+failed_tests);
    end
endmodule