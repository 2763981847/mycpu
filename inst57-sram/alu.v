`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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

module alu (
    input wire clk,
    rst,
    input wire [31:0] a,
    b,
    hi,
    lo,
    input wire [4:0] sa,
    input wire [7:0] op,
    output reg [63:0] y,
    output reg div_stall,
    output wire overflow
);

  reg start_div = 1'b0, signed_div = 1'b0;
  wire div_ready;
  wire [63:0] div_result;
  assign overflow = (op == `EXE_ADD_OP && ((a[31] & b[31] & ~y[31]) | (~a[31] & ~b[31] & y[31]))) | 
                  (op == `EXE_SUB_OP && ((a[31] & ~b[31] & ~y[31]) | (~a[31] & b[31] & y[31])));

  always @(*) begin
    case (op)
      // 逻辑运算指令 R-type
      `EXE_AND_OP: y = a & b;
      `EXE_OR_OP: y = a | b;
      `EXE_XOR_OP: y = a ^ b;
      `EXE_NOR_OP: y = ~(a | b);
      // 逻辑运算指令 I-type
      `EXE_ANDI_OP: y = a & {{16{1'b0}}, b[15:0]};
      `EXE_ORI_OP: y = a | {{16{1'b0}}, b[15:0]};
      `EXE_XORI_OP: y = a ^ {{16{1'b0}}, b[15:0]};
      `EXE_LUI_OP: y = {b[15:0], {16{1'b0}}};
      // 算术运算指令	R-type
      `EXE_ADD_OP, `EXE_ADDU_OP: y = a + b;
      `EXE_SUB_OP: y = $signed(a) - $signed(b);
      `EXE_SUBU_OP: y = a - b;
      `EXE_SLT_OP: y = $signed(a) < $signed(b);
      `EXE_SLTU_OP: y = a < b;
      `EXE_MULT_OP: y = $signed(a) * $signed(b);
      `EXE_MULTU_OP: y = a * b;
      `EXE_DIV_OP, `EXE_DIVU_OP: y = div_result;
      // 算术运算指令	I-type
      `EXE_ADDI_OP, `EXE_ADDIU_OP: y = a + b;
      `EXE_SLTI_OP: y = $signed(a) < $signed(b);
      `EXE_SLTIU_OP: y = a < b;
      // 位移运算指令
      `EXE_SLL_OP: y = b << sa;
      `EXE_SRL_OP: y = b >> sa;
      `EXE_SRA_OP: y = $signed(b) >>> sa;
      `EXE_SLLV_OP: y = b << a[4:0];
      `EXE_SRLV_OP: y = b >> a[4:0];
      `EXE_SRAV_OP: y = $signed(b) >>> a[4:0];
      // 数据移动指令
      `EXE_MFHI_OP: y = hi;
      `EXE_MFLO_OP: y = lo;
      `EXE_MTHI_OP: y = {a, lo};
      `EXE_MTLO_OP: y = {hi, a};
      // 特权指令
      `EXE_MTC0_OP: y = b;
      default: y = 63'b0;
    endcase
  end

  div_radix2 DIV (
      .clk      (clk),
      .rst      (rst),
      .a        (a),           //divident
      .b        (b),           //divisor
      .sign     (signed_div),  //1 signed
      .opn_valid(start_div),
      .res_valid(div_ready),
      .res_ready(start_div),
      .result   (div_result)
  );


  // div divider (
  //     clk,
  //     rst,
  //     signed_div,
  //     a,
  //     b,
  //     start_div,
  //     1'b0,
  //     div_result,
  //     div_ready
  // );

  always @(*) begin
    case (op)
      `EXE_DIV_OP, `EXE_DIVU_OP: begin
        signed_div = op == `EXE_DIV_OP ? 1'b1 : 1'b0;
        if (div_ready == 1'b0) begin
          start_div = 1'b1;
          div_stall = 1'b1;
        end else begin
          start_div = 1'b0;
          div_stall = 1'b0;
        end
      end
      default: begin
        start_div = 1'b0;
        div_stall = 1'b0;
      end
    endcase
  end
endmodule
