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
    input wire [31:0] instr,
    output reg memtoreg,
    memwrite,
    output reg branch,
    alusrc,
    output reg regdst,
    regwrite,
    output reg jump,
    output reg regjump,
    output reg link,
    output reg hilowrite,
    output reg memsignext,
    output reg [1:0] membyte
);

  wire [5:0] op, funct;
  wire [4:0] rt;
  assign op = instr[31:26];
  assign funct = instr[5:0];
  assign rt = instr[20:16];

  // memtoreg
  always @(*) begin
    case (op)
      `EXE_LW, `EXE_LB, `EXE_LBU, `EXE_LH, `EXE_LHU: memtoreg = 1'b1;
      default: memtoreg = 1'b0;
    endcase
  end

  // memwrite
  always @(*) begin
    case (op)
      `EXE_SW, `EXE_SB, `EXE_SH: memwrite = 1'b1;
      default: memwrite = 1'b0;
    endcase
  end

  // branch
  always @(*) begin
    case (op)
      `EXE_BEQ, `EXE_BNE, `EXE_BGTZ, `EXE_BLEZ, `EXE_REGIMM_INST: branch = 1'b1;
      default: branch = 1'b0;
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
      alusrc = 1'b1;
      default: alusrc = 1'b0;
    endcase
  end

  // regdst
  always @(*) begin
    case (op)
      `EXE_NOP: regdst = 1'b1;
      default:  regdst = 1'b0;
    endcase
  end

  // regwrite
  always @(*) begin
    case (op)
      // R-type
      `EXE_NOP: begin
        case (funct)
          // 乘除�??
          `EXE_MULT, `EXE_MULTU, `EXE_DIV, `EXE_DIVU, `EXE_MTHI, `EXE_MTLO: regwrite = 1'b0;
          default: regwrite = 1'b1;
        endcase
      end
      // 逻辑运算指令 I-type
      `EXE_ANDI, `EXE_ORI, `EXE_XORI, `EXE_LUI,
      // 算数运算指令 I-type
      `EXE_ADDI, `EXE_ADDIU, `EXE_SLTI, `EXE_SLTIU,
      // 访存指令
      `EXE_LW, `EXE_LB, `EXE_LBU, `EXE_LH, `EXE_LHU,
      // 跳转指令
      `EXE_JAL:
      regwrite = 1'b1;
      `EXE_REGIMM_INST: begin
        case (rt)
          `EXE_BLTZAL, `EXE_BGEZAL: regwrite = 1'b1;
          default: regwrite = 1'b0;
        endcase
      end
      default: regwrite = 1'b0;
    endcase
  end

  // jump
  always @(*) begin
    case (op)
      `EXE_NOP: begin
        case (funct)
          `EXE_JALR, `EXE_JR: jump = 1'b1;
          default: jump = 1'b0;
        endcase
      end
      `EXE_J, `EXE_JAL: jump = 1'b1;
      default: jump = 1'b0;
    endcase
  end

  // regjump
  always @(*) begin
    case (op)
      `EXE_NOP: begin
        case (funct)
          `EXE_JALR, `EXE_JR: regjump = 1'b1;
          default: regjump = 1'b0;
        endcase
      end
      default:  regjump = 1'b0;
    endcase
  end

  // link
  always @(*) begin
    case (op)
      `EXE_NOP: link = funct == `EXE_JALR;
      `EXE_JAL: link = 1'b1;
      `EXE_REGIMM_INST: begin
        case (rt)
          `EXE_BLTZAL, `EXE_BGEZAL: link = 1'b1;
          default: link = 1'b0;
        endcase
      end
      default:  link = 1'b0;
    endcase
  end


  // hilowrite
  always @(*) begin
    case (op)
      `EXE_NOP: begin
        case (funct)
          `EXE_MTHI, `EXE_MTLO, `EXE_MULT, `EXE_MULTU, `EXE_DIV, `EXE_DIVU: hilowrite = 1'b1;
          default: hilowrite = 1'b0;
        endcase
      end
      default: hilowrite = 1'b0;
    endcase
  end

  // memsignext
  always @(*) begin
    case (op)
      `EXE_LHU, `EXE_LBU: memsignext = 1'b0;
      default: memsignext = 1'b1;
    endcase
  end

  // membyte
  always @(*) begin
    case (op)
      `EXE_LB, `EXE_LBU, `EXE_SB: membyte = `MEM_BYTE;
      `EXE_LH, `EXE_LHU, `EXE_SH: membyte = `MEM_HALFWORD;
      default: membyte = `MEM_WORD;
    endcase
  end


endmodule
