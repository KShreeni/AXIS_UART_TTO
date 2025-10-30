
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


module uart_tx #(
    parameter clk_rate = 50_000_000,
    parameter Baud     = 115200,
    parameter Word_len = 8,
    parameter PARITY   = "even" // Options: "none", "even", "odd"
)
(
    input clk, rst,
    input [Word_len-1:0] tx_data,
    input tx_data_valid,tx_data_last,
    output wire tx_data_ready,
    output reg Uart_tx
);

    localparam Baud_div = (clk_rate / Baud);
    
    // FSM States
    localparam Idle   = 3'd0,
               Start  = 3'd1,
               Data   = 3'd2,
               Parity = 3'd3,
               Stop   = 3'd4;

    reg [2:0] current_state, next_state;

    reg [$clog2(Baud_div)-1:0] baud_cnt;
    reg [$clog2(Word_len)-1:0] bit_cnt;
    reg [Word_len-1:0] shift_reg;
    reg parity_bit;
    reg tx_data_ready_temp;
    reg tx_data_last_temp,tx_data_valid_temp;
    
    assign tx_data_ready = (next_state == Idle);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= Idle;
            tx_data_last_temp <= 0;
            tx_data_valid_temp <= 0;
            end
        else begin
            current_state <= next_state;
            tx_data_last_temp <= tx_data_last;
            tx_data_valid_temp <= tx_data_valid;
          end  
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            Idle: begin
                if (tx_data_valid && !tx_data_last_temp) next_state = Start;
                else next_state = Idle;
            end
            Start: begin
                if (baud_cnt == (Baud_div - 1)) next_state = Data;
            end
            Data: begin
                if (bit_cnt == Word_len - 1 && baud_cnt == (Baud_div - 1)) begin
                    if (PARITY == "none")
                        next_state = Stop;
                    else
                        next_state = Parity;
                end
            end
            Parity: begin
                if (baud_cnt == (Baud_div - 1)) next_state = Stop;
            end
            Stop: begin
                if(baud_cnt == (Baud_div - 1)) next_state = Idle;
                 else if (tx_data_last)next_state = Idle;
                  else next_state = Stop;
            end
            default: next_state = Idle;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_cnt <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            Uart_tx <= 1'b1;
            parity_bit <= 1'b0;
        end else begin
            case (current_state)
                Idle: begin
                    baud_cnt <= 0;
                    bit_cnt <= 0;
                    Uart_tx <= 1'b1;
                   
                end
                
                Start: begin
                 if (tx_data_valid_temp) begin
                        shift_reg <= tx_data;
                        // Pre-calculate the parity bit
                        if (PARITY == "even")
                            parity_bit <= ^tx_data;
                        else if (PARITY == "odd")
                            parity_bit <= ~^tx_data;
                    end
                    Uart_tx <= 1'b0;
                    if (baud_cnt == (Baud_div - 1))
                        baud_cnt <= 0;
                    else
                        baud_cnt <= baud_cnt + 1;
                end
                
                Data: begin
                    Uart_tx <= shift_reg[0];
                    if (baud_cnt == (Baud_div - 1)) begin
                        baud_cnt <= 0;
                        shift_reg <= {1'b1, shift_reg[Word_len-1:1]}; // Shift in 1s
                        bit_cnt <= bit_cnt + 1;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                Parity: begin
                    Uart_tx <= parity_bit; // Send the calculated parity bit
                     if (baud_cnt == (Baud_div - 1))
                        baud_cnt <= 0;
                    else
                        baud_cnt <= baud_cnt + 1;
                end
                
                Stop: begin
                    Uart_tx <= 1'b1;
                    if (baud_cnt == (Baud_div - 1))
                        baud_cnt <= 0;
                    else
                        baud_cnt <= baud_cnt + 1;
                end
            endcase
        end
    end
endmodule
