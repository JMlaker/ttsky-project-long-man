`default_nettype none
module encoder4_2(
	input wire[3:0] in,
	output reg[1:0] out
);
// Not glitchless - this is ok on this path
always_comb begin
	unique case (in)
		4'b0001: out = 2'h0;
		4'b0010: out = 2'h1;
		4'b0100: out = 2'h2;
		4'b1000: out = 2'h3;
		default: out = 2'h0;
	endcase
end
endmodule
`default_nettype wire
