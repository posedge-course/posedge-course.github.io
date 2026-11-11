`timescale 1ns/1ps
// Testbench for bank4. Each position is written with its own number, so
// a lane shows which position it read. Then bases go in one a cycle, at
// falling edges: 14, the lesson's example, then every base from 0 to 80
// in order, then all of them again in a jumping order. Each base's four
// lanes are checked two cycles after it went in: they must hold base,
// base + 1, base + 2 and base + 3.
module bank4_tb;
  logic       clk, we;
  logic [6:0] waddr, base;
  logic [7:0] wdata, lane0, lane1, lane2, lane3;
  int         errors;
  int         was1, was2;       // the bases of one and two cycles ago

  bank4 dut (
    .clk(clk), .we(we), .waddr(waddr), .wdata(wdata), .base(base),
    .lane0(lane0), .lane1(lane1), .lane2(lane2), .lane3(lane3)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  // At a falling edge: check the base that went in two cycles ago, then
  // put in the next one. -1 means no base.
  task automatic read(input int b);
    if ((was2 >= 0) & ((lane0 !== 8'(was2)) | (lane1 !== 8'(was2 + 1)) |
                      (lane2 !== 8'(was2 + 2)) | (lane3 !== 8'(was2 + 3))))
    begin
      // $write prints without ending the line: one line in all.
      $write("TEST FAILED: base %0d: lanes %0d %0d %0d %0d, ", was2,
             lane0, lane1, lane2, lane3);
      $display("expected %0d %0d %0d %0d at %0d ns", was2, was2 + 1,
               was2 + 2, was2 + 3, $time);
      errors = errors + 1;
    end
    was2 = was1;
    was1 = b;
    base = (b >= 0) ? 7'(b) : 7'd0;
    @(negedge clk);
  endtask

  initial begin
    $dumpfile("bank4_tb.vcd");
    $dumpvars(0, bank4_tb);
    errors = 0;
    was1   = -1;
    was2   = -1;
    we     = 1'b0;
    waddr  = 7'd0;
    wdata  = 8'd0;
    base   = 7'd0;
    @(posedge clk);          // wait for a real rising edge first (D96)
    @(negedge clk);
    for (int i = 0; i < 84; i++) begin   // position i holds i
      we    = 1'b1;
      waddr = 7'(i);
      wdata = 8'(i);
      @(negedge clk);
    end
    we = 1'b0;
    read(14);
    for (int b = 0; b <= 80; b++) read(b);
    for (int k = 0; k <= 80; k++) read((k * 37) % 81);
    read(-1);                // two more cycles, for the last two bases
    read(-1);
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
