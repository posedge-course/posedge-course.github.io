// y is 1 when at least two of a, b and c are 1: a vote of three.
module vote (
  input  logic a,
  input  logic b,
  input  logic c,
  output logic y
);
  assign y = (a & b) | (a & c) | (b & c);
endmodule
