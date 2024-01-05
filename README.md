

Authors:111321005鍾亦翰 111321024林秉儀
1. Input/Ouput unit:
* 初始畫面，方塊會從圖片上方落下
<img src="images/wahhh" alt="My Image" width="200">
<!-- ![image](images/wahhh) -->
<!--
<div align="center">
	<img src="./images/IMG_4617.jpg" alt="Editor" width="200">
</div>
-->
* LED燈顯示累計消掉條數
<img src="images/IMG_4617.jpg" alt="My Image" width="200">
* 七段顯示器顯示目前等級，跟消掉條數有關，用於控制方塊掉落速度
<img src="images/IMG_4618.jpg" alt="My Image" width="200">
* 結束畫面
<img src="images/IMG_4620.jpg" alt="My Image" width="200">

* 旋轉、左移、右移、加速下降 -> 接到4-bit SW
* seg[0:6] -> 接到七段顯示器
* line[0:7] -> LED
* DATA_R,DATA_G,DATA_B -> 接到8x8LED
* enable,com[0:2] -> 接到8x8LED控制
* 
遊戲說明：規則同俄羅斯方塊。方塊由上落下，一整排集滿會消掉，LED顯示條數加一。預設每消三條等級升一等。四個按鈕由左而右依序控制旋轉、左移、右移、加速下降。堆疊到頂部後遊戲結束，顯示結束畫面。
