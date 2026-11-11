// rise is 1 for one cycle after level goes from 0 to 1. hist is a 2-bit
// shift register: hist[0] holds level from the last rising edge, and
// hist[1] from the edge before. rise is 1 when the newer one is 1 and the
// older one is 0.
module edge_detect (
  input  logic clk,
  input  logic level,
  output logic rise
);
  logic [1:0] hist;

  always_ff @(posedge clk)
    hist <= {hist[0], level};

  assign rise = hist[0] & ~hist[1];
endmodule
