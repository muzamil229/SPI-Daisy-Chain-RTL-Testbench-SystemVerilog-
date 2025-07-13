`timescale 1ns / 1ps



module top_tb1();

    reg clk = 0;
    reg rst = 0;
    reg tx_enable = 0;
    wire [7:0] dout;
    wire done;
    
    
    always #5 clk = ~clk;
    
    top dut(.clk(clk),.rst(rst),.tx_enable(tx_enable),.dout(dout),.done(done));
    
    initial begin
        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;
    end
    
    initial begin
        tx_enable = 0;
        repeat (5) @(posedge clk);
        tx_enable = 1;
    end
    
    
endmodule
