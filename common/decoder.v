module register
# (
    parameter WIDTH = 8,
    parameter OUTPUT_TYPE = 1
)
(
    input                      clock,
    input                      reset,
    input                      ack,
    input                      load,
    input 	   [WIDTH - 1:0] in,
    output reg     [WIDTH - 1:0] out
);

	always @ (posedge clock, negedge reset)
	  if (~reset)
            out <= {WIDTH { 1'b0 }};
          else if (load & ack)
            out <= in;
endmodule
