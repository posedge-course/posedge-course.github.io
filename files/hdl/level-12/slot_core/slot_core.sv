// A core with the 3D decoder's handshake, in small. A start pulse asks
// for one run of SLOT cycles of work, as one voxel's slot in the
// decoder. The core takes a cycle to begin: then busy goes to 1 and done
// to 0. When the run is over, busy goes back to 0 and done to 1, and
// done stays 1 until the next run begins. The core counts its own
// cycles, from the edge that sees start to the one that sets done, as
// the decoder does, and gives back a result: here the frame it was
// started with, plus 1.
module slot_core #(
  parameter int SLOT = 12              // cycles of work in a run
) (
  input  logic        clk,
  input  logic        rst,             // 1 at an edge: idle, not done
  input  logic        start,           // 1 for one cycle: run once
  input  logic [7:0]  frame,           // the input, read at start
  output logic        busy,
  output logic        done,
  output logic [31:0] cycles,          // cycles from start to done
  output logic [7:0]  result
);
  logic        go;                     // start, one edge later
  logic [7:0]  f;                      // the frame being worked on
  logic [31:0] n;                      // cycles of work done so far

  always_ff @(posedge clk)
    if (rst) begin
      go   <= 1'b0;
      busy <= 1'b0;
      done <= 1'b0;
    end else begin
      go <= start;
      if (start) begin
        f      <= frame;
        cycles <= 32'd1;
      end else if (go | busy) cycles <= cycles + 32'd1;
      if (go) begin
        busy <= 1'b1;
        done <= 1'b0;
        n    <= 32'd0;
      end else if (busy) begin
        n <= n + 32'd1;
        if (n == 32'(SLOT - 1)) begin
          busy   <= 1'b0;
          done   <= 1'b1;
          result <= f + 8'd1;
        end
      end
    end
endmodule
