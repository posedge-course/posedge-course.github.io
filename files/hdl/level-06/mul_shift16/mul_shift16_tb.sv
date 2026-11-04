`timescale 1ns/1ps
// Testbench for mul_shift16, the specification of the level 6 project's
// second way. For each pair, it pulses start for one cycle, then checks
// that busy is 1 for exactly 16 cycles, that done is 1 after them, and
// that p is then a times b. It reads only the ports, so any correct
// mul_shift16 passes.
module mul_shift16_tb;
  logic        clk;
  logic        rst;
  logic        start;
  logic [15:0] a, b;
  logic [31:0] p;
  logic        busy, done;
  logic [31:0] seed;          // the pseudo-random sequence
  int          errors;

  mul_shift16 dut (
    .clk(clk), .rst(rst), .start(start), .a(a), .b(b),
    .p(p), .busy(busy), .done(done)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic multiply(input logic [15:0] x, input logic [15:0] y);
    a = x;
    b = y;
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;
    a = 16'hxxxx;        // the job must have read a and b at the edge
    b = 16'hxxxx;
    for (int i = 0; i < 16; i++) begin
      if ((busy !== 1'b1) | (done !== 1'b0)) begin
        $display("TEST FAILED: busy=%b done=%b in step %0d at %0d ns",
                 busy, done, i, $time);
        errors = errors + 1;
      end
      @(negedge clk);
    end
    if ((busy !== 1'b0) | (done !== 1'b1) | (p !== x * y)) begin
      $display("TEST FAILED: %0d times %0d: p=%0d busy=%b done=%b",
               x, y, p, busy, done);
      $display("TEST FAILED: at %0d ns", $time);
      errors = errors + 1;
    end
  endtask

  initial begin
    $dumpfile("mul_shift16_tb.vcd");
    $dumpvars(0, mul_shift16_tb);
    errors = 0;
    seed = 32'd12345;
    rst = 1'b1;
    start = 1'b0;
    a = 16'd0;
    b = 16'd0;
    @(posedge clk);      // wait for a real rising edge first (D96)
    repeat (2) @(negedge clk);
    rst = 1'b0;
    @(negedge clk);
    multiply(16'd6, 16'd7);              // 42
    multiply(16'd65535, 16'd65535);      // the largest product
    multiply(16'd200, 16'd0);
    multiply(16'd1, 16'd32768);
    for (int i = 0; i < 200; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      multiply(seed[31:16], seed[15:0]);
    end
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
