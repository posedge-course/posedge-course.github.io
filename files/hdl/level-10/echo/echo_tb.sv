`timescale 1ns/1ps
// Testbench for echo, with LAST set to 7 so that each bit lasts 8 cycles
// (80 ns) instead of 868, and a FIFO of four places. It is the
// specification of the level 10 project. It plays the computer: it sends
// bytes on rx from a clock of its own, and a receiver model reads tx and
// checks each byte that comes back. Bytes sent while sw is 0 come
// straight back. While sw is 1 they wait in the FIFO: four fill it, the
// next two are lost and turn lost on, and the four come back, in order,
// when sw goes back to 0. A press of btn turns lost off. count and lost
// are checked after each step.
module echo_tb;
  logic       clk;
  logic       btn;
  logic       sw;
  logic       rx;
  logic       tx;
  logic [2:0] count;
  logic       lost;
  logic [7:0] want [8];      // the bytes that should come back, in order
  int         n_want;        // how many bytes should have come back
  int         n_back;        // how many have
  int         errors;

  echo #(.TBITS(4), .LAST(4'd7), .ABITS(2)) dut (
    .clk(clk), .btn(btn), .sw(sw), .rx(rx), .tx(tx), .count(count),
    .lost(lost)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic fail(input string what);
    $display("TEST FAILED: %s at %0d ns", what, $time);
    errors = errors + 1;
  endtask

  // The computer sends a byte: a start bit, bits 0 to 7, a stop bit.
  // back: the byte should come back.
  task automatic send_byte(input logic [7:0] value, input logic back);
    if (back) begin
      want[n_want] = value;
      n_want = n_want + 1;
    end
    rx = 1'b0;
    #80;
    for (int i = 0; i < 8; i++) begin
      rx = value[i];
      #80;
    end
    rx = 1'b1;
    #80;
  endtask

  task automatic check(input int c, input logic l, input int n);
    if (count !== 3'(c))
      fail($sformatf("count=%0d, expected %0d", count, c));
    if (lost !== l)
      fail($sformatf("lost=%b, expected %b", lost, l));
    if (n_back != n)
      fail($sformatf("%0d bytes came back, expected %0d", n_back, n));
  endtask

  // The computer's receiver: when tx falls, wait half a bit, read the
  // eight bits from the middle of each, then check the stop bit.
  initial begin
    logic [7:0] got;
    forever begin
      @(negedge tx);
      #40;
      if (tx !== 1'b0) fail("tx fell, but not for a start bit");
      for (int i = 0; i < 8; i++) begin
        #80;
        got[i] = tx;
      end
      #80;
      if (tx !== 1'b1) fail("no stop bit on tx");
      if (sw)
        fail($sformatf("%h came back while sw was 1", got));
      else if (n_back >= n_want)
        fail($sformatf("%h came back, but nothing should have", got));
      else if (got !== want[n_back])
        fail($sformatf("%h came back, expected %h", got, want[n_back]));
      n_back = n_back + 1;
    end
  end

  initial begin
    $dumpfile("echo_tb.vcd");
    $dumpvars(0, echo_tb);
    errors = 0;
    n_want = 0;
    n_back = 0;
    btn = 1'b1;
    sw  = 1'b0;
    rx  = 1'b1;
    @(posedge clk);          // wait for a real rising edge first (D96)
    repeat (3) @(negedge clk);
    btn = 1'b0;
    #97;                     // the computer's clock is not clk's
    check(0, 1'b0, 0);
    // sw at 0: h and i come straight back.
    send_byte(8'h68, 1'b1);
    send_byte(8'h69, 1'b1);
    #1000;
    check(0, 1'b0, 2);
    // sw at 1: a, b, c and d wait in the FIFO and fill it.
    sw = 1'b1;
    #100;
    send_byte(8'h61, 1'b1);
    send_byte(8'h62, 1'b1);
    send_byte(8'h63, 1'b1);
    send_byte(8'h64, 1'b1);
    #200;
    check(4, 1'b0, 2);
    // e and f find the FIFO full: they are lost.
    send_byte(8'h65, 1'b0);
    send_byte(8'h66, 1'b0);
    #200;
    check(4, 1'b1, 2);
    // sw at 0: a, b, c and d come back, in order.
    sw = 1'b0;
    #4000;
    check(0, 1'b1, 6);
    // A press of btn turns lost off; then z comes straight back.
    btn = 1'b1;
    #50;
    btn = 1'b0;
    #100;
    check(0, 1'b0, 6);
    send_byte(8'h7A, 1'b1);
    #1000;
    check(0, 1'b0, 7);
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
