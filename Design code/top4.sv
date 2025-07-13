`timescale 1ns / 1ps



// -----------------------------------------

// SPI master

// -----------------------------------------

module spi_m (



input clk, sdi, newd, // sdi - MISO

input [7:0] din,

output reg sdo, cs, // sdo - MOSI

output sclk,

output [7:0] dout



);



reg [7:0] dout_o = 8'h0;


// -----------------------------------------

// sclk gen - fclk / 8

// -----------------------------------------


reg [1:0] scount = 0;

reg sclk_t = 0;


always@(posedge clk) begin


if(scount < 3) begin


scount <= scount + 1;


end

else begin


scount <= 0;

sclk_t <= ~sclk_t;


end


end


// -----------------------------------------

// Send data

// -----------------------------------------


reg [7:0] data_in = 8'h00;

reg [4:0] count = 0;


typedef enum logic [1:0] {sample = 0, send = 1, waitt = 2} state_type;

state_type state = sample;


reg [7:0] din_t = 8'h00;


always @(posedge sclk) begin


case(state)


sample: begin


if(newd == 1'b1) begin


cs <= 1'b0;

din_t <= din;

count <= 1;

sdo <= din[0]; // LSB first

state <= send;


end

else begin


cs <= 1'b1;

state <= sample;


end


end


send: begin


if(count <= 7) begin


sdo <= din_t[count];

count <= count + 1;

state <= send;


end

else begin


cs <= 1'b0;

count <= 0;

state <= waitt;


end


end


waitt: begin // Wait master to receive from slave -> (8 + 1) * 2 - 1


if(count <= 17) begin


count <= count + 1;

state <= waitt;


end

else begin


cs <= 1'b1;

count <= 0;

state <= sample;


end


end


default: state <= sample;


endcase


end


// -----------------------------------------

// Recv data serially

// -----------------------------------------


reg [4:0] count_o = 0;


typedef enum logic [1:0] {idle_o = 0, wait_o = 1, collect_o = 2} state_type_o;

state_type_o state_o = idle_o;


always@(negedge sclk) begin



case(state_o)


idle_o: begin


if(newd == 1'b1)


state_o <= wait_o;


else


state_o <= idle_o;


end


wait_o: begin // Wait slave to receive from master -> (8 + 1) * 2 - 1


if(count_o <= 17) begin


count_o <= count_o + 1;

state_o <= wait_o;


end

else begin


count_o <= 0;

state_o <= collect_o;


end


end


collect_o: begin // Collect data sent by slave


if(count_o <= 7) begin


dout_o[count_o] <= sdi; // LSB

count_o <= count_o + 1;

state_o <= collect_o;


end

else begin


count_o <= 0;

state_o <= idle_o;


end



end


default: state_o <= idle_o;


endcase



end


assign sclk = sclk_t;


assign dout = ((count == 18) && (state == waitt)) ? dout_o : 8'h00;



endmodule



// -----------------------------------------

// SPI slave

// -----------------------------------------

module spi_s1 (



input sclk, sdi, cs, // sdi - MISO

output reg sdo // sdo - MOSI



);



// -----------------------------------------

// Recv data serially

// -----------------------------------------


reg [7:0] data_in = 0;

reg [3:0] count = 0;

reg newd = 0; // Flag - trigger slave to send data to master

reg [7:0] dout_t = 0;


typedef enum logic {idle = 0, collect = 1} state_type;

state_type state = idle;


always@(negedge sclk) begin


case(state)


idle: begin


newd <= 1'b0;


if(cs == 1'b0) begin


data_in[7:0] <= {sdi, data_in[7:1]}; // LSR - LSB first

count <= 1;

state <= collect;


end

else begin


state <= idle;


end


end


collect: begin


if(count <= 7) begin


data_in <= {sdi, data_in[7:1]}; // RSR - LSB first

count <= count + 1;

state <= collect;


end

else begin


count <= 0;

dout_t <= data_in;

newd <= 1'b1;

state <= idle;


end


end


default: state <= idle;


endcase


end


// -----------------------------------------

// Send data serially

// -----------------------------------------


reg [3:0] count_o = 0;


typedef enum logic {idle_o = 0, send_o = 1} state_type_o;

state_type_o state_o = idle_o;


always@(negedge sclk) begin


case(state_o)


idle_o: begin


if((cs == 1'b0) && (newd == 1'b1)) begin


count_o <= 1;

sdo <= dout_t[0];

state_o <= send_o;


end

else begin


state_o <= idle_o;


end


end


send_o: begin


if(count_o <= 7) begin


sdo <= dout_t[count_o];

count_o <= count_o + 1;

state_o <= send_o;


end

else begin


count_o <= 0;

state_o <= idle_o;


end


end


default: state_o <= idle_o;


endcase


end


endmodule



// -----------------------------------------

// SPI slave 2 - posedge sclk

// -----------------------------------------

module spi_s2 (



input sclk, sdi, cs, // sdi - MISO

output reg sdo // sdo - MOSI



);



// -----------------------------------------

// Recv data serially

// -----------------------------------------


reg [7:0] data_in = 0;

reg [3:0] count = 0;

reg newd = 0; // Flag - trigger slave to send data to master

reg [7:0] dout_t = 0;


typedef enum logic {idle = 0, collect = 1} state_type;

state_type state = idle;


always@(posedge sclk) begin


case(state)


idle: begin


newd <= 1'b0;


if(cs == 1'b0) begin


data_in[7:0] <= {sdi, data_in[7:1]}; // LSR - LSB first

count <= 1;

state <= collect;


end

else begin


state <= idle;


end


end


collect: begin


if(count <= 7) begin


data_in <= {sdi, data_in[7:1]}; // RSR - LSB first

count <= count + 1;

state <= collect;


end

else begin


count <= 0;

dout_t <= data_in;

newd <= 1'b1;

state <= idle;


end


end


default: state <= idle;


endcase


end


// -----------------------------------------

// Send data serially

// -----------------------------------------


reg [3:0] count_o = 0;


typedef enum logic {idle_o = 0, send_o = 1} state_type_o;

state_type_o state_o = idle_o;


always@(posedge sclk) begin


case(state_o)


idle_o: begin


if((cs == 1'b0) && (newd == 1'b1)) begin


count_o <= 1;

sdo <= dout_t[0];

state_o <= send_o;


end

else begin


state_o <= idle_o;


end


end


send_o: begin


if(count_o <= 7) begin


sdo <= dout_t[count_o];

count_o <= count_o + 1;

state_o <= send_o;


end

else begin


count_o <= 0;

state_o <= idle_o;


end


end


default: state_o <= idle_o;


endcase


end


endmodule



// -----------------------------------------

// Daisy chain

// -----------------------------------------

module daisy_c (


input clk, newd,

input [7:0] din,

output [7:0] dout



);



wire sdi, sdo1, sdo2, sclk, cs;


spi_m master (clk, sdi, newd, din, sdo1, cs, sclk, dout);

spi_s1 slave1 (sclk, sdo1, cs, sdo2);

spi_s2 slave2 (sclk, sdo2, cs, sdi);



endmodule