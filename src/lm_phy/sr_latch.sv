`default_nettype none
module sr(input wire S, input wire R, output reg Q, output reg Q_n);
    // nor #(1ps)n1(Q, R, Q_n);
    // nor #(1ps)n2(Q_n, S, Q);

`ifdef SIM

		always @(S, R) begin
			if (R) begin
				Q <= 1'b0;
				Q_n <= 1'b1;
			end else if (S) begin
				Q <= 1'b1;
				Q_n <= 1'b0;
			end
		end

`else

  // Gate 1: Q = NOR(R, Q_n)
  // When R is high, Q is forced to 0 (Reset)
  sky130_fd_sc_hd__nor2_1 n1 (
      .Y(Q),
      .A(R),
      .B(Q_n)
  );
  // Gate 2: Q_n = NOR(S, Q)
  // When S is high, Q_n is forced to 0, which makes Q go high (Set)
  sky130_fd_sc_hd__nor2_1 n2 (
      .Y(Q_n),
      .A(S),
      .B(Q)
  );

`endif
//             ___
// S ----------\  \           _
//              )  )o------+--Q
//          ---/__/       /
//          |______      /
//            _____\____/
//           /      \
//          /  ___   \
//         ----\  \   \
//              )  )o--+------Q
// R ----------/__/       
//
endmodule
`default_nettype wire
