// get npc. choose from pc+4, bpc, da, jpc by pcsource
// get ins from rom while mem_clock is on.
// get pc4 <- pc + 4

module pipeif(pcsource, pc, bpc, da, jpc, npc, pc4, ins, rom_clock);
input  [1:0]  pcsource;
input  [31:0] pc, bpc, da, jpc;
input         rom_clock;
output [31:0] npc, pc4, ins;

assign pc4 = pc + 4;

mux4x32 nextpc(pc4, bpc, da, jpc, pcsource, npc);
pipe_instmem instmem(pc, ins, rom_clock);
endmodule
