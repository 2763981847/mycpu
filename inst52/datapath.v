`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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

module datapath (
    input wire clk,
    rst,
    output wire [31:0] pcF,
    input wire [31:0] instrF,
    output wire [3:0] memwenM,
    output wire [31:0] aluoutM,
    realwdataM,
    input wire [31:0] readdataM
);

  //fetch stage
  wire stallF;
  //FD
  wire [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD;
  //decode stage
  wire [31:0] pcplus4D, instrD;
  wire forwardaD, forwardbD;
  wire [5:0] opD, functD;
  wire [4:0] rsD, rtD, rdD, saD;
  wire pcsrcD, memtoregD, memwriteD, branchD, alusrcD,regdstD,regwriteD,
  jumpD,regjumpD, linkD,hilowriteD,memsignextD,flushD, stallD;
  wire [1:0] membyteD;
  wire [7:0] alucontrolD;
  wire [31:0] signimmD, signimmshD;
  wire [31:0] srcaD, srca2D, srcbD, srcb2D;
  //execute stage
  wire memtoregE, memwriteE, alusrcE, linkE, regdstE, regwriteE, hilowriteE, memsignextE,div_stallE,stallE;
  wire [ 1:0] membyteE;
  wire [ 7:0] alucontrolE;
  wire [31:0] pcplus4E;
  wire [1:0] forwardaE, forwardbE;
  wire [4:0] rsE, rtE, rdE, saE;
  wire [4:0] writeregE1, writeregE;
  wire [31:0] signimmE;
  wire [31:0] srcaE, srca2E, srca3E, srcbE, srcb2E, srcb3E;
  wire [63:0] aluoutE;

  //mem stage
  wire memtoregM, memwriteM, regwriteM, memsignextM;
  wire [1:0] membyteM;
  wire [31:0] hiM, loM;
  wire [4:0] writeregM;
  wire [31:0] writedataM, realrdataM;

  //writeback stage
  wire memtoregW, regwriteW;
  wire [4:0] writeregW;
  wire [31:0] aluoutW, readdataW, resultW;

  //hazard detection
  hazard h (
      //fetch stage
      stallF,
      //decode stage
      rsD,
      rtD,
      branchD,
      forwardaD,
      forwardbD,
      stallD,
      //execute stage
      rsE,
      rtE,
      writeregE,
      regwriteE,
      memtoregE,
      div_stallE,
      forwardaE,
      forwardbE,
      flushE,
      stallE,
      //mem stage
      writeregM,
      regwriteM,
      memtoregM,
      //write back stage
      writeregW,
      regwriteW
  );

  //next PC logic (operates in fetch an decode)
  mux2 #(32) pcbrmux (
      pcplus4F,
      pcbranchD,
      pcsrcD,
      pcnextbrFD
  );
  mux3 #(32) pcmux (
      {pcplus4D[31:28], instrD[25:0], 2'b00},
      srca2D,
      pcnextbrFD,
      {~jumpD, regjumpD},
      pcnextFD
  );

  //regfile (operates in decode and writeback)
  regfile rf (
      clk,
      regwriteW,
      rsD,
      rtD,
      writeregW,
      resultW,
      srcaD,
      srcbD
  );

  // hi/lo register
  hilo_reg hilo (
      clk,
      rst,
      aluoutE,
      hilowriteE,
      hiM,
      loM
  );

  //fetch stage logic
  pc #(32) pcreg (
      clk,
      rst,
      ~stallF,
      pcnextFD,
      pcF
  );
  adder pcadd1 (
      pcF,
      32'b100,
      pcplus4F
  );
  //decode stage
  flopenrc #(64) regD (
      clk,
      rst,
      ~stallD,
      flushD,
      {pcplus4F, instrF},
      {pcplus4D, instrD}
  );
  signext se (
      instrD[15:0],
      signimmD
  );
  sl2 immsh (
      signimmD,
      signimmshD
  );
  adder pcadd2 (
      pcplus4D,
      signimmshD,
      pcbranchD
  );
  mux2 #(32) forwardamux (
      srcaD,
      aluoutM,
      forwardaD,
      srca2D
  );
  mux2 #(32) forwardbmux (
      srcbD,
      aluoutM,
      forwardbD,
      srcb2D
  );

  assign opD = instrD[31:26];
  assign functD = instrD[5:0];
  assign rsD = instrD[25:21];
  assign rtD = instrD[20:16];
  assign rdD = instrD[15:11];
  assign saD = instrD[10:6];

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

  branch_judge bj (
      srca2D,
      srcb2D,
      branchcontrolD,
      branchD,
      pcsrcD
  );


  //execute stage
  flopenrc #(166) regE (
      clk,
      rst,
      ~stallE,
      flushE,
      {
        srcaD,  // 32 bits
        srcbD,  // 32 bits
        signimmD,  // 32 bits
        rsD,  // 5 bits
        rtD,  // 5 bits
        rdD,  // 5 bits
        saD,  // 5 bits
        pcplus4D,  // 32 bits
        memtoregD,  // 1 bit
        memwriteD,  // 1 bit
        alusrcD,  // 1 bit
        linkD,  // 1 bit
        regdstD,  // 1 bit
        regwriteD,  // 1 bit
        alucontrolD,  // 8 bits
        hilowriteD,  // 1 bit
        memsignextD,  // 1 bit
        membyteD  // 2 bits
      },
      {
        srcaE,
        srcbE,
        signimmE,
        rsE,
        rtE,
        rdE,
        saE,
        pcplus4E,
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
  mux3 #(32) forwardaemux (
      srcaE,
      resultW,
      aluoutM,
      forwardaE,
      srca2E
  );
  mux2 #(32) srcamux (
      srca2E,
      pcplus4E,
      linkE,
      srca3E
  );
  mux3 #(32) forwardbemux (
      srcbE,
      resultW,
      aluoutM,
      forwardbE,
      srcb2E
  );
  mux3 #(32) srcbmux (
      srcb2E,
      32'b100,
      signimmE,
      {alusrcE, linkE},
      srcb3E
  );
  alu alu (
      clk,
      rst,
      srca3E,
      srcb3E,
      hiM,
      loM,
      saE,
      alucontrolE,
      aluoutE,
      div_stallE
  );

  mux2 #(5) wrmux2 (
      rtE,
      `REG_RA,
      linkE,
      writeregE1
  );

  mux2 #(5) wrmux (
      writeregE1,
      rdE,
      regdstE,
      writeregE
  );



  //mem stage
  flopr #(75) regM (
      clk,
      rst,
      {
        srcb2E,  // 32 bits
        aluoutE,  // 32 bits
        writeregE,  // 5 bits
        memtoregE,  // 1 bit
        memwriteE,  // 1 bit
        regwriteE,  // 1 bit
        memsignextE,  // 1 bit
        membyteE  // 2 bits
      },
      {
        writedataM,  // 32 bits
        aluoutM,  // 32 bits
        writeregM,  // 5 bits
        memtoregM,  // 1 bit
        memwriteM,  // 1 bit
        regwriteM,  // 1 bit
        memsignextM,  // 1 bit
        membyteM  // 2 bits
      }
  );

  mem_ctrl mc (
      membyteM,
      aluoutM[1:0],
      memwriteM,
      memsignextM,
      writedataM,
      readdataM,
      memwenM,
      realwdataM,
      realrdataM
  );

  //writeback stage
  flopr #(71) regW (
      clk,
      rst,
      {
        aluoutM,  // 32 bits
        realrdataM,  // 32 bits
        writeregM,  // 5 bits
        memtoregM,  // 1 bit
        regwriteM  // 1 bit
      },
      {
        aluoutW,  // 32 bits
        readdataW,  // 32 bits
        writeregW,  // 5 bits
        memtoregW,  // 1 bit
        regwriteW  // 1 bit
      }
  );
  mux2 #(32) resmux (
      aluoutW,
      readdataW,
      memtoregW,
      resultW
  );




endmodule
