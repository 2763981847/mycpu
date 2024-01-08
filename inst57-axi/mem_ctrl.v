`include "defines.vh"

module mem_ctrl (
    input wire [1:0] memsizeM,
    input wire [1:0] offsetM,
    input wire memwriteM,
    input wire memtoregM,
    input wire memsignextM,
    input wire [31:0] writedataM,
    input wire [31:0] readdataM,

    output reg [3:0] memwenM,
    output reg [31:0] realwdataM,
    output reg [31:0] realrdataM,
    output reg addrErrorSwM,
    output reg addrErrorLwM
);
  wire [4:0] bitoffsetM;
  assign bitoffsetM = offsetM * 8;
  always @(*) begin
    case (memsizeM)
      `MEM_BYTE: begin  // 单字节操�???
        memwenM = memwriteM ? 4'b0001 << offsetM : 4'b0000;
        realwdataM = (writedataM & `BYTE_MASK) << bitoffsetM;
        realrdataM = {{24{memsignextM & readdataM[bitoffsetM+7]}}, readdataM[bitoffsetM+:8]};
        addrErrorSwM = 1'b0;
        addrErrorLwM = 1'b0;
      end
      `MEM_HALFWORD: begin  // 半字操作
        memwenM = memwriteM ? 4'b0011 << offsetM : 4'b0000;
        realwdataM = (writedataM & `HALFWORD_MASK) << bitoffsetM;
        realrdataM = {{{16{memsignextM & readdataM[bitoffsetM+15]}}}, readdataM[bitoffsetM+:16]};
        addrErrorSwM = memwriteM & offsetM[0];
        addrErrorLwM = memtoregM & offsetM[0];
      end
      `MEM_WORD: begin  // 字操�???
        memwenM = memwriteM ? 4'b1111 : 4'b0000;
        realwdataM = writedataM;
        realrdataM = readdataM;
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
