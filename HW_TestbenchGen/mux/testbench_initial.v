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
        // Test 1
        a = 1'b0; b = 1'b0; sel = 1'b0;
        #1 $display("Test 1: a=%b b=%b sel=%b", a, b, sel);
        // Test 2
        a = 1'b0; b = 1'b0; sel = 1'b1;
        #1 $display("Test 2: a=%b b=%b sel=%b", a, b, sel);
        // Test 3
        a = 1'b0; b = 1'b1; sel = 1'b0;
        #1 $display("Test 3: a=%b b=%b sel=%b", a, b, sel);
        // Test 4
        a = 1'b0; b = 1'b1; sel = 1'b1;
        #1 $display("Test 4: a=%b b=%b sel=%b", a, b, sel);
        // Test 5
        a = 1'b1; b = 1'b0; sel = 1'b0;
        #1 $display("Test 5: a=%b b=%b sel=%b", a, b, sel);
        // Test 6
        a = 1'b1; b = 1'b0; sel = 1'b1;
        #1 $display("Test 6: a=%b b=%b sel=%b", a, b, sel);
        // Test 7
        a = 1'b1; b = 1'b1; sel = 1'b0;
        #1 $display("Test 7: a=%b b=%b sel=%b", a, b, sel);
        // Test 8
        a = 1'b1; b = 1'b1; sel = 1'b1;
        #1 $display("Test 8: a=%b b=%b sel=%b", a, b, sel);
        $finish;
    end
endmodule