// Sends one byte on a serial line, as a UART does: a start bit (0), the
// eight data bits from bit 0 to bit 7, then a stop bit (1). Every bit
// lasts LAST + 1 cycles of clk, and tx rests at 1 between bytes. A pulse
// on send, while busy is 0, sends data; busy is 1 until the stop bit ends.
module uart_tx #(
  parameter int              BITS = 10,  // the width of timer
  parameter logic [BITS-1:0] LAST = 867  // 868 cycles a bit: 115,200 baud
) (
  input  logic       clk,
  input  logic       rst,
  input  logic       send,
  input  logic [7:0] data,
  output logic       tx,
  output logic       busy
);
  typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
  state_t          state, next;
  logic [BITS-1:0] timer;      // cycles into the bit on the line
  logic            bit_end;    // 1 in the last cycle of a bit
  logic [7:0]      shift;      // the byte; bit 0 is the one on the line
  logic [2:0]      index;      // which data bit is on the line

  assign bit_end = (timer == LAST);

  // The controller.
  always_comb begin
    next = state;
    case (state)
      IDLE:  if (send)                       next = START;
      START: if (bit_end)                    next = DATA;
      DATA:  if (bit_end & (index == 3'd7))  next = STOP;
      STOP:  if (bit_end)                    next = IDLE;
      default:                               next = IDLE;
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) state <= IDLE;
    else     state <= next;
  end

  // The bit timer: a counter that runs while a byte is being sent.
  always_ff @(posedge clk) begin
    if ((state == IDLE) | bit_end) timer <= '0;
    else                           timer <= timer + 1;
  end

  // The datapath: load the byte, then shift it down a bit at a time.
  always_ff @(posedge clk) begin
    if ((state == IDLE) & send) begin
      shift <= data;
      index <= 3'd0;
    end else if ((state == DATA) & bit_end) begin
      shift <= {1'b0, shift[7:1]};
      index <= index + 3'd1;
    end
  end

  assign tx   = (state == START) ? 1'b0 :
                (state == DATA)  ? shift[0] : 1'b1;
  assign busy = (state != IDLE);
endmodule
