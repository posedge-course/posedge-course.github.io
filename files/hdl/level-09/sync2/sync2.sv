// A two-flop synchroniser. async_in may change at any time: it comes from
// another clock's domain, or from outside the chip. When it changes too
// close to an edge, meta may go metastable; it then has a whole cycle to
// settle before safe takes its value, so sync_out is a clean 0 or 1 in
// clk's domain, two or three rising edges after async_in changes.
module sync2 (
  input  logic clk,
  input  logic async_in,   // from another domain: may change at any time
  output logic sync_out    // async_in, safe to use in clk's domain
);
  // ASYNC_REG marks the two flip-flops as a synchroniser: Vivado places
  // them close together, and its checks know what they are for (UG901).
  (* ASYNC_REG = "TRUE" *) logic meta, safe;

  always_ff @(posedge clk) begin
    meta <= async_in;      // may go metastable
    safe <= meta;          // a cycle later: settled
  end

  assign sync_out = safe;
endmodule
