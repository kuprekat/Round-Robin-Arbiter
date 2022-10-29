//сохраняет значение с циклическим сдвигом на 1 влево

module shift_register
# (
    parameter WIDTH = 4
)
(
    input                      clk,
    input                      rst,
    input                      load,
    input                      ack,
    input 	   [WIDTH - 1:0] in,
    output reg [WIDTH - 1:0] out
);
    reg [2 * WIDTH - 1:0] temp;

    always @ (posedge clock, negedge reset)
	if (~reset)
        out <= {{(WIDTH - 1){ 1'b0 }}, 1'b1};
      else if (load & ack) begin
        assign temp = {in, in} << 1;
    	assign out = temp[2 * WIDTH - 1: WIDTH];
      end
endmodule
