`default_nettype none
module lm_phy_tx #(
	parameter WIDTH=64
)(
	input wire clk,
	input wire rst_n,
	input wire [WIDTH-1:0] tx_in,
	input wire tx_load,
	output wire tx_done,
	output wire[3:0] TX,
	input wire TX_ACK,
  output wire[5:0] dbg
);

reg load_en;
always @(posedge clk, negedge rst_n) begin
	if(~rst_n) begin
		load_en <= 1'b0;
	end else begin
		load_en <= tx_load;
	end
end

wire shift;
wire load_clk_gated;

wire send_data;

// Turn either edge of TX_ACK into short pulse
wire ack_pulse;
pulse_generator pgen(.rx(TX_ACK), .rx_pulse(ack_pulse));

// Gate the clock so fsm and shift reg receive it only when load is asserted.
// Otherwise their clocks come from ack_pulse
clock_gate_low load_cgate(.clk(clk), .en(load_en), .clk_gated(load_clk_gated));

tx_fsm #(WIDTH) tx_fsm(.clk(clk), .load_clk(load_clk_gated), .rst_n(rst_n), .load(load_en), .ack_pulse(ack_pulse), .done(tx_done), 
	.shift(shift), .send_data(send_data));

wire[1:0] shift_data;
tx_shift_reg #(WIDTH) shift_reg(.load_clk_gated(load_clk_gated), .rst_n(rst_n), .load_en(load_en), .load_data(tx_in), .shift_clk(shift),
	.shift_data(shift_data));

logic send_delay;
delayline #(50) dl(send_delay, send_data);

wire[3:0] decode_out;
decoder2_4 decoder(.in(shift_data), .out(decode_out));

genvar i;
generate
	for(i = 0; i < 4; i = i + 1) begin
		toggle tgl(.rst_n(rst_n), .pulse(decode_out[i] & send_delay & ~tx_done), .data(TX[i]) );
	end
endgenerate

assign dbg[0] = ack_pulse;
assign dbg[1] = send_data;
assign dbg[2] = decode_out[0];
assign dbg[3] = decode_out[1];
assign dbg[4] = load_clk_gated;
assign dbg[5] = shift;

endmodule
`default_nettype wire
