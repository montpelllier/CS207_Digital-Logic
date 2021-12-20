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


module Air_condition(//����ɨ�����������ģ��
    input            en,          //�û����ػ�
    input            keyboard,    //����ɨ�迪��
    input            rst,         //���ð�ť���Ի����¶ȡ��趨�¶Ⱥ�ʣ�������ʼ��
    input            clk,         //ʱ���ź�
    input            charge,      //��ֵģʽ����
    input            record,      //��¼��ѯ����
    input            up,down,     //�����趨�¶�
    input      [1:0] mode_in,     //ģʽ���ƣ�00,11wind,01cold,10hot
    input      [1:0] show_mode,   //��ʾ
    output     [1:0] mode,        //��LED�Ʊ�ʾ��ǰ����ģʽ
    input      [3:0] row,         //������� ��
    output reg [3:0] col,        //������� ��
    output     [7:0] seg_out,     //�߶��������ʾ
    output     [7:0] seg_en       //�߶������ʹ��
);
wire clk_out;  //��Ƶ���ʱ���ź�
divider clock(clk,clk_out);//��Ƶ

wire [8:0] set_temp, env_temp;
wire [9:0] power_in;//modeģ�鴫���ʣ�����
reg on_off;//���ػ�״̬
reg [9:0] power_out;//��ֵģ�������ʣ�����
reg [9:0] add = 10'd0;//
//-----------------------����Ϊ0���Զ��ػ�-----------------------//
always @(en,power_in)
    if(power_in==0) on_off=1'b0;
    else if(en) on_off=1'b1;
    else on_off=1'b0;
