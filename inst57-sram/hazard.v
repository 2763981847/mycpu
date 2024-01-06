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
    input wire flush_exceptionM,
    input wire [4:0] writeregM,
    input wire regwriteM,
    input wire memtoregM,
    output wire flushM,


    //write back stage
    input wire [4:0] writeregW,
    input wire regwriteW,
    output wire flushW
);

  wire lwstallD, branchstallD, jumpstallD;

  //forwarding sources to D stage (branch equality)
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

  //stalls
  assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
  assign  branchstallD = branchD &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
  assign  jumpstallD = regjumpD & ((regwriteE & writeregE == rsD) | (memtoregM & writeregM == rsD));
  assign  flushD = flush_exceptionM;
  assign  stallD = lwstallD | branchstallD | jumpstallD | div_stallE;
  assign  stallF = stallD & ~flush_exceptionM;

  assign  flushE = flush_exceptionM | (stallD & ~div_stallE);
  assign  stallE = stallD;

  assign  flushM = flush_exceptionM;

  assign  flushW = flush_exceptionM;

  //stalling D stalls all previous stages
  // assign flushE = lwstallD | branchstallD;

  //stalling D flushes next stage
  // Note: not necessary to stall D stage on store
  //       if source comes from load;
  //       instead, another bypass network could
  //       be added from W to M
endmodule
