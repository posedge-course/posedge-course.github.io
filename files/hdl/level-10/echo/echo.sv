// UART echo through a FIFO, the level 10 project. Each byte the computer
// sends on rx is received, waits in a FIFO, and goes back on tx. While
// sw is 1 (hold), bytes wait in the FIFO instead. A UART cannot be told
// to wait, so a byte that arrives while the FIFO is full is lost, and
// lost turns on until the next reset. count says how many bytes wait.
module echo #(
  parameter int               TBITS = 10,   // the UARTs' timer width
  parameter logic [TBITS-1:0] LAST  = 867,  // 115,200 baud at 100 MHz
  parameter int               ABITS = 2     // the FIFO: 4 places
) (
  input  logic           clk,
  input  logic           btn,      // reset: straight from the button
  input  logic           sw,       // hold: straight from the switch
  input  logic           rx,       // from the computer
  output logic           tx,       // to the computer
  output logic [ABITS:0] count,    // bytes waiting
  output logic           lost      // a byte came while the FIFO was full
);
  logic       rst;        // btn, through a reset synchroniser
  logic       hold;       // sw, synchronised
  logic [7:0] got;        // the byte uart_rx received...
  logic       got_valid;  // ...good for this one cycle
  logic       room;       // the FIFO can take a byte
  logic       waiting;    // a byte waits in the FIFO
  logic [7:0] oldest;     // the byte that has waited longest
  logic       take;       // uart_tx takes that byte at this edge
  logic       busy;       // uart_tx is sending

  rst_sync reset (.clk(clk), .arst(btn), .rst(rst));
  sync2    hold_sync (.clk(clk), .async_in(sw), .sync_out(hold));

  uart_rx #(.BITS(TBITS), .LAST(LAST)) receiver (
    .clk(clk), .rst(rst), .rx(rx), .data(got), .valid(got_valid)
  );

  fifo #(.ABITS(ABITS)) buffer (
    .clk(clk), .rst(rst),
    .in_valid(got_valid), .in_ready(room), .in_data(got),
    .out_valid(waiting), .out_ready(take), .out_data(oldest),
    .count(count)
  );

  // uart_tx is the FIFO's sink: it is ready when it is not busy, and
  // hold keeps it from taking anything.
  assign take = ~busy & ~hold;

  uart_tx #(.BITS(TBITS), .LAST(LAST)) sender (
    .clk(clk), .rst(rst), .send(waiting & take), .data(oldest),
    .tx(tx), .busy(busy)
  );

  always_ff @(posedge clk)
    if (rst)                    lost <= 1'b0;
    else if (got_valid & ~room) lost <= 1'b1;
endmodule
