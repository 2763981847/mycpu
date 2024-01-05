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


  datapath dp (
      clk,
      rst,
      pc,
      instr,
      memwen,
      aluout,
      writedata,
      readdata
  );

endmodule
