`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/09 13:22:03
// Design Name: 
// Module Name: keyboard
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


module Air_condition(//键盘扫描程序与其他模块
    input            en,          //用户开关机
    input            keyboard,    //键盘扫描开关
    input            rst,         //重置按钮，对环境温度、设定温度和剩余电量初始化
    input            clk,         //时钟信号
    input            charge,      //充值模式开关
    input            record,      //记录查询开关
    input            up,down,     //调整设定温度
    input      [1:0] mode_in,     //模式控制：00,11wind,01cold,10hot
    input      [1:0] show_mode,   //显示
    output     [1:0] mode,        //用LED灯表示当前工作模式
    input      [3:0] row,         //矩阵键盘 行
    output reg [3:0] col,        //矩阵键盘 列
    output     [7:0] seg_out,     //七段数码管显示
    output     [7:0] seg_en       //七段数码管使能
);
wire clk_out;  //降频后的时钟信号
divider clock(clk,clk_out);//分频

wire [8:0] set_temp, env_temp;
wire [9:0] power_in;//mode模块传入的剩余电量
reg on_off;//开关机状态
reg [9:0] power_out;//充值模块输出的剩余电量
reg [9:0] add = 10'd0;//
//-----------------------电量为0后自动关机-----------------------//
always @(en,power_in)
    if(power_in==0) on_off=1'b0;
    else if(en) on_off=1'b1;
    else on_off=1'b0;
//-----------------------键盘扫描程序-----------------------//   
reg [2:0] state;  //状态标志
reg key_flag;   //按键标志位
reg [3:0] col_reg;  //寄存扫描列值
reg [3:0] row_reg;  //寄存扫描行值  
always @(posedge clk_out or negedge keyboard)
    if(!keyboard) begin col<=4'b0000;state<=0;end//键盘开关关闭后初始化
    else
        begin 
        case (state)
        0://没有按下
        begin
            col[3:0]<=4'b0000;//四列都有效
            key_flag<=1'b0;
            if(row[3:0]!=4'b1111) begin state<=1;col[3:0]<=4'b0111;end //有键按下，扫描第一列
            else state<=0;  //保持该状态
        end 
        1://扫描第一列
        begin
            if(row[3:0]!=4'b1111) begin state<=5;end   //判断是否是第一列
            else begin state<=2;col[3:0]<=4'b1011;end  //扫描第二列
        end 
        2://扫描第二列
        begin    
            if(row[3:0]!=4'b1111) begin state<=5;end    //判断是否是第二列
            else begin state<=3;col[3:0]<=4'b1101;end  //扫描第三列
        end
        3://扫描第三列
        begin    
            if(row[3:0]!=4'b1111) begin state<=5;end   //判断是否是第三列
            else begin state<=4;col[3:0]<=4'b1110;end  //扫描第四列
        end
        4://扫描第四列
        begin    
            if(row[3:0]!=4'b1111) begin state<=5;end  //判断是否是第四列
            else  state<=0;//没有键按下，回到状态0
        end
        5://确定行列坐标
        begin  
            if(row[3:0]!=4'b1111) 
                begin
                col_reg<=col;  //保存扫描列值 从高到低代表1到4列
                row_reg<=row;  //保存扫描行值 从高到低代表1到4行
                state<=5;      //保持该状态
                key_flag<=1'b1;  //有键按下
                end             
            else
                begin state<=0;end
        end    
        endcase 
        end   
//-----------------------根据行列坐标确定键值-----------------------//
reg [3:0] key_value;    // 键盘值
wire key_out;
debounce debounce(clk,charge,key_flag,key_out);//消抖模块

always @(clk_out or col_reg or row_reg)
    begin
    if(key_out==1'b1) 
        begin
        case ({col_reg,row_reg})
        8'b1110_1110:key_value<=4'h0;//D;   //四列四行
        8'b1110_1101:key_value<=4'h0;//C;   //四列三行
        8'b1110_1011:key_value<=4'h0;//B;
        8'b1110_0111:key_value<=4'h0;//A;
        8'b1101_1110:key_value<=4'hE;//E; 确定  //三列四行
        8'b1101_1101:key_value<=4'h9;
        8'b1101_1011:key_value<=4'h6;
        8'b1101_0111:key_value<=4'h3;
        8'b1011_1110:key_value<=4'h0;   //二列
        8'b1011_1101:key_value<=4'h8;
        8'b1011_1011:key_value<=4'h5;
        8'b1011_0111:key_value<=4'h2;
        8'b0111_1110:key_value<=4'hF;//F; 清零  //一列
        8'b0111_1101:key_value<=4'h7;
        8'b0111_1011:key_value<=4'h4;
        8'b0111_0111:key_value<=4'h1;     
        endcase 
        end   
    end
//-----------------------根据不同键值进行赋值,充值记录查询操作-----------------------//
reg [1:0] record_num = 2'b00, current_num;//将要储存数据的记录编号；当前查询的记录编号
reg [2:0] max = 3'b000;//存储的记录条数（暂定最大4条）
reg [9:0] add0=0,power_charged0=0,add1=0,power_charged1=0,add2=0,power_charged2=0,add3=0,power_charged3=0;//储存的记录（可用数组）
reg [9:0] add_show,power_show;//最终将要显示的数

always@(on_off, charge, record)//查询模块
    if(!on_off && charge && !record) begin power_show = power_in; add_show = add;end//初始化显示数
    else if(!on_off && charge && record)
        begin
        case(current_num)
        0:  begin add_show=add0; power_show=power_charged0;end
        1:  begin add_show=add1; power_show=power_charged1;end
        2:  begin add_show=add2; power_show=power_charged2;end 
        3:  begin add_show=add3; power_show=power_charged3;end 
        endcase
        end
        
always @(negedge key_out or posedge on_off)//充值模式和查询模式下键盘输入对应的操作
    if(on_off) power_out=power_in;//开机状态接受耗电对剩余电量的改变
    else if(!on_off && charge && !record)//充值模式
        begin
        case(key_value)
        4'hF: add = 10'd0;//键盘输入清零
        4'hE://确定
            begin 
            power_out = power_in + add;
            case(record_num)//储存充值记录
            0:  begin add0=add; power_charged0=power_out;end
            1:  begin add1=add; power_charged1=power_out;end
            2:  begin add2=add; power_charged2=power_out;end 
            3:  begin add3=add; power_charged3=power_out;end 
            endcase
            if(record_num+1 >= max) max = record_num+1;//当记录满四条后为4
            if(record == 3) record_num = 0;
            else record_num = record_num+1;
            add = 10'd0;//确定后清零
            end 
        default:
            if(add*10+key_value<10'd999-power_in) add = add*10+key_value;
            else add = 10'd999-power_in;//使输入的充值电量与剩余电量之和不超过999
        endcase
        end
    else if(!on_off && charge && record)//查询模式
        begin
        case(key_value)
        4'hF: current_num = 2'b00; 
        4'hE: current_num = max-1;
        default: 
            if(key_value+1<max) current_num = key_value;
            else current_num = max-1;           
       endcase     
       end                

mode md(rst,clk,mode_in,on_off,set_temp,power_out,mode,env_temp,power_in);//空调工作模块
setting st(clk,rst,on_off,up,down,set_temp);//设定温度的设置模块
display dis(on_off,charge,record,power_show,add_show,max,current_num,rst,clk,show_mode,seg_en,seg_out,env_temp,set_temp,power_in);//数码管显示模块

endmodule
