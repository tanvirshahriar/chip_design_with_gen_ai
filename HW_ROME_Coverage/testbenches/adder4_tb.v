`timescale 1ns/1ps

module tb_adder4;
  reg  [3:0] a, b;
  reg        cin;
  wire [3:0] sum;
  wire       cout;
  integer num_tests, fail_count;

  adder4 dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  task run_test;
    input [3:0] ta;
    input [3:0] tb_val;
    input       tcin;
    reg   [4:0] expected;
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
    num_tests = 0;
    fail_count = 0;
    run_test(4'd0,  4'd0,  1'b0);
    run_test(4'd1,  4'd2,  1'b0);
    run_test(4'd5,  4'd6,  1'b1);
    run_test(4'd7,  4'd8,  1'b0);
    run_test(4'd15, 4'd1,  1'b0);
    run_test(4'd15, 4'd15, 1'b1);
    run_test(4'd9,  4'd3,  1'b1);
    run_test(4'd12, 4'd2,  1'b0);
    $display("Total tests: %0d", num_tests);
    if (fail_count == 0) $display("All tests passed!");
    else $display("%0d test(s) failed.", fail_count);
    $finish;
  end
endmodule
