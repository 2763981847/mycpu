`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard (
    //fetch stage
    input wire i_stall,
    output wire stallF,
    //decode stage
    input wire [4:0] rsD,
    rtD,
    input wire branchD,
    regjumpD,
    output wire forwardaD,
    forwardbD,
    output wire stallD,
    output wire flushD,
    //execute stage
    input wire [4:0] rsE,
    rtE,
    input wire [4:0] writeregE,
    input wire regwriteE,
    input wire memtoregE,
    input wire div_stallE,
    output reg [1:0] forwardaE,
    forwardbE,
    output wire flushE,
    stallE,
    //mem stage
    input wire d_stall,
    input wire flush_exceptionM,
    input wire [4:0] writeregM,
    input wire regwriteM,
    input wire memtoregM,
    output wire flushM,
    output wire stallM,

    //write back stage
    input wire [4:0] writeregW,
    input wire regwriteW,
    output wire flushW,
    output wire stallW
);

  wire lwstallD, branchstallD, jumpstallD, longest_stall;

  //forwarding sources to D stage (branch equality or jump register)
  assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
  assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);

  //forwarding sources to E stage (ALU)

  always @(*) begin
    forwardaE = 2'b00;
    forwardbE = 2'b00;
    if (rsE != 0) begin
      /* code */
      if (rsE == writeregM & regwriteM) begin
        /* code */
        forwardaE = 2'b10;
      end else if (rsE == writeregW & regwriteW) begin
        /* code */
        forwardaE = 2'b01;
      end
    end
    if (rtE != 0) begin
      /* code */
      if (rtE == writeregM & regwriteM) begin
        /* code */
        forwardbE = 2'b10;
      end else if (rtE == writeregW & regwriteW) begin
        /* code */
        forwardbE = 2'b01;
      end
    end
  end

  // stalls
  assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
  assign branchstallD = branchD &
  			(regwriteE & 
  			(writeregE == rsD | writeregE == rtD) |
  			memtoregM &
  			(writeregM == rsD | writeregM == rtD));
  assign jumpstallD = regjumpD & ((regwriteE & writeregE == rsD) | (memtoregM & writeregM == rsD));


  assign longest_stall = i_stall | d_stall;
  assign stallF = stallD & ~flush_exceptionM;
  assign stallD = stallE | branchstallD | jumpstallD | lwstallD;
  assign stallE = stallM | div_stallE;
  assign stallM = stallW;
  assign stallW = longest_stall;


  assign flushD = flush_exceptionM;
  assign flushE = flush_exceptionM | (stallD & ~stallE);
  assign flushM = flush_exceptionM;
  assign flushW = flush_exceptionM;

endmodule
