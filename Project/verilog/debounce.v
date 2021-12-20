`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/18 20:01:28
// Design Name: 
// Module Name: debounce
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

module debounce(
    input wire clk, nrst,
    input wire key_in,
    output reg key_out//key_flag����ʾ�Ƿ���
    );

    localparam TIME_20MS = 1_000_000;
//    localparam TIME_20MS = 1_000;       // just for test

    reg key_cnt;
    reg [20:0] cnt;

    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            key_cnt <= 0;
        else if(key_cnt == 0 && key_out != key_in)
            key_cnt <= 1;
        else if(cnt == TIME_20MS - 1)
            key_cnt <= 0;
    end

    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            cnt <= 0;
        else if(key_cnt)
            cnt <= cnt + 1'b1;
        else
            cnt <= 0;
    end

    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            key_out <= 0;
        else if(key_cnt == 0 && key_out != key_in)
            key_out <= key_in;
    end
endmodule
