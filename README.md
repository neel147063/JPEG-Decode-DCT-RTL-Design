# JPEG-Decode-DCT-RTL-Design
use Vivado 2023.2 ml edition 

# row_transform
    `timescale 1ns / 1ps
    module row_transform(input logic clk,reset, 
                    output logic [31:0]idct_row[7:0]
    );
    logic[31:0]dct_coeff[7:0];
    logic[31:0]mul[7:0];
    
    initial begin
        dct_coeff[0]=32'd100;
        dct_coeff[1]=32'd150;
        dct_coeff[2]=32'd200;
        dct_coeff[3]=32'd250;
        dct_coeff[4]=32'd300;
        dct_coeff[5]=32'd350;
        dct_coeff[6]=32'd400;
        dct_coeff[7]=32'd450;
    end
    always_ff@(posedge clk or negedge reset)begin
        if(!reset)begin
        idct_row[7]<=32'b0;
        idct_row[6]<=32'b0;
        idct_row[5]<=32'b0;
        idct_row[4]<=32'b0;
        idct_row[3]<=32'b0;
        idct_row[2]<=32'b0;
        idct_row[1]<=32'b0;
        idct_row[0]<=32'b0;
        end
        else begin
        mul[0]<=dct_coeff[0]*cos_val(0);
        mul[1]<=dct_coeff[1]*cos_val(1);
        mul[2]<=dct_coeff[2]*cos_val(2);
        mul[3]<=dct_coeff[3]*cos_val(3);
        mul[4]<=dct_coeff[4]*cos_val(4);
        mul[5]<=dct_coeff[5]*cos_val(5);
        mul[6]<=dct_coeff[6]*cos_val(6);
        mul[7]<=dct_coeff[7]*cos_val(7);
        
        idct_row[0]<=mul[0]+mul[4];
        idct_row[1]<=mul[1]+mul[5];
        idct_row[2]<=mul[2]+mul[6];
        idct_row[3]<=mul[3]+mul[7];
        idct_row[4]<=mul[4]-mul[0];
        idct_row[5]<=mul[5]-mul[1];
        idct_row[6]<=mul[6]-mul[2];
        idct_row[7]<=mul[7]-mul[3];
        
        end
        end
        function [31:0]cos_val(input int u);
        case(u)
            0: cos_val = 32'h5a82799a; 
            1: cos_val = 32'h5d4130c1;
            2: cos_val = 32'h6a6d98a4;
            3: cos_val = 32'h7d8a5f40;
            4: cos_val = 32'h7fffffff; 
            5: cos_val = 32'h7d8a5f40;
            6: cos_val = 32'h6a6d98a4;
            7: cos_val = 32'h5d4130c1;
            default: cos_val = 32'h0;
        endcase 
        endfunction 
    endmodule

# col_transform

    `timescale 1ns / 1ps
    module column_transform(input logic clk,reset,input logic [31:0]idct_row[7:0],
                        output logic [31:0]idct_col[7:0]);
                        logic[31:0]mul[7:0];
                        always_ff@(posedge clk or negedge reset)begin
                            if(!reset)begin
                            for(int i=0;i<8;i++)begin
                                idct_col[i]<=32'b0;
                            end
                            end
                            else begin
                                mul[0]<=idct_row[0]*cos_val(0);
                                mul[1]<=idct_row[1]*cos_val(1);
                                mul[2]<=idct_row[2]*cos_val(2);
                                mul[3]<=idct_row[3]*cos_val(3);
                                mul[4]<=idct_row[4]*cos_val(4);
                                mul[5]<=idct_row[5]*cos_val(5);
                                mul[6]<=idct_row[6]*cos_val(6);
                                mul[7]<=idct_row[7]*cos_val(7);
                                
                                idct_col[0]<=mul[0]+mul[4];
                                idct_col[1]<=mul[1]+mul[5];
                                idct_col[2]<=mul[2]+mul[6];
                                idct_col[3]<=mul[3]+mul[7];
                                idct_col[4]<=mul[4]-mul[0];
                                idct_col[5]<=mul[5]-mul[1];
                                idct_col[6]<=mul[6]-mul[2];
                                idct_col[7]<=mul[7]-mul[3];
                                
                            end
                        end
        function [31:0]cos_val(input int u);
        case(u)
            0: cos_val = 32'h5a82799a; 
            1: cos_val = 32'h5d4130c1;
            2: cos_val = 32'h6a6d98a4;
            3: cos_val = 32'h7d8a5f40;
            4: cos_val = 32'h7fffffff; 
            5: cos_val = 32'h7d8a5f40;
            6: cos_val = 32'h6a6d98a4;
            7: cos_val = 32'h5d4130c1;
        endcase 
        endfunction
      endmodule

# controller

    `timescale 1ns / 1ps
    module controller(input logic clk,reset,start, 
                  output logic ready,output logic [31:0]idct_out[7:0]);
                  logic[31:0]row_result[7:0];
                  logic[31:0]col_result[7:0];
                  logic row_done,col_done;
                  
                  row_transform u_row(.clk(clk),
                                      .reset(reset),
                                      .idct_row(row_result));
                  column_transform u_col(.clk(clk),
                                         .reset(reset),
                                         .idct_row(row_result),
                                         .idct_col(col_result));
                  
                  always_ff@(posedge clk or negedge reset)begin
                    if(!reset)begin
                    ready<=0;
                    row_done<=0;
                    col_done<=0;
                    for(int i=0;i<8;i++)begin
                        idct_out[i]<=32'd0;
                    end
                    end
                    else begin
                        if(start && !row_done)begin
                            row_done<=1;
                        end
                        else if(row_done && !col_done) begin 
                            col_done<=1;
                        end
                        else if(col_done) begin
                            idct_out<=col_result;
                        end
                    end
                  end
    endmodule
    
# output scaling

    `timescale 1ns / 1ps
    module output_scaling(input logic[31:0]idct_out[7:0],
                      output logic[31:0]pixel_values[7:0]);
         always_ff@(idct_out)begin
            for(int i=0;i<8;i++)begin
                pixel_values[i]=(idct_out[i]>2147483648)?2147483648:(idct_out[i]<0)?0:idct_out[i];
            end
         end
    endmodule

# testbench

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
    


