`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller (
    input wire clk,
    rst,
    //decode stage
    input wire [5:0] opD,
    functD,
    output wire pcsrcD,
    branchD,
    equalD,
    jumpD,

    //execute stage
    input wire flushE,
    output wire memtoregE,
    alusrcE,
    output wire regdstE,
    regwriteE,
    output wire [7:0] alucontrolE,
    output wire hilowriteE,

    //mem stage
    output wire memtoregM,
    memwriteM,
    regwriteM,
    memsignextM,
    output wire [1:0] membyteM,
    //write back stage
    output wire memtoregW,
    regwriteW
);

  //decode stage
  wire memtoregD, memwriteD, alusrcD, regdstD, regwriteD, hilowriteD, memsignextD;
  wire [1:0] membyteD;
  wire [7:0] alucontrolD;

  //execute stage
  wire memwriteE, memsignextE;
  wire [1:0] membyteE;

  maindec md (
      opD,
      functD,
      memtoregD,
      memwriteD,
      branchD,
      alusrcD,
      regdstD,
      regwriteD,
      jumpD,
      hilowriteD,
      memsignextD,
      membyteD
  );

  aludec ad (
      opD,
      functD,
      alucontrolD
  );
  // todo
  assign pcsrcD = branchD & equalD;

  //pipeline registers
  floprc #(17) regE (
      clk,
      rst,
      flushE,
      {
        memtoregD,
        memwriteD,
        alusrcD,
        regdstD,
        regwriteD,
        alucontrolD,
        hilowriteD,
        memsignextD,
        membyteD
      },
      {
        memtoregE,
        memwriteE,
        alusrcE,
        regdstE,
        regwriteE,
        alucontrolE,
        hilowriteE,
        memsignextE,
        membyteE
      }
  );
  flopr #(6) regM (
      clk,
      rst,
      {memtoregE, memwriteE, regwriteE, memsignextE, membyteE},
      {memtoregM, memwriteM, regwriteM, memsignextM, membyteM}
  );
  flopr #(2) regW (
      clk,
      rst,
      {memtoregM, regwriteM},
      {memtoregW, regwriteW}
  );
endmodule
