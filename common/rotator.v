module rotator
#( 
    parameter WIDTH = 4
)
(
    input  [WIDTH - 1:0] x,
    output [WIDTH - 1:0] z
);

    wire [2 * WIDTH - 1:0] temp;
    assign temp = {x, x} << 1'b1;
    assign z = temp[2 * WIDTH - 1: WIDTH];
endmodule

