module my_io(addr,dmem_clk,datain,write_io_enable,dataout,io_in,io_out);
input	[4:0]	addr;
input	[9:0]	io_in;
input [31:0] datain;
input dmem_clk,write_io_enable;
output [23:0] io_out;
output [31:0] dataout;

reg	[23:0]	io_out;
reg 	[31:0]	dataout;

always @ (posedge dmem_clk) // output
  if (write_io_enable)
    begin
		case (addr)
		5'b00000:
        io_out[3:0] <= datain[3:0];
      5'b00001:
        io_out[7:4] <= datain[3:0];
      5'b00010:
        io_out[11:8] <= datain[3:0];
      5'b00011:
        io_out[15:12] <= datain[3:0];
      5'b00100:
        io_out[19:16] <= datain[3:0];
      5'b00101:
			io_out[23:20] <= datain[3:0];
		default:
			io_out <= 0;
		endcase
	 end

always @ (posedge dmem_clk) // input
	begin
		case (addr)
      5'b10000:
        dataout <= io_in;
      default:
        dataout <= 0;
		endcase
	end
endmodule
