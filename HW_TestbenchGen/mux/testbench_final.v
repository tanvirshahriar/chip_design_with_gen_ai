`timescale 1ns/1ps

module tb_mux2to1;
    reg a;
    reg b;
    reg sel;
    wire y;

    // Instantiate the module under test
    mux2to1 uut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
        integer passed_tests = 0;
        integer failed_tests = 0;

        // Test 1
        a = 1'b0; b = 1'b0; sel = 1'b0;
        #1 $display("Test 1: a=%b b=%b sel=%b", a, b, sel);
        #10;
        if (y === 1'b0) begin
            $display("  ✓ y: expected 0, got %b", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ y: expected 0, got %b", y);
            failed_tests = failed_tests + 1;
        end

        // Test 2
        a = 1'b0; b = 1'b0; sel = 1'b1;
        #1 $display("Test 2: a=%b b=%b sel=%b", a, b, sel);
        #10;
        if (y === 1'b0) begin
            $display("  ✓ y: expected 0, got %b", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ y: expected 0, got %b", y);
            failed_tests = failed_tests + 1;
        end

        // Test 3
        a = 1'b0; b = 1'b1; sel = 1'b0;
        #1 $display("Test 3: a=%b b=%b sel=%b", a, b, sel);
        #10;
        if (y === 1'b0) begin
            $display("  ✓ y: expected 0, got %b", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ y: expected 0, got %b", y);
            failed_tests = failed_tests + 1;
        end

        // Test 4
        a = 1'b0; b = 1'b1; sel = 1'b1;
        #1 $display("Test 4: a=%b b=%b sel=%b", a, b, sel);
        #10;
        if (y === 1'b1) begin
            $display("  ✓ y: expected 1, got %b", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ y: expected 1, got %b", y);
            failed_tests = failed_tests + 1;
        end

        // Test 5
        a = 1'b1; b = 1'b0; sel = 1'b0;
        #1 $display("Test 5: a=%b b=%b sel=%b", a, b, sel);
        #10;
        if (y === 1'b1) begin
            $display("  ✓ y: expected 1, got %b", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ y: expected 1, got %b", y);
            failed_tests = failed_tests + 1;
        end

        // Test 6
        a = 1'b1; b = 1'b0; sel = 1'b1;
        #1 $display("Test 6: a=%b b=%b sel=%b", a, b, sel);
        #10;
        if (y === 1'b0) begin
            $display("  ✓ y: expected 0, got %b", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ y: expected 0, got %b", y);
            failed_tests = failed_tests + 1;
        end

        // Test 7
        a = 1'b1; b = 1'b1; sel = 1'b0;
        #1 $display("Test 7: a=%b b=%b sel=%b", a, b, sel);
        #10;
        if (y === 1'b1) begin
            $display("  ✓ y: expected 1, got %b", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ y: expected 1, got %b", y);
            failed_tests = failed_tests + 1;
        end

        // Test 8
        a = 1'b1; b = 1'b1; sel = 1'b1;
        #1 $display("Test 8: a=%b b=%b sel=%b", a, b, sel);
        #10;
        if (y === 1'b1) begin
            $display("  ✓ y: expected 1, got %b", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ y: expected 1, got %b", y);
            failed_tests = failed_tests + 1;
        end

        $display("-------------------------------------------------");
        $display("Test Summary:");
        $display("  Total tests run: %d", passed_tests + failed_tests);
        $display("  Passed: %d", passed_tests);
        $display("  Failed: %d", failed_tests);
        $finish;
    end
endmodule