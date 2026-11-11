`timescale 1ns/1ps
// Testbench for harness, with LAST set to 7 so that each bit lasts 8
// cycles (80 ns) instead of 868. It plays the computer: it sends frames
// on rx, one byte each, and a receiver model reads the replies on tx.
// Each reply must be the frame plus 1 as two hexadecimal digits, a
// space, the core's cycle count, 3458 (00000D82), and CR LF. The frames
// alternate, as the thesis's board runs did, so that a reply with the
// last frame's result shows. A byte sent while a reply goes out must be
// ignored.
module harness_tb;
  logic       clk, btn, rx, tx, led;
  logic [7:0] heard [16];    // the characters that came back...
  int         n_heard;       // ...and how many
  logic [7:0] want [13];     // the reply expected
  int         errors;

  harness #(.TBITS(4), .LAST(4'd7)) dut (
    .clk(clk), .btn(btn), .rx(rx), .tx(tx), .led(led)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // The computer sends a byte: a start bit, bits 0 to 7, a stop bit.
  task automatic send_byte(input logic [7:0] value);
    rx = 1'b0;
    #80;
    for (int i = 0; i < 8; i++) begin
      rx = value[i];
      #80;
    end
    rx = 1'b1;
    #80;
  endtask

  // The computer's receiver: when tx falls, read a byte from the middle
  // of each bit, and keep it in heard.
  initial begin
    logic [7:0] got;
    forever begin
      @(negedge tx);
      #40;
      for (int i = 0; i < 8; i++) begin
        #80;
        got[i] = tx;
      end
      #80;
      if (n_heard < 16) heard[n_heard] = got;
      n_heard = n_heard + 1;
    end
  end

  // A hexadecimal digit in ASCII.
  function automatic logic [7:0] hex(input logic [3:0] d);
    return (d < 4'd10) ? 8'h30 + 8'(d) : 8'h37 + 8'(d);
  endfunction

  // The reply for a result and a count: two digits, a space, eight
  // digits, CR, LF.
  task automatic expect_reply(input logic [7:0] r, input logic [31:0] c);
    want[0] = hex(r[7:4]);
    want[1] = hex(r[3:0]);
    want[2] = 8'h20;
    for (int i = 0; i < 8; i++) want[3 + i] = hex(c[31 - 4 * i -: 4]);
    want[11] = 8'h0D;
    want[12] = 8'h0A;
  endtask

  // Prints one character of a reply: CR and LF as \r and \n.
  task automatic show(input logic [7:0] c);
    if (c == 8'h0D)      $write("\\r");
    else if (c == 8'h0A) $write("\\n");
    else                 $write("%c", c);
  endtask

  // Wait for 13 characters (at most 100 us), then compare.
  task automatic check_reply(input logic [7:0] frame);
    logic same;
    for (int t = 0; (t < 1000) & (n_heard < 13); t++) #100;
    #2000;                   // and nothing more may come
    same = (n_heard == 13);
    for (int i = 0; i < 13; i++)
      if (same & (heard[i] !== want[i])) same = 1'b0;
    if (~same) begin
      $write("TEST FAILED: frame %c: the reply was \"", frame);
      for (int i = 0; (i < n_heard) & (i < 16); i++) show(heard[i]);
      $write("\", expected \"");
      for (int i = 0; i < 13; i++) show(want[i]);
      $display("\" at %0d ns", $time);
      errors = errors + 1;
    end
  endtask

  task automatic run(input logic [7:0] frame);
    n_heard = 0;
    expect_reply(frame + 8'd1, 32'd3458);
    send_byte(frame);
    check_reply(frame);
  endtask

  initial begin
    $dumpfile("harness_tb.vcd");
    $dumpvars(0, harness_tb);
    errors  = 0;
    n_heard = 0;
    btn     = 1'b1;
    rx      = 1'b1;
    @(posedge clk);          // wait for a real rising edge first (D96)
    repeat (3) @(negedge clk);
    btn = 1'b0;
    #97;                     // the computer's clock is not clk's
    if (led !== 1'b0) begin
      $display("TEST FAILED: led=%b before any run at %0d ns", led, $time);
      errors = errors + 1;
    end
    run(8'h41);              // A, then B, A and B again, then z
    if (led !== 1'b1) begin
      $display("TEST FAILED: led=%b after a run at %0d ns", led, $time);
      errors = errors + 1;
    end
    run(8'h42);
    run(8'h41);
    run(8'h42);
    run(8'h7A);
    // 0, then 1 while the reply to 0 goes out: one reply, for 0, and
    // none after it, not even once a run of 1 would have finished.
    n_heard = 0;
    expect_reply(8'h31, 32'd3458);
    send_byte(8'h30);
    // Wait until the reply to 0 is under way, as check_reply waits: at
    // most 100 us, so that a harness that never replies cannot hang the
    // run.
    for (int t = 0; (t < 1000) & (n_heard < 2); t++) #100;
    if (n_heard < 2) begin
      $display("TEST FAILED: no reply to 0 at %0d ns", $time);
      errors = errors + 1;
    end
    send_byte(8'h31);
    check_reply(8'h30);
    #50000;
    if (n_heard > 13) begin  // a short reply has failed check_reply already
      $display("TEST FAILED: 1 came during a reply, and got one at %0d ns",
               $time);
      errors = errors + 1;
    end
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
