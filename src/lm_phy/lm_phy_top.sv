`default_nettype none
module lm_phy_top #(parameter WIDTH = 64) (
	input wire clk,
	input wire rst_n,

	// TX chip side interface
	input wire[WIDTH-1:0] tx_in,
	input wire tx_load,
	output wire tx_done,

	// RX chip side interface
	output wire[WIDTH-1:0] rx_out,
	output wire rx_vld,
	input wire rx_rdy,

	// TX off chip interface
	output wire[3:0] TX,
	input wire TX_ACK,
	
	// TX off chip interface
	input wire[3:0] RX,
	output wire RX_ACK,

  // Debug bus
  output wire[11:0] dbg
);

wire [5:0] dbg_tx, dbg_rx;

assign dbg = {dbg_tx, dbg_rx};

	lm_phy_tx #(WIDTH) u_lm_phy_tx(.clk(clk), .rst_n(rst_n), .TX(TX), .TX_ACK(TX_ACK), .tx_in(tx_in), .tx_load(tx_load), .tx_done(tx_done), .dbg(dbg_tx));
	lm_phy_rx #(WIDTH) u_lm_phy_rx(.clk(clk), .rst_n(rst_n), .RX(RX), .RX_ACK(RX_ACK), .rx_out(rx_out), .rx_vld(rx_vld), .rx_rdy(rx_rdy), .dbg(dbg_rx));

endmodule
`default_nettype wire
