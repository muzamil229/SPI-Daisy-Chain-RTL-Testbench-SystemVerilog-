`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2025 08:07:51 PM
// Design Name: 
// Module Name: top1
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


module top(
    input clk,rst,tx_enable,
    output [7:0] dout,
    output done
    );
    
    wire mosi, ss ,sclk;
    
    fsm_spi uut(.clk(clk),.rst(rst),.tx_enable(tx_enable),.mosi(mosi),.cs(ss),.sclk(sclk));
    spi_slave uut1(.sclk(sclk),.mosi(mosi),.cs(ss),.dout(dout),.done(done));
    
endmodule
