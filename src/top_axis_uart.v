
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2025 15:56:15
// Design Name: 
// Module Name: top_axis_uart
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


module top_axis_uart #(parameter DATA_BITS = 8) (input clk,rst,input wire [7:0] axis_data,
input wire axis_valid,
input wire axis_last,output wire uart_tx,rx_valid,output m_axis_ready,output wire [DATA_BITS-1:0]rx_data);//,output wire parity_err);

wire [7:0] m_axis_data;
wire axis_ready;

wire m_axis_valid_out;

assign m_axis_ready = axis_ready;

axis_master_inp #(.WIDTH(8)) mast_inst(.clk(clk),.rst(rst),.load_data(axis_data),
.m_axis_valid(axis_valid),.m_axis_ready(axis_ready),.m_axis_valid_out(m_axis_valid_out),.m_axis_data(m_axis_data));

axis_fifo_uart_tx #(.WIDTH(8),.DEPTH(8),.CLK_RATE(50000000),.BAUD(115200)) axis_fifo_uart_tx_inst(.clk(clk),.rst(rst),
.s_axis_data(m_axis_data),.s_axis_valid(m_axis_valid_out),.s_axis_ready(axis_ready),.s_axis_last(axis_last),.uart_tx(uart_tx));

uart_rec #(.CLK_FREQ(50000000),.BAUD(115200),.DATA_BITS(DATA_BITS)) 
uart_rec_inst(.clk(clk),.rst(rst),.rx(uart_tx),.rx_data(rx_data),.rx_valid(rx_valid));//.parity_error(parity_err));
endmodule
/*
module top_axis_uart #(parameter DATA_BITS = 8, parameter MSG_LEN = 32) (
    input  clk,
    input  rst,
    output wire uart_tx,
    output wire rx_valid,
    output wire [DATA_BITS-1:0] rx_data
);

    // AXI stream signals
    wire [7:0] axis_data;
    wire  axis_valid;
    wire  axis_last;
    wire axis_ready;

    // External load signals for master
    wire load;
    wire [$clog2(MSG_LEN)-1:0] load_index;
    wire [7:0] load_data;

    // Master
    axis_master_inp #(.WIDTH(8), .MSG_LEN(MSG_LEN)) mast_inst (
        .clk(clk), .rst(rst),
        .load(load),
        .load_index(load_index),
        .load_data(load_data),
        .m_axis_ready(axis_ready),
        .m_axis_valid(axis_valid),
        .m_axis_last(axis_last),
        .m_axis_data(axis_data)
    );

    // FIFO + UART TX
    axis_fifo_uart_tx #(.WIDTH(8), .DEPTH(8), .CLK_RATE(100_000_000), .BAUD(115200))
    axis_fifo_uart_tx_inst (
        .clk(clk), .rst(rst),
        .s_axis_data(axis_data),
        .s_axis_valid(axis_valid),
        .s_axis_ready(axis_ready),
        .s_axis_last(axis_last),
        .uart_tx(uart_tx)
    );

    // UART RX
    uart_rec #(.CLK_FREQ(100_000_000), .BAUD(115200), .DATA_BITS(DATA_BITS))
    uart_rec_inst (
        .clk(clk), .rst(rst),
        .rx(uart_tx),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

endmodule*/
