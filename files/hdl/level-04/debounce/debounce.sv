// Turns a bouncing button into a clean level. btn first goes through two
// flip-flops (level 9 explains why two). stable then takes sync's value
// only after sync has differed from it at HOLD + 1 rising edges in a row.
module debounce #(
  parameter int              BITS = 20,
  parameter logic [BITS-1:0] HOLD = 999_999  // about 10 ms at 100 MHz
) (
  input  logic clk,
  input  logic rst,      // at a rising edge: stable to 0
  input  logic btn,      // straight from the button: it bounces
  output logic stable    // the button's state without the bounces
);
  logic            sync0, sync;  // btn, one and two edges late
  logic [BITS-1:0] count;        // edges in a row that sync has differed

  always_ff @(posedge clk) begin
    sync0 <= btn;
    sync  <= sync0;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      stable <= 1'b0;
      count  <= '0;
    end else if (sync == stable) begin
      count  <= '0;              // agrees again: start counting afresh
    end else if (count == HOLD) begin
      stable <= sync;            // has differed long enough
      count  <= '0;
    end else begin
      count  <= count + 1;
    end
  end
endmodule
