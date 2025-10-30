
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2025 15:29:19
// Design Name: 
// Module Name: axis_master_inp
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

/*
module axis_master_inp #(parameter WIDTH = 8)
(
 input clk,rst,
 input m_axis_ready,
 output reg[WIDTH-1:0] m_axis_data,
 output reg m_axis_valid,
 output reg m_axis_last
 );
 integer i;
 localparam MSG_LEN = 6;
 reg [WIDTH-1:0] message [0:MSG_LEN-1];
 reg start;
 reg done;
 always @(posedge clk or posedge rst) begin
    if (rst) begin
       for(i=0; i<MSG_LEN;i=i+1)begin
         message[i] <= 8'd0;
         start <= 0;
         
         end  
    end
    else begin
        message[0] <= "H";
        message[1] <= "E";
        message[2] <= "L";
        message[3] <= "L"; 
        message[4] <= "O";
        message[5] <= "\n";
        start <= 1;
        
    end
 end
     
 reg [$clog2(MSG_LEN)-1:0] indx;
 
 always@(posedge clk or posedge rst)begin
  if(rst) begin
    indx <= 0;
    m_axis_data <= 0;
    m_axis_valid <= 0;
    m_axis_last <= 0;
    done <= 0;
  end
  else begin

  if(start)begin
   if(!done)begin
    if(!m_axis_valid)begin
      m_axis_data <= message[indx];
      if(indx == MSG_LEN-1)
      done <= 1;
      else done <= 0;
      m_axis_valid <= 1;
      m_axis_last <= (indx == MSG_LEN-1);
    end
    else if(m_axis_valid && m_axis_ready)begin                      //data is being transferred and fifo is ready
      indx <= (indx == MSG_LEN-1)?0:indx+1;
      m_axis_valid <= 0;                                            //for presenting next data
    end
    else begin
      m_axis_valid <= m_axis_valid;
      m_axis_data <= m_axis_data;
      m_axis_last <= m_axis_last;
    end
  *//*   if (indx == MSG_LEN-1) begin
                    // last character accepted -> stop streaming
                    start        <= 0;
                    indx         <= 0;
                    m_axis_valid <= 0;
                    m_axis_last  <= 0;
                end else begin
                    indx         <= indx + 1;
                    m_axis_valid <= 0;  // deassert to present next
                end*/
  /*  end
    else m_axis_data <= 0;
    end
  else begin
      m_axis_valid <= m_axis_valid;
      m_axis_data <= m_axis_data;
      m_axis_last <= m_axis_last;
    end
 end
 end
endmodule*/
/*
module axis_master_inp #(parameter WIDTH = 8, parameter MSG_LEN = 16) // stream 16 random bytes
(
    input  clk, rst,
    input  m_axis_ready,
    output reg [WIDTH-1:0] m_axis_data,
    output reg m_axis_valid,
    output reg m_axis_last
);

    // ============================================================
    // LFSR for pseudo-random number generation (WIDTH bits)
    // ============================================================
    reg [WIDTH-1:0] lfsr;
    wire feedback = lfsr[WIDTH-1] ^ lfsr[5] ^ lfsr[3] ^ lfsr[0]; // taps for randomness

    // control signals
    reg start;
    reg done;
    reg [$clog2(MSG_LEN)-1:0] indx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr         <= {WIDTH{1'b1}};  // non-zero seed
            indx         <= 0;
            start        <= 1'b1;
            done         <= 1'b0;
            m_axis_data  <= 0;
            m_axis_valid <= 0;
            m_axis_last  <= 0;
        end else begin
            if (start && !done) begin
                if (!m_axis_valid) begin
                    // shift LFSR and take new random data
                    lfsr        <= {lfsr[WIDTH-2:0], feedback};
                    m_axis_data <= lfsr;
                    m_axis_valid <= 1;
                    m_axis_last  <= (indx == MSG_LEN-1);
                end else if (m_axis_valid && m_axis_ready) begin
                    indx         <= (indx == MSG_LEN-1) ? 0 : indx + 1;
                    done         <= (indx == MSG_LEN-1);
                    m_axis_valid <= 0;  // deassert before next byte
                end
            end
        end
    end

endmodule*/

module axis_master_inp #(parameter WIDTH = 8) (
    input  wire clk,
    input  wire rst,
    input  wire [WIDTH-1:0] load_data,
    input  wire m_axis_ready,
    input  wire m_axis_valid,   // input from source (testbench)
    input wire m_axis_last,
    output reg  m_axis_valid_out,
    output reg  [WIDTH-1:0] m_axis_data
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            m_axis_data <= 0;
            m_axis_valid_out <= 0;
        end else begin
            // Hold valid high until handshake completes
          m_axis_valid_out <= m_axis_valid;
            // note: no "else" resetting valid_out

            // Update data only when handshake occurs
            if (m_axis_valid && m_axis_ready)
                m_axis_data <= load_data;
        end
    end
endmodule


