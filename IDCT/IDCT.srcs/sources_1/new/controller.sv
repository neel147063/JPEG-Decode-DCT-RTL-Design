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
