// 32bit D flip-flop.
module dff32(d, clk, clrn, q);
input      [31:0] d;
input             clk, clrn;
output reg [31:0] q;

always @(negedge clrn or posedge clk)
  if (clrn == 0)
      q <= 0;
  else
      q <= d;
endmodule
