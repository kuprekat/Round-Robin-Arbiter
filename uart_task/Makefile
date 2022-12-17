GENERATES = a.out dump.vcd
TRASH = out.txt

a.out: clock_divider.v serializer.v shift_register_l.v uart_deserializer.v uart_transmitter.v mul_vectors.v  uart_receiver.v main.v multiplier.v uart_transmitter_fsm.v testbench_all.v uart_transmitter_sender.v
	iverilog $^
	
test: a.out
	make > out.txt 2>> out.txt
	./a.out 2>> out.txt
	gtkwave dump.vcd 2>> out.txt
	
clean:
	rm -f $(TRASH) $(GENERATES)
