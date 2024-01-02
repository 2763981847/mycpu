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
    hi,
    lo,
    input  wire [ 4:0] sa,
    input  wire [ 7:0] op,
    output reg  [63:0] y
);
  always @(*) begin
    case (op)
      // 逻辑运算指令 R-type
      `EXE_AND_OP: y <= a & b;
      `EXE_OR_OP: y <= a | b;
      `EXE_XOR_OP: y <= a ^ b;
      `EXE_NOR_OP: y <= ~(a | b);
      // 逻辑运算指令 I-type
      `EXE_ANDI_OP: y <= a & {{16{1'b0}}, b[15:0]};
      `EXE_ORI_OP: y <= a | {{16{1'b0}}, b[15:0]};
      `EXE_XORI_OP: y <= a ^ {{16{1'b0}}, b[15:0]};
      `EXE_LUI_OP: y <= {b[15:0], {16{1'b0}}};
      // 算术运算指令	R-type
      `EXE_ADD_OP, `EXE_ADDU_OP: y <= a + b;
      `EXE_SUB_OP, `EXE_SUBU_OP: y <= a - b;
      `EXE_SLT_OP: y <= $signed(a) < $signed(b);
      `EXE_SLTU_OP: y <= a < b;
      `EXE_MULT_OP: y <= $signed(a) * $signed(b);
      `EXE_MULTU_OP: y <= {32'b0, a} * {32'b0, b};
      `EXE_DIV_OP: y <= {$signed(a) % $signed(b), $signed(a) / $signed(b)};
      `EXE_DIVU_OP: y <= {a % b, a / b};
      // 算术运算指令	I-type
      `EXE_ADDI_OP, `EXE_ADDIU_OP: y <= a + b;
      `EXE_SLTI_OP: y <= $signed(a) < $signed(b);
      `EXE_SLTIU_OP: y <= a < b;
      // 位移运算指令
      `EXE_SLL_OP: y <= b << sa;
      `EXE_SRL_OP: y <= b >> sa;
      `EXE_SRA_OP: y <= $signed(b) >>> sa;
      `EXE_SLLV_OP: y <= b << a;
      `EXE_SRLV_OP: y <= b >> a;
      `EXE_SRAV_OP: y <= $signed(b) >>> a;
      default: y <= 63'b0;
    endcase
  end
endmodule
