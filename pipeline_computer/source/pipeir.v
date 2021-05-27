// get dpc4 by pc4 and get inst by ins if wpcir != 0 and clock is on.

module pipeir(pc4, ins, wpcir, clock, resetn, dpc4, inst);
input  [31:0] pc4, ins;
input         wpcir, clock, resetn;
output [31:0] dpc4, inst;

dffe32 pc4_r_d(pc4, clock, resetn, wpcir, dpc4);
dffe32 ins_r_d(ins, clock, resetn, wpcir, inst);
endmodule
