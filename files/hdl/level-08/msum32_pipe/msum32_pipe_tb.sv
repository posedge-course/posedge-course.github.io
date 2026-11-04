`timescale 1ns/1ps
// Testbench for msum32_pipe. din changes on falling edges, from a fixed
// pseudo-random sequence that starts with 32 samples of 65,535, then 0
// for 70 cycles but for one sample of 1. A model keeps the last 32
// samples, and y must be their sum as it was LATENCY + 1 edges ago. The
// checks start at the first falling edge where y holds a sum of 32 real
// samples, which is the largest sum, all 32 at 65,535. y_nonzero is 1
// while y is not 0, for a figure that follows the sample of 1.
module msum32_pipe_tb;
  localparam int LATENCY = 4;   // cycles later than msum32
  logic        clk;
  logic [15:0] din;
  logic [20:0] y;
  logic        y_nonzero;        // 1 while y is not 0
  logic [15:0] hist [0:31];      // the model: the last 32 samples
  logic [20:0] want [0:LATENCY]; // their sum, then that sum delayed
  logic [31:0] seed;             // the pseudo-random sequence
  int          errors;

  msum32_pipe dut (.clk(clk), .din(din), .y(y));

  assign y_nonzero = (y != 21'd0);

  initial clk = 1'b0;
  always #5 clk = ~clk;

  function automatic logic [20:0] total();
    logic [20:0] s = 21'd0;
    for (int i = 0; i < 32; i++) s = s + {5'd0, hist[i]};
    return s;
  endfunction

  always @(posedge clk) begin
    hist[0] <= din;
    for (int i = 1; i < 32; i++) hist[i] <= hist[i-1];
    want[0] <= total();
    for (int i = 1; i <= LATENCY; i++) want[i] <= want[i-1];
  end

  initial begin
    $dumpfile("msum32_pipe_tb.vcd");
    $dumpvars(0, msum32_pipe_tb);
    errors = 0;
    seed = 32'd99;
    din = 16'd0;
    @(posedge clk);      // wait for a real rising edge first (D96)
    for (int k = 0; k < 470; k++) begin
      @(negedge clk);
      if ((k >= 33 + LATENCY) & ((y !== want[LATENCY])
          | (y_nonzero !== (want[LATENCY] != 21'd0)))) begin
        $display("TEST FAILED: y=%0d, expected %0d at %0d ns",
                 y, want[LATENCY], $time);
        errors = errors + 1;
      end
      seed = seed * 32'd1664525 + 32'd1013904223;
      if (k < 32)       din = 16'hFFFF;
      else if (k < 400) din = seed[31:16];
      else if (k == 450) din = 16'd1;
      else               din = 16'd0;
    end
    if (errors == 0) $display("TEST PASSED");
    $finish;
  end
endmodule
