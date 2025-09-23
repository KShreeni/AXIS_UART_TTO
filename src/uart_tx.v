
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2025 09:35:15
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(parameter clk_rate = 100000000, parameter Baud = 115200, parameter Word_len = 8
)
(
input clk,rst,
input [Word_len-1:0]tx_data,
input tx_data_valid,tx_data_last,
output wire tx_data_ready,
output reg Uart_tx
);

  localparam  Baud_div = (clk_rate/Baud);
localparam  Baud_cnt_width = $clog2(Baud_div);
//localparam NORM_WAIT = Baud_div - 1;
//localparam PACKET_WAIT = (Baud_div * 2) - 1;

localparam Idle = 2'd0, Start = 2'd1, Data = 2'd2, Stop = 2'd3;

reg[1:0] current_state,next_state; 

  reg[Baud_cnt_width:0] baud_cnt;
reg[$clog2(Word_len+1)-1:0] bit_cnt;
reg[Word_len-1:0] shift_reg;

assign tx_data_ready = (current_state == Idle);  

always@(posedge clk or posedge rst)begin
  if(rst)begin
  current_state <= Idle;
  end
  else begin
     current_state <= next_state;
  end
end

always@(*)begin
next_state = current_state;
case(current_state)
   Idle : begin
         if(tx_data_valid) next_state = Start;
         else next_state = Idle;
   end
   
   Start : begin
          if(baud_cnt ==  (Baud_div[Baud_cnt_width-1:0] - 1)) next_state = Data;
          else next_state = Start;
   end
   
   Data : begin
          if(bit_cnt == Word_len-1 && baud_cnt == (Baud_div[Baud_cnt_width-1:0] - 1)) next_state = Stop;
          else next_state = Data;
   end
   
   Stop : begin
          if(baud_cnt == (Baud_div[Baud_cnt_width-1:0] - 1)) next_state = Idle;
          else next_state = Stop;
   end
   
   /*Wait : begin
          if(baud_cnt == (tx_data_last? PACKET_WAIT:NORM_WAIT)) 
             next_state = Idle;
          else next_state = Wait;
   end*/
   
   default : next_state = Idle;
   
   endcase
end

always@(posedge clk or posedge rst)begin
 if(rst)begin
   baud_cnt <= 0;
   bit_cnt <= 0;
   shift_reg <= {Word_len{1'b0}};
   Uart_tx <= 1'b1;
 end
 else begin
  
   case(current_state)
     Idle : begin
           baud_cnt <= 0;
           bit_cnt <= 0;
           Uart_tx <= 1'b1;
            if(tx_data_valid && tx_data_ready) shift_reg <= tx_data;  
     end
     
     Start : begin
            Uart_tx <= 1'b0;
            if(baud_cnt == (Baud_div[Baud_cnt_width-1:0] - 1))begin
              baud_cnt <= 0;
            end
            else begin
              baud_cnt <= baud_cnt+ 1;
            end
     end
     
     Data : begin
           Uart_tx <= shift_reg[0];
           if(baud_cnt == (Baud_div[Baud_cnt_width-1:0] - 1))begin
             baud_cnt <= 0;
             shift_reg <= {1'b0,shift_reg[Word_len-1:1]};
             if(bit_cnt == Word_len-1)
               bit_cnt <= 0;
             else
               bit_cnt <= bit_cnt + 1;
           end
           else 
             baud_cnt <= baud_cnt + 1;
     end
     
     Stop : begin
           Uart_tx <= 1'b1;
           if(baud_cnt == (Baud_div[Baud_cnt_width-1:0] - 1))
              baud_cnt <= 0;
           else
              baud_cnt <= baud_cnt + 1;
     end
     
   /*  Wait : begin
           Uart_tx <= 1'b1;
           
           if(baud_cnt == (tx_data_last? PACKET_WAIT:NORM_WAIT))
              baud_cnt <= 0;
           else
              baud_cnt <= baud_cnt + 1;
     end*/
     
     default : begin
               baud_cnt <= 0;
               bit_cnt <= 0;
               shift_reg <= {Word_len{1'b0}};
               Uart_tx <= 1'b1;
     end
   endcase
 end
end
endmodule
