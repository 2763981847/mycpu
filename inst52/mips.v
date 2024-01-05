`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips (
    input wire clk,
    rst,
    output wire [31:0] pc,
    input wire [31:0] instr,
    output wire [3:0] memwen,
    output wire [31:0] aluout,
    writedata,
    input wire [31:0] readdata
);

  wire [31:0] instrD;
  wire [ 2:0] branchcontrolD;
  wire regdstE,alusrcE,linkE,pcsrcD,memtoregE,memtoregM,memsignextM,memtoregW,
			regwriteE,regwriteM,regwriteW,hilowriteE,branchD,jumpD,regjumpD;
  wire [1:0] membyteM;
  wire [7:0] alucontrolE;
  wire flushE;

  controller c (
      clk,
      rst,
      //decode stage
      instrD,
      branchcontrolD,
      branchD,
      jumpD,
      regjumpD,

      //execute stage
      flushE,
      memtoregE,
      alusrcE,
      linkE,
      regdstE,
      regwriteE,
      alucontrolE,
      hilowriteE,

      //mem stage
      memtoregM,
      memwrite,
      regwriteM,
      memsignextM,
      membyteM,

      //write back stage
      memtoregW,
      regwriteW
  );
  datapath dp (
      clk,
      rst,
      //fetch stage
      pc,
      instr,
      //decode stage
      branchcontrolD,
      branchD,
      jumpD,
      regjumpD,
      instrD,
      //execute stage
      memtoregE,
      hilowriteE,
      alusrcE,
      linkE,
      regdstE,
      regwriteE,
      alucontrolE,
      flushE,
      //mem stage
      memtoregM,
      memwrite,
      regwriteM,
      memsignextM,
      membyteM,
      memwen,
      aluout,
      writedata,
      readdata,
      //writeback stage
      memtoregW,
      regwriteW
  );

endmodule
