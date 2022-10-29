module test_arbiter;
      parameter integer WIDTH = 4;
	reg [WIDTH - 1:0] request;
	reg rst, clk, ack;
	wire [WIDTH - 1:0] grant;

	rr_arbiter #(WIDTH) rr_arbiter(.clk(clk), .resetb(rst), .ack(ack), .request(request), .grant(grant));
	

      always #1
            clk = !clk;

	initial
		begin
			rst = 0;
			ack = 0;
			
			#10;
			rst = 1;
			
			request = 4'b1010;
			ack = 1;
			#100;

			rst = 0;
			ack = 0;
			#10;
			rst = 1;
			request = 4'b0111;
			ack = 1;
			#100;

			rst = 0;
			ack = 0;
			#10;
			rst = 1;
			request=4'b1000;
			ack = 1;
			#100;

		end

	always@(request)
		$monitor("\n\tREQUEST VECTOR: %b\tGRANT VECTOR: %b\n",request,grant );

      initial begin 
            $dumpfile("dump.vcd");
            $dumpvars(1);
      end

endmodule