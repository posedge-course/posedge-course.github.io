// A FIFO (first in, first out): up to 2**ABITS values wait, in order,
// between a source and a sink on one clock. Values go in and come out
// with valid and ready, as in vr_reg: in_ready is 1 while there is room,
// out_valid while a value is waiting, and the oldest value is always on
// out_data. A value can go in and another come out at the same edge.
module fifo #(
  parameter int ABITS = 4               // 2**ABITS places: 16
) (
  input  logic           clk,
  input  logic           rst,
  input  logic           in_valid,
  output logic           in_ready,      // there is room
  input  logic [7:0]     in_data,
  output logic           out_valid,     // a value is waiting
  input  logic           out_ready,
  output logic [7:0]     out_data,      // the oldest value
  output logic [ABITS:0] count          // values held: 0 to 2**ABITS
);
  localparam logic [ABITS:0] FULL = {1'b1, {ABITS{1'b0}}};

  logic [7:0]       mem [2**ABITS];     // the places, used as a ring
  logic [ABITS-1:0] wr;                 // the place the next value goes
  logic [ABITS-1:0] rd;                 // the place of the oldest value
  logic             push;               // a value goes in at this edge
  logic             pop;                // a value comes out at this edge

  assign in_ready  = (count != FULL);
  assign out_valid = (count != '0);
  assign push      = in_valid & in_ready;
  assign pop       = out_valid & out_ready;
  assign out_data  = mem[rd];

  always_ff @(posedge clk)
    if (push) mem[wr] <= in_data;

  // wr and rd wrap from the last place back to the first by themselves.
  // count goes up when a value goes in, down when one comes out, and
  // stays put when both happen at once.
  always_ff @(posedge clk)
    if (rst) begin
      wr    <= '0;
      rd    <= '0;
      count <= '0;
    end else begin
      if (push) wr <= wr + 1'b1;
      if (pop)  rd <= rd + 1'b1;
      if (push & ~pop)      count <= count + 1'b1;
      else if (pop & ~push) count <= count - 1'b1;
    end
endmodule
