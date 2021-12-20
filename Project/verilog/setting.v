`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/11 16:34:16
// Design Name: 
// Module Name: setting
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


module setting(clk,rst,on_off,up,down,set_temp);
    input clk;
    input rst;
    input on_off;
    input up;
    input down;
    output reg[8:0] set_temp;
        
    wire up_out,down_out;
    debounce u(clk,on_off,up,up_out);
    debounce d(clk,on_off,down,down_out);     
    always @(negedge rst,posedge up_out,posedge down_out)
    begin
    if(rst)
        set_temp <= 9'd250;
    //加一度
    else if (on_off && up_out)
        begin
            case(set_temp)
                9'd290:set_temp = 9'd300;
                9'd280:set_temp = 9'd290;
                9'd270:set_temp = 9'd280;
                9'd260:set_temp = 9'd270;
                9'd250:set_temp = 9'd260;
                9'd240:set_temp = 9'd250;
                9'd230:set_temp = 9'd240; 
                9'd220:set_temp = 9'd230;
                9'd210:set_temp = 9'd220;
                9'd200:set_temp = 9'd210;
            endcase
            end
     //减一度
    else if (on_off && down_out)
        begin
            case(set_temp)
                9'd210:set_temp = 9'd200;
                9'd220:set_temp = 9'd210;
                9'd230:set_temp = 9'd220;  
                9'd240:set_temp = 9'd230; 
                9'd250:set_temp = 9'd240; 
                9'd260:set_temp = 9'd250; 
                9'd270:set_temp = 9'd260; 
                9'd280:set_temp = 9'd270; 
                9'd290:set_temp = 9'd280; 
                9'd300:set_temp = 9'd290; 
            endcase
        end
    end    
endmodule