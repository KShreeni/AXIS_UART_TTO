
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
    parameter CLK_FREQ    = 50_000_000,
    parameter BAUD        = 115200,
    parameter DATA_BITS   = 8,
    parameter PARITY      = "even"      
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,                    
    output reg  [DATA_BITS-1:0] rx_data, 
    output reg  rx_valid              
    //output reg  parity_error            
);

    localparam BAUD_DIV    = (CLK_FREQ / BAUD);
    localparam HALF_BAUD   = BAUD_DIV / 2;
    
    // FSM States
    localparam IDLE   = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               PARITY_S = 3'd3, 
               STOP   = 3'd4;
    
    reg [2:0] state, next_state;
    reg [$clog2(BAUD_DIV):0] baud_cnt;
    reg [$clog2(DATA_BITS):0] bit_cnt;
    reg [DATA_BITS-1:0] shift_reg;
    reg received_parity_bit;
    wire calculated_parity;
    reg parity_match;
    
   // reg rx_d1, rx_sync;
   // always @(posedge clk or posedge rst) begin
   //     if (rst) begin
   //         rx_d1   <= 1'b1;
   //         rx_sync <= 1'b1;
   //     end else begin
    //        rx_d1   <= rx;
      //      rx_sync <= rx_d1;
       // end
   // end

   
    assign calculated_parity = ^shift_reg;
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

   
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (!rx) // Start bit detected
                    next_state = START;
            end
            START: begin
                if (baud_cnt == HALF_BAUD)
                    next_state = DATA;
            end
            DATA: begin
                if (baud_cnt == (BAUD_DIV - 1) && bit_cnt == DATA_BITS - 1) begin
                    if (PARITY == "none")
                        next_state = STOP;
                    else
                        next_state = PARITY_S;
                end
            end
            PARITY_S: begin
                if (baud_cnt == (BAUD_DIV - 1))
                    next_state = STOP;
                  //  calculated_parity = ^shift_reg;
            end
            STOP: begin
                if (baud_cnt == (BAUD_DIV - 1))
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

   
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_cnt <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            rx_data <= 0;
            rx_valid <= 0;
           // parity_error <= 0;
            received_parity_bit <= 0;
            parity_match <= 0;
        end else begin
          
            rx_valid <= 0;
          //  parity_error <= 0;

            case (state)
                IDLE: begin
                    bit_cnt <= 0;
                    baud_cnt <= 0;
                end
                
                START: begin
                    if (baud_cnt == BAUD_DIV/2) begin
                        baud_cnt <= 0;
                        bit_cnt <= 0;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end
                
                DATA: begin
                    if (baud_cnt == (BAUD_DIV - 1)) begin
                        baud_cnt <= 0;
                        shift_reg <= {rx, shift_reg[DATA_BITS-1:1]};
                        bit_cnt <= bit_cnt + 1;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                PARITY_S: begin
                    if (baud_cnt == (BAUD_DIV - 1)) begin
                        baud_cnt <= 0;
                        received_parity_bit <= rx; // Capture the parity bit
                    end else
                        baud_cnt <= baud_cnt + 1;
                end
                
                STOP: begin
                    if (baud_cnt == (BAUD_DIV - 1)) begin
                        baud_cnt <= 0;
                        rx_data <= shift_reg;

                        if (PARITY == "none") begin
                            rx_valid <= 1'b1;
                           // parity_error <= 1'b0;
                        end else begin
                            rx_valid <= rx_valid; 
                              //parity_error <= parity_error;
                            

                            if (PARITY == "even")
                                parity_match <= (calculated_parity == received_parity_bit);
                            else 
                                parity_match <= 0;//(calculated_parity != received_parity_bit);

                            if (parity_match) begin
                                rx_valid <= 1'b1; 
                               // parity_error <= 1'b0;
                            end else begin
                                rx_valid <= 1'b0; 
                                //parity_error <= 1'b1;
                            end
                        end
                    end else
                        baud_cnt <= baud_cnt + 1;
                end
            endcase
        end
    end
                          
endmodule
