// *************************
// *модуль uart_transmitter*
// *************************
// Модуль передачи сообщения по протоколу UART.
// 
// Требует подключения модулей:
// * clock_divider
// * serializer
// * uart_transmitter_fsm
// * uart_transmitter_sender
// 
// = Входы =
// [шина] data [W]: передаваемые данные.
// [ бит] start   : начать передачу.
// [ бит] clock   : такт.
// [ бит] reset   : асинхронный сброс.
//
// = Выходы =
// [бит] tx  : провод данных.
// [бит] busy: передатчик занят.
//
// = Параметры =
// [integer] IF                 [50000000]: частота тактового сигнала схемы.
// [integer] UF                 [9600    ]: частота передачи сообщения по протоколу UART.
// [integer] W                  [8       ]: число битов в передаваемом сообщении.
// [integer] Mode               [0       ]: порядок передачи битов сообщения:
//   Mode == 0: от младшего к старшему;
//   Mode == 1: от старшего к младшему.
// [integer] Parity             [0       ]: вид проверки чётности:
//   Parity == 0: проверки чётности нет;
//   Parity == 1: прямая проверка чётности;
//   Parity == 2: обратная проверка чётности.
// [integer] AdditionalStopbits [0       ]: число дополнительных завершающих битов.
// 
// = Ограничения на параметры =
// IF >= UF >= 1
// W >= 1
// Mode in {0, 1}
// Parity in {0, 1, 2}
// AdditionalStopbits >= 0
//
// = Функционирование =
// До асинхронного сброса значения выходных сигналов не определены.
// Далее описывается функционирование модуля после сброса.
// 
// Модуль может находиться в двух режимах:
// * режим ожидания;
// * режим передачи.
// После сброса модуль переходит в режим ожидания.
// 
// В режиме ожидания:
// * busy == 0.
// * tx == 1.
// * @ posedge clock, start == 1:
//   сохраняется значение data (сохранённое значение далее обозначается как message);
//   модуль переходит в режим передачи.
// 
// В режиме передачи:
// * busy == 1.
// * На проводе tx последовательно выставляются значения, соответствующие передаче сообщения message по протоколу UART согласно выставленным параметрам модуля:
//  * Генерируется замедленный тактовый сигнал uclock. Отношение частоты сигнала uclock к частоте тактового сигнала clock равно UF/IF. В частности, если clock имеет частоту IF Гц, то uclock имеет частоту UF Гц.
//  * На каждом такте сигнала uclock на проводе tx выставляется константное значение. В порядке тактов:
//   * 0 (начинающий бит; start bit);
//   * биты message от от младшего к старшему, если Mode == 0, и от старшего к младшему, если Mode == 1;
//   * если Parity != 0, то бит проверки чётности: сумма по модулю 2 всех битов message, если Parity == 1, и отрицание этой суммы, если Parity == 2;
//   * 1 (завершающий бит; stop bit);
//   * 1 столько раз, сколько записано в параметре AdditionalStopbits (дополнительные завершающие биты).
// * Вскоре после передачи последнего бита модуль переходит в режим ожидания.
// 
// = Модуль написал =
// Владислав Подымов
// 2018
// e-mail: valdus@yandex.ru
module uart_transmitter(data, start, clock, reset, tx, busy);
  parameter integer IF = 50000000;
  parameter integer UF = 9600;
  parameter integer W = 8;
  parameter integer Mode = 0; // 0: lsb -> msb; 1: msb -> lsb
  parameter integer Parity = 0; // 0 = none; 1 = odd; 2 = even
  parameter integer AdditionalStopbits = 0; // send 1+this stopbits at the end of every message
  input [W-1:0] data;
  input start, clock, reset;
  output tx, busy;
  
  wire uclock, slow_mode, message_bit, last_bit, sender_finished, save, shift;
  
  clock_divider #(
    .IF(IF),
    .OF(UF)
  )
  _divider(
    .in(clock),
    .reset(reset || !slow_mode),
    .out(uclock)
  );
  
  serializer #(
    .W(W),
    .Mode(Mode)
  )
  _uart_message(
    .in(data),
    .save(save),
    .shift(shift),
    .clock(slow_mode ? uclock : clock),
    .out(message_bit),
    .last_bit(last_bit)
  );
  
  uart_transmitter_fsm
  _fsm(
    .start(start),
    .sender_finished(sender_finished),
    .clock(clock),
    .reset(reset),
    .busy(busy),
    .slow_mode(slow_mode),
    .save(save)
  );
  
  uart_transmitter_sender #(
    .Parity(Parity),
    .AdditionalStopbits(AdditionalStopbits)
  )
  _sender (
    .message_bit(message_bit),
    .last_bit(last_bit),
    .clock(uclock),
    .reset(reset || !slow_mode),
    .shift(shift),
    .tx(tx),
    .finished(sender_finished)
  );
endmodule
