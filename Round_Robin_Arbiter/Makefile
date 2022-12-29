GENERATES = a.out dump.vcd
TRASH = out.txt

a.out: register.v rotator.v arbiter.v rr_arbiter.v decoder.v test.v
	iverilog $^
	
test: a.out
	make > out.txt 2>> out.txt
	./a.out 2>> out.txt
	gtkwave dump.vcd 2>> out.txt
	
clean:
	rm -f $(TRASH) $(GENERATES)
