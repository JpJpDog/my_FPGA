module stopwatch_01(CLOCK_50, key_reset_, key_start_pause_, key_display_stop_,
                    hex0, hex1, hex2, hex3, hex4, hex5,
                    led0, led1, led2, led3 );
input CLOCK_50,key_reset_, key_start_pause_, key_display_stop_;
output [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
output led0, led1, led2, led3;
// reg led0, led1, led2, led3;

reg [3:0] minute_display_high;
reg [3:0] minute_display_low;
reg [3:0] second_display_high;
reg [3:0] second_display_low;
reg [3:0] msecond_display_high;
reg [3:0] msecond_display_low;

reg [3:0] minute_counter_high;
reg [3:0] minute_counter_low;
reg [3:0] second_counter_high;
reg [3:0] second_counter_low;
reg [3:0] msecond_counter_high;
reg [3:0] msecond_counter_low;

reg [31:0] counter_50M;
reg [1:0] status;
reg time_flush;
reg display_flush;
reg reset_flush;

wire key_reset, key_start_pause, key_display_stop;

initial
  begin
    time_flush = 0;
    display_flush = 0;
    reset_flush = 1;
    counter_50M = 0;
    status = 0;
  end

sevenseg LED8_minute_display_high ( minute_display_high, hex5 );
sevenseg LED8_minute_display_low ( minute_display_low, hex4 );
sevenseg LED8_second_display_high( second_display_high, hex3 );
sevenseg LED8_second_display_low ( second_display_low, hex2 );
sevenseg LED8_msecond_display_high( msecond_display_high, hex1 );
sevenseg LED8_msecond_display_low ( msecond_display_low, hex0 );

jitter_eliminater key_reset_je (CLOCK_50, ~key_reset_, key_reset);
jitter_eliminater key_start_pause_je (CLOCK_50, ~key_start_pause_, key_start_pause);
jitter_eliminater key_display_stop_je (CLOCK_50, ~key_display_stop_, key_display_stop);

always @(posedge CLOCK_50)
  if (time_flush)
    begin
      time_flush <= 0;
      counter_50M <= 0;
    end
  else if (status == 1 || status == 2)
    if (counter_50M >= 500000)
      begin
        time_flush <= 1;
      end
    else
      counter_50M <= counter_50M + 1;
  else //status == 0
    counter_50M <= 0;

always @(posedge CLOCK_50)
  if (display_flush || reset_flush)
    begin
      display_flush <= 0;
      reset_flush <= 0;
    end
  else if (key_reset)
    begin
      status <= 0;
      reset_flush <= 1;
    end
  else if (key_start_pause)
    if (status == 0 || status == 2)
      status <= 1;
    else //status == 1
      status <= 0;
  else if (key_display_stop)
    if (status == 1)
      status <= 2;
    else if (status == 2)
      display_flush <= 1;

always @(posedge time_flush or posedge display_flush or posedge reset_flush)
  if (reset_flush)
    begin
      msecond_display_low <= 0;
      msecond_display_high <= 0;
      second_display_low <= 0;
      second_display_high <= 0;
      minute_display_low <= 0;
      minute_display_high <= 0;
    end
  else if (display_flush)
    begin
      msecond_display_low <= msecond_counter_low;
      msecond_display_high <= msecond_counter_high;
      second_display_low <= second_counter_low;
      second_display_high <= second_counter_high;
      minute_display_low <= minute_counter_low;
      minute_display_high <= minute_counter_high;
    end
  else //time_flush
    if(status == 1)
      begin
        msecond_display_low <= msecond_counter_low;
        msecond_display_high <= msecond_counter_high;
        second_display_low <= second_counter_low;
        second_display_high <= second_counter_high;
        minute_display_low <= minute_counter_low;
        minute_display_high <= minute_counter_high;
      end

always @(posedge reset_flush or posedge time_flush)
  if (reset_flush)
    begin
      msecond_counter_low <= 0;
      msecond_counter_high <= 0;
      second_counter_low <= 0;
      second_counter_high <= 0;
      minute_counter_low <= 0;
      minute_counter_high <= 0;
    end
  else if (msecond_counter_low < 9) //time_flush
    msecond_counter_low <= msecond_counter_low + 1;
  else
    begin
      msecond_counter_low <= 0;
      if (msecond_counter_high < 9)
        msecond_counter_high <= msecond_counter_high + 1;
      else
        begin
          msecond_counter_high <= 0;
          if (second_counter_low < 9)
            second_counter_low <= second_counter_low + 1;
          else
            begin
              second_counter_low <= 0;
              if (second_counter_high < 5)
                second_counter_high <= second_counter_high + 1;
              else
                begin
                  second_counter_high <= 0;
                  if (minute_counter_low < 9)
                    minute_counter_low <= minute_counter_low + 1;
                  else
                    begin
                      minute_counter_low <= 0;
                      if (minute_counter_high < 5)
                        minute_counter_high <= minute_counter_high + 1;
                      else
                        minute_counter_high <= 0;
                    end
                end
            end
        end
    end
endmodule
