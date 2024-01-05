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
    input wire [31:0] instrD,
    output wire [2:0] branchcontrolD,
    output wire branchD,
    jumpD,
    regjumpD,

    //execute stage
    input wire flushE,
    output wire memtoregE,
    alusrcE,
    linkE,
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
  wire memtoregD, memwriteD, alusrcD, regdstD, regwriteD,linkD, hilowriteD, memsignextD;
  wire [1:0] membyteD;
  wire [7:0] alucontrolD;
  wire [5:0] opD, functD;
  wire [4:0] rtD;

  //execute stage
  wire memwriteE, memsignextE;
  wire [1:0] membyteE;

  assign opD = instrD[31:26];
  assign functD = instrD[5:0];
  assign rtD = instrD[20:16];
  maindec md (
      instrD,
      memtoregD,
      memwriteD,
      branchD,
      alusrcD,
      regdstD,
      regwriteD,
      jumpD,
      regjumpD,
      linkD,
      hilowriteD,
      memsignextD,
      membyteD
  );

  aludec ad (
      opD,
      functD,
      alucontrolD
  );

  branchdec bd (
      opD,
      rtD,
      branchcontrolD
  );


  //pipeline registers
  floprc #(18) regE (
      clk,
      rst,
      flushE,
      {
        memtoregD,
        memwriteD,
        alusrcD,
        linkD,
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
        linkE,
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
