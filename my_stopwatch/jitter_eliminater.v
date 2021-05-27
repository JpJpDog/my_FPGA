module jitter_eliminater(CLOCK_50, in, out);

input CLOCK_50, in;
output out;
reg [31:0] wait_n;
reg [1:0]status;
reg out;

initial
  begin
    wait_n = 0;
    status = 0;
  end

always @(posedge CLOCK_50)
  if (out)
    out <= 0;
  else if (status == 1 || status == 3)
    if (wait_n >= 500000)
      begin
        wait_n <= 0;
        if (status == 1)
          if (in)
            begin
              status <= 2;
              out <= 1;
            end
          else
            status <= 0;
        else if (!in) //status == 3
          status <= 0;
        else
          status <= 2;
      end
    else
      wait_n <= wait_n + 1;
  else if (status == 0 && in)
    status <= 1;
  else if (status == 2 && !in)
    status <= 3;

endmodule
