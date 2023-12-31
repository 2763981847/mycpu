`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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

module alu (
    input  wire [31:0] a,
    b,
    input  wire [ 4:0] sa,
    input  wire [ 7:0] op,
    output reg  [31:0] y
);
  always @(*) begin
    case (op)
      // 逻辑运算指令
      `EXE_AND_OP: y <= a & b;
      `EXE_OR_OP: y <= a | b;
      `EXE_XOR_OP: y <= a ^ b;
      `EXE_NOR_OP: y <= ~(a | b);
      `EXE_ANDI_OP: y <= a & {{16{1'b0}}, b[15:0]};
      `EXE_ORI_OP: y <= a | {{16{1'b0}}, b[15:0]};
      `EXE_XORI_OP: y <= a ^ {{16{1'b0}}, b[15:0]};
      `EXE_LUI_OP: y <= {b[15:0], {16{1'b0}}};
      // 算数运算	
      `EXE_ADD_OP: y <= a + b;
      `EXE_SUB_OP: y <= a - b;
      `EXE_SLT_OP: y <= a < b;
      `EXE_ADDU_OP: y <= a + b;
      // 位移运算
      `EXE_SLL_OP: y <= b <<< sa;
      `EXE_SRL_OP: y <= b >>> sa;
      `EXE_SRA_OP: y <= b >> sa;
      `EXE_SLLV_OP: y <= b <<< a;
      `EXE_SRLV_OP: y <= b >>> a;
      `EXE_SRAV_OP: y <= b >> a;
      default: y <= 32'b0;
    endcase
  end
endmodule
