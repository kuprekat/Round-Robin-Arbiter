module test_register;
      parameter integer WIDTH = 4;
	reg [WIDTH - 1:0] in;
	reg rst, clk, ack, load;
	wire [WIDTH - 1:0] out;

	register #(WIDTH) register(.clk(clk), .rst(rst), .load(load), .ack(ack),  .in(in), .out(out));
	
 	initial clk = 0;
	always #1
            clk = !clk;

	initial
		begin
		        rst = 1;
		        ack = 1;
		        load = 1;
		        in = 4'b1101;
		        #2
		        load = 0;
		        load = 1;
			ack = 0;
			load = 0;
			
			#2;
			rst = 1;
			
			in = 4'b1010;
			ack = 1;
			#2
			load = 1;
			#4;

			ack = 0;
			load = 0;
			#2;
			in = 4'b0111;
			ack = 1;
			#2
			load = 1;
			#4;

			ack = 0;
			load = 0;
			#2;
			in=4'b1000;
			ack = 1;
			#2
			load = 1;
			#5;

		end

	always@(in | load)
		$monitor("\n\tIN: %b\tOUT: %b\n",in,out );

      initial begin 
            $dumpfile("dump.vcd");
            $dumpvars(1);
            #40;
            $finish;
      end

endmodule
