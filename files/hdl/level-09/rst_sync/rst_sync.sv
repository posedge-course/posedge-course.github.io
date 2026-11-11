// A reset synchroniser: rst rises as soon as arst does, without waiting
// for clk, and falls only at a rising edge of clk, two edges after arst
// falls, so that every flip-flop it resets leaves reset at the same edge.
// arst may come from a button or another clock domain.
module rst_sync (
  input  logic clk,
  input  logic arst,   // asynchronous: 1 resets at once
  output logic rst     // for clk's domain
);
  (* ASYNC_REG = "TRUE" *) logic r1, r2;

  always_ff @(posedge clk or posedge arst) begin
    if (arst) begin
      r1 <= 1'b1;
      r2 <= 1'b1;
    end else begin
      r1 <= 1'b0;
      r2 <= r1;
    end
  end

  assign rst = r2;
endmodule
