`timescale 1ns / 1ps



module fsm_spi_tb();

    reg clk,rst,tx_enable = 0;
    wire mosi;
    wire sclk;
    wire cs;
    
    always #5 clk = ~clk;
    
    fsm_spi dut(.clk(clk),.rst(rst),.tx_enable(tx_enable),.mosi(mosi),.sclk(sclk),.cs(cs));
    
    initial begin
        clk = 0;
        rst  = 1;
        repeat(5) @(posedge clk);
        rst  = 0;
    end
    
    initial begin
        tx_enable = 0;
        repeat (5) @(posedge clk);
        tx_enable = 1;
    end
    
    
endmodule
