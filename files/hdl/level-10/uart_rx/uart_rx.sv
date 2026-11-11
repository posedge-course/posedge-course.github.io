// Receives bytes on a serial line, as a UART does. The line rests at 1;
// a byte is a start bit (0), the eight data bits from bit 0 to bit 7, and
// a stop bit (1), each LAST + 1 cycles of clk long (level 5's uart_tx).
// rx comes from another chip, so it is synchronised first. At the start
// bit's falling edge the receiver waits half a bit, to stand in its
// middle, then reads each bit a whole bit later, in its middle too. If
// the stop bit is 1, valid is 1 for one cycle with the byte on data;
// otherwise the byte is dropped.
module uart_rx #(
  parameter int              BITS = 10,  // the width of timer
  parameter logic [BITS-1:0] LAST = 867  // 868 cycles a bit: 115,200 baud
) (
  input  logic       clk,
  input  logic       rst,
  input  logic       rx,       // the serial line: changes at any time
  output logic [7:0] data,     // the byte: good while valid is 1
  output logic       valid     // 1 for one cycle for each byte
);
  typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
  state_t          state, next;
  logic            line;       // rx, synchronised to clk (level 9)
  logic            line_was;   // line one cycle ago
  logic [BITS-1:0] timer;      // cycles since the edge or the last read
  logic            mid;        // 1 in the cycle the line is read
  logic [2:0]      index;      // which data bit is read next

  sync2 sync (.clk(clk), .async_in(rx), .sync_out(line));

  always_ff @(posedge clk)
    line_was <= line;

  // Half a bit after the falling edge, then a whole bit after each read.
  assign mid = (state == START) ? (timer == (LAST >> 1)) : (timer == LAST);

  always_comb begin
    next = state;
    case (state)
      IDLE:  if (line_was & ~line)       next = START;
      START: if (mid & line)             next = IDLE;   // only a dip
             else if (mid)               next = DATA;
      DATA:  if (mid & (index == 3'd7))  next = STOP;
      STOP:  if (mid)                    next = IDLE;
      default:                           next = IDLE;
    endcase
  end

  always_ff @(posedge clk)
    if (rst) state <= IDLE;
    else     state <= next;

  always_ff @(posedge clk)
    if ((state == IDLE) | mid) timer <= '0;
    else                       timer <= timer + 1;

  // Each data bit goes in at the top and moves down, so bit 0, which
  // comes first, ends at the bottom.
  always_ff @(posedge clk)
    if (state == START) begin
      index <= 3'd0;
      data  <= 8'h00;
    end else if ((state == DATA) & mid) begin
      data  <= {line, data[7:1]};
      index <= index + 3'd1;
    end

  assign valid = (state == STOP) & mid & line;
endmodule
