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

module aludec (
    input  wire [5:0] opD,
    functD,
    output reg  [7:0] alucontrol
);
  always @(*) begin
    case (opD)
      `EXE_NOP:  // R-type
      case (functD)
        // 算数运算
        `EXE_ADD: alucontrol <= `EXE_ADD_OP;  //add
        `EXE_SUB: alucontrol <= `EXE_SUB_OP;  //sub
        `EXE_SLT: alucontrol <= `EXE_SLT_OP;  //slt
        //逻辑运算
        `EXE_AND: alucontrol <= `EXE_AND_OP;  //and
        `EXE_OR:  alucontrol <= `EXE_OR_OP;  //or
        `EXE_XOR: alucontrol <= `EXE_XOR_OP;  //xor
        `EXE_NOR: alucontrol <= `EXE_NOR_OP;  //nor
        default:  alucontrol <= `EXE_ADDU_OP;
      endcase
      // 逻辑运算 immediate
      `EXE_ANDI: alucontrol <= `EXE_ANDI_OP;  //andi
      `EXE_ORI: alucontrol <= `EXE_ORI_OP;  //ori
      `EXE_XORI: alucontrol <= `EXE_XORI_OP;  //xori
      `EXE_LUI: alucontrol <= `EXE_LUI_OP;  //lui
      // 算术运算 immediate
      `EXE_ADDI: alucontrol <= `EXE_ADD_OP;  //addi
      // 访存指令
      `EXE_LW, `EXE_SW: alucontrol <= `EXE_ADD_OP;  //lw, sw
      // 跳转指令
      `EXE_J, `EXE_BEQ: alucontrol <= `EXE_ADDU_OP;  //j, beq
      default: alucontrol <= `EXE_ADDU_OP;

    endcase
  end
endmodule
