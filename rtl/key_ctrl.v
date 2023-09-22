`timescale  1ns/1ns
//=================================================================================
//  Author       ：la
//  Project name ：Gas Sensor on FPGA
//  Module Name  : tft_ctrl
//  Created Time ：2022.5.16
//  Description  ：AD7606控制模块
//=================================================================================

module  key_ctrl
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //系统复位，低电平有效
    input   wire            key_flag    ,   //按键消抖标志信号
    input   wire    [9:0] 	ch1			,   //AD第1通道的数据
	input   wire    [9:0] 	ch2			,   //AD第2通道的数据
	input   wire    [9:0] 	ch3			,   //AD第3通道的数据
	input   wire    [9:0] 	ch4			,   //AD第4通道的数据

    output  reg     [9:0]   data_out     ,       //输出数据给lcd显示
    output  reg     [2:0]   data_flag    
);


//********************************************************************//
//******************************* Main Code **************************//
//********************************************************************//

//data_flag：数据切换标志信号
always@(posedge sys_clk or  negedge sys_rst_n)begin
    if(sys_rst_n == 1'b0)
        data_flag    <=  2'd0;
    else    if(key_flag == 1'b1)
        data_flag    <=  data_flag+2'b1;
    else    if(key_flag == 1'b1&&data_flag==3'd4)
        data_flag    <=  1'd0; 
    else    
        data_flag    <=  data_flag; 
end     

//data_out:输出数码管显示数据
always@(posedge sys_clk or  negedge sys_rst_n)begin
    if(sys_rst_n == 1'b0)
        data_out    <=  ch1;
    else    if(data_flag == 2'd0)
        data_out    <=  ch1;
    else    if(data_flag == 2'd1)
        data_out    <=  ch2;
    else    if(data_flag == 2'd2)
        data_out    <=  ch3;
    else    if(data_flag == 2'd3)
        data_out    <=  ch4;
   else
        data_out    <=  ch1;
end

endmodule
