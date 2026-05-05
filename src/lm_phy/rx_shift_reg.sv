`default_nettype none
module rx_shift_reg #(parameter WIDTH = 64) (
    input wire shift_clk,
    input wire rst_n,
    input wire[1:0] shift_data,
    output reg[WIDTH-1:0] rx_out
    );
`ifdef SIM
always @(posedge shift_clk, negedge rst_n) begin
if(~rst_n) begin
rx_out <= '0;
end else begin
rx_out <= {shift_data, rx_out[WIDTH-1:2]};
end
end
`else
wire [(WIDTH/2):0] clk_chain;
// The LSBs (highest index in our shift right) receive the source clock first
assign clk_chain[0] = shift_clk;
genvar i;
generate
for (i = 0; i < WIDTH/2; i = i + 1) begin : gen_shift_stages
  if (i < (WIDTH/2)) begin
  sky130_fd_sc_hd__clkbuf_1 clk_gen (
      .X(clk_chain[i+1]),
      .A(clk_chain[i])
      );
  end
  always @(posedge clk_chain[i], negedge rst_n) begin
    if (~rst_n) begin
      rx_out[(i*2) +: 2] <= 2'b00;
  end else begin
  if (i == (WIDTH/2) - 1) begin
  // The "entry" point for new data (MSBs)
  rx_out[(i*2) +: 2] <= shift_data;
  end else begin
  // Internal shift bits
  rx_out[(i*2) +: 2] <= rx_out[((i+1)*2) +: 2];
  end
  end
  end
  end
  endgenerate
  `endif
  endmodule
  `default_nettype wire
