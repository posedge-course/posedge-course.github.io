`timescale 1ns/1ps
// Testbench for alarm. Each row sets the three inputs, waits 10 ns, then
// checks that siren is the value the row expects.
module alarm_tb;
  logic armed, door_open, window_open;  // the inputs the testbench sets
  logic siren;                          // the output it checks
  int   errors;                         // how many rows went wrong

  alarm dut (.armed(armed), .door_open(door_open),
             .window_open(window_open), .siren(siren));

  // One row: armed, door_open and window_open, then the siren we expect.
  task automatic step(input logic va, input logic vd, input logic vw,
                      input logic want);
    armed       = va;
    door_open   = vd;
    window_open = vw;
    #10;
    if (siren !== want) begin
      $display("TEST FAILED: %b%b%b gave siren=%b, expected %b at %0d ns",
               armed, door_open, window_open, siren, want, $time);
      errors = errors + 1;
    end
  endtask

  initial begin
    $dumpfile("alarm_tb.vcd");
    $dumpvars(0, alarm_tb);
    errors = 0;

    // Part 1: a story.
    step(1'b0, 1'b0, 1'b0, 1'b0);  // all quiet
    step(1'b0, 1'b1, 1'b0, 1'b0);  // the door opens, but nobody armed it
    step(1'b1, 1'b1, 1'b0, 1'b1);  // armed with the door open
    step(1'b1, 1'b0, 1'b0, 1'b0);  // the door closes
    step(1'b1, 1'b0, 1'b1, 1'b1);  // the window opens
    step(1'b0, 1'b0, 1'b1, 1'b0);  // switched off
    step(1'b1, 1'b1, 1'b1, 1'b1);  // armed, everything open
    step(1'b0, 1'b0, 1'b0, 1'b0);  // all quiet again

    // Part 2: all eight rows in counting order, from 000 to 111.
    step(1'b0, 1'b0, 1'b0, 1'b0);
    step(1'b0, 1'b0, 1'b1, 1'b0);
    step(1'b0, 1'b1, 1'b0, 1'b0);
    step(1'b0, 1'b1, 1'b1, 1'b0);
    step(1'b1, 1'b0, 1'b0, 1'b0);
    step(1'b1, 1'b0, 1'b1, 1'b1);
    step(1'b1, 1'b1, 1'b0, 1'b1);
    step(1'b1, 1'b1, 1'b1, 1'b1);

    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
