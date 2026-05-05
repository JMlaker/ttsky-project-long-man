`default_nettype none

module tx_fsm #(parameter WIDTH = 64)(
    input wire clk,
    input wire load_clk,
    input wire rst_n,
    input wire load,
    input wire ack_pulse,
    output reg done,
    output wire shift,
    output wire send_data
);

////////////////////
// Wires and Regs //
////////////////////

reg[$clog2(WIDTH/2):0] counter;

reg load_edge;
reg loaded;

/////////////////////////
// Load Edge Detection //
/////////////////////////

always_ff @(posedge clk, negedge rst_n) begin
  if (~rst_n)
    load_edge <= 1'b0;
  else
    load_edge <= load;
end

// Loading should always be faster than clock (since it's
// simultaneous assignment) so we can assume the data is "loaded"
// by the negedge of the load signal
assign loaded = ~load & load_edge;

///////////////////
// Shift counter //
///////////////////

wire fsm_clk;


assign fsm_clk = load_clk | ack_pulse;

always_ff @(posedge fsm_clk, negedge rst_n) begin
  if (~rst_n) begin
    counter <= ($bits(counter))'(WIDTH/2)-1;
    done <= 1'b0;
  end

  else if (load) begin
    counter <= ($bits(counter))'(WIDTH/2)-1;
    done <= 1'b0;
  end

  // Identical counter and done logic as rx_fsm
  else if (~done) begin
    counter <= counter - 1;
    done <= (counter == 0);
  end

  else if (done) begin
    done <= 1'b1;
  end
end

/////////////////////////////////////
// Behavioral from 'state machine' //
/////////////////////////////////////

assign shift = done ? 1'b0 : ack_pulse;

neg_pulse_generator send_data_pulse(.rx(loaded | ack_pulse & ~done), .rx_pulse(send_data));

endmodule
`default_nettype wire
