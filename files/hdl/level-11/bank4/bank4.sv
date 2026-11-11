// The decoder's banked map, in small: 84 positions in four banks of 21
// rows, room for a 9 x 9 map (81 positions), so that four neighbouring
// positions can be read in one cycle. Position i lives in bank i mod 4,
// at row i / 4. To read base to base + 3, split base into its row q and
// its bank r (base = 4q + r): bank b reads row q + 1 if b < r, else row
// q. Each bank is read through two registers, the memory's own read and
// its output register, so the words come two rising edges after the
// base, in bank order. r goes through two registers too, and lane j
// takes the word of bank (r + j) mod 4, which puts them back in order.
module bank4 #(
  parameter int W = 8                  // bits per position
) (
  input  logic         clk,
  input  logic         we,             // write wdata at position waddr
  input  logic [6:0]   waddr,
  input  logic [W-1:0] wdata,
  input  logic [6:0]   base,           // read base to base + 3
  output logic [W-1:0] lane0,          // two edges later: position base
  output logic [W-1:0] lane1,          // base + 1
  output logic [W-1:0] lane2,          // base + 2
  output logic [W-1:0] lane3           // base + 3
);
  logic [W-1:0] mem0 [21];             // bank 0: positions 0, 4, 8 ...
  logic [W-1:0] mem1 [21];             // bank 1: positions 1, 5, 9 ...
  logic [W-1:0] mem2 [21];             // bank 2: positions 2, 6, 10 ...
  logic [W-1:0] mem3 [21];             // bank 3: positions 3, 7, 11 ...
  logic [4:0]   q;                     // base's row
  logic [1:0]   r;                     // base's bank
  logic [4:0]   row0, row1, row2, row3;  // the row each bank reads
  logic [W-1:0] q1 [4];                // each bank's word, one edge later
  logic [W-1:0] word [4];              // and two edges later
  logic [1:0]   r1, r2;                // r, one and two edges later

  assign q    = base[6:2];
  assign r    = base[1:0];
  assign row0 = (r > 2'd0) ? q + 5'd1 : q;   // 0 < r
  assign row1 = (r > 2'd1) ? q + 5'd1 : q;   // 1 < r
  assign row2 = (r > 2'd2) ? q + 5'd1 : q;   // 2 < r
  assign row3 = q;                           // 3 < r never holds

  always_ff @(posedge clk) begin
    if (we & (waddr[1:0] == 2'd0)) mem0[waddr[6:2]] <= wdata;
    if (we & (waddr[1:0] == 2'd1)) mem1[waddr[6:2]] <= wdata;
    if (we & (waddr[1:0] == 2'd2)) mem2[waddr[6:2]] <= wdata;
    if (we & (waddr[1:0] == 2'd3)) mem3[waddr[6:2]] <= wdata;
    q1[0]   <= mem0[row0];             // read stage 1: the read
    q1[1]   <= mem1[row1];
    q1[2]   <= mem2[row2];
    q1[3]   <= mem3[row3];
    word[0] <= q1[0];                  // read stage 2: output register
    word[1] <= q1[1];
    word[2] <= q1[2];
    word[3] <= q1[3];
    r1      <= r;                      // r, in step with the words
    r2      <= r1;
  end

  assign lane0 = word[r2];
  assign lane1 = word[r2 + 2'd1];
  assign lane2 = word[r2 + 2'd2];
  assign lane3 = word[r2 + 2'd3];
endmodule
