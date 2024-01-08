`timescale 1ns / 1ps
`include "defines.vh"
module branch_judge(
	input wire [31:0] srca2D,srcb2D,
	input wire [2:0] branchcontrolD,
	input wire branchD,
	output reg pcsrcD
);
	always @(*) begin
		case(branchD)
			1'b1:begin
				case(branchcontrolD)
					`BRANCH_EQ: pcsrcD = !(srca2D ^ srcb2D);
					`BRANCH_NEQ: pcsrcD = |(srca2D ^ srcb2D);
					`BRANCH_GTZ: pcsrcD = ~srca2D[31] & (|srca2D);
					`BRANCH_GEZ:  pcsrcD = ~srca2D[31];
					`BRANCH_LTZ:  pcsrcD = srca2D[31];
					`BRANCH_LEZ:  pcsrcD = srca2D[31] | ~(|srca2D);
					default: pcsrcD = 1'b0;
				endcase
			end
			default: pcsrcD = 1'b0;
		endcase
	end
endmodule