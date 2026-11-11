// Level 9's project on the board. BTN0's presses are debounced on the
// board's 100 MHz clock and counted on a second clock, 29.963 MHz, which
// an MMCM makes from the first (UG472); LD4 to LD7 show the count. BTN1
// resets both sides, each through its own reset synchroniser.
module press_count_top #(
  parameter int               PBITS = 20,
  parameter logic [PBITS-1:0] HOLD  = 999_999   // about 10 ms at 100 MHz
) (
  input  logic       clk,       // the board's 100 MHz clock
  input  logic       btn,       // BTN0: counted
  input  logic       rst_btn,   // BTN1: resets the count
  output logic [3:0] led        // LD4 to LD7: the count
);
  logic clk_fb, clk_fb_buf;     // the MMCM's feedback, out and back in
  logic clk_b_mmcm, clk_b;      // the second clock, before and after BUFG
  logic rst_a, rst_b;           // a reset for each clock's domain

  // 100 MHz x 10 = 1000 MHz inside the MMCM, / 33.375 = 29.963 MHz.
  MMCME2_BASE #(
    .CLKIN1_PERIOD   (10.0),
    .CLKFBOUT_MULT_F (10.0),
    .DIVCLK_DIVIDE   (1),
    .CLKOUT0_DIVIDE_F(33.375)
  ) mmcm (
    .CLKIN1  (clk),
    .CLKFBIN (clk_fb_buf),
    .RST     (1'b0),
    .PWRDWN  (1'b0),
    .CLKFBOUT(clk_fb),
    .CLKOUT0 (clk_b_mmcm)
  );

  // Global clock buffers drive a clock onto the chip's clock network.
  BUFG fb_buf (.I(clk_fb),     .O(clk_fb_buf));
  BUFG b_buf  (.I(clk_b_mmcm), .O(clk_b));

  rst_sync sync_a (.clk(clk),   .arst(rst_btn), .rst(rst_a));
  rst_sync sync_b (.clk(clk_b), .arst(rst_btn), .rst(rst_b));

  press_count #(.PBITS(PBITS), .HOLD(HOLD)) core (
    .clk_a(clk),   .rst_a(rst_a), .btn(btn),
    .clk_b(clk_b), .rst_b(rst_b), .count(led)
  );
endmodule
