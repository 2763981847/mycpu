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
    input wire [5:0] ext_int,
    //inst
    output wire [31:0] pcF,
    output wire inst_enF,
    input wire [31:0] instrF,
    //data
    output wire mem_enM,
    output wire [31:0] mem_addrM,
    input wire [31:0] mem_rdataM,
    output wire [3:0] mem_wenM,
    output wire [31:0] mem_wdataM,
    //debug
    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata,
    // harzard
    input wire i_stall,
    d_stall,
    output wire longest_stall
);


  //fetch stage
  wire stallF;
  //FD
  wire [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD;
  wire [2:0] branchcontrolD;
  wire is_in_delayslotF, pcErrorF;
  //decode stage
  wire [31:0] pcplus4D, instrD, pcD;
  wire forwardaD, forwardbD;
  wire [5:0] opD, functD;
  wire [4:0] rsD, rtD, rdD, saD;
  wire pcsrcD, memtoregD, memwriteD, branchD, alusrcD,regdstD,regwriteD, jumpD,regjumpD, 
  linkD,hilowriteD,memsignextD,flushD, stallD,breakD,syscallD,eretD,cp0writeD,cp0toregD,
  is_in_delayslotD,riD,pcErrorD;
  wire [1:0] memsizeD;
  wire [7:0] alucontrolD;
  wire [31:0] signimmD, signimmshD;
  wire [31:0] srcaD, srca2D, srcbD, srcb2D;
  //execute stage
  wire flushE,memtoregE, memwriteE, alusrcE, linkE, regdstE, regwriteE, hilowriteE, memsignextE,
  div_stallE,stallE,breakE,syscallE,eretE,cp0writeE,cp0toregE,is_in_delayslotE,riE,overflowE,
  pcErrorE;
  wire [1:0] memsizeE;
  wire [7:0] alucontrolE;
  wire [31:0] pcplus4E, pcE;
  wire [1:0] forwardaE, forwardbE;
  wire [4:0] rsE, rtE, rdE, saE;
  wire [4:0] writeregE1, writeregE;
  wire [31:0] signimmE;
  wire [31:0] srcaE, srca2E, srca3E, srcbE, srcb2E, srcb3E;
  wire [63:0] aluoutE;
  wire [31:0] aluout2E;
  wire [31:0] cp0readdataE, cp0readdata2E, cp0_causeE, cp0_statusE, cp0_epcE;

  //mem stage
  wire [31:0] pcM;
  wire flushM,memtoregM, memwriteM, regwriteM, memsignextM, breakM, syscallM, eretM,cp0writeM,cp0toregM,
  is_in_delayslotM,riM,overflowM,pcErrorM,addrErrorSwM,addrErrorLwM,stallM,flush_exceptionM;
  wire [31:0] hiM, loM, aluoutM;
  wire [1:0] memsizeM;
  wire [4:0] writeregM;
  wire [31:0] writedataM, readdataM;
  wire [31:0] cp0readdataM, cp0_causeM, cp0_statusM, cp0_epcM;

  //writeback stage
  wire [31:0] pcW;
  wire flushW, memtoregW, regwriteW, cp0toregW, stallW;
  wire [4:0] writeregW;
  wire [31:0] aluoutW, readdataW, resultW, cp0readdataW;


  //hazard detection
  hazard h (
      //fetch stage
      i_stall,
      stallF,
      //decode stage
      rsD,
      rtD,
      branchD,
      regjumpD,
      forwardaD,
      forwardbD,
      stallD,
      flushD,
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
      d_stall,
      flush_exceptionM,
      writeregM,
      regwriteM,
      memtoregM,
      flushM,
      stallM,
      //write back stage
      writeregW,
      regwriteW,
      flushW,
      stallW
  );


  assign longest_stall = i_stall | d_stall | div_stallE;

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
  wire [31:0] pcnext;
  mux2 #(32) exceptionmux (
      pcnextFD,
      exceptionM.pc_exception,
      exceptionM.pc_trap,
      pcnext
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
  // cp0 register (operates in excution and memory)
  cp0_reg cp0 (
      .clk(clk),
      .rst(rst),
      .we_i(cp0writeM),
      .waddr_i(writeregM),
      .raddr_i(rdE),
      .data_i(aluoutM),
      .int_i(ext_int),
      .excepttype_i(exceptionM.except_type),
      .current_inst_addr_i(pcM),
      .is_in_delayslot_i(is_in_delayslotM),
      .bad_addr_i(exceptionM.badvaddrM),
      .count_o(),
      .data_o(cp0readdataE),
      .compare_o(),
      .status_o(cp0_statusE),
      .cause_o(cp0_causeE),
      .epc_o(cp0_epcE),
      .config_o(),
      .prid_o(),
      .badvaddr(),
      .timer_int_o()
  );


  // hi/lo register
  hilo_reg hilo (
      clk,
      rst,
      aluoutE,
      hilowriteE & ~flush_exceptionM,
      hiM,
      loM
  );

  //fetch stage logic
  assign inst_enF = ~flush_exceptionM & ~pcErrorF;
  assign is_in_delayslotF = branchD | jumpD;
  assign pcErrorF = pcF[1:0] != 2'b00;

  pc #(32) pcreg (
      clk,
      rst,
      ~stallF,
      pcnext,
      pcF
  );
  adder pcadd1 (
      pcF,
      32'b100,
      pcplus4F
  );
  //decode stage
  flopenrc #(98) regD (
      clk,
      rst,
      ~stallD,
      flushD,
      {pcplus4F, instrF, pcF, is_in_delayslotF, pcErrorF},
      {pcplus4D, instrD, pcD, is_in_delayslotD, pcErrorD}
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
      memsizeD,
      breakD,
      syscallD,
      eretD,
      cp0writeD,
      cp0toregD,
      riD
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
  flopenrc #(206) regE (
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
        pcD,  // 32 bits
        memtoregD,  // 1 bit
        memwriteD,  // 1 bit
        alusrcD,  // 1 bit
        linkD,  // 1 bit
        regdstD,  // 1 bit
        regwriteD,  // 1 bit
        alucontrolD,  // 8 bits
        hilowriteD,  // 1 bit
        memsignextD,  // 1 bit
        memsizeD,  // 2 bits
        breakD,  // 1 bit
        syscallD,  // 1 bit
        eretD,  // 1 bit
        cp0writeD,  // 1 bit
        cp0toregD,  // 1 bit
        is_in_delayslotD,  // 1 bit
        riD,  // 1 bit
        pcErrorD
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
        pcE,
        memtoregE,
        memwriteE,
        alusrcE,
        linkE,
        regdstE,
        regwriteE,
        alucontrolE,
        hilowriteE,
        memsignextE,
        memsizeE,
        breakE,
        syscallE,
        eretE,
        cp0writeE,
        cp0toregE,
        is_in_delayslotE,
        riE,
        pcErrorE
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
      stallE,
      aluoutE,
      div_stallE,
      overflowE
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

  mux2 #(32) forwardcp0emux (
      cp0readdataE,
      aluoutM,
      cp0toregM & (rdE == writeregM),
      cp0readdata2E
  );

  // 为了复用通路
  mux2 #(32) aluoutmux (
      aluoutE[31:0],
      cp0readdata2E,
      cp0toregE,
      aluout2E
  );


  //mem stage
  flopenrc #(244) regM (
      clk,
      rst,
      ~stallM,
      flushM,
      {
        pcE,  // 32 bits
        srcb2E,  // 32 bits
        aluout2E,  // 32 bits
        writeregE,  // 5 bits
        memtoregE,  // 1 bit
        memwriteE,  // 1 bit
        regwriteE,  // 1 bit
        memsignextE,  // 1 bit
        memsizeE,  // 2 bits
        breakE,  // 1 bit
        syscallE,  // 1 bit
        eretE,  // 1 bit
        cp0writeE,  // 1 bit
        cp0toregE,  // 1 bit
        is_in_delayslotE,  // 1 bit
        riE,  // 1 bit
        overflowE,  // 1 bit
        pcErrorE,  // 1 bit
        cp0readdata2E,  // 32 bits
        cp0_causeE,  // 32 bits
        cp0_statusE,  // 32 bits
        cp0_epcE  // 32 bits
      },
      {
        pcM,  // 32 bits
        writedataM,  // 32 bits
        aluoutM,  // 32 bits
        writeregM,  // 5 bits
        memtoregM,  // 1 bit
        memwriteM,  // 1 bit
        regwriteM,  // 1 bit
        memsignextM,  // 1 bit
        memsizeM,  // 2 bits
        breakM,  // 1 bit
        syscallM,  // 1 bit
        eretM,  // 1 bit
        cp0writeM,  // 1 bit
        cp0toregM,  // 1 bit
        is_in_delayslotM,  // 1 bit
        riM,  // 1 bit
        overflowM,  // 1 bit
        pcErrorM,  // 1 bit
        cp0readdataM,  // 32 bits
        cp0_causeM,  // 32 bits
        cp0_statusM,  // 32 bits
        cp0_epcM  // 32 bits
      }
  );
  mem_ctrl mc (
      memsizeM,
      aluoutM[1:0],
      memwriteM,
      memtoregM,
      memsignextM,
      writedataM,
      mem_rdataM,
      mem_wenM,
      mem_wdataM,
      readdataM,
      addrErrorSwM,
      addrErrorLwM
  );

  exception exceptionM (
      .rst(rst),
      .ext_int(ext_int),
      .ri(riM),
      .break(breakM),
      .syscall(syscallM),
      .overflow(overflowM),
      .addrErrorSw(addrErrorSwM),
      .addrErrorLw(addrErrorLwM),
      .pcError(pcErrorM),
      .eretM(eretM),
      .cp0_status(cp0_statusM),
      .cp0_cause(cp0_causeM),
      .cp0_epc(cp0_epcM),
      .pcM(pcM),
      .alu_outM(aluoutM),
      .except_type(),
      .flush_exception(flush_exceptionM),
      .pc_exception(),
      .pc_trap(),
      .badvaddrM()
  );

  assign mem_addrM = aluoutM;
  assign mem_enM   = (memwriteM | memtoregM) & ~addrErrorSwM & ~addrErrorLwM;  // 读或者写

  //writeback stage
  flopenrc #(136) regW (
      clk,
      rst,
      ~stallW,
      flushW,

      {
        pcM,  // 32 bits
        aluoutM,  // 32 bits
        readdataM,  // 32 bits
        writeregM,  // 5 bits
        memtoregM,  // 1 bit
        regwriteM,  // 1 bit
        cp0toregM,  // 1 bit
        cp0readdataM  // 32 bits
      },
      {
        pcW,  // 32 bits
        aluoutW,  // 32 bits
        readdataW,  // 32 bits
        writeregW,  // 5 bits
        memtoregW,  // 1 bit
        regwriteW,  // 1 bit
        cp0toregW,  // 1 bit
        cp0readdataW  // 32 bits
      }
  );

  mux2 #(32) resmux (
      aluoutW,
      readdataW,
      memtoregW,
      resultW
  );

  assign debug_wb_pc = pcW;
  assign debug_wb_rf_wen = {4{regwriteW & (~stallW | flushW)}};
  assign debug_wb_rf_wnum = writeregW;
  assign debug_wb_rf_wdata = resultW;



endmodule
