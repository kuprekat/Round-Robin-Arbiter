// Технический модуль, используемый в uart_transmitter.
// 
// = Модуль написал =
// Владислав Подымов
// 2018
// e-mail: valdus@yandex.ru
module uart_transmitter_fsm(start, sender_finished, clock, reset, busy, slow_mode, save);
  input start, sender_finished, clock, reset;
  output reg busy, slow_mode, save;
  
  reg [1:0] state, n_state;
  localparam integer S_IDLE = 0;
  localparam integer S_STOP_SAVE = 1;
  localparam integer S_SEND = 2;
  
  always @(posedge clock, posedge reset)
    if(reset) state <= S_IDLE;
    else state <= n_state;
  
  always @(*)
  begin
    n_state = state;
    busy = 1;
    slow_mode = 0;
    save = 0;
    case(state)
    S_IDLE:
    begin
      if(start) n_state = S_STOP_SAVE;
      busy = 0;
      save = 1;
    end
    S_STOP_SAVE:
      n_state = S_SEND;
    S_SEND:
    begin
      if(sender_finished) n_state = S_IDLE;
      slow_mode = 1;
    end
    endcase
  end
endmodule
