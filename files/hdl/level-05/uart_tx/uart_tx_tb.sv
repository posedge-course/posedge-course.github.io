`timescale 1ns/1ps
// Testbench for uart_tx, with LAST set to 4 so that each bit lasts 5
// cycles instead of 868. It is the specification of the level 5 project.
// A receiver model watches tx: when tx falls it waits half a bit, checks
// the start bit, reads eight data bits from the middle of each, then
// checks the stop bit, and compares the byte with the one sent. busy is
// checked too: it must be 1 from the edge after send until the stop bit
// has ended. It reads only the ports, so any correct uart_tx passes.
module uart_tx_tb;
  logic       clk;
  logic       rst;
  logic       send;
  logic [7:0] data;
  logic       tx;
  logic       busy;
  logic [7:0] sent;          // the byte the receiver should see next
  int         errors;
  int         bytes;         // bytes the receiver has checked

  uart_tx #(.BITS(3), .LAST(3'd4)) dut (
    .clk(clk), .rst(rst), .send(send), .data(data), .tx(tx), .busy(busy)
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
      if (got !== sent) begin
        $display("TEST FAILED: received %h, expected %h at %0d ns",
                 got, sent, $time);
        errors = errors + 1;
      end
      bytes = bytes + 1;
    end
  end

  // Pulse send for one cycle with this byte, then check busy and tx for
  // the 50 cycles of the frame and n cycles after it.
  task automatic send_byte(input logic [7:0] value, input int n);
    data = value;
    sent = value;
    send = 1'b1;
    @(negedge clk);
    send = 1'b0;
    repeat (50) begin
      if (busy !== 1'b1) begin
        $display("TEST FAILED: busy=%b during a frame at %0d ns",
                 busy, $time);
        errors = errors + 1;
      end
      @(negedge clk);
    end
    repeat (n) begin
      if ((busy !== 1'b0) | (tx !== 1'b1)) begin
        $display("TEST FAILED: busy=%b tx=%b after a frame at %0d ns",
                 busy, tx, $time);
        errors = errors + 1;
      end
      @(negedge clk);
    end
  endtask

  initial begin
    $dumpfile("uart_tx_tb.vcd");
    $dumpvars(0, uart_tx_tb);
    errors = 0;
    bytes = 0;
    rst = 1'b1;
    send = 1'b0;
    data = 8'h00;
    @(posedge clk);      // wait for a real rising edge first (D96)
    repeat (2) @(negedge clk);
    rst = 1'b0;
    repeat (3) @(negedge clk);

    send_byte(8'h41, 4);     // the letter A: 0100_0001
    send_byte(8'h0F, 2);
    send_byte(8'hA5, 1);

    // send while busy is ignored: pulse it again in the middle of a frame.
    data = 8'h3C;
    sent = 8'h3C;
    send = 1'b1;
    @(negedge clk);
    send = 1'b0;
    repeat (15) @(negedge clk);
    data = 8'hFF;
    send = 1'b1;
    @(negedge clk);
    send = 1'b0;
    repeat (40) @(negedge clk);

    send_byte(8'h00, 3);
    send_byte(8'hFF, 3);

    if (bytes != 6) begin
      $display("TEST FAILED: the receiver saw %0d bytes, expected 6",
               bytes);
      errors = errors + 1;
    end
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
