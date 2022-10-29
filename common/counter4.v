module counter (clk, reset, q); 
input clock, reset; 
output [3:0] q; 
reg [3:0] tmp; 
 
  always @(posedge clock or posedge reset) 
    begin 
      if (reset) 
        tmp = 4'b0000; 
      else 
        tmp = (tmp + 1'b1) % 4; 
      end 
  assign q = tmp; 
endmodule 