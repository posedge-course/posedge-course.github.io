// Blinks an LED. At each rising edge of clk, count adds 1 while run is 1
// and keeps its value while run is 0; rst sets it back to 0. The LED shows
// the top bit of count.
module blink #(
  parameter int BITS = 27   // the width of count; the testbench sets 4
) (
  input  logic clk,
  input  logic rst,         // sets count to 0 at a rising edge
  input  logic run,         // 1 to count, 0 to pause
  output logic led
);
  logic [BITS-1:0] count;

  always_ff @(posedge clk) begin
    if (rst)      count <= '0;   // '0 means every bit 0
    else if (run) count <= count + 1;
  end

  assign led = count[BITS-1];
endmodule
