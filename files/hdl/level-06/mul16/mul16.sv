// Multiplies two 16-bit numbers with one * : at each rising edge, p takes
// a times b. The product of two numbers from 0 to 65,535 fits in 32 bits.
module mul16 (
  input  logic        clk,
  input  logic [15:0] a,
  input  logic [15:0] b,
  output logic [31:0] p
);
  always_ff @(posedge clk)
    p <= a * b;
endmodule
