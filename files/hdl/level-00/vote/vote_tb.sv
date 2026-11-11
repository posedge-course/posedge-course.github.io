`timescale 1ns/1ps
// Testbench for vote. Each row sets a, b and c, waits 10 ns, then checks
// that y is the value the row expects.
module vote_tb;
  logic a, b, c;  // the inputs the testbench sets
  logic y;        // the output it checks
  int   errors;   // how many rows went wrong

  vote dut (.a(a), .b(b), .c(c), .y(y));  // one vote, the design under test

  // One row: the inputs a, b and c, then the y we expect.
  task automatic step(input logic va, input logic vb, input logic vc,
                      input logic want);
    a = va;
    b = vb;
    c = vc;
    #10;
    if (y !== want) begin
      $display("TEST FAILED: a=%b b=%b c=%b y=%b, expected %b at %0d ns",
               a, b, c, y, want, $time);
      errors = errors + 1;
    end
  endtask

  initial begin
    $dumpfile("vote_tb.vcd");
    $dumpvars(0, vote_tb);
    errors = 0;

    // Part 1: the eight rows in a mixed order.
    step(1'b0, 1'b0, 1'b0, 1'b0);
    step(1'b1, 1'b1, 1'b0, 1'b1);
    step(1'b0, 1'b1, 1'b1, 1'b1);
    step(1'b1, 1'b0, 1'b0, 1'b0);
    step(1'b1, 1'b1, 1'b1, 1'b1);
    step(1'b0, 1'b0, 1'b1, 1'b0);
    step(1'b1, 1'b0, 1'b1, 1'b1);
    step(1'b0, 1'b1, 1'b0, 1'b0);

    // Part 2: the same eight rows in counting order, from 000 to 111.
    step(1'b0, 1'b0, 1'b0, 1'b0);
    step(1'b0, 1'b0, 1'b1, 1'b0);
    step(1'b0, 1'b1, 1'b0, 1'b0);
    step(1'b0, 1'b1, 1'b1, 1'b1);
    step(1'b1, 1'b0, 1'b0, 1'b0);
    step(1'b1, 1'b0, 1'b1, 1'b1);
    step(1'b1, 1'b1, 1'b0, 1'b1);
    step(1'b1, 1'b1, 1'b1, 1'b1);

    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
