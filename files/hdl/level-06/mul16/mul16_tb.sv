`timescale 1ns/1ps
// Testbench for mul16, the specification of the level 6 project's first
// way. a and b change on falling edges; p must keep its value until the
// next rising edge, and after it be their product. It tries the corners and
// 2,000 pairs from a fixed pseudo-random sequence, and reads only the
// ports, so any correct mul16 passes.
module mul16_tb;
  logic        clk;
  logic [15:0] a, b;
  logic [31:0] p;
  logic [31:0] seed;          // the pseudo-random sequence
  int          errors;

  mul16 dut (.clk(clk), .a(a), .b(b), .p(p));

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Set a and b for the next rising edge: p must not change before it, and
  // must be their product after it.
  task automatic check(input logic [15:0] x, input logic [15:0] y);
    logic [31:0] held;   // p before the edge
    held = p;
    a = x;
    b = y;
    #1;
    if (p !== held) begin
      $display("TEST FAILED: p changed before a rising edge at %0d ns",
               $time);
      errors = errors + 1;
    end
    @(negedge clk);
    if (p !== x * y) begin
      $display("TEST FAILED: %0d times %0d gave %0d at %0d ns",
               x, y, p, $time);
      errors = errors + 1;
    end
  endtask

  initial begin
    $dumpfile("mul16_tb.vcd");
    $dumpvars(0, mul16_tb);
    errors = 0;
    seed = 32'd12345;
    a = 16'd0;
    b = 16'd0;
    @(posedge clk);      // wait for a real rising edge first (D96)
    @(negedge clk);
    check(16'd6, 16'd7);                 // 42
    check(16'd65535, 16'd65535);         // the largest product
    check(16'd0, 16'd65535);
    check(16'd1, 16'd40000);
    check(16'd256, 16'd256);             // 65,536: needs bit 16
    for (int i = 0; i < 2000; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      check(seed[31:16], seed[15:0]);
    end
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
