// The sum of the last 32 samples. At each rising edge, x[0] takes the new
// sample din and every older sample moves one place along, and y takes
// the sum of all 32 as they were just before the edge. Each x holds its
// sample with five 0 bits on top: the sum of 32 needs 21 bits.
module msum32 (
  input  logic        clk,
  input  logic [15:0] din,
  output logic [20:0] y
);
  logic [20:0] x [0:31];   // x[0] is the newest sample, x[31] the oldest
  logic [20:0] sum;        // the sum of all 32, worked out between edges

  // 31 additions, all between one edge and the next.
  always_comb begin
    sum = 21'd0;
    for (int i = 0; i < 32; i++) sum = sum + x[i];
  end

  always_ff @(posedge clk) begin
    x[0] <= {5'd0, din};
    for (int i = 1; i < 32; i++) x[i] <= x[i-1];
    y <= sum;
  end
endmodule
