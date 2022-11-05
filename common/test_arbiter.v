module test_arbiter;
      parameter integer WIDTH = 4;
        reg clk;
	reg [WIDTH - 1:0] request;
	reg [WIDTH-1:0] base;
	wire [WIDTH - 1:0] grant;

	arbiter #(WIDTH) arbiter(.req(request), .grant(grant), .base(base));
	
      initial clk = 0;
      always #1
            clk = !clk;

	initial
		begin			
			#10;
			base = 4'b0010;
			request = 4'b1010;
			#100;

			request = 4'b0111;
			#100;

			request=4'b1000;
			#100;

		end

	always@(request)
		$monitor("\n\tREQUEST VECTOR: %b\tGRANT VECTOR: %b\tBASE: %b\n",request,grant,base );

      initial begin 
            $dumpfile("dump.vcd");
            $dumpvars(1);
            #500;
            $finish;
      end

endmodule
