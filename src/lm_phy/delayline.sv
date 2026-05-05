module delayline #(parameter TPS = 10) (
    output wire out, 
    input wire in
);
    wire [TPS:0] delay_chain;
    assign delay_chain[0] = in;
    genvar i;
    generate
        for (i = 0; i < TPS; i = i + 1) begin : buffer_chain
					`ifdef SIM

          buf #(10ps) buffa(delay_chain[i+1],delay_chain[i]);

					`else

          sky130_fd_sc_hd__buf_2 bufa(.X(delay_chain[i+1]),.A(delay_chain[i]));

					`endif
        end
    endgenerate
    assign out = delay_chain[TPS];

endmodule
