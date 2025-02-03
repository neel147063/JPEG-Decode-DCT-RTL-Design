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
