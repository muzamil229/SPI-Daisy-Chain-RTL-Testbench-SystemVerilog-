`timescale 1ns / 1ps



module fsm_spi(
    input wire clk,
    input wire rst,
    input wire tx_enable,
    output reg mosi,
    output reg cs,
    output reg sclk
);

    typedef enum logic [1:0] { idle = 0, start_tx = 1, tx_data = 2, end_tx =3} state_type;
    
    state_type state, next_state;
    
    reg [7:0] din = 8'b10101010;
    
    reg spi_sclk = 0;
    reg [2:0] ccount = 0;
    reg [2:0] count = 0;
    integer bit_count = 0;
    
    ////////////////////////generating sclk
    
  /*  always@(posedge clk)
    begin
        case(next_state)
            idle: 
            begin
                spi_sclk <=1'b0;
            end
            
            start_tx:
            begin
                if(count < 3'b011 || count == 3'b111)
                begin
                    spi_sclk <= 1'b1;
                end
                else
                begin
                    spi_sclk <= 1'b0;
                end
            end
            
            tx_data:
            begin
                if(count < 3'b011 || count == 3'b111)
                begin
                    spi_sclk <= 1'b1;
                end
                else
                begin
                    spi_sclk <= 1'b0;
                end
           end
           
           end_tx:
           begin
                if(count < 3'b011 || count == 3'b111)
                begin
                    spi_sclk <= 1'b1;
                end
                else
                begin
                    spi_sclk <= 1'b0;
                end
           end
           
           default: spi_sclk<= 1'b0;
           
         endcase
       end
       */
       
       always@(posedge clk)
       begin
            if(!rst && tx_enable)
            begin
                if(ccount <3)
                begin
                    ccount <= ccount + 1;
                end
                else
                begin
                    ccount <= 0;
                    spi_sclk <= ~spi_sclk;
                end
           end
     end
     
     always@(posedge sclk)
     begin
          case(state)
          idle:
          begin
                mosi <= 1'b0;
                cs <= 1'b1;
                if(tx_enable && !rst)
                begin
                    state<= tx_data;
                    cs <= 1'b0;
                end
                else
                begin
                    state <= idle;
                end
          end
          
          tx_data:
          begin
                if(count <8)
                begin
                    mosi <= din[7-count];
                    count <= count +1;
                 end
               else
               begin
                    mosi <= 0;
                    count <= 0;
                    cs <= 1'b1;
                    state <= idle;
               end
        end
        
        default: state<= idle;
       endcase 
    end
     
      /* 
       ///////sense reset
       always@(posedge clk)
       begin
            if(rst)
            begin
                state <= idle;
            end
            else
            begin
                state <= next_state;
            end
       end
       
       ///////// next_state_decoder  combinational block
       
       always@(*)
       begin
            
            case(state)
                
                idle:
                begin
                    mosi = 1'b0;
                    cs   = 1'b1;
                    if(tx_enable)
                    begin
                        next_state = start_tx;
                    end
                    else
                    begin
                        next_state = idle;
                    end
               end
               
               start_tx:
               begin
                    cs = 1'b0;
                    
                    if(count == 3'b111)
                    begin
                        next_state = tx_data;
                    end
                    else
                    begin
                        next_state = start_tx;
                    end
              end
              
              tx_data:
              begin
                    mosi = din[7-bit_count];
                    if(bit_count != 8) 
                    begin
                        next_state = tx_data;
                    end
                    else 
                    begin
                       next_state = end_tx;
                        mosi = 1'b0;
                    end
              end
              
              end_tx:
              begin
                    cs = 1'b1;
                    mosi = 1'b0;
                    if(count == 3'b111)
                    begin
                        next_state = idle;
                    end
                    else
                    begin
                        next_state = end_tx;
                    end
             end
             
             
             
       endcase
       
       
       end
       
       
       ///////////////////////////////////////////
       always@(posedge clk)
       begin
            case(state)
            
            idle:
            begin
                count <= 0;
                bit_count <=0;
            end
            
            start_tx:
            begin
                count <= count + 1;
            end
            
            tx_data:
            begin
                if(bit_count !=8)
                begin
                    if(count < 3'b111)
                    begin
                        count <= count + 1;
                    end
                    else 
                    begin
                        count <= 0;
                        bit_count <= bit_count + 1;
                    end
                end
          end
          
          end_tx:
          begin
                count <= count + 1;
                bit_count <= 0;
          end
          
          default:
          begin
                count <= 0;
                bit_count <= 0;
          end
          
          
      endcase
  end
  */
  
  
  assign sclk = spi_sclk;
                        
                    
            
endmodule
