`timescale 1ns/1ps

module tb_full_adder;
  reg  a, b, cin;
  wire sum, cout;
  reg  [1:0] expected;
  integer i, num_tests, fail_count;

  full_adder dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  initial begin
    num_tests = 0;
    fail_count = 0;
    for (i = 0; i < 8; i = i + 1) begin
      {a, b, cin} = i[2:0];
      #1;
      expected = a + b + cin;
      num_tests = num_tests + 1;
      if ({cout, sum} !== expected) begin
        $display("ERROR: a=%b b=%b cin=%b expected {cout,sum}=%b got %b%b", a, b, cin, expected, cout, sum);
        fail_count = fail_count + 1;
      end
    end
    $display("Total tests: %0d", num_tests);
    if (fail_count == 0) $display("All tests passed!");
    else $display("%0d test(s) failed.", fail_count);
    $finish;
  end
endmodule
