//сохраняет значение 

module register
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

    always @ (posedge clk, negedge rst)
        if (~rst)
            out <= {{(WIDTH - 1){ 1'b0 }}, 1'b1};
        else if (load)
            out <= in;
            else out <= 4'b0000;
endmodule
