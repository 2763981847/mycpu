`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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
module maindec (
    input wire [5:0] op,
    funct,
    output reg memtoreg,
    memwrite,
    output reg branch,
    alusrc,
    output reg regdst,
    regwrite,
    output reg jump,
    output reg hilowrite,
    output reg memsignext,
    output reg [1:0] membyte
);

  // memtoreg
  always @(*) begin
    case (op)
      `EXE_LW, `EXE_LB, `EXE_LBU, `EXE_LH, `EXE_LHU: memtoreg <= 1'b1;
      default: memtoreg <= 1'b0;
    endcase
  end

  // memwrite
  always @(*) begin
    case (op)
      `EXE_SW, `EXE_SB, `EXE_SH: memwrite <= 1'b1;
      default: memwrite <= 1'b0;
    endcase
  end

  // branch
  always @(*) begin
    case (op)
      `EXE_BEQ, `EXE_BNE, `EXE_BGTZ, `EXE_BLEZ, `EXE_REGIMM_INST: branch <= 1'b1;
      default: branch <= 1'b0;
    endcase
  end

  // alusrc
  always @(*) begin
    case (op)
      // 逻辑运算指令 I-type
      `EXE_ANDI, `EXE_ORI, `EXE_XORI, `EXE_LUI,
      // 算数运算指令 I-type
      `EXE_ADDI, `EXE_ADDIU, `EXE_SLTI, `EXE_SLTIU,
      // 访存指令
      `EXE_LW, `EXE_SW, `EXE_LB, `EXE_LBU, `EXE_LH, `EXE_LHU, `EXE_SB, `EXE_SH:
      alusrc <= 1'b1;
      default: alusrc <= 1'b0;
    endcase
  end

  // regdst
  always @(*) begin
    case (op)
      `EXE_NOP: regdst <= 1'b1;
      default:  regdst <= 1'b0;
    endcase
  end

  // regwrite
  always @(*) begin
    case (op)
      // R-type
      `EXE_NOP: begin
        case (funct)
          // 乘除�?
          `EXE_MULT, `EXE_MULTU, `EXE_DIV, `EXE_DIVU, `EXE_MTHI, `EXE_MTLO: regwrite <= 1'b0;
          default: regwrite <= 1'b1;
        endcase
      end
      // 逻辑运算指令 I-type
      `EXE_ANDI, `EXE_ORI, `EXE_XORI, `EXE_LUI,
      // 算数运算指令 I-type
      `EXE_ADDI, `EXE_ADDIU, `EXE_SLTI, `EXE_SLTIU,
      // 访存指令
      `EXE_LW, `EXE_LB, `EXE_LBU, `EXE_LH, `EXE_LHU:
      regwrite <= 1'b1;
      default: regwrite <= 1'b0;
    endcase
  end

  // jump
  always @(*) begin
    case (op)
      `EXE_J:  jump <= 1'b1;
      default: jump <= 1'b0;
    endcase
  end

  // hilowrite
  always @(*) begin
    case (op)
      `EXE_NOP: begin
        case (funct)
          `EXE_MTHI, `EXE_MTLO, `EXE_MULT, `EXE_MULTU, `EXE_DIV, `EXE_DIVU: hilowrite <= 1'b1;
          default: hilowrite <= 1'b0;
        endcase
      end
      default: hilowrite <= 1'b0;
    endcase
  end

  // memsignext
  always @(*) begin
    case (op)
      `EXE_LHU, `EXE_LBU: memsignext <= 1'b0;
      default: memsignext <= 1'b1;
    endcase
  end

  // membyte
  always @(*) begin
    case (op)
      `EXE_LB, `EXE_LBU, `EXE_SB: membyte <= `MEM_BYTE;
      `EXE_LH, `EXE_LHU, `EXE_SH: membyte <= `MEM_HALFWORD;
      default: membyte <= `MEM_WORD;
    endcase
  end


endmodule
