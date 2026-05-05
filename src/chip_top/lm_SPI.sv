`default_nettype none

module lm_SPI #(parameter WIDTH = 64) (
  // clock and active low reset
  input wire clk,
  input wire rst_n,

  // Standard SPI signals
  input wire MOSI_async,
  output reg MISO,
  input wire SCLK_async,

  // TX related signals
  output reg [WIDTH-1:0] tx_data,   // Holds tx_data to be sent to lm_TOP

  // RX related signals
  input wire rx_capture,            // Asserted by lm_TOP to initiate MISO line
  input wire [WIDTH-1:0] rx_data    // Holds rx_data to be sent out of board
);

reg[2:0] SCLK;

always @(posedge clk, negedge rst_n) begin
  if(~rst_n) begin
    SCLK <= 3'b0;
  end else begin
    SCLK <= {SCLK_async,SCLK[2:1]};
  end
end
wire sample;
assign sample = (SCLK[0])&(~SCLK[1]);

// Dealy MOSI by same amount as SCLK (2cyc)
reg[1:0] MOSI;

always @(posedge clk, negedge rst_n) begin
  if(~rst_n) begin
    MOSI <= 2'b0;
  end else begin
    MOSI <= {MOSI_async,MOSI[1]};
  end
end

always @(posedge clk, negedge rst_n) begin
  if(~rst_n) begin
    tx_data <= '0;
  end else if(sample) begin
    tx_data = {MOSI[0], tx_data[WIDTH-1:1]};
  end
end

reg[1:0] capture;
always @(posedge clk, negedge rst_n) begin
  if(~rst_n) begin
    capture <= 2'b0;
  end else begin
    capture <= {rx_capture, capture[1]};
  end
end

reg[WIDTH-1:0] outgoing;
always @(posedge clk, negedge rst_n) begin
  if(~rst_n) begin
    MISO <= '0;
    outgoing <= '0;
  end else if(capture) begin
    outgoing = rx_data;
  end else if(sample) begin
    MISO <= outgoing[0];
    outgoing = {1'b0, outgoing[WIDTH-1:1]};
  end
end

endmodule
`default_nettype wire
