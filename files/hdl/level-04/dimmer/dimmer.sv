// An LED with eight brightness levels. Each press of btn_up makes it one
// step brighter and each press of btn_down one step dimmer: duty moves by
// 32, from 0 (off) to 224. press turns each button into one pulse a
// press, and pwm makes the LED's on-off pattern from duty.
module dimmer #(
  parameter int              BITS = 20,
  parameter logic [BITS-1:0] HOLD = 999_999
) (
  input  logic clk,
  input  logic rst,
  input  logic btn_up,
  input  logic btn_down,
  output logic led
);
  logic       up, down;   // one-cycle pulses, one per press
  logic [7:0] duty;

  press #(.BITS(BITS), .HOLD(HOLD)) up_press (
    .clk(clk), .rst(rst), .btn(btn_up), .pulse(up)
  );
  press #(.BITS(BITS), .HOLD(HOLD)) down_press (
    .clk(clk), .rst(rst), .btn(btn_down), .pulse(down)
  );

  always_ff @(posedge clk) begin
    if (rst)                        duty <= 8'd0;
    else if (up & (duty != 8'd224)) duty <= duty + 8'd32;
    else if (down & (duty != 8'd0)) duty <= duty - 8'd32;
  end

  pwm #(.BITS(8)) light (.clk(clk), .rst(rst), .duty(duty), .out(led));
endmodule
