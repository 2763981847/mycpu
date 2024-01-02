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
    output reg hilowrite
);
  // memtoreg
  always @(*) begin
    case (op)
      `EXE_LW: memtoreg <= 1'b1;
      default: memtoreg <= 1'b0;
    endcase
  end
  // memwrite
  always @(*) begin
    case (op)
      `EXE_SW: memwrite <= 1'b1;
      default: memwrite <= 1'b0;
    endcase
  end
  // branch
  always @(*) begin
    case (op)
      `EXE_BEQ: branch <= 1'b1;
      default:  branch <= 1'b0;
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
      `EXE_LW, `EXE_SW:
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
      `EXE_NOP,
      // 逻辑运算指令 R-type
      `EXE_ANDI, `EXE_ORI, `EXE_XORI, `EXE_LUI,
      // 算数运算指令 R-type
      `EXE_ADDI, `EXE_ADDIU, `EXE_SLTI, `EXE_SLTIU,
      // 访存指令
      `EXE_LW:
      regwrite <= 1'b1;  //LW
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
          `EXE_MTHI, `EXE_MTLO: hilowrite <= 1'b1;
          default: hilowrite <= 1'b0;
        endcase
      end
      default: hilowrite <= 1'b0;
    endcase
  end

endmodule
