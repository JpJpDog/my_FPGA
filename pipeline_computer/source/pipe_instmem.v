module pipe_instmem (pc, ins, rom_clock);
input  [31:0] pc;
input         rom_clock;
output [31:0] ins;

lpm_rom_irom irom (pc[7:2],rom_clock,ins);
endmodule
