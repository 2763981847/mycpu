`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.vh"

module branchdec (
    input  wire [5:0] op,
    input wire [4:0] rt,
    output reg  [2:0] branchcontrol
);
	// branch_judge控制信号
	always @(*) begin
		case(op)
			`EXE_BEQ:
                branchcontrol = `BRANCH_EQ;
            `EXE_BNE:
                branchcontrol = `BRANCH_NEQ;
            `EXE_BGTZ:
                branchcontrol = `BRANCH_GTZ;
            `EXE_BLEZ:   
                branchcontrol = `BRANCH_LEZ;
            `EXE_REGIMM_INST:   //bltz, bltzal, bgez, bgezal
                case(rt)
                    `EXE_BLTZ, `EXE_BLTZAL:      
                        branchcontrol = `BRANCH_LEZ;
                    `EXE_BGEZ,`EXE_BGEZAL:
                        branchcontrol = `BRANCH_GEZ;
                    default:
                        branchcontrol = 3'b000; 
                endcase
			default:
				branchcontrol = 3'b000;
		endcase	
	end
endmodule
