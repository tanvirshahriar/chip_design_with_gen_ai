module half_adder(input wire a, input wire b, output wire sum, output wire cout);
  assign sum = a ^ b;
  assign cout = a & b;
endmodule
module full_adder(
  input  wire a,
  input  wire b,
  input  wire cin,
  output wire sum,
  output wire cout
);

  wire sum1, carry1, carry2;

  half_adder ha1 (
    .a    (a),
    .b    (b),
    .sum  (sum1),
    .cout (carry1)
  );

  half_adder ha2 (
    .a    (sum1),
    .b    (cin),
    .sum  (sum),
    .cout (carry2)
  );

  assign cout = carry1 | carry2;

endmodule
module adder4 (
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       cin,
  output wire [3:0] sum,
  output wire       cout
);

  wire c1, c2, c3;

  full_adder fa0 (.a(a[0]), .b(b[0]), .cin(cin),  .sum(sum[0]), .cout(c1));
  full_adder fa1 (.a(a[1]), .b(b[1]), .cin(c1),   .sum(sum[1]), .cout(c2));
  full_adder fa2 (.a(a[2]), .b(b[2]), .cin(c2),   .sum(sum[2]), .cout(c3));
  full_adder fa3 (.a(a[3]), .b(b[3]), .cin(c3),   .sum(sum[3]), .cout(cout));

endmodule
module adder8(
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       cin,
  output wire [7:0] sum,
  output wire       cout
);

  wire [3:0] sum_low, sum_high;
  wire       carry_low;

  adder4 u_adder4_low (
    .a    (a[3:0]),
    .b    (b[3:0]),
    .cin  (cin),
    .sum  (sum_low),
    .cout (carry_low)
  );

  adder4 u_adder4_high (
    .a    (a[7:4]),
    .b    (b[7:4]),
    .cin  (carry_low),
    .sum  (sum_high),
    .cout (cout)
  );

  assign sum = {sum_high, sum_low};

endmodule
