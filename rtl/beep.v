`timescale  1ns/1ns
//=================================================================================
//  Author       ：la
//  Project name ：Gas Sensor on FPGA
//  Module Name  : beep
//  Created Time ：2022.7.15
//  Description  ：报警
//=================================================================================

module  beep(
    input   wire              sys_clk     ,   //系统时钟,频率33MHz
    input   wire              sys_rst_n   ,   //系统复位，低有效
    input   wire    [15:0]    ad_data     ,

    output  reg                beep            //输出蜂鸣器控制信号
);

parameter   DO  =   18'd127226 ;   //"哆"音调分频计数值（频率262）
reg        [17:0]  freq_cnt    ;   //音调计数器
wire       [17:0]  freq_data   ;   //音调分频计数值
wire       [16:0]  duty_data   ;   //占空比计数值

always@(posedge sys_clk or  negedge sys_rst_n)
    if(!sys_rst_n)
        freq_cnt    <=  18'd0;
    else    if(freq_cnt == freq_data)
        freq_cnt    <=  18'd0;
    else
        freq_cnt    <=  freq_cnt +  1'b1;

//设置50％占空比：音阶分频计数值的一半即为占空比的高电平数
assign  duty_data   =  freq_data>> 1'b1;
assign  freq_data   =  DO;


//beep：输出蜂鸣器波形
always@(posedge sys_clk or  negedge sys_rst_n)
    if(!sys_rst_n)
        beep    <=  1'b1;
    else    if(freq_cnt >= duty_data && ad_data>16'd200)
        beep    <=  1'b0;
    else
        beep    <=  1'b1;

endmodule
