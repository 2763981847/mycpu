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
    //fetch stage
    output wire [31:0] pcF,
    input wire [31:0] instrF,
    //decode stage
    input wire [2:0] branchcontrolD,
    input wire branchD,
    input wire jumpD,
    input wire regjumpD,
    output wire [31:0] instrD,
    //execute stage
    input wire memtoregE,
    input wire hilowriteE,
    input wire alusrcE,
    linkE,
    regdstE,
    input wire regwriteE,
    input wire [7:0] alucontrolE,
    output wire flushE,
    //mem stage
    input wire memtoregM,
    input wire memwriteM,
    input wire regwriteM,
    input wire memsignextM,
    input wire [1:0] membyteM,
    output wire [3:0] memwenM,
    output wire [31:0] aluoutM,
    realwdataM,
    input wire [31:0] readdataM,
    //writeback stage
    input wire memtoregW,
    regwriteW
);

  //fetch stage
  wire stallF;
  //FD
  wire [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD;
  //decode stage
  wire [31:0] pcplus4D;
  wire forwardaD, forwardbD;
  wire [4:0] rsD, rtD, rdD, saD;
  wire pcsrcD, flushD, stallD;
  wire [31:0] signimmD, signimmshD;
  wire [31:0] srcaD, srca2D, srcbD, srcb2D;
  //execute stage
  wire [31:0] pcplus4E;
  wire [1:0] forwardaE, forwardbE;
  wire [4:0] rsE, rtE, rdE, saE;
  wire [ 4:0] writeregE1, writeregE;
  wire [31:0] signimmE;
  wire [31:0] srcaE, srca2E,srca3E, srcbE, srcb2E, srcb3E;
  wire [63:0] aluoutE;

  //mem stage
  wire [31:0] hiM, loM;
  wire [4:0] writeregM;
  wire [31:0] writedataM, realrdataM;

  //writeback stage
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
      forwardaE,
      forwardbE,
      flushE,
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
      {~jumpD,regjumpD},
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
  flopenr #(32) r1D (
      clk,
      rst,
      ~stallD,
      pcplus4F,
      pcplus4D
  );
  flopenrc #(32) r2D (
      clk,
      rst,
      ~stallD,
      flushD,
      instrF,
      instrD
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


  branch_judge bj (
      srca2D,
      srcb2D,
      branchcontrolD,
      branchD,
      pcsrcD
  );

  assign rsD = instrD[25:21];
  assign rtD = instrD[20:16];
  assign rdD = instrD[15:11];
  assign saD = instrD[10:6];

  //execute stage
  floprc #(32) r1E (
      clk,
      rst,
      flushE,
      srcaD,
      srcaE
  );
  floprc #(32) r2E (
      clk,
      rst,
      flushE,
      srcbD,
      srcbE
  );
  floprc #(32) r3E (
      clk,
      rst,
      flushE,
      signimmD,
      signimmE
  );
  floprc #(5) r4E (
      clk,
      rst,
      flushE,
      rsD,
      rsE
  );
  floprc #(5) r5E (
      clk,
      rst,
      flushE,
      rtD,
      rtE
  );
  floprc #(5) r6E (
      clk,
      rst,
      flushE,
      rdD,
      rdE
  );
  floprc #(5) r7E (
      clk,
      rst,
      flushE,
      saD,
      saE
  );
  floprc #(32) r8E (
      clk,
      rst,
      flushE,
      pcplus4D,
      pcplus4E
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
      {alusrcE,linkE},
      srcb3E
  );
  alu alu (
      srca3E,
      srcb3E,
      hiM,
      loM,
      saE,
      alucontrolE,
      aluoutE
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
  flopr #(32) r1M (
      clk,
      rst,
      srcb2E,
      writedataM
  );
  flopr #(32) r2M (
      clk,
      rst,
      aluoutE[31:0],
      aluoutM
  );
  flopr #(5) r3M (
      clk,
      rst,
      writeregE,
      writeregM
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
  flopr #(32) r1W (
      clk,
      rst,
      aluoutM,
      aluoutW
  );
  flopr #(32) r2W (
      clk,
      rst,
      realrdataM,
      readdataW
  );
  flopr #(5) r3W (
      clk,
      rst,
      writeregM,
      writeregW
  );
  mux2 #(32) resmux (
      aluoutW,
      readdataW,
      memtoregW,
      resultW
  );
endmodule
