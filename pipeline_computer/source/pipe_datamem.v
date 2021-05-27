module pipe_datamem(addr, datain, dataout, we, ram_clock, resetn, sw, hex5, hex4, hex3, hex2, hex1, hex0);
input              we, ram_clock, resetn;
input      [31:0]  addr, datain;
input      [9:0]   sw;
output reg [31:0]  dataout;
output reg [3:0]   hex5, hex4, hex3, hex2, hex1, hex0;

wire               write_mem;
wire       [31:0]  mem_dataout;

assign write_mem = we & (addr[7] != 0);

lpm_ram_dq_dram dram(addr[6:2], ram_clock, datain, write_mem, mem_dataout);

// IO ports design.
always @(posedge ram_clock or negedge resetn)
  begin
    if (!resetn)
      begin // reset hexs and leds
        hex0 <= 0;
        hex1 <= 0;
        hex2 <= 0;
        hex3 <= 0;
        hex4 <= 0;
        hex5 <= 0;
      end
    else if (we)
      begin // write when ram_clock posedge comes
        case (addr[7:2])
          6'b100000:
            hex0 <= datain[3:0];
          6'b100001:
            hex1 <= datain[3:0];
          6'b100010:
            hex2 <= datain[3:0];
          6'b100011:
            hex3 <= datain[3:0];
          6'b100100:
            hex4 <= datain[3:0];
          6'b100101:
            hex5 <= datain[3:0];
        endcase
      end
  end

always @(*)
  begin // read asynchonously
    case (addr[7:2])
      6'b110000:
        dataout = {22'b0, sw};
      default:
        dataout = mem_dataout;
    endcase
  end
endmodule
