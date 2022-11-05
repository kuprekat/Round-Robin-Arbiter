module rr_arbiter(clk, resetb, ack, request, grant);
	parameter integer WIDTH = 4;
	input clk, resetb, ack;
	input [WIDTH - 1:0] request;
	output [WIDTH - 1:0] grant;

	wire [WIDTH - 1:0] next_base;
	wire [WIDTH - 1:0] grant_tmp;
	wire [WIDTH - 1:0] shifted_base;
	
	rotator rotator(.x(grant_tmp), .z(shifted_base));
	
	register base(.clk(clk), .rst(resetb), .ack(ack), .load(1'b1), .in(shifted_base), .out(next_base));

	arbiter arbiter(.req(request), .grant(grant_tmp), .base(next_base));

	decoder final_decoder(.clk(clk), .rst(resetb), .ack(ack), .load(1'b1), .in(grant_tmp), .out(grant));

endmodule
