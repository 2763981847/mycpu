`include "defines.vh"

module mem_ctrl (
    input wire [1:0] membyteM,
    input wire [1:0] offsetM,
    input wire memwriteM,
    input wire memsignextM,
    input wire [31:0] writedataM,
    input wire [31:0] readdataM,

    output reg [ 3:0] memwenM,
    output reg [31:0] realwdataM,
    output reg [31:0] realrdataM
);
  always @(*) begin
    case (membyteM)
      `MEM_BYTE: begin  // 单字节操�??
        memwenM <= memwriteM ? 4'b0001 << offsetM : 4'b0000;
        realwdataM <= (writedataM & `BYTE_MASK) << (offsetM * 8);
        realrdataM <= {{24{memsignextM & readdataM[7]}}, readdataM[(offsetM)*8+:8]};
      end
      `MEM_HALFWORD: begin  // 半字操作
        memwenM <= memwriteM ? 4'b0011 << offsetM : 4'b0000;
        realwdataM <= (writedataM & `HALFWORD_MASK) << (offsetM * 8);
        realrdataM <= {{{16{readdataM[15] & memsignextM}}}, readdataM[(offsetM)*8+:16]};
      end
      `MEM_WORD: begin  // 字操�??
        memwenM <= memwriteM ? 4'b1111 : 4'b0000;
        realwdataM <= writedataM;
        realrdataM <= readdataM;
      end
      default: begin
        memwenM <= 4'b0000;
        realwdataM <= 32'b0;
        realrdataM <= 32'b0;
      end
    endcase
  end

endmodule
