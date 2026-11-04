// Multiplies two 16-bit numbers by shifting and adding, one bit of b a
// cycle, so it needs no multiplier. A pulse on start while busy is 0
// begins a job, which reads a and b at that edge. In each of the next 16
// cycles, if the lowest bit of bits is 1, p adds addend; then addend moves
// one place left and bits one place right. After the sixteenth, done is 1
// and p holds a times b, until the next start.
module mul_shift16 (
  input  logic        clk,
  input  logic        rst,
  input  logic        start,
  input  logic [15:0] a,
  input  logic [15:0] b,
  output logic [31:0] p,
  output logic        busy,
  output logic        done
);
  typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
  state_t      state, next;
  logic [31:0] addend;   // a, moved one place left each step
  logic [15:0] bits;     // b, moved one place right each step
  logic [3:0]  step;     // steps done so far in this job

  // The controller.
  always_comb begin
    next = state;
    case (state)
      IDLE, DONE: if (start)         next = BUSY;
      BUSY:       if (step == 4'd15) next = DONE;
      default:                       next = IDLE;
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) state <= IDLE;
    else     state <= next;
  end

  // The datapath.
  always_ff @(posedge clk) begin
    if (start & (state != BUSY)) begin
      p      <= 32'd0;
      addend <= {16'd0, a};
      bits   <= b;
      step   <= 4'd0;
    end else if (state == BUSY) begin
      if (bits[0]) p <= p + addend;
      addend <= {addend[30:0], 1'b0};
      bits   <= {1'b0, bits[15:1]};
      step   <= step + 4'd1;
    end
  end

  assign busy = (state == BUSY);
  assign done = (state == DONE);
endmodule
