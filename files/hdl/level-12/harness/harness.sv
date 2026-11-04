// Runs a core on the board and times it, as the 3D decoder's board
// harness does. Each byte the computer sends is a frame: run_ctl starts
// the core on it and waits for busy, then done. The core counts its own
// cycles. The reply is the core's result as two hexadecimal digits, a
// space, the count as eight digits, then a carriage return and a line
// feed. A byte that arrives while a reply is going out is ignored. LD4
// shows the core's done.
module harness #(
  parameter int               TBITS = 10,   // the UARTs' timer width
  parameter logic [TBITS-1:0] LAST  = 867,  // 115,200 baud at 100 MHz
  parameter int               SLOT  = 3456  // the core's run: one slot
) (
  input  logic clk,
  input  logic btn,          // reset: straight from the button
  input  logic rx,           // from the computer
  output logic tx,           // to the computer
  output logic led           // the core's done
);
  logic        rst;          // btn, through a reset synchroniser
  logic [7:0]  got;          // the byte uart_rx received...
  logic        got_valid;    // ...good for this one cycle
  logic        start, busy, done, reply;
  logic [31:0] cycles;       // the core's count of its own cycles
  logic [7:0]  result;       // the core's result
  logic [39:0] val;          // the digits still to send, top first
  logic [3:0]  pos;          // the next character, 0 to 12; 13: none
  logic [3:0]  digit;        // the top digit of val
  logic [7:0]  ch;           // the next character, in ASCII
  logic        idle;         // no reply is going out
  logic        send, tx_busy;

  rst_sync reset (.clk(clk), .arst(btn), .rst(rst));

  uart_rx #(.BITS(TBITS), .LAST(LAST)) receiver (
    .clk(clk), .rst(rst), .rx(rx), .data(got), .valid(got_valid)
  );

  run_ctl control (
    .clk(clk), .rst(rst), .go(got_valid & idle), .busy(busy),
    .done(done), .start(start), .reply(reply)
  );

  slot_core #(.SLOT(SLOT)) core (
    .clk(clk), .rst(rst), .start(start), .frame(got), .busy(busy),
    .done(done), .cycles(cycles), .result(result)
  );

  // The reply, a character at a time. In ASCII, the digits 0 to 9 are
  // 30 to 39, A to F are 41 to 46, a space is 20, CR 0D and LF 0A.
  assign digit = val[39:36];
  assign idle  = (pos == 4'd13);
  assign send  = ~idle & ~tx_busy;

  always_comb
    case (pos)
      4'd2:    ch = 8'h20;
      4'd11:   ch = 8'h0D;
      4'd12:   ch = 8'h0A;
      default: ch = (digit < 4'd10) ? 8'h30 + 8'(digit)
                                    : 8'h37 + 8'(digit);
    endcase

  always_ff @(posedge clk)
    if (rst)
      pos <= 4'd13;
    else if (reply) begin
      val <= {result, cycles};
      pos <= 4'd0;
    end else if (send) begin
      pos <= pos + 4'd1;
      if (pos != 4'd2) val <= {val[35:0], 4'h0};
    end

  uart_tx #(.BITS(TBITS), .LAST(LAST)) sender (
    .clk(clk), .rst(rst), .send(send), .data(ch), .tx(tx),
    .busy(tx_busy)
  );

  assign led = done;
endmodule
