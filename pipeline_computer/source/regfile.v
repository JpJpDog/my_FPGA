// get value in reg[rna], reg[rnb] to qa and qb
// write reg[wn] value d if we == 1

module regfile(rna, rnb, d, wn, we, clk, clrn, qa, qb);
input  [4:0]  rna, rnb, wn;
input  [31:0] d;
input         we, clk, clrn;
output [31:0] qa, qb;
reg    [31:0] register [1:31]; // r1 - r31

assign qa = (rna == 0) ? 0 : register[rna]; // read, r0 always contains 0
assign qb = (rnb == 0) ? 0 : register[rnb]; // read, r0 always contains 0

always @(negedge clk or negedge clrn)
  begin
    if (clrn == 0) begin
		integer i;
		for (i = 1; i < 32; i = i + 1)
        register[i] <= 0;
	 end else if (wn != 0 && we == 1)// write at negedge of clock
      register[wn] <= d;
  end
endmodule
