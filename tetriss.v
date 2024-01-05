module tetriss(//input Count,
			output reg [7:0] DATA_R, DATA_G, DATA_B,//紅綠藍三色燈
			output reg [2:0] COMM,
			output reg [2:0] s = 3'b000,	// 方塊形狀索引
			output reg [2:0] s4 = 3'b000,	// 方塊形狀索引（用於計時）
			input change, left, right, down,//旋轉、左移、右移、加速下落按鈕
			output enable,	
			output reg [0:1] point = 2'b00,	//經驗值
			output reg [0:6] seg = 7'b0000001,	//七段顯示器用於顯示目前等級
			output reg [0:7] line =8'b00101101,	//消除條數
			input CLK);	
			
	assign enable = 1'b1;
	reg newblock;
	int level = 0;	//等級，控制下墜速度

			
	var bit [7:0][7:0] blank_Char = '{8'b11111111,
												 8'b11111111,
												 8'b11111111,
												 8'b11111111,
												 8'b11111111,
												 8'b11111111,
												 8'b11111111,
												 8'b11111111};
												 
	var bit [0:7][0:7] die_Char='{8'b00111111,	//遊戲結束時顯示
											8'b00111111,
											8'b00001111,
											8'b00000000,
											8'b00000000,
											8'b00001111,
											8'b00111111,
											8'b00111111}; 
	var bit [0:10][0:11] front_Char = '{12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111};
	var bit [0:10][0:11] blank_front_Char = '{12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111};
	var bit [0:10][0:11] back_Char = '{12'b111111111111,
												  12'b111111111111,
												  12'b111111111111,
												  12'b111111111111,
												  12'b111111111111,
												  12'b111111111111,
												  12'b111111111111,
												  12'b111111111111,
												  12'b111111111111,
												  12'b111111111111,
												  12'b111111111111};
	var bit [0:10][0:11] backup_Char = '{12'b111111111111,
													 12'b111111111111,
													 12'b111111111111,
													 12'b111111111111,
													 12'b111111111111,
													 12'b111111111111,
													 12'b111111111111,
													 12'b111111111111,
													 12'b111111111111,
													 12'b111111111111,
													 12'b111111111111};
	var bit [0:10][0:11] back_test_Char = '{12'b111111111111,
														 12'b111111111111,
														 12'b111111111111,
														 12'b111111111111,
														 12'b111111111111,
														 12'b111111111111,
														 12'b111111111111,
														 12'b111111111111,
														 12'b111111111111,
														 12'b111111111111,
														 12'b111111111111};
	var bit [0:10][0:11] front_test_Char = '{12'b111111111111,
														  12'b111111111111,
														  12'b111111111111,
														  12'b111111111111,
														  12'b111111111111,
														  12'b111111111111,
														  12'b111111111111,
														  12'b111111111111,
														  12'b111111111111,
														  12'b111111111111,
														  12'b111111111111};
	var bit [0:10][0:11] back_test_two_Char = '{12'b111111111111,
															  12'b111111111111,
															  12'b111111111111,
															  12'b111111111111,
															  12'b111111111111,
															  12'b111111111111,
															  12'b111111111111,
															  12'b111111111111,
															  12'b111111111111,
															  12'b111111111111,
															  12'b111111111111};
	var bit [0:10][0:11] over_Char =  '{12'b111111111111,
													12'b111111111111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111111111};
	
	parameter logic [0:3] tetris [0:127] = '{//七種方塊和他的四種型態(旋轉)	
													  //..
													  4'b1111,
													  4'b1111,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b1111,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b1111,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b1111,
													  4'b0111,
													  4'b1111,
													  //I
													  4'b1111,
													  4'b0111,
													  4'b0111,
													  4'b0111,
													  
													  4'b1111,
													  4'b1111,
													  4'b0001,
													  4'b1111,
													  
													  4'b1111,
													  4'b0111,
													  4'b0111,
													  4'b0111,
													  
													  4'b1111,
													  4'b1111,
													  4'b0001,
													  4'b1111,
													  //J
													  4'b1011,
													  4'b1011,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0111,
													  4'b0001,
													  4'b1111,
													  
													  4'b0011,
													  4'b0111,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b0001,
													  4'b1101,
													  4'b1111,
													  //L
													  4'b0111,
													  4'b0111,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0001,
													  4'b0111,
													  4'b1111,
													  
													  4'b0011,
													  4'b1011,
													  4'b1011,
													  4'b1111,
													  
													  4'b1111,
													  4'b1101,
													  4'b0001,
													  4'b1111,
													  //O
													  4'b1111,
													  4'b0011,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0011,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0011,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0011,
													  4'b0011,
													  4'b1111,
													  //S
													  4'b1111,
													  4'b1001,
													  4'b0011,
													  4'b1111,
													  
													  4'b0111,
													  4'b0011,
													  4'b1011,
													  4'b1111,
													  
													  4'b1111,
													  4'b1001,
													  4'b0011,
													  4'b1111,
													  
													  4'b0111,
													  4'b0011,
													  4'b1011,
													  4'b1111,
													  //T
													  4'b1111,
													  4'b1011,
													  4'b0001,
													  4'b1111,
													  
													  4'b0111,
													  4'b0011,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b0001,
													  4'b1011,
													  4'b1111,
													  
													  4'b1011,
													  4'b0011,
													  4'b1011,
													  4'b1111,
													  //Z
													  4'b1111,
													  4'b0011,
													  4'b1001,
													  4'b1111,
													  
													  4'b1011,
													  4'b0011,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b0011,
													  4'b1001,
													  4'b1111,
													  
													  4'b1011,
													  4'b0011,
													  4'b0111,
													  4'b1111};
	
	divfreq F0 (CLK, CLK_div);
	divfreq2 F1 (CLK, CLK_div2);
	divfreq_change F2 (CLK, CLK_div_change);
	byte count;
	int x;
	int y;
	reg [0:1] rotate = 2'b00;
	int over;
	int tim;
	int clean_flag;

	initial
		begin
			count = 0;
			DATA_R = 8'b11111111;
			DATA_G = 8'b11111111;
			DATA_B = 8'b11111111;
			newblock <= 0;
			x = 5;
			y = 9;
			rotate = 0;
			s <= s4%8;
			over = 0;
			seg <= 7'b0000001;
			line <= 8'b00101101;
			level = 3;
			tim=0;
		end
	
	always @(posedge CLK_div)// update screen
		begin
			if(count >= 7)
				count <= 0;
			else
				count <= count+1;
			COMM <= count;
			
			
			if(newblock)
			begin
				//testled <= 1'b0;
				back_Char <= back_Char&front_Char;
				s <= s4%7; //get new block
				
				
				//clean whole line
				for(int j=0;j<8;j++)
				begin
					clean_flag = 1;
					for(int i=2;i<10;i++)
						if(back_Char[i][j]==1'b1)
							clean_flag = 0;
					
					//if((~clean_Char&~back_Char)==(~clean_Char)) //old
					if(clean_flag)			//判斷是否需要整條消除
					begin
						line+=1'b1;	//消除條數+1
						//buzz<=1;
						if(tim<500)
						begin
							tim=tim+1;
						end
						tim=0;
						for(int i=0;i<11;i++)
							begin
								for(int element=j;element<7;element++)
									back_Char[i][element] <= back_Char[i][element+1];
								back_Char[i][7] <= 1'b1;
							end
						//point max -> level up (speed up)
						if(point == 2'b11)//if you want to level up quickly, change to 8'b10000000 will level up very fast and easy
						begin
							level = level + 1;
							point <= 2'b00;
							
						end
						//level plus
						else
							point <= {1'b1, point[0]};
					end
					//buzz<=0;
				end
				
				//game over
				if(~over_Char&~back_Char) //vector "every bit AND", a quickly way
				begin
					front_Char <= blank_front_Char;
					back_Char <= blank_front_Char;
					over = 1;
					point <= 2'b00;
					level = 0;
					line=0;
				end
				
			end
			
			//clean
			front_Char <= blank_front_Char;
			//GAME OVER will NOT show new blocks, windows cry only
			if(over==0)
			begin
			for(int i=0;i<4;i++)
				begin
					front_Char[x+i][y+:4] <= tetris[s*16+i+rotate*4];
				end
			end
			
			//print
			//DATA_B <= clean_Char[count+2][0:7];
			DATA_R <= front_Char[count+2][0:7];
			DATA_G <= back_Char[count+2][0:7];
			
			//print level number(seg)
			if(level==0)
				seg <= 7'b0000001;
			else if(level==1)
				seg <= 7'b1001111;
			else if(level==2)
				seg <= 7'b0010010; 
			else if(level==3)
				seg <= 7'b0000110;
			else if(level==4)
				seg <= 7'b1001100;
			else if(level==5)
				seg <= 7'b0100100; 
			else if(level==6)
				seg <= 7'b0100000;
			else if(level==7)
				seg <= 7'b0001111;
			else if(level==8)
				seg <= 7'b0000000;
			else if(level==9)
				seg <= 7'b0000100;
			else
				seg <= 7'b0000000;
			
			//print GAME OVER :(
			if(over>0&&over<50000)		//顯示50000ms遊戲結束圖示
			begin
				DATA_B <= die_Char[count];
				DATA_G <= die_Char[count];
				DATA_R <= ~die_Char[count];
				//DATA_R <= blank_Char[count];
				over++;
			end
			else if(over>=50000)
			begin
				DATA_B <= 8'b11111111;
				over=0;
			end
			//prepare for touch check
			for(int i=0;i<11;i++)
			begin
				back_test_Char[i] <= {1'b0, back_Char[i][0:7],3'b111};
				back_test_two_Char[i] <= {2'b00, back_Char[i][0:5],4'b1111};
				front_test_Char[i] <= {front_Char[i][0:8],3'b111};
			end
			
		end
	always @(posedge CLK_div2)// quickly add number as random base
		begin
			s4 <= s4 + 1'b1;
		end
	
	always @(posedge CLK_div_change)
		begin
			if(over==0)
			begin
				int count = 0;
				int dcount = 0;
				int slow = 0;
				//user input
				if(slow > 10)
				begin
					slow = 0;
					if(change)
					begin
						rotate <= rotate + 1'b1;
					end
					else if(left && front_Char[2]==12'b111111111111)
						x = x - 1;
					else if(right && front_Char[9]==12'b111111111111)
						x = x + 1;
				end
				else
					slow++;
				
				if(newblock==1)
					newblock<=0;
				else if (down && y > 0 && (~(~front_test_Char[10] & ~back_test_two_Char[10]) && dcount == 0))
				  begin
						y = y - 1;
						dcount = 1;
						count = 0;
				  end
				else if(count>40 - 4*level)
				begin
					count <= 0;
					dcount = 1;
					
					if(~front_test_Char&~back_test_Char)
						begin
							newblock <= 1;
							x = 5;
							y = 9;
							rotate <= 0;
						end	
					else if(y>0)
						y = y - 1;
					else
					begin
						newblock <= 1;
						x = 5;
						y = 9;
						rotate <= 0;
				end
			end
			else
				count++;
			
			//prevent user full down too fast
			if(dcount>20&&~(~front_test_Char&~back_test_two_Char))
				dcount = 0;
			else if(~(~front_test_Char&~back_test_two_Char))
				dcount = dcount + 1;
			else
				dcount = 0;
			
			//fix tetris overflow
			if(x==1 && tetris[s*16+rotate*4]!=4'b1111)
				x = x + 1;
			if(x==0 && s==0 && (rotate==0||rotate==2))
				x = x + 2;
			else if(x==-1 && s==0 && (rotate==0||rotate==2))
				x = x + 3;
		
			end
		end
		
endmodule

//update front and do lots of things immediately
module divfreq(input CLK, output reg CLK_div);
reg [24:0] Count;
always @(posedge CLK)
begin
	if(Count > 1000)//2000
		begin
			Count <= 25'b0;
			CLK_div <= ~CLK_div;
		end
		else
			Count <= Count + 1'b1;
end
endmodule

//generate random number
module divfreq2(input CLK, output reg CLK_div2);
reg [24:0] Count;
always @(posedge CLK)
begin
	if(Count >= 333)	//333
		begin
			Count <= 25'b0;
			CLK_div2 <= ~CLK_div2;
		end
		else
			Count <= Count + 1'b1;
end
endmodule

//tetris full down speed
module divfreq_change(input CLK, output reg CLK_div_change);
reg [24:0] Count;
always @(posedge CLK)
begin
	if(Count >= 300000)
		begin
			Count <= 25'b0;
			CLK_div_change <= ~CLK_div_change;
		end
		else
			Count <= Count + 1'b1;
end
endmodule
