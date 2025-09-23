
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2025 10:43:15
// Design Name: 
// Module Name: uart_rec
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


module uart_rec #(
    parameter CLK_FREQ = 100_000_000,   // FPGA clock (100 MHz example)
    parameter BAUD     = 115200,
    parameter DATA_BITS = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,              // UART serial input line
    output reg  [DATA_BITS-1:0] rx_data, // Received byte
    output reg  rx_valid         // High for 1 clk when new data is ready
);

    localparam  BAUD_DIV = (CLK_FREQ/BAUD);
   

    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;
    localparam Baud_cnt_width = $clog2(BAUD_DIV);
    reg [1:0] state, next_state;
    reg [$clog2(BAUD_DIV):0] baud_cnt;
    reg [$clog2(DATA_BITS):0] bit_cnt;
    reg [DATA_BITS-1:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            baud_cnt <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            rx_data <= 0;
            rx_valid <= 0;
        end else begin
            state <= next_state;
            case(state)
                IDLE: begin
                    rx_valid <= 0;
                    if (!rx) begin // start bit detected
                        baud_cnt <= 0;
                        next_state <= START;
                    end else begin
                        next_state <= IDLE;
                    end
                end
                START: begin
                    if (baud_cnt == BAUD_DIV[Baud_cnt_width-1:0]/2) begin
                        baud_cnt <= 0;
                        bit_cnt <= 0;
                        next_state <= DATA;
                    end else baud_cnt <= baud_cnt + 1;
                end
                DATA: begin
                    if (baud_cnt == (BAUD_DIV[Baud_cnt_width-1:0] - 1)) begin
                        baud_cnt <= 0;
                        shift_reg <= {rx, shift_reg[DATA_BITS-1:1]}; // LSB first
                        if (bit_cnt == DATA_BITS-1) begin
                            next_state <= STOP;
                        end else bit_cnt <= bit_cnt + 1;
                    end else baud_cnt <= baud_cnt + 1;
                end
                STOP: begin
                    if (baud_cnt ==  (BAUD_DIV[Baud_cnt_width-1:0] - 1)) begin
                        baud_cnt <= 0;
                        rx_data <= shift_reg;
                        rx_valid <= 1;
                        next_state <= IDLE;
                    end else baud_cnt <= baud_cnt + 1;
                end
                default: next_state <= IDLE;
            endcase
        end
    end
endmodule

