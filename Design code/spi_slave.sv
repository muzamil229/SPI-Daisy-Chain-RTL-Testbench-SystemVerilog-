`timescale 1ns / 1ps

module spi_slave(
    input sclk, mosi,cs,
    output reg [7:0] dout,
    output reg done
    );
    
    
    integer count = 0;
    typedef enum logic {idle = 0 , sample = 1} state_type;
    state_type state;
    
    reg [7:0] data = 0;
    
    always@(negedge sclk)
    begin
        
        case(state)

            idle:
            begin
                done <= 1'b0;
                
                if(cs == 1'b0)
                begin
                    state<= sample;
                end
                else
                begin
                    state <= idle;
                end
           end
           
           sample:
           begin
                if(count < 8)
                begin
                    count <= count + 1;
                    data <= {data[6:0], mosi};
                    state <= sample;
                end
                else
                begin
                    count <= 0;
                    state <= idle;
                    done <= 1'b1;
                end
          end
          
          default: state <= idle;
          
          
       endcase
       
    end
    assign dout = data;
        
endmodule
