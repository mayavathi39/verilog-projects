`timescale 1ns/1ps 
module alarm_clock(
 input reset,clk, 
input [1:0]H_in1, input [3:0]H_in0,M_in1,M_in0, 
input LD_time,LD_alarm,STOP_al,AL_ON, 
output reg Alarm, 
output [3:0] H_out1,H_out0,M_out1,M_out0,S_out1,S_out0 ); 
localparam integer CLK_DIV = 27'd100000000; 
reg [26:0] div_cnt = 0; 
reg clk_1hz = 0; 
wire one_hz_tick;  
// a single-cycle tick at clk when div_cnt reaches CLK_DIV-1 
always @(posedge clk or posedge reset) begin 
if (reset) begin 
div_cnt <= 0; 
clk_1hz <= 0; 
end 
else begin 
if (div_cnt == CLK_DIV - 1) begin 
div_cnt <= 0; 
clk_1hz <= ~clk_1hz; 
end 
else begin 
div_cnt <= div_cnt + 1; 
end 
end 
end 
assign one_hz_tick = (div_cnt == CLK_DIV - 1);
 // --- internal registers for time & alarm 
reg [5:0] hour, minute, second; 
reg [5:0] alarm_hour, alarm_minute, alarm_second; 
reg [5:0] alarm_timer = 6'd0; 
always @(posedge clk or posedge reset) begin 
if (reset) begin 
hour <= 6'd0; 
minute <= 6'd0; 
second <= 6'd0; 
alarm_hour <= 6'd0; 
alarm_minute <= 6'd0; 
alarm_second <= 6'd0; 
Alarm <= 1'b0; 
end 
else begin 
if (LD_time) begin 
hour <= H_in1 * 6'd10 + H_in0; 
minute <= M_in1 * 6'd10 + M_in0; 
second <= 6'd0; 
end 
else if (one_hz_tick) begin 
if (second == 6'd59) begin 
second <= 6'd0; 
if (minute == 6'd59) begin 
minute <= 6'd0; 
if (hour == 6'd23) begin 
hour <= 6'd0; 
end 
else begin 
hour <= hour + 6'd1; 
end 
end 
else begin 
minute <= minute + 6'd1; 
end 
end 
else begin 
second <= second + 6'd1; 
end 
end 
// Load alarm 
if (LD_alarm) begin 
alarm_hour <= H_in1 * 6'd10 + H_in0;
 alarm_minute <= M_in1 * 6'd10 + M_in0; 
alarm_second <= 6'd0; 
end 
// Alarm 
if (AL_ON && (hour == alarm_hour) && (minute == alarm_minute) && (second == alarm_second)) begin 
Alarm <= 1'b1; 
alarm_timer <= 6'd0; 
end 
// Alarm timer counts only when alarm is active 
if (Alarm && one_hz_tick) begin 
if (alarm_timer < 6'd60) 
alarm_timer <= alarm_timer + 6'd1; 
else 
Alarm <= 1'b0;  // Auto stop after 60 seconds 
end 
// Manual stop 
if (STOP_al) begin 
Alarm <= 1'b0; 
alarm_timer <= 6'd0; 
end 
end 
end 
// Output 
assign H_out1 = hour / 10; 
assign H_out0 = hour % 10; 
assign M_out1 = minute / 10; 
assign M_out0 = minute % 10; 
assign S_out1 = second / 10; 
assign S_out0 = second % 10; 
endmodule 
