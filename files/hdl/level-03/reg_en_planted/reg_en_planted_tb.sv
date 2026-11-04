`timescale 1ns/1ps
// One testbench that catches the planted bug. It checks reg_en_planted
// against a model of lesson 2.4's rules after every rising edge, over
// rows that try rst and load in every combination.
module reg_en_planted_tb;
  logic       clk, rst, load;
  logic [3:0] d, q;
  logic [3:0] expected;   // the model of q
  int         errors;

  reg_en_planted dut (.clk(clk), .rst(rst), .load(load), .d(d), .q(q));

  // A 10 ns clock: rising edges at 5, 15, 25 ns and so on.
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // The model: lesson 2.4's rules, the simplest way to write them.
  always @(posedge clk) begin
    if (rst)       expected <= 4'd0;
    else if (load) expected <= d;
  end

  // At the next falling edge, check q, then set the inputs for the next
  // rising edge.
  task automatic next_cycle(input logic r, input logic l,
                            input logic [3:0] value);
    @(negedge clk);
    if (q !== expected) begin
      $display("TEST FAILED: q=%h, expected %h at %0d ns",
               q, expected, $time);
      errors = errors + 1;
    end
    rst = r;
    load = l;
    d = value;
  endtask

  initial begin
    $dumpfile("reg_en_planted_tb.vcd");
    $dumpvars(0, reg_en_planted_tb);
    errors = 0;
    rst = 1'b1;
    load = 1'b0;
    d = 4'h0;

    // clk starts as X, and X to 0 counts as a falling edge, so wait for a
    // real rising edge before the first falling one.
    @(posedge clk);

    //         rst   load  d
    next_cycle(1'b0, 1'b1, 4'h5);   // load 5
    next_cycle(1'b0, 1'b0, 4'hA);   // load is 0: keep 5
    next_cycle(1'b1, 1'b0, 4'h3);   // reset with load at 0
    next_cycle(1'b0, 1'b1, 4'h9);   // load 9
    next_cycle(1'b1, 1'b1, 4'h6);   // reset with load at 1: reset wins
    next_cycle(1'b0, 1'b1, 4'hC);   // load C
    next_cycle(1'b0, 1'b0, 4'h0);   // keep C
    next_cycle(1'b0, 1'b0, 4'h0);

    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
