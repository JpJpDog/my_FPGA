module slow_clk(clk,out_clk);
	input clk;
	output reg out_clk;
	
	reg counter;

	always @(posedge clk) begin
		if (counter) begin
			counter<=0;
			out_clk<=~out_clk;
		end
		else
			counter<=1;
	end
endmodule