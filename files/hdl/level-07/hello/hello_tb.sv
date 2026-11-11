`timescale 1ns/1ps
// Testbench for hello, with each bit 5 cycles long instead of 868 and a
// debounce of 4 cycles instead of 1,000,000. A receiver model reads every
// character from tx, as in uart_tx_tb, and checks it against the message.
// The button is pressed, then pressed twice more while the message is going
// out, during its first character and during its third (which must change
// nothing), then pressed once more for a second message.
module hello_tb;
  logic       clk;
  logic       rst;
  logic       btn;
  logic       tx;
  logic [7:0] message [0:6];  // what each press must send
  int         errors;
  int         chars;          // characters the receiver has checked

  hello #(.TBITS(3), .LAST(3'd4), .PBITS(2), .HOLD(2'd3)) dut (
    .clk(clk), .rst(rst), .btn(btn), .tx(tx)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // The receiver model. A bit lasts 5 cycles (50 ns); the middle of the
  // start bit is 25 ns after tx falls.
  initial begin
    logic [7:0] got;
    forever begin
      @(negedge tx);
      #25;
      if (tx !== 1'b0) begin
        $display("TEST FAILED: start bit is %b at %0d ns", tx, $time);
        errors = errors + 1;
      end
      for (int i = 0; i < 8; i++) begin
        #50;
        got[i] = tx;
      end
      #50;
      if (tx !== 1'b1) begin
        $display("TEST FAILED: stop bit is %b at %0d ns", tx, $time);
        errors = errors + 1;
      end
      if (got !== message[chars % 7]) begin
        $display("TEST FAILED: received %h, expected %h at %0d ns",
                 got, message[chars % 7], $time);
        errors = errors + 1;
      end
      chars = chars + 1;
    end
  end

  // Hold the button down for n cycles, then let go for 20.
  task automatic push(input int n);
    btn = 1'b1;
    repeat (n) @(negedge clk);
    btn = 1'b0;
    repeat (20) @(negedge clk);
  endtask

  initial begin
    $dumpfile("hello_tb.vcd");
    $dumpvars(0, hello_tb);
    message[0] = 8'h68;   // h
    message[1] = 8'h65;   // e
    message[2] = 8'h6C;   // l
    message[3] = 8'h6C;   // l
    message[4] = 8'h6F;   // o
    message[5] = 8'h0D;   // carriage return
    message[6] = 8'h0A;   // line feed
    errors = 0;
    chars = 0;
    rst = 1'b1;
    btn = 1'b0;
    @(posedge clk);      // wait for a real rising edge first (D96)
    repeat (2) @(negedge clk);
    rst = 1'b0;
    repeat (5) @(negedge clk);
    if (tx !== 1'b1) begin
      $display("TEST FAILED: tx=%b before any press at %0d ns", tx, $time);
      errors = errors + 1;
    end
    push(10);                  // the first message
    push(10);                  // pressed again during its first character
    repeat (60) @(negedge clk);
    push(10);                  // and during its third
    repeat (400) @(negedge clk);
    if (chars !== 7) begin
      $display("TEST FAILED: %0d characters after one message", chars);
      $display("TEST FAILED: at %0d ns", $time);
      errors = errors + 1;
    end
    push(10);                  // the second message
    repeat (420) @(negedge clk);
    if ((chars !== 14) | (tx !== 1'b1)) begin
      $display("TEST FAILED: %0d characters, tx=%b after two messages",
               chars, tx);
      $display("TEST FAILED: at %0d ns", $time);
      errors = errors + 1;
    end
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
