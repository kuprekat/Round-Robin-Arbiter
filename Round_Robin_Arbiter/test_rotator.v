module test_arbiter;
      parameter integer WIDTH = 4;
        reg clk;
	reg [WIDTH - 1:0] x;
	wire [WIDTH - 1:0] z;

	rotator #(WIDTH) rotator(.x(x), .z(z));
	

      always #1
            clk = !clk;

	initial
		begin			
			#10;
			x = 4'b0010;
			#100;

			x = 4'b0111;
			#100;

			x=4'b1000;
			#100;

		end

	always@(x)
		$monitor("\n\tX: %b\tZ: %b\n",x, z );

      initial begin 
            $dumpfile("dump.vcd");
            $dumpvars(1);
            #400;
            $finish;
      end

endmodule
