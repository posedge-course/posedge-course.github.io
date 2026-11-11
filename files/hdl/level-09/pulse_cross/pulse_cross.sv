// Carries one-cycle pulses from clk_a's domain to clk_b's. A pulse of
// clk_a can be over before clk_b has an edge, so a synchroniser on its
// own could miss it. It crosses as a level instead: each pulse flips
// level_a, which then holds still, and clk_b's side turns each change of
// the synchronised level back into one pulse. Pulses must come at least
// two cycles of clk_b apart, so that clk_b sees every level.
module pulse_cross (
  input  logic clk_a,
  input  logic rst_a,      // clk_a's reset
  input  logic pulse_a,    // 1 for one cycle of clk_a
  input  logic clk_b,
  output logic pulse_b     // 1 for one cycle of clk_b, once per pulse_a
);
  logic level_a;           // flips at each pulse_a
  logic level_b;           // level_a, synchronised to clk_b
  logic last_b;            // level_b, one edge of clk_b ago

  always_ff @(posedge clk_a)
    if (rst_a) level_a <= 1'b0;
    else       level_a <= level_a ^ pulse_a;

  sync2 sync (.clk(clk_b), .async_in(level_a), .sync_out(level_b));

  always_ff @(posedge clk_b)
    last_b <= level_b;

  assign pulse_b = level_b ^ last_b;   // a change, either way
endmodule
