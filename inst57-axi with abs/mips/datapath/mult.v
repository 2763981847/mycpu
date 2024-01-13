module mult (
    input wire        clk,
    input wire        rst,
    input wire [31:0] a,    // Multiplicand
    input wire [31:0] b,    // Multiplier
    input wire        sign, // 1:signed

    input wire opn_valid,  // Operation start signal
    output reg res_valid,  // Result ready signal
    input wire res_ready,  // Ready to receive result
    output reg [63:0] result  // 64-bit Result
);

  // State machine states
  localparam IDLE = 0;
  localparam COMPUTE = 1;
  localparam STALL = 2;
  localparam OUTPUT = 3;

  reg [63:0] temp_result;
  reg [1:0] state, next_state;

  // Temporary registers to hold intermediate values
  reg [31:0] operand_a, operand_b;
  reg temp_sign;
  // State machine for controlling the multiplier
  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
      next_state <= IDLE;
      res_valid <= 0;
      result <= 0;
    end else begin
      state <= next_state;
      case (state)
        IDLE: begin
          res_valid <= 0;
          if (opn_valid) begin
            operand_a  <= a;
            operand_b  <= b;
            temp_sign  <= sign;
            next_state <= COMPUTE;
          end
        end
        COMPUTE: begin
          if (temp_sign) begin
            temp_result <= $signed(operand_a) * $signed(operand_b);
          end else begin
            temp_result <= operand_a * operand_b;
          end
          next_state <= OUTPUT;
        end
        OUTPUT: begin
          res_valid <= 1;
          result <= temp_result;
          if (res_ready) begin
            next_state <= IDLE;
          end
        end
      endcase
    end
  end


endmodule
