// **********************
// *модуль clock_divider*
// **********************
// Делитель частоты.
// 
// = Входы =
// [бит] in   : входной такт.
// [бит] reset: асинхронный сброс.
//
// = Выходы =
// [бит] out: выходной такт.
//
// = Параметры =
// [integer] IF    [50000000]: частота входного тактового сигнала.
// [integer] OF    [9600    ]: частота выходного тактового сигнала.
// [integer] Scale [IF/OF   ]: во сколько раз выходная частота меньше входной.
// 
// = Ограничения на параметры =
// IF >= 1
// OF >= 1
// 
// = Функционирование =
// До асинхронного сброса значения выходных сигналов не определены.
// Далее описывается функционирование модуля после сброса.
// 
// Если in - тактовый сигнал заданной частоты, то:
// * если Scale > 1, то
//   * out - тактовый сигнал в Scale раз меньшей частоты;
//   * передние фронты out располагаются возле передних фронтов in;
//   * задние фронты out располагаются возле передних фронтов in наиболее близко к середине такта (среди одинаково близких фронтов выбирается более ранний);
// * если Scale <= 1, то
//   @ always: out <- in.
// 
// = Пример использования =
// Два эквивалентных экземпляра модуля, выводящего в out тактовый сигнал в 3 раза более медленный, чем тактовый сигнал in:
// clock_divider #(.IF(300), .OF(100)) _divider(.in(in), .reset(reset), .out(out));
// clock_divider #(.Scale(3)         ) _divider(.in(in), .reset(reset), .out(out));
// 
// Диаграмма сигналов in, reset, out:
// reset: _____--___________________________
// in:    __--__--__--__--__--__--__--__--__
// out:   xxxxx_____----________----________
// 
// После сброса out поднимается по первому переднему фронту in.
// 
// = Модуль написал =
// Владислав Подымов
// 2018
// e-mail: valdus@yandex.ru
module clock_divider(in, reset, out);
  parameter integer IF = 50000000;
  parameter integer OF = 9600;
  parameter integer Scale = IF/OF;
  localparam integer MiddleTick = Scale/2;
  input in, reset;
  output out;
  
  generate
    if(Scale <= 1)
    begin : trivial_scale
      assign out = in;
    end
    else
    begin : nontrivial_scale
      localparam integer TickW = $clog2(Scale);
      reg [TickW-1:0] tickreg;
      reg to_out;
      
      always @(posedge in, posedge reset)
        if(reset) tickreg <= 0;
        else tickreg <= (tickreg + 1) % Scale;
      
      always @(posedge in, posedge reset)
        if(reset) to_out <= 0;
        else if(tickreg == 0 || tickreg == MiddleTick) to_out <= !out;
      
      assign out = to_out;
    end
  endgenerate
endmodule
