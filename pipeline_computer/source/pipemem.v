module pipemem(mwmem, malu, mb, ram_clock, resetn, mmo, sw, hex0, hex1, hex2, hex3, hex4, hex5);
input         mwmem, ram_clock, resetn;
input  [31:0] malu, mb;
input  [9:0]  sw;
output [31:0] mmo;
output [3:0]  hex0, hex1, hex2, hex3, hex4, hex5;

wire [31:0] mem_data;

pipe_datamem datamem(malu, mb, mmo, mwmem, ram_clock, resetn, sw, hex0, hex1, hex2, hex3, hex4, hex5);

endmodule
