`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/22 21:20:24
// Design Name: 
// Module Name: display
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



module display(on_off,charge,record,power_show,add_show,max,current_num,rst,clk,show_mod,DIG,Y,num_ET,num_RT,num_Po);//开关，时钟，环境温度，空调温度，电量，显示， 输出
input rst ;
input [0:0] on_off;
input [0:0]charge;
input [0:0]record;
input [9:0] power_show;
input [9:0] add_show;
input [1:0] max;
input [1:0] current_num;
input [8:0] num_ET,num_RT;
input [9:0] num_Po;

input clk ;
input [1:0] show_mod; //10为空调温度，01为电量，00、11为环境温度
output [7:0] DIG ;
output [7:0] Y ;
 
reg [9:0] num;
reg clkout ;
reg [31:0]cnt;  
reg [2:0]scan_cnt ;     
reg [7:0] num1;//最高位
reg [7:0] num2;//个位
reg [7:0] num3;//小数位
parameter  period= 100000;
reg [6:0] Y_r;
reg [0:0] dot;
reg [7:0] DIG_r ;
assign Y = {dot,(~Y_r[6:0])};
assign DIG =~DIG_r;

always@(show_mod,num_ET,num_RT,num_Po)
begin
if(on_off)
    begin
    case(show_mod)
    0:num<=num_ET;
    1:num<=num_RT;
    2:num<=num_Po;
    default: num=num_ET;
    endcase
    end
else if(!on_off&&!charge)
    begin
    num=num_ET;
    end
end

always @( posedge clk or negedge rst)      //分频50Hz
    begin 
    if (rst)
        cnt <= 0 ;
    else  
    begin  
        cnt<= cnt+1;
        if (cnt == (period >> 1) - 1)               
            clkout <= #1 1'b1;
        else if (cnt == period - 1)                    
        begin 
            clkout <= #1 1'b0;
            cnt <= #1 'b0;      
        end
    end
    end
 
always @(posedge clkout or negedge rst)          
    begin 
    if (rst)
        scan_cnt <= 0 ;
    else
        begin
        scan_cnt <= scan_cnt + 1;    
        if(scan_cnt==3'd7)  scan_cnt <= 0;
        end 
    end
     
always @( scan_cnt)         //数码管选择
    begin 
    if(!charge&!record)
    begin
    case ( scan_cnt )    
        3'b000 : DIG_r <= 8'b0000_0000;    
        3'b001 : DIG_r <= 8'b0000_0000;    
        3'b010 : DIG_r <= 8'b0000_0000;    
        3'b011 : DIG_r <= 8'b0000_0000;    
        3'b100 : DIG_r <= 8'b0000_0000;    
        3'b101 : DIG_r <= 8'b0010_0000;    
        3'b110 : DIG_r <= 8'b0100_0000;     
        3'b111 : DIG_r <= 8'b1000_0000;    
        default :DIG_r <= 8'b0000_0000;    
    endcase
    end
    if(!on_off&charge&!record)
        begin
        case ( scan_cnt )    //只用前三个
            3'b000 : DIG_r <= 8'b0000_0000;    
            3'b001 : DIG_r <= 8'b0000_0010;    
            3'b010 : DIG_r <= 8'b0000_0100;    
            3'b011 : DIG_r <= 8'b0000_1000;    
            3'b100 : DIG_r <= 8'b0000_0000;    
            3'b101 : DIG_r <= 8'b0010_0000;    
            3'b110 : DIG_r <= 8'b0100_0000;     
            3'b111 : DIG_r <= 8'b1000_0000;    
            default :DIG_r <= 8'b0000_0000;   
        endcase
        end
        if(!on_off&charge&record)
            begin
            case ( scan_cnt )    //只用前三个
                3'b000 : DIG_r <= 8'b0000_0001;    
                3'b001 : DIG_r <= 8'b0000_0010;    
                3'b010 : DIG_r <= 8'b0000_0100;    
                3'b011 : DIG_r <= 8'b0000_1000;    
                3'b100 : DIG_r <= 8'b0001_0000;    
                3'b101 : DIG_r <= 8'b0010_0000;    
                3'b110 : DIG_r <= 8'b0100_0000;     
                3'b111 : DIG_r <= 8'b1000_0000;    
                default :DIG_r <= 8'b0000_0000;   
            endcase
            end
    end

always@(num)
    begin
    case(num/100)
        0: num1=7'b0111111;
        1: num1 = 7'b0000110;    // 1 
        2: num1 = 7'b1011011; // 2
        3: num1 = 7'b1001111; // 3
        4: num1 = 7'b1100110; // 4
        5: num1 = 7'b1101101; // 5
        6: num1 = 7'b1111101;// 6
        7: num1 = 7'b0100111; // 7
        8: num1 = 7'b1111111; // 8
        9: num1 = 7'b1100111; // 9
    endcase
    end
    
always@(num)
    begin
    case((num/10)%10)
        0: num2 = 7'b0111111;
        1: num2 = 7'b0000110;    // 1 
        2: num2 = 7'b1011011; // 2
        3: num2 = 7'b1001111; // 3
        4: num2 = 7'b1100110; // 4
        5: num2 = 7'b1101101; // 5
        6: num2 = 7'b1111101;// 6
        7: num2 = 7'b0100111; // 7
        8: num2 = 7'b1111111; // 8
        9: num2 = 7'b1100111; // 9
    endcase
end

always@(num)
    begin
    case(num%10)
        0: num3 = 7'b0111111;//0
        1: num3 = 7'b0000110;    // 1 
        2: num3 = 7'b1011011; // 2
        3: num3 = 7'b1001111; // 3
        4: num3 = 7'b1100110; // 4
        5: num3 = 7'b1101101; // 5
        6: num3 = 7'b1111101;// 6
        7: num3 = 7'b0100111; // 7
        8: num3 = 7'b1111111; // 8
        9: num3 = 7'b1100111; // 9
    endcase
    end
    
always @ (power_show,add_show,max,current_num,scan_cnt ) //译码
    begin         //只有用了num1，num1，num3的能显示，剩下的没用。之后有需要再改
    if(!charge&!record)
        begin
        case (scan_cnt)
            0: Y_r = 7'b0111111;       // 
            1: Y_r = 7'b0000110;    // 1 
            2: Y_r = 7'b1011011; // 2
            3: Y_r = 7'b1001111; // 3
            4: Y_r = 7'b1100110; // 4
            5: Y_r = num3; // 5
            6: Y_r = num2;// 6
            7: Y_r = num1; // 7
            8: Y_r = 7'b1111111; // 8
            9: Y_r = 7'b1100111; // 9
            10: Y_r = 7'b1110111; // A
            11: Y_r = 7'b1111100; // b
            12: Y_r = 7'b0111001; // c
            13: Y_r = 7'b1011110; // d
            14: Y_r = 7'b1111001; // E
            15: Y_r = 7'b1110001; // F
            default: Y_r = 7'b0000000;
        endcase
        end
    if(!on_off && charge)
        begin
        case (scan_cnt)
            1: 
                case(add_show%10)
                0: Y_r = 7'b0111111; //0
                1: Y_r = 7'b0000110; // 1 
                2: Y_r = 7'b1011011; // 2
                3: Y_r = 7'b1001111; // 3
                4: Y_r = 7'b1100110; // 4
                5: Y_r = 7'b1101101; // 5
                6: Y_r = 7'b1111101; // 6
                7: Y_r = 7'b0100111; // 7
                8: Y_r = 7'b1111111; // 8
                9: Y_r = 7'b1100111; // 9
                endcase
            2: 
                case((add_show/10)%10)
                0: Y_r = 7'b0111111; //0
                1: Y_r = 7'b0000110; // 1 
                2: Y_r = 7'b1011011; // 2
                3: Y_r = 7'b1001111; // 3
                4: Y_r = 7'b1100110; // 4
                5: Y_r = 7'b1101101; // 5
                6: Y_r = 7'b1111101; // 6
                7: Y_r = 7'b0100111; // 7
                8: Y_r = 7'b1111111; // 8
                9: Y_r = 7'b1100111; // 9
                endcase
            3:
                 case(add_show/100)
                 0: Y_r = 7'b0111111; //0
                 1: Y_r = 7'b0000110; // 1 
                 2: Y_r = 7'b1011011; // 2
                 3: Y_r = 7'b1001111; // 3
                 4: Y_r = 7'b1100110; // 4
                 5: Y_r = 7'b1101101; // 5
                 6: Y_r = 7'b1111101; // 6
                 7: Y_r = 7'b0100111; // 7
                 8: Y_r = 7'b1111111; // 8
                 9: Y_r = 7'b1100111; // 9
                 endcase
            5:
                 case(power_show%10)
                 0: Y_r = 7'b0111111; //0
                 1: Y_r = 7'b0000110; // 1 
                 2: Y_r = 7'b1011011; // 2
                 3: Y_r = 7'b1001111; // 3
                 4: Y_r = 7'b1100110; // 4
                 5: Y_r = 7'b1101101; // 5
                 6: Y_r = 7'b1111101; // 6
                 7: Y_r = 7'b0100111; // 7
                 8: Y_r = 7'b1111111; // 8
                 9: Y_r = 7'b1100111; // 9
                 endcase
            6: 
                 case((power_show/10)%10)
                 0: Y_r = 7'b0111111; //0
                 1: Y_r = 7'b0000110; // 1 
                 2: Y_r = 7'b1011011; // 2
                 3: Y_r = 7'b1001111; // 3
                 4: Y_r = 7'b1100110; // 4
                 5: Y_r = 7'b1101101; // 5
                 6: Y_r = 7'b1111101; // 6
                 7: Y_r = 7'b0100111; // 7
                 8: Y_r = 7'b1111111; // 8
                 9: Y_r = 7'b1100111; // 9
                 endcase
            7:
                 case(power_show/100)
                 0: Y_r = 7'b0111111; //0
                 1: Y_r = 7'b0000110; // 1 
                 2: Y_r = 7'b1011011; // 2
                 3: Y_r = 7'b1001111; // 3
                 4: Y_r = 7'b1100110; // 4
                 5: Y_r = 7'b1101101; // 5
                 6: Y_r = 7'b1111101; // 6
                 7: Y_r = 7'b0100111; // 7
                 8: Y_r = 7'b1111111; // 8
                 9: Y_r = 7'b1100111; // 9
                 endcase
            0:
                 case(current_num)
                 0: Y_r = 7'b0111111; //0
                 1: Y_r = 7'b0000110; // 1 
                 2: Y_r = 7'b1011011; // 2
                 3: Y_r = 7'b1001111; // 3
                 4: Y_r = 7'b1100110; // 4
                 5: Y_r = 7'b1101101; // 5
                 6: Y_r = 7'b1111101; // 6
                 7: Y_r = 7'b0100111; // 7
                 8: Y_r = 7'b1111111; // 8
                 9: Y_r = 7'b1100111; // 9
                 endcase
            4:
                case(max)
                0: Y_r = 7'b0111111; //0
                1: Y_r = 7'b0000110; // 1 
                2: Y_r = 7'b1011011; // 2
                3: Y_r = 7'b1001111; // 3
                4: Y_r = 7'b1100110; // 4
                5: Y_r = 7'b1101101; // 5
                6: Y_r = 7'b1111101; // 6
                7: Y_r = 7'b0100111; // 7
                8: Y_r = 7'b1111111; // 8
                9: Y_r = 7'b1100111; // 9
                endcase
            endcase
        end
    end    

always@(scan_cnt)
    begin
    if(scan_cnt==7||scan_cnt==3) //第二位小数点显示
        begin dot=1'b0;end
    else dot=1'b1;
    end
    
endmodule
