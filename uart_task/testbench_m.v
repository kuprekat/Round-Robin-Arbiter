module testbench_m;
      parameter integer N = 2, WIDTH = 2;
      reg rst, clk;
      reg [WIDTH - 1:0] num1;
      reg [WIDTH - 1:0] num2;
      wire [WIDTH * 2 - 1:0] result;

	multiplier #(WIDTH) multiplier(.a(num1),  .b(num2), .out(result));
	
 	initial clk = 0;
	always #1
            clk = !clk;

	initial
	    begin
		num1 = 2'b10;
		num2 = 2'b11;

		#5;
	    end

    initial begin
        #1;
        $display("vec1:  %d\n", num1);
        $display("vec2:  %d\n", num2);
    end

    always @*
        $display("res:  %d\n", result);

      initial begin 
            $dumpfile("dump.vcd");
            $dumpvars(1);
            #20;
            $finish;
      end

endmodule
