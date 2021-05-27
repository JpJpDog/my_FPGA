module sc_datamem (addr,datain,dataout,we,clock,mem_clk,dmem_clk,
		io_in,io_out);
 
   input  [31:0]  addr;
   input  [31:0]  datain;
   
   input          we, clock,mem_clk;
   output [31:0]  dataout;
   output         dmem_clk;
	
	input	[9:0]	io_in;
	output	[23:0]	io_out;
   
   wire           dmem_clk;    
   wire           write_enable; 
	wire				write_mem_enable,write_io_enable;
	wire	[31:0]	mem_dataout,io_dataout;

   assign         write_enable = we & ~clock; 
   assign         dmem_clk = mem_clk & ( ~ clock) ; 
	assign			write_mem_enable=(~addr[7])&write_enable;
	assign			write_io_enable=addr[7]&write_enable;
   assign 			dataout = addr[7]?io_dataout:mem_dataout;
   lpm_ram_dq_dram  dram(addr[6:2],dmem_clk,datain,write_mem_enable,mem_dataout);
	my_io my_io_inst(addr[6:2],dmem_clk,datain,write_io_enable,io_dataout,io_in,io_out);
endmodule 