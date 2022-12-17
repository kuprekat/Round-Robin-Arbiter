// *******************
// *модуль serializer*
// *******************
// Сериализатор
// 
// Сохраняет значение с входной шины и перечисляет биты - в зависимости от параметров, либо от младшего к старшему, либо наоборот.
// 
// = Входы =
// [шина] in [W]: входные данные.
// [ бит] save  : сохранить данные.
// [ бит] shift : перейти к выдаче следующего бита.
// [ бит] clock : такт.
//
// = Выходы =
// [бит] out     : текущий выдаваемый бит сохранённых данных.
// [бит] last_bit: сейчас выдаётся последний оставшийся бит сохранённых данных.
//
// = Параметры =
// [integer] W    [8]: ширина данных.
// [integer] Mode [0]: режим работы:
//   Mode == 0: биты перечисляются от младшего к старшему;
//   Mode == 1: биты перечисляются от старшего к младшему.
// 
// = Ограничения на параметры =
// W >= 1
// Mode in {0, 1}
//
// = Функционирование =
// Содержит данные stored ширины W и номер k текущего выдаваемого бита.
// 
// * @ posedge clock, save == 1:
//   stored <- in
//   out <- первый по порядку бит stored
// * @ posedge clock, save != 1, shift == 1:
//   если в out выводится не последний по порядку бит stored, то
//     out <- следующий по порядку бит stored
// * @ always:
//   last_bit == 1 <=> выводится последний по порядку бит stored
//   
// = Модуль написал =
// Владислав Подымов
// 2018
// e-mail: valdus@yandex.ru
module serializer(in, save, shift, clock, out, last_bit);
  parameter integer W = 8;
  parameter integer Mode = 0; // 0: lsb -> msb; 1: msb -> lsb
  input [W-1:0] in;
  input save, shift, clock;
  output out, last_bit;
  
  localparam integer CW = (W == 1)
                          ? 1
                          : $clog2(W);
  reg [W-1:0] stored;
  reg [CW-1:0] bits_left;
  
  always @(posedge clock)
    if(save) begin
      stored <= in;
      bits_left <= W-1;
    end
    else
    begin
      if(shift && bits_left > 0)
      begin
        if(Mode == 0) stored <= {1'bx, stored[W-1:1]};
        else stored <= {stored[W-2:0], 1'bx};
        bits_left <= bits_left - 1;
      end
    end
  
  assign out = (Mode == 0) ? stored[0] : stored[W-1];
  assign last_bit = (bits_left == 0);
  
endmodule
