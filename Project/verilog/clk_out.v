`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/18 20:17:22
// Design Name: 
// Module Name: clk_out
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock(
    input clk,
    output reg clk_out
    );
reg[19:0] count;
always@(posedge clk)
    begin
    if(count == 10_0000) 
        begin
        count <= 0;
        clk_out <= clk_out+1;
        end
    else count <= count+1;
    end
endmodule