//-----------------------����ɨ�����-----------------------//   
reg [2:0] state;  //״̬��־
reg key_flag;   //������־λ
reg [3:0] col_reg;  //�Ĵ�ɨ����ֵ
reg [3:0] row_reg;  //�Ĵ�ɨ����ֵ  
always @(posedge clk_out or negedge keyboard)
    if(!keyboard) begin col<=4'b0000;state<=0;end//���̿��عرպ��ʼ��
    else
        begin 
        case (state)
        0://û�а���
        begin
            col[3:0]<=4'b0000;//���ж���Ч
            key_flag<=1'b0;
            if(row[3:0]!=4'b1111) begin state<=1;col[3:0]<=4'b0111;end //�м����£�ɨ���һ��
            else state<=0;  //���ָ�״̬
        end 
        1://ɨ���һ��
        begin
            if(row[3:0]!=4'b1111) begin state<=5;end   //�ж��Ƿ��ǵ�һ��
            else begin state<=2;col[3:0]<=4'b1011;end  //ɨ��ڶ���
        end 
        2://ɨ��ڶ���
        begin    
            if(row[3:0]!=4'b1111) begin state<=5;end    //�ж��Ƿ��ǵڶ���
            else begin state<=3;col[3:0]<=4'b1101;end  //ɨ�������
        end
        3://ɨ�������
        begin    
            if(row[3:0]!=4'b1111) begin state<=5;end   //�ж��Ƿ��ǵ�����
            else begin state<=4;col[3:0]<=4'b1110;end  //ɨ�������
        end
        4://ɨ�������
        begin    
            if(row[3:0]!=4'b1111) begin state<=5;end  //�ж��Ƿ��ǵ�����
            else  state<=0;//û�м����£��ص�״̬0
        end
        5://ȷ����������
        begin  
            if(row[3:0]!=4'b1111) 
                begin
                col_reg<=col;  //����ɨ����ֵ �Ӹߵ��ʹ���1��4��
                row_reg<=row;  //����ɨ����ֵ �Ӹߵ��ʹ���1��4��
                state<=5;      //���ָ�״̬
                key_flag<=1'b1;  //�м�����
                end             
            else
                begin state<=0;end
        end    
        endcase 
        end   
//-----------------------������������ȷ����ֵ-----------------------//
reg [3:0] key_value;    // ����ֵ
wire key_out;
debounce debounce(clk,charge,key_flag,key_out);//����ģ��

always @(clk_out or col_reg or row_reg)
    begin
    if(key_out==1'b1) 
        begin
        case ({col_reg,row_reg})
        8'b1110_1110:key_value<=4'h0;//D;   //��������
        8'b1110_1101:key_value<=4'h0;//C;   //��������
        8'b1110_1011:key_value<=4'h0;//B;
        8'b1110_0111:key_value<=4'h0;//A;
        8'b1101_1110:key_value<=4'hE;//E; ȷ��  //��������
        8'b1101_1101:key_value<=4'h9;
        8'b1101_1011:key_value<=4'h6;
        8'b1101_0111:key_value<=4'h3;
        8'b1011_1110:key_value<=4'h0;   //����
        8'b1011_1101:key_value<=4'h8;
        8'b1011_1011:key_value<=4'h5;
        8'b1011_0111:key_value<=4'h2;
        8'b0111_1110:key_value<=4'hF;//F; ����  //һ��
        8'b0111_1101:key_value<=4'h7;
        8'b0111_1011:key_value<=4'h4;
        8'b0111_0111:key_value<=4'h1;     
        endcase 
        end   
    end
//-----------------------���ݲ�ͬ��ֵ���и�ֵ,��ֵ��¼��ѯ����-----------------------//
reg [1:0] record_num = 2'b00, current_num;//��Ҫ�������ݵļ�¼��ţ���ǰ��ѯ�ļ�¼���
reg [2:0] max = 3'b000;//�洢�ļ�¼�������ݶ����4����
reg [9:0] add0=0,power_charged0=0,add1=0,power_charged1=0,add2=0,power_charged2=0,add3=0,power_charged3=0;//����ļ�¼���������飩
reg [9:0] add_show,power_show;//���ս�Ҫ��ʾ����

always@(on_off, charge, record)//��ѯģ��
    if(!on_off && charge && !record) begin power_show = power_in; add_show = add;end//��ʼ����ʾ��
    else if(!on_off && charge && record)
        begin
        case(current_num)
        0:  begin add_show=add0; power_show=power_charged0;end
        1:  begin add_show=add1; power_show=power_charged1;end
        2:  begin add_show=add2; power_show=power_charged2;end 
        3:  begin add_show=add3; power_show=power_charged3;end 
        endcase
        end
        
always @(negedge key_out or posedge on_off)//��ֵģʽ�Ͳ�ѯģʽ�¼��������Ӧ�Ĳ���
    if(on_off) power_out=power_in;//����״̬���ܺĵ��ʣ������ĸı�
    else if(!on_off && charge && !record)//��ֵģʽ
        begin
        case(key_value)
        4'hF: add = 10'd0;//������������
        4'hE://ȷ��
            begin 
            power_out = power_in + add;
            case(record_num)//�����ֵ��¼
            0:  begin add0=add; power_charged0=power_out;end
            1:  begin add1=add; power_charged1=power_out;end
            2:  begin add2=add; power_charged2=power_out;end 
            3:  begin add3=add; power_charged3=power_out;end 
            endcase
            if(record_num+1 >= max) max = record_num+1;//����¼��������Ϊ4
            if(record == 3) record_num = 0;
            else record_num = record_num+1;
            add = 10'd0;//ȷ��������
            end 
        default:
            if(add*10+key_value<10'd999-power_in) add = add*10+key_value;
            else add = 10'd999-power_in;//ʹ����ĳ�ֵ������ʣ�����֮�Ͳ�����999
        endcase
        end
    else if(!on_off && charge && record)//��ѯģʽ
        begin
        case(key_value)
        4'hF: current_num = 2'b00; 
        4'hE: current_num = max-1;
        default: 
            if(key_value+1<max) current_num = key_value;
            else current_num = max-1;           
       endcase     
       end                

mode md(rst,clk,mode_in,on_off,set_temp,power_out,mode,env_temp,power_in);//�յ�����ģ��
setting st(clk,rst,on_off,up,down,set_temp);//�趨�¶ȵ�����ģ��
display dis(on_off,charge,record,power_show,add_show,max,current_num,rst,clk,show_mode,seg_en,seg_out,env_temp,set_temp,power_in);//�������ʾģ��

endmodule
