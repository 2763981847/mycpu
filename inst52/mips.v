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
    output wire memwrite,
    output wire [31:0] aluout,
    writedata,
    input wire [31:0] readdata
);

  wire [5:0] opD, functD;
  wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW,hilowriteE,branchD,jumpD;
  wire [7:0] alucontrolE;
  wire flushE, equalD;

  controller c (
      clk,
      rst,
      //decode stage
      opD,
      functD,
      pcsrcD,
      branchD,
      equalD,
      jumpD,

      //execute stage
      flushE,
      memtoregE,
      alusrcE,
      regdstE,
      regwriteE,
      alucontrolE,
      hilowriteE,

      //mem stage
      memtoregM,
      memwrite,
      regwriteM,
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
      pcsrcD,
      branchD,
      jumpD,
      equalD,
      opD,
      functD,
      //execute stage
      memtoregE,
      hilowriteE,
      alusrcE,
      regdstE,
      regwriteE,
      alucontrolE,
      flushE,
      //mem stage
      memtoregM,
      regwriteM,
      aluout,
      writedata,
      readdata,
      //writeback stage
      memtoregW,
      regwriteW
  );

endmodule
