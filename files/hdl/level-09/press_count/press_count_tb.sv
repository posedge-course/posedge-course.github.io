`timescale 1ns/1ps
// Testbench for press_count, the specification of level 9's project.
// clk_a is 100 MHz; clk_b has a 33.376 ns period, close to the board's
// 29.963 MHz, and nothing lines its edges up with clk_a's. press is set
// small: a press settles after 4 cycles of clk_a. The button bounces at
// each press and release. Three presses must count 1, 2, 3; a reset of
// clk_b's side must set the count to 0; one more press must count 1.
module press_count_tb;
  logic       clk_a, rst_a, btn;
  logic       clk_b, rst_b;
  logic [3:0] count;
  int         errors;

  press_count #(.PBITS(3), .HOLD(3'd3)) dut (
    .clk_a(clk_a), .rst_a(rst_a), .btn(btn),
    .clk_b(clk_b), .rst_b(rst_b), .count(count)
  );

  initial clk_a = 1'b0;
  always #5 clk_a = ~clk_a;          // rising edges at 5, 15 ... ns
  initial clk_b = 1'b0;
  always #16.688 clk_b = ~clk_b;     // rising edges at 16.688 ... ns

  // A press: bounce, hold for 20 cycles of clk_a, bounce, release for 30.
  task automatic push;
    repeat (2) begin
      @(negedge clk_a) btn = 1'b1;
      @(negedge clk_a) btn = 1'b0;
    end
    @(negedge clk_a) btn = 1'b1;
    repeat (20) @(negedge clk_a);
    @(negedge clk_a) btn = 1'b0;
    @(negedge clk_a) btn = 1'b1;
    @(negedge clk_a) btn = 1'b0;
    repeat (30) @(negedge clk_a);
  endtask

  task automatic expect_count(input logic [3:0] want);
    if (count !== want) begin
      $display("TEST FAILED: count=%0d, expected %0d at %0d ns",
               count, want, $time);
      errors = errors + 1;
    end
  endtask

  initial begin
    $dumpfile("press_count_tb.vcd");
    $dumpvars(0, press_count_tb);
    errors = 0;
    btn = 1'b0;
    rst_a = 1'b1;
    rst_b = 1'b1;
    @(posedge clk_a);        // wait for a real rising edge first (D96)
    repeat (12) @(negedge clk_a);
    rst_a = 1'b0;
    @(negedge clk_b) rst_b = 1'b0;
    repeat (4) @(negedge clk_a);
    expect_count(4'd0);

    push();
    expect_count(4'd1);
    push();
    expect_count(4'd2);
    push();
    expect_count(4'd3);

    @(negedge clk_b) rst_b = 1'b1;   // reset clk_b's side only
    @(negedge clk_b) rst_b = 1'b0;
    expect_count(4'd0);
    push();
    expect_count(4'd1);
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
