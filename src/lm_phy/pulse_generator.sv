`default_nettype none
module pulse_generator
(
    input wire rx,
    output wire rx_pulse
);

wire delay;
delayline #(10) dl (delay, rx);

assign rx_pulse = rx ^ delay;

endmodule
`default_nettype wire
