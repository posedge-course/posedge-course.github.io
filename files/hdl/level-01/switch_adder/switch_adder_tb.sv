`timescale 1ns/1ps
// Testbench for switch_adder, the level 1 project. Each step sets a and b,
// waits 10 ns, then checks low, carry and big against the sum the
// testbench works out itself.
module switch_adder_tb;
  logic [3:0] a, b;       // the inputs the testbench sets
  logic [3:0] low;        // the outputs it checks
  logic       carry, big;
  logic [4:0] total;      // the five-bit sum this step should give
  int         errors;     // how many steps went wrong

  switch_adder dut (.a(a), .b(b), .low(low), .carry(carry), .big(big));

  // One step: set a and b, wait 10 ns, then compare.
  task automatic step(input logic [3:0] va, input logic [3:0] vb);
    a = va;
    b = vb;
    #10;
    total = a + b;
    if ((low !== total[3:0]) | (carry !== total[4]) |
        (big !== (total > 5'd9))) begin
      $display("TEST FAILED: %0d+%0d: low=%0d carry=%b big=%b at %0d ns",
               a, b, low, carry, big, $time);
      errors = errors + 1;
    end
  endtask

  initial begin
    $dumpfile("switch_adder_tb.vcd");
    $dumpvars(0, switch_adder_tb);
    errors = 0;

    // Part 1: eight sums to read in the waveform, one every 10 ns.
    step(4'd3, 4'd4);    //  0 ns: 7
    step(4'd9, 4'd8);    // 10 ns: 17
    step(4'd5, 4'd5);    // 20 ns: 10
    step(4'd9, 4'd0);    // 30 ns: 9
    step(4'd6, 4'd9);    // 40 ns: 15
    step(4'd15, 4'd15);  // 50 ns: 30
    step(4'd8, 4'd1);    // 60 ns: 9
    step(4'd0, 4'd0);    // 70 ns: 0

    // Part 2: every pair, a from 0 to 15 with b from 0 to 15.
    for (int i = 0; i < 16; i = i + 1)
      for (int j = 0; j < 16; j = j + 1)
        step(i[3:0], j[3:0]);

    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
