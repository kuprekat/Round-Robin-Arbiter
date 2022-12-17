module mul_vectors
#(parameter N = 8, parameter WIDTH = 8)
(
    input [WIDTH * 2 - 1:0] vec1,
    input [WIDTH * 2 - 1:0] vec2,
    output [WIDTH * 2 * N - 1:0] result
);

    wire [WIDTH * 2 * N - 1:0] tmp;
    
    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin:step
            multiplier 
            #(
                .WIDTH(WIDTH)
            )
            elem
            (
                .a  (vec1[(i + 1) * WIDTH - 1:WIDTH * i]),
                .b  (vec2[(i + 1) * WIDTH - 1:WIDTH * i]),
                .out(tmp[2 * (i + 1) * WIDTH - 1:2 * i * WIDTH]  )
            );
         end;
    endgenerate

    assign result = tmp;

endmodule
