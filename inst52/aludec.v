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
        `EXE_ADD:  alucontrol <= `EXE_ADD_OP;  //add
        `EXE_ADDU: alucontrol <= `EXE_ADDU_OP;  //addu
        `EXE_SUB:  alucontrol <= `EXE_SUB_OP;  //sub
        `EXE_SUBU: alucontrol <= `EXE_SUBU_OP;  //subu
        `EXE_SLT:  alucontrol <= `EXE_SLT_OP;  //slt
        `EXE_SLTU: alucontrol <= `EXE_SLTU_OP;  //sltu
        // 逻辑运算
        `EXE_AND:  alucontrol <= `EXE_AND_OP;  //and
        `EXE_OR:   alucontrol <= `EXE_OR_OP;  //or
        `EXE_XOR:  alucontrol <= `EXE_XOR_OP;  //xor
        `EXE_NOR:  alucontrol <= `EXE_NOR_OP;  //nor
        // 移位运算
        `EXE_SLL:  alucontrol <= `EXE_SLL_OP;  //sll
        `EXE_SRL:  alucontrol <= `EXE_SRL_OP;  //srl
        `EXE_SRA:  alucontrol <= `EXE_SRA_OP;  //sra
        `EXE_SLLV: alucontrol <= `EXE_SLLV_OP;  //sllv
        `EXE_SRLV: alucontrol <= `EXE_SRLV_OP;  //srlv
        `EXE_SRAV: alucontrol <= `EXE_SRAV_OP;  //srav
        default:   alucontrol <= `EXE_ADDU_OP;
      endcase
      // 逻辑运算 immediate
      `EXE_ANDI: alucontrol <= `EXE_ANDI_OP;  //andi
      `EXE_ORI: alucontrol <= `EXE_ORI_OP;  //ori
      `EXE_XORI: alucontrol <= `EXE_XORI_OP;  //xori
      `EXE_LUI: alucontrol <= `EXE_LUI_OP;  //lui
      // 算术运算 immediate
      `EXE_ADDI: alucontrol <= `EXE_ADD_OP;  //addi
      `EXE_ADDIU: alucontrol <= `EXE_ADDIU_OP;  //addiu
      `EXE_SLTI: alucontrol <= `EXE_SLTI_OP;  //slti
      `EXE_SLTIU: alucontrol <= `EXE_SLTIU_OP;  //sltiu
      // 访存指令
      `EXE_LW, `EXE_SW: alucontrol <= `EXE_ADD_OP;  //lw, sw
      // 跳转指令
      `EXE_J, `EXE_BEQ: alucontrol <= `EXE_ADDU_OP;  //j, beq
      default: alucontrol <= `EXE_ADDU_OP;

    endcase
  end
endmodule
