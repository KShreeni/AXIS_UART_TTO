
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2025 14:33:41
// Design Name: 
// Module Name: axis_fifo_uart_tx
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


module axis_fifo_uart_tx #(parameter WIDTH = 8, DEPTH = 8, CLK_RATE = 100000000, BAUD = 115200)
(
 input clk,rst,
 input [WIDTH-1:0] s_axis_data,
 input s_axis_valid,
 input s_axis_last,
 output wire s_axis_ready,
 output wire uart_tx
);

wire[WIDTH-1:0] fifo_out;
wire fifo_out_last;
wire fifo_full,fifo_empty;
wire fifo_wr_en,fifo_rd_en;

assign s_axis_ready = !fifo_full;
assign fifo_wr_en = s_axis_valid && s_axis_ready;

wire uart_valid = !fifo_empty;
wire uart_ready;

assign fifo_rd_en = uart_valid && uart_ready;

sync_fifo #(.WIDTH(WIDTH),.DEPTH(DEPTH)) fifo_inst(.clk(clk),.rst(rst),
.wr_en(fifo_wr_en),.din(s_axis_data),.din_last(s_axis_last),.full(fifo_full),
.empty(fifo_empty),.rd_en(fifo_rd_en),.dout(fifo_out),.dout_last(fifo_out_last));

uart_tx #(.clk_rate(CLK_RATE),.Baud(BAUD),.Word_len(WIDTH)) uart_inst(.clk(clk),.rst(rst),
.tx_data(fifo_out),.tx_data_valid(uart_valid),.tx_data_ready(uart_ready),.tx_data_last(fifo_out_last),
.Uart_tx(uart_tx));


endmodule
