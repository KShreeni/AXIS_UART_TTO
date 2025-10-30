
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


module sync_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
)(
    input  wire clk,
    input  wire rst,

    // Write interface
    input  wire wr_en,
    input  wire din_last,
    input  wire [WIDTH-1:0] din,
    output wire full,

    // Read interface
    input  wire rd_en,
    output reg  dout_last,
    output wire empty,
    output reg  [WIDTH-1:0] dout
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    reg [WIDTH-1:0] mem_data [0:DEPTH-1];
    reg             mem_last [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    reg [ADDR_WIDTH:0]   count;

    integer i;

    // --------------------------
    // Sequential Logic
    // --------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= 0;
            dout_last <= 0;
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem_data[i] <= 0;
                mem_last[i] <= 0;
            end
        end 
        else begin
            // ===== WRITE =====
            if (wr_en && !full) begin
                mem_data[wr_ptr] <= din;
                mem_last[wr_ptr] <= din_last;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // ===== READ =====
            if (rd_en && !empty) begin
                dout      <= mem_data[rd_ptr];
                dout_last <= mem_last[rd_ptr];
                rd_ptr    <= rd_ptr + 1'b1;
            end
            if(dout_last == 1) dout_last <= 0;
            // ===== COUNT UPDATE =====
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;  // write only
                2'b01: count <= count - 1'b1;  // read only
                default: count <= count;       // both or none → no change
            endcase
        end
    end

    // --------------------------
    // Status Flags
    // --------------------------
    assign full  = (count == DEPTH);
    assign empty = (count == 0);

endmodule
