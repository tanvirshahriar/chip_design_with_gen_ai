`timescale 1ns/1ps

module tb_adder8;
  reg  [7:0] a, b;
  reg        cin;
  wire [7:0] sum;
  wire       cout;
  integer num_tests, fail_count;

  adder8 dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  // Expected value is computed with Verilog arithmetic, not hard-coded.
  task run_test;
    input [7:0] ta;
    input [7:0] tb_val;
    input       tcin;
    reg   [8:0] expected;
    begin
      a = ta; b = tb_val; cin = tcin;
      #1;
      expected = ta + tb_val + tcin;
      num_tests = num_tests + 1;
      if ({cout, sum} !== expected) begin
        $display("ERROR: a=%0d b=%0d cin=%b expected %0d got %0d", ta, tb_val, tcin, expected, {cout, sum});
        fail_count = fail_count + 1;
      end
    end
  endtask

  initial begin
    a = 8'd0; b = 8'd0; cin = 1'b0;
    num_tests = 0;
    fail_count = 0;

    // Baseline tests: small values only, no carry out of bit 7.
    run_test(8'd0,   8'd0,  1'b0);
    run_test(8'd1,   8'd2,  1'b0);
    run_test(8'd3,   8'd4,  1'b1);
    run_test(8'd10,  8'd5,  1'b0);
    run_test(8'd15,  8'd1,  1'b0);
    run_test(8'd16,  8'd32, 1'b0);
    run_test(8'd100, 8'd27, 1'b0);
    run_test(8'd64,  8'd64, 1'b1);

    // Additional tests for coverage
    run_test(8'h03, 8'h03, 1'b0);
    run_test(8'h03, 8'h01, 1'b0);
    run_test(8'h0F, 8'h0F, 1'b0);
    run_test(8'h10, 8'h10, 1'b0);
    run_test(8'hF0, 8'hF0, 1'b0);
    run_test(8'hC0, 8'h40, 1'b0);
    run_test(8'hFF, 8'h01, 1'b0);
    run_test(8'hFF, 8'hFF, 1'b1);
    run_test(8'h80, 8'h80, 1'b0);
    run_test(8'h0F, 8'h01, 1'b0);
    run_test(8'h00, 8'h00, 1'b0);

    // Cover missed half-adder combinations in high adder
    run_test(8'b11000000, 8'b11000000, 1'b0); // fa2.ha1 (1,1) and fa3.ha1 (1,1)
    run_test(8'b10000000, 8'b00000000, 1'b0); // fa3.ha2 (1,0)

    $display("Total tests: %0d", num_tests);
    if (fail_count == 0) $display("All tests passed!");
    else $display("%0d test(s) failed.", fail_count);
    $finish;
  end
endmodule
