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
    output wire memtoreg,
    memwrite,
    output wire branch,
    alusrc,
    output wire regdst,
    regwrite,
    output wire jump
);
  reg [8:0] controls;
  assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump} = controls;
  always @(*) begin
    case (op)
      // R-TYPE 
      `EXE_NOP: controls <= 7'b1100000;  //R-TYRE
      // 逻辑指令 immediate
      `EXE_ANDI, `EXE_ORI, `EXE_XORI, `EXE_LUI: controls <= 7'b1010000;  //ANDI, ORI, XORI, LUI
      // 算术指令 immediate
      `EXE_ADDI: controls <= 7'b1010000;  //ADDI
      // 访存指令
      `EXE_LW: controls <= 7'b1010010;  //LW
      `EXE_SW: controls <= 7'b0010100;  //SW
      // 跳转指令
      `EXE_BEQ: controls <= 7'b0001000;  //BEQ
      `EXE_J: controls <= 7'b0000001;  //J
      default: controls <= 7'b0000000;  //illegal op
    endcase
  end
endmodule
