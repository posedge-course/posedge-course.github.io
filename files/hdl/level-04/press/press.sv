// pulse is 1 for one cycle each time the button is pressed. debounce
// turns btn into a clean level, and edge_detect turns each rise of that
// level into a single pulse.
module press #(
  parameter int              BITS = 20,
  parameter logic [BITS-1:0] HOLD = 999_999
) (
  input  logic clk,
  input  logic rst,
  input  logic btn,
  output logic pulse
);
  logic stable;

  debounce #(.BITS(BITS), .HOLD(HOLD)) clean (
    .clk(clk), .rst(rst), .btn(btn), .stable(stable)
  );

  edge_detect once (.clk(clk), .level(stable), .rise(pulse));
endmodule
