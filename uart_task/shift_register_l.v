// *************************
// *модуль shift_register_l*
// *************************
// Сдвиговый регистр с синхронным включением загрузки.
// 
// = Входы =
// [бит] in   : входной бит.
// [бит] load : включение загрузки.
// [бит] clock: такт.
//
// = Выходы =
// [шина] out [W]: выходные данные.
//
// = Параметры =
// [integer] W    [8]: ширина выходных данных.
// [integer] Mode [0]: сторона сдвига:
//   Mode == 0 - сдвиг в сторону старшего бита, вход записывается в младший бит;
//   Mode == 1 - сдвиг в сторону младшего бита, вход записывается в старший бит.
// 
// = Ограничения на параметры =
// W >= 1
// Mode in {0, 1}
//
// = Функционирование =
// * @ posedge clock, load == 1, Mode == 0:
//   out <- {out[W-2:0], in}
// * @ posedge clock, load == 1, Mode == 1:
//   out <- {in, out[W-1:1]}
// 
// = Модуль написал =
// Владислав Подымов
// 2018
// e-mail: valdus@yandex.ru
module shift_register_l(in, load, clock, out);
  parameter integer W = 8;
  parameter integer Mode = 0;
  input in, load, clock;
  output reg [W-1:0] out;
  
  always @(posedge clock)
    if(load)
    begin
      if(Mode == 0) out <= {out[W-2:0], in};
      else out <= {in, out[W-1:1]};
    end
endmodule
