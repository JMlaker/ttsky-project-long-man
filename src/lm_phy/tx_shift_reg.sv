`default_nettype none
module tx_shift_reg #(parameter WIDTH=64) (
    input wire load_clk_gated,
    input wire rst_n,
    input wire load_en,
    input wire [WIDTH-1:0] load_data,
    input wire shift_clk,
    output wire [1:0] shift_data
);

  wire reg_clk;
  assign reg_clk = load_clk_gated | shift_clk;

  reg [WIDTH-1:0] data;
  assign shift_data = data[1:0];
  always @(posedge reg_clk, negedge rst_n) begin
    if (~rst_n) begin
      data <= '0;
    end else if (load_en) begin
      // Load parallel
      data <= load_data;
    end else begin
      data <= {2'b0, data[WIDTH-1:2]};
    end
  end

endmodule
`default_nettype wire
