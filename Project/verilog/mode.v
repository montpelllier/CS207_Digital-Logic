`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/11 13:58:34
// Design Name: 
// Module Name: mode
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


module mode(rst,clk,mode_in,on_off,set_temp,power_in,mode,env_temp,power);
        input rst;
        input clk;
        input [1:0] mode_in;//00,11wind,01cold,10hot
        input on_off;
        input [8:0] set_temp;
        input [9:0] power_in;
        output reg[1:0] mode;//00,11wind,01cold,10hot
        output reg[8:0] env_temp;
        output reg[9:0] power;
        
        //++++++++++++++++++++++++++++++++++++++
        // ��Ƶ���� ��ʼ
        //++++++++++++++++++++++++++++++++++++++
        reg [22:0] count;//
        reg clk_10hz;  //10HZʱ���ź�
        
        always @(negedge clk or negedge rst)
            if(rst) begin clk_10hz<=0; count<=0; end
            else
                begin
                if(count == 23'd4_999_999) begin clk_10hz<=~clk_10hz;count<=0;end
                else count<=count+1;
                end
        //--------------------------------------
        // ��Ƶ���� ����
        //--------------------------------------
    
    parameter wind = 2'b00, cold = 2'b01, hot = 2'b10;
    parameter begin_env_temp = 9'd240, begin_set_temp = 9'd250, begin_power = 10'd100;
    parameter period = 4'd10;//Ƶ��Ϊ10hz,ÿ��10������
    reg [3:0] cnt;
    reg [1:0] wind_cnt;
    always@(negedge clk_10hz,negedge rst)
    begin
        if(rst)
            begin
            power <= begin_power;
            env_temp <= begin_env_temp;
            cnt <= 0 ;
            wind_cnt <=0;    
            end
        else if (on_off) 
            begin
            case(mode_in)
            cold://������ģʽΪ�����������¶ȵ��ڻ����¶�ʱ�л�������ģʽ
            if(set_temp<env_temp) 
                  mode = cold;
            else mode = wind;
            hot://������ģʽΪ�����������¶ȸ��ڻ����¶�ʱ�л�������ģʽ
              if(set_temp>env_temp) 
                  mode = hot;
              else mode = wind;           
            wind://�л����ͷ�ģʽ  
                  mode = wind;
            default:
            mode = wind;
            endcase
        case(mode)
            cold:
            if(cnt == period-4'd1) begin//ʮ�������¶ȼ�0.1��
                cnt <= 0;
                env_temp <= env_temp - 9'd1;
                power <= power - 10'd1;//ÿ����������0.1w
                end
            else begin
                cnt <= cnt+4'd1;
                power <= power - 10'd1;//ÿ����������0.1w
                end
            hot:
            if(cnt == period-4'd1) begin//ʮ�������¶���0.1��
                cnt <= 4'd0;
                env_temp <= env_temp + 9'd1;
                power <= power - 10'd1;//ÿ����������0.1w
                 end
            else begin
                cnt <= cnt+4'd1;
                power <= power - 10'd1;//ÿ����������0.1w
                end
            wind:
            if(wind_cnt == 2'd3) begin
                wind_cnt <= 0;
                power <= power - 10'd1;//ÿ4����������0.1w
                end
            else 
                wind_cnt <= wind_cnt+2'd1;               
        endcase
        end
        else if(!on_off)//�ػ�״̬�½��ܳ�ֵģ��ĵ����ı�
            begin
            power <= power_in;
            mode <= wind;
            end
    end
                                                         
endmodule
