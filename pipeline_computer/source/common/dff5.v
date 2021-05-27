// 5bit D flip-flop.
module dff5(d, clk, clrn, q);
input      [4:0] d;
input            clk, clrn;
output reg [4:0] q;

always @(negedge clrn or posedge clk)
  if (clrn == 0)
    q <= 0;
  else
    q <= d;
endmodule
