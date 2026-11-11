`timescale 1ns/1ps
// Testbench for blink, with BITS set to 4 so that the LED changes every 8
// cycles instead of every 67,108,864. It is the specification of the level
// 2 project: after every rising edge it checks led against a model of the
// counter. It reads only the ports, so any correct blink passes.
module blink_tb;
  logic       clk;
  logic       rst, run;
  logic       led;
  logic [3:0] model;   // what count must hold
  int         errors;

  blink #(.BITS(4)) dut (.clk(clk), .rst(rst), .run(run), .led(led));

  // A 10 ns clock, like the Arty A7's 100 MHz.
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // The model: rst sets it to 0, and run lets it count.
  always @(posedge clk) begin
    if (rst)      model <= 4'd0;
    else if (run) model <= model + 4'd1;
  end

  // Run n cycles with these inputs, checking led at every falling edge.
  // repeat (n) runs the lines inside it n times.
  task automatic cycles(input int n, input logic r, input logic go);
    rst = r;
    run = go;
    repeat (n) begin
      @(negedge clk);
      if (led !== model[3]) begin
        $display("TEST FAILED: led=%b, expected %b at %0d ns",
                 led, model[3], $time);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("blink_tb.vcd");
    $dumpvars(0, blink_tb);
    errors = 0;
    rst = 1'b1;
    run = 1'b0;

    // clk starts as X, and X to 0 counts as a falling edge, so wait for a
    // real rising edge before the first falling one (D96).
    @(posedge clk);

    cycles(2, 1'b1, 1'b0);    // reset
    cycles(20, 1'b0, 1'b1);   // count: led changes every 8 cycles
    cycles(5, 1'b0, 1'b0);    // pause: led and count keep their values
    cycles(12, 1'b0, 1'b1);   // count again from where it stopped
    cycles(2, 1'b1, 1'b1);    // reset while running
    cycles(40, 1'b0, 1'b1);   // count past 15, back round to 0

    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
