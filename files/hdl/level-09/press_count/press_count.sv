// Level 9's project: presses of a button, counted in another clock's
// domain. press (level 4) turns btn into one pulse of clk_a per press;
// pulse_cross carries each pulse to clk_b's domain, where a 4-bit counter
// counts them. Each side has its own reset, from its own clock's domain.
module press_count #(
  parameter int               PBITS = 20,
  parameter logic [PBITS-1:0] HOLD  = 999_999   // about 10 ms at 100 MHz
) (
  input  logic       clk_a,    // the clock press runs on
  input  logic       rst_a,    // clk_a's reset
  input  logic       btn,      // straight from the button
  input  logic       clk_b,    // the clock the count runs on
  input  logic       rst_b,    // clk_b's reset: the count to 0
  output logic [3:0] count     // presses so far, in clk_b's domain
);
  logic pulse_a;               // one cycle of clk_a per press
  logic pulse_b;               // the same press, one cycle of clk_b

  press #(.BITS(PBITS), .HOLD(HOLD)) push (
    .clk(clk_a), .rst(rst_a), .btn(btn), .pulse(pulse_a)
  );

  pulse_cross to_b (
    .clk_a(clk_a), .rst_a(rst_a), .pulse_a(pulse_a),
    .clk_b(clk_b), .pulse_b(pulse_b)
  );

  always_ff @(posedge clk_b)
    if (rst_b)        count <= 4'd0;
    else if (pulse_b) count <= count + 4'd1;
endmodule
