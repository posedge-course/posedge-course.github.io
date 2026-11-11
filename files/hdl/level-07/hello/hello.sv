// Sends "hello" and a new line over the UART each time btn is pressed.
// press turns the button into one pulse; the sender then gives uart_tx
// the seven characters one at a time, each once uart_tx is idle again.
module hello #(
  parameter int               TBITS = 10,      // uart_tx's timer width
  parameter logic [TBITS-1:0] LAST  = 867,     // 115,200 baud at 100 MHz
  parameter int               PBITS = 20,      // press's counter width
  parameter logic [PBITS-1:0] HOLD  = 999_999  // about 10 ms at 100 MHz
) (
  input  logic clk,
  input  logic rst,      // at a rising edge: stop sending
  input  logic btn,      // straight from the button
  output logic tx        // the serial line to the computer
);
  typedef enum logic [1:0] {IDLE, SEND, WAIT} state_t;
  state_t     state, next;
  logic       pressed;   // 1 for one cycle at each press
  logic       send;      // 1 for one cycle: uart_tx takes char
  logic       busy;      // uart_tx is sending a character
  logic [2:0] index;     // which character of the message
  logic [7:0] char;      // the character at index

  press #(.BITS(PBITS), .HOLD(HOLD)) button (
    .clk(clk), .rst(rst), .btn(btn), .pulse(pressed)
  );

  uart_tx #(.BITS(TBITS), .LAST(LAST)) uart (
    .clk(clk), .rst(rst), .send(send), .data(char), .tx(tx), .busy(busy)
  );

  // The sender: SEND gives uart_tx one character, WAIT waits until it
  // has gone, then either sends the next or stops after the seventh.
  always_comb begin
    next = state;
    case (state)
      IDLE:    if (pressed)                  next = SEND;
      SEND:                                  next = WAIT;
      WAIT:    if (~busy & (index == 3'd6))  next = IDLE;
               else if (~busy)               next = SEND;
      default:                               next = IDLE;
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) state <= IDLE;
    else     state <= next;
  end

  always_ff @(posedge clk) begin
    if ((state == IDLE) & pressed)    index <= 3'd0;
    else if ((state == WAIT) & ~busy) index <= index + 3'd1;
  end

  assign send = (state == SEND);

  // The message, one character for each value of index.
  always_comb begin
    case (index)
      3'd0:    char = 8'h68;   // h
      3'd1:    char = 8'h65;   // e
      3'd2:    char = 8'h6C;   // l
      3'd3:    char = 8'h6C;   // l
      3'd4:    char = 8'h6F;   // o
      3'd5:    char = 8'h0D;   // carriage return: back to the line start
      default: char = 8'h0A;   // line feed: down to a new line
    endcase
  end
endmodule
