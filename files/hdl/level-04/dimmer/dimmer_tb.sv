`timescale 1ns/1ps
// Testbench for dimmer, with the debouncers' HOLD set to 2 so that a
// press takes a few cycles instead of 10 ms. It is the specification of
// the second part of the level 4 project. It presses btn_up and btn_down,
// with bounces, and after each press counts the cycles in which led is 1
// over 256 cycles: that count must equal the brightness the presses so far
// ask for. It reads only the ports, so any correct dimmer passes.
module dimmer_tb;
  logic clk;
  logic rst;
  logic btn_up, btn_down;
  logic led;
  int   level;           // the brightness the presses ask for, 0 to 224
  int   errors;

  dimmer #(.BITS(2), .HOLD(2'd2)) dut (
    .clk(clk), .rst(rst), .btn_up(btn_up), .btn_down(btn_down), .led(led)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Hold one button down for a while, bouncing at the start and at the
  // end as a real button does, then wait for things to settle.
  task automatic push(input logic up);
    logic [15:0] bounce;
    bounce = 16'b1011_0111_1111_1101;
    for (int i = 15; i >= 0; i--) begin
      @(negedge clk);
      if (up) btn_up = bounce[i];
      else    btn_down = bounce[i];
    end
    @(negedge clk);
    btn_up = 1'b0;
    btn_down = 1'b0;
    repeat (12) @(negedge clk);
    if (up & (level != 224))  level = level + 32;
    if (~up & (level != 0))   level = level - 32;
  endtask

  // Count the cycles with led at 1 over 256 cycles, one whole period.
  task automatic measure();
    int on;
    on = 0;
    repeat (256) begin
      @(negedge clk);
      if (led === 1'b1) on = on + 1;
    end
    if (on != level) begin
      $display("TEST FAILED: led was 1 for %0d of 256 cycles, expected %0d",
               on, level);
      $display("TEST FAILED: at %0d ns", $time);
      errors = errors + 1;
    end
  endtask

  initial begin
    $dumpfile("dimmer_tb.vcd");
    $dumpvars(0, dimmer_tb);
    errors = 0;
    level = 0;
    rst = 1'b1;
    btn_up = 1'b0;
    btn_down = 1'b0;
    @(posedge clk);      // wait for a real rising edge first (D96)
    repeat (3) @(negedge clk);
    rst = 1'b0;

    measure();                         // off after a reset
    push(1'b1); measure();             // one step up
    push(1'b1); measure();             // two steps
    push(1'b0); measure();             // one step down
    push(1'b0); measure();             // off again
    push(1'b0); measure();             // down at 0 stays 0
    repeat (9) push(1'b1);             // up past the top
    measure();                         // stays at 224

    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
