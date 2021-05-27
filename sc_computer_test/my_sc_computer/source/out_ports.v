module out_ports(io_out,hex0,hex1,hex2,hex3,hex4,hex5,
led0,led1,led2,led3,led4,led5,led6,led7,led8,led9);
input [33:0] io_out;
output [6:0] hex0,hex1,hex2,hex3,hex4,hex5;
output led0,led1,led2,led3,led4,led5,led6,led7,led8,led9;
sevenseg sg0(io_out[3:0],hex0);
sevenseg sg1(io_out[7:4],hex1);
sevenseg sg2(io_out[11:8],hex2);
sevenseg sg3(io_out[15:12],hex3);
sevenseg sg4(io_out[19:16],hex4);
sevenseg sg5(io_out[23:20],hex5);
assign led0=io_out[24];
assign led1=io_out[25];
assign led2=io_out[26];
assign led3=io_out[27];
assign led4=io_out[28];
assign led5=io_out[29];
assign led6=io_out[30];
assign led7=io_out[31];
assign led8=io_out[32];
assign led9=io_out[33];
endmodule
