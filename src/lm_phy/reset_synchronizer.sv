`default_nettype none
module reset_sync(input wire clk, input wire rst_n_async, output wire rst_n);
	reg[1:0] flops;
	always @(posedge clk, negedge rst_n_async) begin
		if(!rst_n_async) begin
			flops <= 2'b0;
		end else begin
			flops <= {flops[0], 1'b1};
		end
	end
	assign rst_n = flops[1];
endmodule
`default_nettype wire
