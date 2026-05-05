`default_nettype none
module toggle(
	input wire rst_n,
	input wire pulse,
	output reg data
);
	always @(posedge pulse, negedge rst_n) begin
		if(!rst_n) begin
			data <= 1'b0;
		end else begin
			data <= ~data;
		end
	end
endmodule
`default_nettype wire
