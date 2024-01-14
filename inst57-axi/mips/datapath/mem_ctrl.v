`include "defines.vh"
module mem_ctrl (
    input wire [ 1:0] memsizeM,     // 0: byte, 1: halfword, 2: word
    input wire [ 1:0] offsetM,      // 访存地址偏移量（字节偏移量）
    input wire        memwriteM,    // 访存写使能
    input wire        memtoregM,    // 访存读使能
    input wire        memsignextM,  // 访存读数据符号扩展
    input wire [31:0] writedataM,   // 原始访存写数据
    input wire [31:0] readdataM,    // 原始访存读数据

    output reg [ 3:0] memwenM,       // 访存写使能（4位）
    output reg [31:0] realwdataM,    // 处理后访存写数据
    output reg [31:0] realrdataM,    // 处理后访存读数据 
    output reg        addrErrorSwM,  // 访存写地址错误
    output reg        addrErrorLwM   // 访存读地址错误
);
  wire [4:0] bitoffsetM;  // 访存地址偏移量（比特偏移量）
  assign bitoffsetM = offsetM * 8;
  always @(*) begin
    case (memsizeM)
      `MEM_BYTE: begin  // 单字节操作
        memwenM = memwriteM ? 4'b0001 << offsetM : 4'b0000;
        realwdataM = (writedataM & `BYTE_MASK) << bitoffsetM;
        realrdataM = {{24{memsignextM & readdataM[bitoffsetM+7]}}, readdataM[bitoffsetM+:8]};
        // 单字节操作不会出现地址错误
        addrErrorSwM = 1'b0;
        addrErrorLwM = 1'b0;
      end
      `MEM_HALFWORD: begin  // 半字操作
        memwenM = memwriteM ? 4'b0011 << offsetM : 4'b0000;
        realwdataM = (writedataM & `HALFWORD_MASK) << bitoffsetM;
        realrdataM = {{{16{memsignextM & readdataM[bitoffsetM+15]}}}, readdataM[bitoffsetM+:16]};
        // 半字操作时，地址错误发生在最低位
        addrErrorSwM = memwriteM & offsetM[0];
        addrErrorLwM = memtoregM & offsetM[0];
      end
      `MEM_WORD: begin  // 字操作
        memwenM = memwriteM ? 4'b1111 : 4'b0000;
        realwdataM = writedataM;
        realrdataM = readdataM;
        // 字操作时，地址错误发生在最低两位
        addrErrorSwM = memwriteM & (offsetM[0] | offsetM[1]);
        addrErrorLwM = memtoregM & (offsetM[0] | offsetM[1]);
      end
      default: begin
        memwenM = 4'b0000;
        realwdataM = 32'b0;
        realrdataM = 32'b0;
        addrErrorSwM = 1'b0;
        addrErrorLwM = 1'b0;
      end
    endcase
  end
endmodule
