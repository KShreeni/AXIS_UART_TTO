
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2025 11:15:06
// Design Name: 
// Module Name: sync_fifo
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


module sync_fifo #(parameter WIDTH=8,DEPTH=4)
(
input clk,rst,
input wr_en,din_last,
input[WIDTH-1:0] din,
output wire full,
input rd_en,
output reg dout_last,
output wire empty,
output reg[WIDTH-1:0] dout
);

localparam ADDR_width = $clog2(DEPTH);

reg [WIDTH-1:0] mem_data [0:DEPTH-1];
reg    mem_last [0:DEPTH-1];

reg [ADDR_width-1:0] wr_ptr,rd_ptr;
reg [ADDR_width:0] count;

integer i;

always@(posedge clk or posedge rst)begin
 if(rst)begin
   wr_ptr <= 0;
   rd_ptr <= 0;
   count <= 0;
   for(i=0;i<DEPTH;i=i+1)begin
     mem_data[i] <= {WIDTH{1'b0}};
     mem_last[i] <= 1'b0;
   end
   dout <= {WIDTH{1'b0}};
   dout_last <= 1'b0;
  end
  else begin
    if(wr_en && !full)begin
     mem_data[wr_ptr] <= din;
     mem_last[wr_ptr] <= din_last;
     wr_ptr <= wr_ptr + 1;
     count <= count + 1;
   end
   if(rd_en && !empty)begin  // Remove 'else if' - use separate 'if'
     dout <= mem_data[rd_ptr];
     dout_last <= mem_last[rd_ptr];
     rd_ptr <= rd_ptr + 1;
     count <= count - 1;
   end
   else begin
     dout <= dout;
     dout_last <= dout_last;
   end
 end
end

assign full = (count == DEPTH);
assign empty = (count == 0);

endmodule
