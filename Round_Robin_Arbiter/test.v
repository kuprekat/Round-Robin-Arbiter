module test_arbiter;
      parameter integer WIDTH = 4;
	reg [WIDTH - 1:0] request;
	reg rst, clk, ack;
	wire [WIDTH - 1:0] grant;

	rr_arbiter #(WIDTH) rr_arbiter(.clk(clk), .resetb(rst), .ack(ack), .request(request), .grant(grant));
	
      initial clk = 0;
      always #1
            clk = !clk;

	initial
		begin
			rst = 0;
			ack = 0;
			
			#2;
			rst = 1;
			
			request = 4'b1010;
			ack = 1;
			#4;

			ack = 0;
			#2;
			request = 4'b0111;
			#2
			ack = 1;
			#4;

			ack = 0;
			#2;
			request=4'b1000;
			#2
			ack = 1;
			#4;

		end

	always@(request)
		$monitor("\n\tREQUEST VECTOR: %b\tGRANT VECTOR: %b\t ACK: %d\n",request,grant,ack );

      initial begin 
            $dumpfile("dump.vcd");
            $dumpvars(1);
            #30;
            $finish;
      end

endmodule
