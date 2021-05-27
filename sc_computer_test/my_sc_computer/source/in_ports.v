module in_ports(sw0,sw1,sw2,sw3,sw4,sw5,sw6,sw7,sw8,sw9,io_in);
input sw0,sw1,sw2,sw3,sw4,sw5,sw6,sw7,sw8,sw9;
output [0:9] io_in;

assign io_in[9]=sw0;
assign io_in[8]=sw1;
assign io_in[7]=sw2;
assign io_in[6]=sw3;
assign io_in[5]=sw4;
assign io_in[4]=sw5;
assign io_in[3]=sw6;
assign io_in[2]=sw7;
assign io_in[1]=sw8;
assign io_in[0]=sw9;

endmodule