`timescale  1ns/1ns
//=================================================================================
//  Author       ：la
//  Project name ：Gas Sensor on FPGA
//  Module Name  : tft_pic
//  Created Time ：2022.5.12
//  Description  ：文字和图像生成模块
//=================================================================================

module  tft_pic
(
    input   wire             tft_clk_33m  ,               //输入工作时钟,频率33MHz
    input   wire             sys_rst_n    ,               //输入复位信号,低电平有效
    input   wire    [10:0]   pix_x        ,               //输入TFT有效显示区域像素点X轴坐标
    input   wire    [10:0]   pix_y        ,               //输入TFT有效显示区域像素点Y轴坐标

    input   wire    [9:0]    ch1          ,               //AD数据
    input   wire    [3:0]    unit1        ,               //个位BCD码
    input   wire    [3:0]    ten1         ,               //十位BCD码
    input   wire    [3:0]    hun1         ,               //百位BCD码

    input   wire    [9:0]    ch2          ,               //AD数据
    input   wire    [3:0]    unit2        ,               //个位BCD码
    input   wire    [3:0]    ten2         ,               //十位BCD码
    input   wire    [3:0]    hun2         ,               //百位BCD码  

    input   wire    [9:0]    ch3          ,               //AD数据
    input   wire    [3:0]    unit3        ,               //个位BCD码
    input   wire    [3:0]    ten3         ,               //十位BCD码
    input   wire    [3:0]    hun3         ,               //百位BCD码

    input   wire    [9:0]    ch4          ,               //AD数据
    input   wire    [3:0]    unit4        ,               //个位BCD码
    input   wire    [3:0]    ten4         ,               //十位BCD码
    input   wire    [3:0]    hun4         ,               //百位BCD码   

    output  reg     [23:0]   pix_data                     //输出像素点色彩信息
);          

//--------------------------------------------------------------------------
//------------------------------参数和变量定义-------------------------------
//--------------------------------------------------------------------------

parameter   H_VALID =   11'd800            ,              //行有效数据
            V_VALID =   11'd480            ;              //场有效数据

                 
parameter   BLACK   =  24'h000000          ,              //黑色
            GOLDEN  =  24'hffff00          ,              //金色
            WHITE   =  24'hffffff          ;              //白色 


//------------------------------------------------------------------------------
//---------------------------------------CH1------------------------------------
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
//--------------------------------------CH2-------------------------------------
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
//--------------------------------------CH3-------------------------------------
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
//--------------------------------------CH4-------------------------------------
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
//-----------------------------------AD图像显示----------------------------------
//------------------------------------------------------------------------------
parameter CNT_MAX = 25'd33_333_332;
reg [799:0] char8 [399:0];
reg [24:0] cnt ;
reg cnt_flag ;
reg [9:0] charx ;

always@(posedge tft_clk_33m or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt   <= 25'd0;
    else if(cnt == CNT_MAX)
        cnt <= 25'b0;
    else
        cnt <= cnt + 1'b1;

 always@(posedge tft_clk_33m or negedge sys_rst_n)
    if(!sys_rst_n)
        cnt_flag <= 1'b0;
    else if(cnt == CNT_MAX - 1)
        cnt_flag <= 1'b1;
    else
        cnt_flag <= 1'b0;

 always@(posedge tft_clk_33m or negedge sys_rst_n)
    if(!sys_rst_n)
        charx <= 10'd0;
    else if(charx == 10'd799 && cnt_flag == 1'b1)
        charx <= 10'd0;
    else if(cnt_flag == 1'b1)
        charx <= charx +10'd1;

integer i;
//reg [8:0] i;  
 always@(posedge tft_clk_33m or negedge sys_rst_n)
    if(!sys_rst_n)
        for (i=0;i<=359;i=i+1)
            char8[i] <= 800'b0;
    else
        char8[10'd400 - ch1][10'd799-charx]<= 1'b1;

//----------------------------------------------------------------------------------------------
//-----------------------------------pix_data:输出像素点色彩信息----------------------------------
//----------------------------------------------------------------------------------------------
always@(posedge tft_clk_33m or negedge sys_rst_n)begin
    if(!sys_rst_n)
        pix_data    <= BLACK;
//AD图像        
    else    if(((pix_x >= 10'd0) && (pix_x < ( 10'd800)))
                && ((pix_y >= 10'd40) && (pix_y <  10'd400)))
    begin
            if(char8[10'd400 - ch1][10'd799-charx] == 1'b1)
                pix_data    <=  WHITE;
            else
                pix_data    <=  BLACK;
    end
//分割线        
    else    if(pix_y==11'd40)
                pix_data    <=  GOLDEN;
    else    if(pix_y==11'd400)
                pix_data    <=  GOLDEN;   
    else
        pix_data    <=  BLACK;
end


endmodule
