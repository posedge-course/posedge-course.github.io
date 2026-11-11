`timescale 1ns/1ps
// Testbench for pwm, with BITS set to 3 so that one period is 8 cycles
// instead of 256. It is the specification of the level 4 project: at
// every falling edge it checks out against a model, for several values of
// duty. It reads only the ports, so any correct pwm passes.
module pwm_tb;
  logic       clk;
  logic       rst;
  logic [2:0] duty;
  logic       out;
  logic [2:0] model;     // what pwm's count must hold
  int         errors;

  pwm #(.BITS(3)) dut (.clk(clk), .rst(rst), .duty(duty), .out(out));

  // A 10 ns clock, like the Arty A7's 100 MHz.
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // The model of the count: rst sets it to 0, then it runs 0 to 7.
  always @(posedge clk) begin
    if (rst) model <= 3'd0;
    else     model <= model + 3'd1;
  end

  // Run n cycles with these inputs, checking out at every falling edge.
  task automatic cycles(input int n, input logic r, input logic [2:0] d);
    rst = r;
    duty = d;
    repeat (n) begin
      @(negedge clk);
      if (out !== (model < duty)) begin
        $display("TEST FAILED: duty=%0d out=%b, expected %b at %0d ns",
                 duty, out, model < duty, $time);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("pwm_tb.vcd");
    $dumpvars(0, pwm_tb);
    errors = 0;
    rst = 1'b1;
    duty = 3'd0;

    // clk starts as X, and X to 0 counts as a falling edge, so wait for a
    // real rising edge before the first falling one (D96).
    @(posedge clk);

    cycles(2, 1'b1, 3'd0);    // reset
    cycles(16, 1'b0, 3'd2);   // out is 1 for 2 cycles in every 8
    cycles(16, 1'b0, 3'd5);   // 5 in every 8
    cycles(16, 1'b0, 3'd0);   // never
    cycles(16, 1'b0, 3'd7);   // 7 in every 8: the most with 3 bits
    cycles(3, 1'b0, 3'd1);    // duty changes part-way through a period
    cycles(13, 1'b0, 3'd6);
    cycles(2, 1'b1, 3'd6);    // a reset starts the period again
    cycles(16, 1'b0, 3'd3);

    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
