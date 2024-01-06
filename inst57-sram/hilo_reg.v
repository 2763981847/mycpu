module hilo_reg (
    input clk,
    input reset,
    input [63:0] hilo_input,
    input wen,
    output reg [31:0] hi_output,
    output reg [31:0] lo_output
);

  always @(negedge clk or posedge reset) begin
    if (reset) begin
      // 复位，清零 hi 和 lo 寄存器
      hi_output <= 32'b0;
      lo_output <= 32'b0;
    end else if (wen) begin
      // 写入
      hi_output <= hilo_input[63:32];
      lo_output <= hilo_input[31:0];
    end else begin
      // 读取
      hi_output <= hi_output;
      lo_output <= lo_output;
    end
  end

endmodule
