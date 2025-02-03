`timescale 1ns / 1ps
module testbench;
reg clk;
reg reset;
reg start;
wire [31:0]idct_out[7:0];
reg [31:0]pixel_values[7:0];
wire ready;
controller uut(.clk(clk),
             .reset(reset),
             .start(start),
             .ready(ready),
             .idct_out(idct_out));
output_scaling uut1(.idct_out(idct_out),
                    .pixel_values(pixel_values));
               
               initial begin
               clk=0;
               reset=0;
               start=0;
               #1;
               reset=1;
               #20;
               start=1;
               #200;
               $display("IDCT output:%0p",idct_out);
               $finish();
               end
               always #5 clk=~clk;
endmodule
/*so each address having 32 bit value now divide 32 by 4 so you got 8 part of one address 
which is more like matrix and i will show you like 
mux ={[0,0,0,0,0,1,c,2],
      [0,0,0,0,0,1,9,0],
      [0,0,0,0,0,1,5,e],
      [0,0,0,0,0,1,2,c],
      [0,0,0,0,0,0,f,a],
      [0,0,0,0,0,0,c,8],
      [0,0,0,0,0,0,9,6],
      [0,0,0,0,0,0,6,4]}  this is input mux or pixel now IDCT

MUX ={[4,3,8,D,3,1,C,2],
      [8,0,0,0,0,0,0,0],etc....} */