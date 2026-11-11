// Pulse-width modulation. count runs 0, 1, 2 and so on to its top value
// and round again, 2**BITS cycles in all; out is 1 while count is less
// than duty, so out is 1 for duty cycles in every 2**BITS.
module pwm #(
  parameter int BITS = 8
) (
  input  logic            clk,
  input  logic            rst,
  input  logic [BITS-1:0] duty,
  output logic            out
);
  logic [BITS-1:0] count;

  always_ff @(posedge clk) begin
    if (rst) count <= '0;
    else     count <= count + 1;
  end

  assign out = (count < duty);
endmodule
