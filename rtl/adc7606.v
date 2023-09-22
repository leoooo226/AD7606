`timescale  1ns/1ns
//=================================================================================
//  Author       ：la
//  Project name ：Gas Sensor on FPGA
//  Module Name  : tft_ctrl
//  Created Time ：2022.5.16
//  Description  ：AD7606控制模块
//=================================================================================

module ad7606(
    input        		pll_clk_33m        ,              //50mhz
	input        		sys_rst_n          ,   
	   
	input [15:0] 		ad_data			   ,              //ad7606 采样数据
	input        		ad_busy		       ,              //ad7606 忙标志位 
	    
	output [2:0] 		ad_os		       ,              //ad7606 过采样倍率选择
	output reg   		ad_cs			   ,              //ad7606 AD cs
	output reg   		ad_rd			   ,              //ad7606 AD data read
	output reg   		ad_reset           ,              //ad7606 AD reset
	output reg   		ad_convstab        ,              //ad7606 AD convert start

	output reg [9:0] 	ch1				   ,              //AD第1通道的数据
	output reg [9:0] 	ch2				   ,              //AD第2通道的数据
	output reg [9:0] 	ch3				   ,              //AD第3通道的数据
	output reg [9:0] 	ch4				   ,              //AD第4通道的数据
	output reg [9:0] 	ch5				   ,              //AD第5通道的数据
	output reg [9:0] 	ch6				   ,              //AD第6通道的数据
	output reg [9:0] 	ch7				   ,              //AD第7通道的数据
	output reg [9:0] 	ch8				   ,              //AD第8通道的数据	
	output wire [9:0] 	ppm                               //气体浓度	
    );

//--------------------------------------------------------------------------
//------------------------------参数和变量定义-------------------------------
//--------------------------------------------------------------------------

reg [15:0]  			cnt				   ;
reg [5:0]   			i				   ;
reg [3:0]   			state			   ;

parameter 				IDLE=4'd0          ;
parameter 				AD_CONV=4'd1       ;
parameter 				Wait_1=4'd2        ;
parameter 				Wait_busy=4'd3     ;
parameter 				READ_CH1=4'd4      ;
parameter 				READ_CH2=4'd5      ;
parameter 				READ_CH3=4'd6      ;
parameter 				READ_CH4=4'd7      ;
parameter 				READ_CH5=4'd8      ;
parameter 				READ_CH6=4'd9      ;
parameter 				READ_CH7=4'd10     ;
parameter 				READ_CH8=4'd11     ;
parameter 				READ_DONE=4'd12    ;

reg [15:0] 				ad_ch1			   ;
reg [15:0] 				ad_ch2			   ;
reg [15:0] 				ad_ch3			   ;
reg [15:0] 				ad_ch4			   ;
reg [15:0] 				ad_ch5			   ;
reg [15:0] 				ad_ch6			   ;
reg [15:0] 				ad_ch7			   ;
reg [15:0] 				ad_ch8			   ;

//--------------------------------------------------------------------------
//---------------------------------Main Code--------------------------------
//--------------------------------------------------------------------------

assign ad_os=3'b000;

//AD 复位电路
always@(posedge pll_clk_33m or negedge sys_rst_n)
 begin
 		if(!sys_rst_n) begin
 			ad_reset<=1'b0; 
 			cnt<=16'h0;
 		end
    else if(cnt<16'h000f) begin
        cnt<=cnt+1'b1;
        ad_reset<=1'b1;
      end
      else
        ad_reset<=1'b0;       
   end

always @(posedge pll_clk_33m or negedge sys_rst_n) 
 begin
	 if (!sys_rst_n) begin 
			 state<=IDLE; 
			 ad_ch1<=0;
			 ad_ch2<=0;
			 ad_ch3<=0;
			 ad_ch4<=0;
			 ad_ch5<=0;
			 ad_ch6<=0;
			 ad_ch7<=0;
			 ad_ch8<=0;
			 ad_cs<=1'b1;
			 ad_rd<=1'b1; 
			 ad_convstab<=1'b1;
			 i<=0;
	 end
	 else 	 if (ad_reset) begin 
			 state<=IDLE; 
			 ad_ch1<=0;
			 ad_ch2<=0;
			 ad_ch3<=0;
			 ad_ch4<=0;
			 ad_ch5<=0;
			 ad_ch6<=0;
			 ad_ch7<=0;
			 ad_ch8<=0;
			 ad_cs<=1'b1;
			 ad_rd<=1'b1; 
			 ad_convstab<=1'b1;
			 i<=0;
	 end		 
	 else begin
		  case(state)
		  IDLE: begin
				 ad_cs<=1'b1;
				 ad_rd<=1'b1; 
				 ad_convstab<=1'b1; 
				 if(i==20) begin                         //等待20个clock
					 i<=0;			 
					 state<=AD_CONV;
				 end
				 else 
					 i<=i+1'b1;
		  end
		  AD_CONV: begin	   
				 if(i==2) begin                        //等待2个clock
					 i<=0;			 
					 state<=Wait_1;
					 ad_convstab<=1'b1;       				 
				 end
				 else begin
					 i<=i+1'b1;
					 ad_convstab<=1'b0;                     //启动AD转换
				 end
		  end
		  Wait_1: begin            
				 if(i==5) begin                           //等待5个clock, 等待busy信号为高
					 i<=0;
					 state<=Wait_busy;
				 end
				 else 
					 i<=i+1'b1;
		  end		 
		  Wait_busy: begin            
				 if(ad_busy==1'b0) begin                    //等待busy信号为低
					 i<=0;			 
					 state<=READ_CH1;
				 end
		  end
		  READ_CH1: begin 
				 ad_cs<=1'b0;                              //cs信号有效	  
				 if(i==3) begin
					 ad_rd<=1'b1;
					 i<=0;
					 ad_ch1<=ad_data;                        //读CH1
					 state<=READ_CH2;				 
				 end
				 else begin
					 ad_rd<=1'b0;	
					 i<=i+1'b1;
				 end
		  end
		  READ_CH2: begin 
				 if(i==3) begin
					 ad_rd<=1'b1;
					 i<=0;
					 ad_ch2<=ad_data;                        //读CH2
					 state<=READ_CH3;				 
				 end
				 else begin
					 ad_rd<=1'b0;	
					 i<=i+1'b1;
				 end
		  end
		  READ_CH3: begin 
				 if(i==3) begin
					 ad_rd<=1'b1;
					 i<=0;
					 ad_ch3<=ad_data;                        //读CH3
					 state<=READ_CH4;				 
				 end
				 else begin
					 ad_rd<=1'b0;	
					 i<=i+1'b1;
				 end
		  end
		  READ_CH4: begin 
				 if(i==3) begin
					 ad_rd<=1'b1;
					 i<=0;
					 ad_ch4<=ad_data;                        //读CH4
					 state<=READ_CH5;				 
				 end
				 else begin
					 ad_rd<=1'b0;	
					 i<=i+1'b1;
				 end
		  end
		  READ_CH5: begin 
				 if(i==3) begin
					 ad_rd<=1'b1;
					 i<=0;
					 ad_ch5<=ad_data;                        //读CH5
					 state<=READ_CH6;				 
				 end
				 else begin
					 ad_rd<=1'b0;	
					 i<=i+1'b1;
				 end
		  end
		  READ_CH6: begin 
				 if(i==3) begin
					 ad_rd<=1'b1;
					 i<=0;
					 ad_ch6<=ad_data;                        //读CH6
					 state<=READ_CH7;				 
				 end
				 else begin
					 ad_rd<=1'b0;	
					 i<=i+1'b1;
				 end
		  end
		  READ_CH7: begin 
				 if(i==3) begin
					 ad_rd<=1'b1;
					 i<=0;
					 ad_ch7<=ad_data;                        //读CH7
					 state<=READ_CH8;				 
				 end
				 else begin
					 ad_rd<=1'b0;	
					 i<=i+1'b1;
				 end
		  end
		  READ_CH8: begin 
				 if(i==3) begin
					 ad_rd<=1'b1;
					 i<=0;
					 ad_ch8<=ad_data;                        //读CH8
					 state<=READ_DONE;				 
				 end
				 else begin
					 ad_rd<=1'b0;	
					 i<=i+1'b1;
				 end
		  end
		  READ_DONE:begin
					 ad_rd<=1'b1;	 
					 ad_cs<=1'b1;
					 state<=IDLE;
		  end		
		  default:	state<=IDLE;
		  endcase	
    end	  

 end
//每隔一秒输出ad数据到tft
reg [26:0]  outputcnt;
always@(posedge pll_clk_33m or negedge sys_rst_n)begin
 	if(!sys_rst_n) begin
 		outputcnt<=27'b0;

	end
    else if(outputcnt== 27'd33333332)  begin      
        outputcnt<=27'b0;

	end
    else begin
        outputcnt<=outputcnt+1'b1;
 
	end    
   end



always@(posedge pll_clk_33m or negedge sys_rst_n)begin
 	if(!sys_rst_n)begin
		ch1<=10'd0;
		ch2<=10'd0;
		ch3<=10'd0;
		ch4<=10'd0;
		ch5<=10'd0;
		ch6<=10'd0;
		ch7<=10'd0;
		ch8<=10'd0;

	end
	else if(outputcnt== 27'd33333329) begin
		ch1<=21'b110010000000000000000/ad_ch1-10'd50;
		ch2<=21'b110010000000000000000/ad_ch2-10'd50;
		ch3<=21'b110010000000000000000/ad_ch3-10'd50;
		ch4<=21'b110010000000000000000/ad_ch4-10'd50;
		ch5<=21'b110010000000000000000/ad_ch5-10'd50;
		ch6<=21'b110010000000000000000/ad_ch6-10'd50;
		ch7<=21'b110010000000000000000/ad_ch7-10'd50;
		ch8<=21'b110010000000000000000/ad_ch8-10'd50;
	end
	
	else begin
		ad_ch1<=ad_ch1;
		ad_ch2<=ad_ch2;
		ad_ch3<=ad_ch3;
		ad_ch4<=ad_ch4;
		ad_ch5<=ad_ch5;
		ad_ch6<=ad_ch6;
		ad_ch7<=ad_ch7;
		ad_ch8<=ad_ch8;

		ch1<=ch1;
		ch2<=ch2;
		ch3<=ch3;
		ch4<=ch4;
		ch5<=ch5;
		ch6<=ch6;
		ch7<=ch7;
		ch8<=ch8;


	end
	end
assign ppm=ch1;
endmodule
