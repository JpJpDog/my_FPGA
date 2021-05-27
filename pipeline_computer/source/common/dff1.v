// 1bit D flip-flop.
module dff1(d, clk, clrn, q);
input      d, clk, clrn;
output reg q;

always @(negedge clrn or posedge clk)
  if (clrn == 0)
      q <= 0;
  else
      q <= d;
endmodule
