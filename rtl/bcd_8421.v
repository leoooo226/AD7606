`timescale  1ns/1ns
//=================================================================================
//  Author       ：la
//  Project name ：Gas Sensor on FPGA
//  Module Name  : bcd_8421
//  Created Time ：2022.5.13
//  Description  ：二进制数转BCD码
//=================================================================================
module  bcd_8421
(
    input   wire            pll_clk_33m          ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n            ,   //复位信号，低电平有效
    input   wire    [9:0]   data                 ,   //输入需要转换的数据

    output  reg     [3:0]   unit                 ,   //个位BCD码
    output  reg     [3:0]   ten                  ,   //十位BCD码
    output  reg     [3:0]   hun                      //百位BCD码

);

//--------------------------------------------------------------------------
//------------------------------参数和变量定义-------------------------------
//--------------------------------------------------------------------------

reg       [3:0]       cnt_shift                  ;   //移位判断计数器
reg       [21:0]      data_shift                 ;   //移位判断数据寄存器
reg                   shift_flag                 ;   //移位判断标志信号,flag=0判断，flag=1移位

//--------------------------------------------------------------------------
//---------------------------------Main Code--------------------------------
//--------------------------------------------------------------------------

//cnt_shift:从0到11循环计数，一次判断和移位需要两个周期，每两个周期自加一次
always@(posedge pll_clk_33m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_shift   <=  4'd0;
    else    if((cnt_shift == 4'd11) && (shift_flag == 1'b1))
        cnt_shift   <=  4'd0;
    else    if(shift_flag == 1'b1)
        cnt_shift   <=  cnt_shift + 1'b1;
    else
        cnt_shift   <=  cnt_shift;
       
//data_shift：计数器为0时赋初值，计数器为1~10时进行移位判断操作
always@(posedge pll_clk_33m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_shift  <=  22'b0;
    else    if(cnt_shift == 5'd0)
        data_shift  <=  {12'b0,data};
    else    if((cnt_shift <= 10) && (shift_flag == 1'b0))
        begin
            data_shift[13:10]   <=  (data_shift[13:10] > 4) ? (data_shift[13:10] + 2'd3) : (data_shift[13:10]);
            data_shift[17:14]   <=  (data_shift[17:14] > 4) ? (data_shift[17:14] + 2'd3) : (data_shift[17:14]);
            data_shift[21:18]   <=  (data_shift[21:18] > 4) ? (data_shift[21:18] + 2'd3) : (data_shift[21:18]);
        end
    else    if((cnt_shift <= 10) && (shift_flag == 1'b1))
        data_shift  <=  data_shift << 1;
    else
        data_shift  <=  data_shift;

//shift_flag：移位判断标志信号，用于控制移位判断的先后顺序
always@(posedge pll_clk_33m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        shift_flag  <=  1'b0;
    else
        shift_flag  <=  ~shift_flag;

//当计数器等于10时，移位判断操作完成，对各个位数的BCD码进行赋值
always@(posedge pll_clk_33m or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            unit    <=  4'b0;
            ten     <=  4'b0;
            hun     <=  4'b0;

        end
    else    if(cnt_shift == 4'd11)
        begin
            unit    <=  data_shift[13:10];
            ten     <=  data_shift[17:14];
            hun     <=  data_shift[21:18];
        end

endmodule