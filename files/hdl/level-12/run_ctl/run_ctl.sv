// Runs a core once each time go is 1, as the 3D decoder's board wrapper
// does: it pulses start, waits until the core reports busy, then until
// it reports done, and then pulses reply: the core's results are new.
// The core's done is still 1 from the last run until the core has begun
// the new one, so done counts only after busy has been seen.
module run_ctl (
  input  logic clk,
  input  logic rst,                    // 1 at an edge: back to idle
  input  logic go,                     // 1 for one cycle: run the core
  input  logic busy,                   // from the core
  input  logic done,                   // from the core
  output logic start,                  // to the core: 1 for one cycle
  output logic reply                   // 1 for one cycle: results new
);
  typedef enum logic [1:0] {IDLE, WAIT_BUSY, WAIT_DONE} state_t;
  state_t state;

  always_ff @(posedge clk)
    if (rst) begin
      state <= IDLE;
      start <= 1'b0;
      reply <= 1'b0;
    end else begin
      start <= 1'b0;
      reply <= 1'b0;
      case (state)
        IDLE:      if (go) begin
                     start <= 1'b1;
                     state <= WAIT_BUSY;
                   end
        WAIT_BUSY: if (busy) state <= WAIT_DONE;
        WAIT_DONE: if (done) begin
                     reply <= 1'b1;
                     state <= IDLE;
                   end
        default:   state <= IDLE;
      endcase
    end
endmodule
