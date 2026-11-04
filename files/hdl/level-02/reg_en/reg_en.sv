// A 4-bit register. At a rising edge: rst clears it; otherwise, if load
// is 1, it takes d; otherwise it keeps its value.
module reg_en (
  input  logic       clk,
  input  logic       rst,
  input  logic       load,
  input  logic [3:0] d,
  output logic [3:0] q
);
  always_ff @(posedge clk) begin
    if (rst)       q <= 4'd0;
    else if (load) q <= d;
  end
endmodule
