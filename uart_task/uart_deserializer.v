// Технический модуль, используемый в uart_receiver.
// 
// = Модуль написал =
// Владислав Подымов
// 2018
// e-mail: valdus@yandex.ru
module uart_deserializer(rx, clock, reset, data, valid, busy);
  parameter integer W = 8;
  parameter integer Mode = 0; // 0 = lsb->msb, 1 = msb->lsb
  parameter integer Parity = 0; // 0 = none, 1 = odd, 2 = even
  parameter integer Precision = 1; // 2+this subtacts are contained in one uart tact; the middle tact is where the value is read
  input rx, clock, reset;
  output [W-1:0] data;
  output reg valid, busy;
  
  localparam integer TicksTact = Precision;
  localparam integer TicksHalfTact = (Precision-1)/2;
  localparam integer CouW = $clog2(TicksTact+1);
  localparam integer DataW = W >= 2
                             ? $clog2(W)
                             : 1;
  
  reg store;
  
  shift_register_l #(
    .W(W),
    .Mode(1-Mode)
  )
  _received_data(
    .in(rx),
    .load(store),
    .clock(clock),
    .out(data)
  );
  
  reg [3:0] state, n_state;
  reg [CouW-1:0] tick_counter, n_tick_counter;
  localparam integer S_IDLE = 0;
  localparam integer S_START_DELAY = 1;
  localparam integer S_START = 2;
  localparam integer S_BIT_READ_DELAY = 3;
  localparam integer S_BIT_READ = 4;
  localparam integer S_PARITY_DELAY = 5;
  localparam integer S_PARITY = 6;
  localparam integer S_STOP_DELAY = 7;
  localparam integer S_STOP = 8;
  
  always @(posedge clock, posedge reset)
    if(reset)
    begin
      state <= S_IDLE;
      tick_counter <= 0;
    end
    else
    begin
      if(tick_counter == 0)
      begin
        state <= n_state;
        tick_counter <= n_tick_counter;
      end
      else
        tick_counter <= tick_counter - 1;
    end
  
  reg parity_bit, n_parity_bit;
  
  always @(posedge clock)
    if(tick_counter == 0) parity_bit <= n_parity_bit;
  
  reg n_valid;
  
  always @(posedge clock, posedge reset)
    if(reset) valid <= 0;
    else if(tick_counter == 0) valid <= n_valid;
  
  reg [DataW-1:0] bits_left, n_bits_left;
  
  always @(posedge clock)
    if(tick_counter == 0) bits_left <= n_bits_left;
  
  always @(*)
  begin
    n_state = state;
    n_tick_counter = 0;
    case(state)
    S_IDLE:
      if(!rx)
      begin
        if(TicksHalfTact == 0)
          n_state = S_START;
        else
        begin
          n_state = S_START_DELAY;
          n_tick_counter = TicksHalfTact-1;
        end
      end
    S_START_DELAY:
      n_state = S_START;
    S_START:
      if(rx)
        n_state = S_IDLE;
      else
      begin
        n_state = S_BIT_READ_DELAY;
        n_tick_counter = TicksTact;
      end
    S_BIT_READ_DELAY:
      n_state = S_BIT_READ;
    S_BIT_READ:
      if(bits_left > 0)
      begin
        n_state = S_BIT_READ_DELAY;
        n_tick_counter = TicksTact;
      end
      else
        if(Parity == 0)
        begin
          n_state = S_STOP_DELAY;
          n_tick_counter = TicksTact;
        end
        else
        begin
          n_state = S_PARITY_DELAY;
          n_tick_counter = TicksTact;
        end
    S_PARITY_DELAY:
      n_state = S_PARITY;
    S_PARITY:
      if(rx == parity_bit)
      begin
        n_state = S_STOP_DELAY;
        n_tick_counter = TicksTact;
      end
      else
        n_state = S_IDLE;
    S_STOP_DELAY:
      n_state = S_STOP;
    S_STOP:
      n_state = S_IDLE;
    endcase
  end
  
  always @(*)
  begin
    busy = 1;
    store = 0;
    n_parity_bit = parity_bit;
    n_valid = valid;
    n_bits_left = bits_left;
    case(state)
    S_IDLE:
    begin
      busy = 0;
      if(!rx)
      begin
        n_parity_bit = 0;
        if(Parity == 2) n_parity_bit = 1;
        n_valid = 0;
        n_bits_left = W-1;
      end
    end
    S_BIT_READ:
    begin
      store = 1;
      n_parity_bit = parity_bit ^ rx;
      if(bits_left > 0) n_bits_left = bits_left - 1;
    end
    S_STOP:
      if(rx) n_valid = 1;
    endcase
  end
endmodule
