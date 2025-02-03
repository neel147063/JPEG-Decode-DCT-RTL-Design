`timescale 1ns / 1ps
module output_scaling(input logic[31:0]idct_out[7:0],
                      output logic[31:0]pixel_values[7:0]);
         always_ff@(idct_out)begin
            for(int i=0;i<8;i++)begin
                pixel_values[i]=(idct_out[i]>2147483648)?2147483648:(idct_out[i]<0)?0:idct_out[i];
            end
         end
endmodule
