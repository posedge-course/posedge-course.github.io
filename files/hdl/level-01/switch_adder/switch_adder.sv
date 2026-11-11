// The sum of the number on the switches and the number on the buttons.
// low is the sum's four low bits, carry is 1 when the sum is more than
// 15, and big is 1 when it is more than 9.
module switch_adder (
  input  logic [3:0] a,      // switches SW3 to SW0
  input  logic [3:0] b,      // buttons BTN3 to BTN0
  output logic [3:0] low,    // LEDs LD7 to LD4
  output logic       carry,  // RGB LED LD0, green
  output logic       big     // RGB LED LD1, blue
);
  logic [4:0] sum;           // the sum of a and b

  assign sum   = a + b;
  assign low   = sum[3:0];
  assign carry = sum[4];

  always_comb begin
    big = 1'b0;              // the usual value, so big is never a latch
    if (sum > 5'd9) big = 1'b1;
  end
endmodule
