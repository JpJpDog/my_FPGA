module sevenseg ( data, ledsegments);
input [3:0] data;
output ledsegments;
reg [6:0] ledsegments;
always @ (*)
  case(data)
    0:
      ledsegments = 7'b000_0001;
    1:
      ledsegments = 7'b100_1111;
    2:
      ledsegments = 7'b001_0010;
    3:
      ledsegments = 7'b000_0110;
    4:
      ledsegments = 7'b100_1100;
    5:
      ledsegments = 7'b010_0100;
    6:
      ledsegments = 7'b010_0000;
    7:
      ledsegments = 7'b000_1111;
    8:
      ledsegments = 7'b000_0000;
    9:
      ledsegments = 7'b000_0100;
    default:
      ledsegments = 7'b111_1111;  // 其它值时全灭。
  endcase
endmodule
