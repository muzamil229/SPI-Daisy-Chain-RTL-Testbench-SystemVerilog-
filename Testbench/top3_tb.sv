`timescale 1ns / 1ps

module top3_tb();

    reg clk100mhz = 0;
    wire cs;
    wire mosi;
    wire sclk;
    reg st_wrt = 0;
    reg [11:0] data_in = 0;
    wire done;
    
    top3 dut(clk100mhz,cs,mosi,sclk,st_wrt,data_in,done);
    
    always #5 clk100mhz = ~clk100mhz;
    
    initial begin
        st_wrt = 1;
        data_in = 12'b101010101010;
    end
    
    
endmodule
