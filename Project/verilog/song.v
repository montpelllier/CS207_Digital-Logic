`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/11 18:55:18
// Design Name: 
// Module Name: song
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



module	song(swtich,clk,beep);	//模块名称song	
input [0:0] swtich;	
input	   clk;					//系统时钟50MHz	
output	beep;					//蜂鸣器输出端
reg		beep_r;				//寄存器
reg[7:0] state;				//乐谱状态机
reg[16:0]count,count_end;
reg[23:0]count1;
//乐谱参数:D=F/2K  (D:参数,F:时钟频率,K:音高频率)
parameter   L_3 = 17'd75850,  //低音3
            L_5 = 17'd63776,  //低音5
            L_6 = 17'd56818,	//低音6
				L_7 = 17'd50618,	//低音7
				M_1 = 17'd47774,	//中音1
				M_2 = 17'd42568,	//中音2
				M_3 = 17'd37919,	//中音3
				M_5 = 17'd31888,	//中音5
				M_6 = 17'd28409,	//中音6
				H_1 = 17'd23889;	//高音1			
parameter	TIME =15000000;	//控制每一个音的长短(250ms)									
assign beep = beep_r;			//输出音乐
always@(posedge clk) begin
	count <= count + 1'b1;		//计数器加1
	if(count == count_end) begin	
		count <= 17'h0;			//计数器清零
		beep_r <= !beep_r;		//输出取反
	end
	if(!swtich)
	count<=0;
end

//曲谱 产生分频的系数并描述出曲谱

always @(posedge clk) 
begin
if(swtich)
   if(count1 < TIME)             //一个节拍250mS
      count1 = count1 + 1'b1;
   else begin
      count1 = 24'd0;
      if(state == 8'd63)
         state = 8'd0;
      else
         state = state + 1'b1;
   case(state)
   8'd0:count_end = L_6;  
	8'd1:count_end=M_1;
	8'd2:count_end=M_3;
	8'D3:count_end=M_5;
	8'D4,8'D5:count_end=M_3;
	8'D6:count_end=M_3;
	8'D7:count_end=M_2;
   
	8'D8,8'D9:count_end=M_3;
	8'D10:count_end=M_3;
	8'D11:count_end=M_2;
	8'D12,8'D13:count_end=M_3;
	8'D14:count_end=L_6;
	8'D15:count_end=L_7;
	
	8'D16:count_end=M_1;
	8'D17:count_end=M_3;
	8'D18:count_end=M_2;
	8'D19:count_end=M_1;
	8'D20,8'D21:count_end=L_6;
	8'D22,8'D23:count_end=L_5;
	
	8'D24,8'D25,8'D26,8'D27,8'D28,8'D29,8'D30,8'D31:count_end=L_3;
	
	8'd32:count_end = L_6;  
	8'd33:count_end=M_1;
	8'd34:count_end=M_3;
	8'D35:count_end=M_5;
	8'D36,8'D37:count_end=M_3;
	8'D38:count_end=M_3;
	8'D39:count_end=M_2;
   
	8'D40,8'D41:count_end=M_3;
	8'D42:count_end=M_3;
	8'D43:count_end=M_2;
	8'D44,8'D45:count_end=M_3;
	8'D46:count_end=L_6;
	8'D47:count_end=L_7;
	
	8'D48:count_end=M_1;
	8'D49:count_end=M_3;
	8'D50:count_end=M_2;
	8'D51:count_end=M_1;
	8'D52,8'D53:count_end=L_6;
	8'D54,8'D55:count_end=L_5;
	
	8'D56,8'D57,8'D58,8'D59,8'D60,8'D61:count_end=L_6;
	8'D62:count_end=L_6;
	8'D63:count_end=L_7;
   default: count_end = 16'h0;
 
     
   endcase
   end
  if(!swtich)
  state<=0;
  
end
endmodule



