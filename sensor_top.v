//=================================================================================
//  Author       ：la
//  Project name ：Gas Sensor on FPGA
//  Module Name  : top
//  Created Time ：2022.5.16
//  Description  ：用AD7606采集4路传感器数据，经过数据处理之后送入LCD进行显示
//=================================================================================
`timescale 1ns/1ns

module  sensor_top(
    //system signal
    input  wire                 sys_clk_50m                         ,
    input  wire                 sys_rst_n                           ,    
    //AD7606
    input  wire     [15:0]      ad_data                             ,   // AD7606测量数据                                 
    input  wire                 ad_busy                             ,    
    input  wire    key2                                            ,   //按键输入信号
    output wire     [ 2:0]      ad_os                               ,
    output wire                 ad_cs                               ,      
    output wire                 ad_rd                               ,      
    output wire                 ad_reset                            ,   
    output wire                 ad_convstab                         ,
    //TFT
    output  wire    [23:0]      rgb_tft                             ,   //TFT显示数据
    output  wire                hsync                               ,   //TFT行同步信号
    output  wire                vsync                               ,   //TFT场同步信号
    output  wire                tft_clk                             ,   //TFT像素时钟
    output  wire                tft_de                              ,   //TFT数据使能
    output  wire                tft_bl                              ,    //TFT背光信号
    output  wire                 beep
    );

    //--------------------------------------------------------------------------
    //------------------------------参数和变量定义-------------------------------
    //--------------------------------------------------------------------------

    wire     [  9:0]            ch8                                 ;
    wire     [  9:0]            ch1                                 ;
    wire     [  9:0]            ch2                                 ;
    wire     [  9:0]            ch3                                 ;
    wire     [  9:0]            ch4                                 ;
    wire     [  9:0]            ch5                                 ;
    wire     [  9:0]            ch6                                 ;
    wire     [  9:0]            ch7                                 ;
    wire     [  9:0]            ppm                                 ;

    wire     [  0:0]            pll_clk_33m                         ;

    wire     [  3:0]            unit1                               ;
    wire     [  3:0]            ten1                                ;
    wire     [  3:0]            hun1                                ;

    wire     [  3:0]            unit5                               ;
    wire     [  3:0]            ten5                                ;
    wire     [  3:0]            hun5                                ;

    wire     [  3:0]            unit2                               ;
    wire     [  3:0]            ten2                                ;
    wire     [  3:0]            hun2                                ;

    wire     [  3:0]            unit3                               ;
    wire     [  3:0]            ten3                                ;
    wire     [  3:0]            hun3                                ;

    wire     [  3:0]            unit4                               ;
    wire     [  3:0]            ten4                                ;
    wire     [  3:0]            hun4                                ;
    wire     [ 23:0]            pix_data                            ; 

    wire     [ 10:0]            pix_x                               ;
    wire     [ 10:0]            pix_y                               ;
    wire                        q                                   ;
    wire                        key_flag                            ;
    wire     [  2:0]            data_flag                           ;
    wire     [  9:0]            data_out                            ;
    //-----------------------------------------------------------------------
    //---------------------------------模块例化-------------------------------
    //-----------------------------------------------------------------------  

    pll_clk                     pll_clk_init(
	    .areset                 (                  ~sys_rst_n)      ,
	    .inclk0                 (                 sys_clk_50m)      ,
	    .c0                     (                 pll_clk_33m)      ,
	    .locked                 (                            )  
    );  


    // 例化AD7606模块：
    ad7606                      ad7606_init(  
        .pll_clk_33m            (                 pll_clk_33m)      ,
        .sys_rst_n              (                   sys_rst_n)      ,
              
        .ad_data                (                     ad_data)      ,
        .ad_busy                (                     ad_busy)      ,       
        .ad_os                  (                       ad_os)      ,
        .ad_cs                  (                       ad_cs)      ,      
        .ad_rd                  (                       ad_rd)      ,      
        .ad_reset               (                    ad_reset)      ,   
        .ad_convstab            (                 ad_convstab)      ,       
        .ch1                    (                         ch1)      ,
        .ch2                    (                         ch2)      ,
        .ch3                    (                         ch3)      ,
        .ch4                    (                         ch4)      ,
        .ch5                    (                         ch5)      ,
        .ch6                    (                         ch6)      ,
        .ch7                    (                         ch7)      ,
        .ch8                    (                         ch8)      ,
        .ppm                    (                         ppm)
    );

    // 例化BCD_8421模块：
    bcd_8421                    bcd_8421ch1(
        .pll_clk_33m            (                 pll_clk_33m)      ,//系统时钟，频率50MHz
        .sys_rst_n              (                   sys_rst_n)      ,//复位信号，低电平有效
        .data                   (                         ch1)      ,//输入需要转换的数据
  
        .unit                   (                       unit1)      ,//个位BCD码
        .ten                    (                        ten1)      ,//十位BCD码
        .hun                    (                        hun1)       //百位BCD码
        );
    bcd_8421                    bcd_8421ch2(
        .pll_clk_33m            (                 pll_clk_33m)      ,//系统时钟，频率50MHz
        .sys_rst_n              (                   sys_rst_n)      ,//复位信号，低电平有效
        .data                   (                         ch2)      ,//输入需要转换的数据
  
        .unit                   (                       unit2)      ,//个位BCD码
        .ten                    (                        ten2)      ,//十位BCD码
        .hun                    (                        hun2)       //百位BCD码
        );
    bcd_8421                    bcd_8421ch3(
        .pll_clk_33m            (                 pll_clk_33m)      ,//系统时钟，频率50MHz
        .sys_rst_n              (                   sys_rst_n)      ,//复位信号，低电平有效
        .data                   (                         ch3)      ,//输入需要转换的数据
  
        .unit                   (                       unit3)      ,//个位BCD码
        .ten                    (                        ten3)      ,//十位BCD码
        .hun                    (                        hun3)       //百位BCD码
        );    
    bcd_8421                    bcd_8421ch4(
        .pll_clk_33m            (                 pll_clk_33m)      ,//系统时钟，频率50MHz
        .sys_rst_n              (                   sys_rst_n)      ,//复位信号，低电平有效
        .data                   (                         ch4)      ,//输入需要转换的数据
  
        .unit                   (                       unit4)      ,//个位BCD码
        .ten                    (                        ten4)      ,//十位BCD码
        .hun                    (                        hun4)       //百位BCD码
        ); 

    bcd_8421                    bcd_8421ppm(
        .pll_clk_33m            (                 pll_clk_33m)      ,//系统时钟，频率50MHz
        .sys_rst_n              (                   sys_rst_n)      ,//复位信号，低电平有效
        .data                   (                         ppm)      ,//输入需要转换的数据
  
        .unit                   (                       unit5)      ,//个位BCD码
        .ten                    (                        ten5)      ,//十位BCD码
        .hun                    (                        hun5)       //百位BCD码
        ); 
    // 例化TFT_pic模块：
    tft_pic                     tft_pic_init(
        .tft_clk_33m            (                 pll_clk_33m)      ,               //输入工作时钟,频率33MHz
        .sys_rst_n              (                   sys_rst_n)      ,               //输入复位信号,低电平有效
        .pix_x                  (                 pix_x      )      ,               //输入TFT有效显示区域像素点X轴坐标
        .pix_y                  (                 pix_y      )      ,               //输入TFT有效显示区域像素点Y轴坐标

        .ch1                    (                 ch1        )      ,               //AD数据
        .unit1                  (                 unit1      )      ,               //个位BCD码
        .ten1                   (                 ten1       )      ,               //十位BCD码
        .hun1                   (                 hun1       )      ,               //百位BCD码

        .ch2                    (                 ch2        )      ,               //AD数据
        .unit2                  (                 unit2      )      ,               //个位BCD码
        .ten2                   (                 ten2       )      ,               //十位BCD码
        .hun2                   (                 hun2       )      ,               //百位BCD码  

        .ch3                    (                 ch3        )      ,               //AD数据
        .unit3                  (                 unit3      )      ,               //个位BCD码
        .ten3                   (                 ten3       )      ,               //十位BCD码
        .hun3                   (                 hun3       )      ,               //百位BCD码

        .ch4                    (                 ch4        )      ,               //AD数据
        .unit4                  (                 unit4      )      ,               //个位BCD码
        .ten4                   (                 ten4       )      ,               //十位BCD码
        .hun4                   (                 hun4       )      ,               //百位BCD码   

        .unit5                  (                 unit5      )      ,               //个位BCD码
        .ten5                   (                 ten5       )      ,               //十位BCD码
        .hun5                   (                 hun5       )      ,               //百位BCD码   
        .data_out               (                 data_out       )      ,             //输出数据给lcd显示
        .data_flag              (                 data_flag       )      , 

        .pix_data               (                 pix_data)                         //输出像素点色彩信息
        );  
    // 例化TFT_ctrl模块：
    tft_ctrl                    tft_ctrl_init(
        .tft_clk_33m            (                 pll_clk_33m)      ,   //输入时钟,频率33MHz
        .sys_rst_n              (                   sys_rst_n)      ,   //系统复位,低电平有效
        .pix_data               (                    pix_data)      ,   //待显示数据

        .pix_x                  (                 pix_x      )      ,   //输出TFT有效显示区域像素点X轴坐标
        .pix_y                  (                 pix_y      )      ,   //输出TFT有效显示区域像素点Y轴坐标
        .rgb_tft                (                 rgb_tft    )      ,   //TFT显示数据
        .hsync                  (                 hsync      )      ,   //TFT行同步信号
        .vsync                  (                 vsync      )      ,   //TFT场同步信号
        .tft_clk                (                 tft_clk    )      ,   //TFT像素时钟
        .tft_de                 (                 tft_de     )      ,   //TFT数据使能
        .tft_bl                 (                 tft_bl     )          //TFT背光信号
        );

    beep                        beep_init(
        .sys_clk                (                 pll_clk_33m)      ,   //系统时钟,频率33MHz
        .sys_rst_n              (                   sys_rst_n)      ,   //系统复位，低有效
        .ad_data                (                     ad_data)      ,
      
        . beep                  (                   beep     )           //输出蜂鸣器控制信号
);      
    key_filter                  key_filter1(      
        .sys_clk                (                 pll_clk_33m)      ,   //系统时钟50Mhz
        .sys_rst_n              (                 sys_rst_n  )      ,   //全局复位
        .key2                   (                 key2       )      ,   //按键输入信号        
        .key_flag               (                 key_flag   )           //key_flag为1时表示消抖后检测到按键被按下
                                                                         //key_flag为0时表示没有检测到按键被按下
    );            
    key_ctrl                               key_ctrl1(
        . sys_clk               (                 pll_clk_33m)      ,   //系统时钟，频率50MHz
        . sys_rst_n             (                 sys_rst_n  )      ,   //系统复位，低电平有效
        . key_flag              (                 key_flag   )      ,   //按键消抖标志信号
        .	ch1		            (                 ch1        )      ,   //AD第1通道的数据
    	.	ch2		            (                 ch2        )      ,   //AD第2通道的数据
    	.	ch3		            (                 ch3        )      ,   //AD第3通道的数据
    	.	ch4		            (                 ch4        )      ,   //AD第4通道的数据  
        .data_flag              (                 data_flag  )      ,
        .data_out               (                 data_out   )          //输出数据给lcd显示
        
    );

endmodule
