// The sum of the last 32 samples, as in msum32, but added as a tree with
// a register after each level: pairs of samples, then pairs of those
// sums, and so on. Each path through it does one addition between two
// edges, and y comes four cycles later than msum32's.
module msum32_pipe (
  input  logic        clk,
  input  logic [15:0] din,
  output logic [20:0] y
);
  logic [20:0] x  [0:31];  // the samples, as in msum32
  logic [20:0] s1 [0:15];  // sums of two samples
  logic [20:0] s2 [0:7];   // sums of four
  logic [20:0] s3 [0:3];   // sums of eight
  logic [20:0] s4 [0:1];   // sums of sixteen

  always_ff @(posedge clk) begin
    x[0] <= {5'd0, din};
    for (int i = 1; i < 32; i++) x[i] <= x[i-1];
    for (int i = 0; i < 16; i++) s1[i] <= x[2*i] + x[2*i+1];
    for (int i = 0; i < 8; i++)  s2[i] <= s1[2*i] + s1[2*i+1];
    for (int i = 0; i < 4; i++)  s3[i] <= s2[2*i] + s2[2*i+1];
    for (int i = 0; i < 2; i++)  s4[i] <= s3[2*i] + s3[2*i+1];
    y <= s4[0] + s4[1];
  end
endmodule
