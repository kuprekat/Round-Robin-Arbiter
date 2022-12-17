// Технический модуль, используемый в uart_transmitter.
// 
// = Модуль написал =
// Владислав Подымов
// 2018
// e-mail: valdus@yandex.ru
module uart_transmitter_sender(message_bit, last_bit, clock, reset, shift, tx, finished);
  parameter integer Parity = 0;
  parameter integer AdditionalStopbits = 0;
  input message_bit, last_bit, clock, reset;
  output shift;
  output reg tx;
  output finished;
  
  // = fsm states =
  reg [2:0] state, n_state;
  localparam integer S_IDLE = 0;
  localparam integer S_START = 1;
  localparam integer S_DATA = 2;
  localparam integer S_PARITY = 3;
  localparam integer S_STOP = 4;
  localparam integer S_FINISH = 5;
  
  always @(posedge clock, posedge reset)
    if(reset) state <= S_IDLE;
    else state <= n_state;
  // - fsm states -
  
  // = parity bit =
  reg parity_bit, n_parity_bit;
  
  always @(posedge clock)
    parity_bit <= n_parity_bit;
  // - parity bit -
  
  // = stopbit counter =
  localparam SCW = (AdditionalStopbits == 0)
                   ? 1
                   : $clog2(AdditionalStopbits + 1);
  reg [SCW-1:0] stopbits_remain, n_stopbits_remain;
  
  always @(posedge clock)
    stopbits_remain <= n_stopbits_remain;
  // - stopbit counter -
  
  // = fsm transitions =
  always @(*)
  begin
    n_state = state;
    case(state)
    S_IDLE:
      n_state = S_START;
    S_START:
      n_state = S_DATA;
    S_DATA:
      if(last_bit)
      begin
        if(Parity == 0) n_state = S_STOP;
        else n_state = S_PARITY;
      end
    S_PARITY:
      n_state = S_STOP;
    S_STOP:
      if(stopbits_remain == 0) n_state = S_FINISH;
    endcase
  end
  // - fsm transitions -
  
  // = parity update =
  always @(*)
  begin
    n_parity_bit = parity_bit;
    case(state)
    S_START:
      if(Parity == 2) n_parity_bit = 1;
      else n_parity_bit = 0;
    S_DATA:
      n_parity_bit = parity_bit ^ message_bit;
    endcase
  end
  // - parity update -
  
  // = stopbit counter update =
  always @(*)
  begin
    n_stopbits_remain = 0;
    case(state)
    S_DATA:
      if(Parity == 0) n_stopbits_remain = AdditionalStopbits;
    S_PARITY:
      n_stopbits_remain = AdditionalStopbits;
    S_STOP:
      if(stopbits_remain > 0) n_stopbits_remain = stopbits_remain - 1;
    endcase
  end
  // - stopbit counter -
  
  // = outputs =
  assign shift = (state == S_DATA);
  assign finished = (state == S_FINISH);
  always @(*)
  begin
    tx = 1;
    case(state)
    S_START:
      tx = 0;
    S_DATA:
      tx = message_bit;
    S_PARITY:
      tx = parity_bit;
    endcase
  end
  // - outputs -
endmodule
