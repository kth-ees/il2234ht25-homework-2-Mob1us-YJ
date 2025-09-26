module LFSR_6bit (
  input  logic clk, rst_n,
  input  logic sel,
  input  logic [5:0] parallel_in,
  output logic [5:0] parallel_out
);
  logic [5:0] lfsr_reg;
  logic feedback;
  assign feedback = lfsr_reg[1] ^ lfsr_reg[5];

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            lfsr_reg <= 6'b000000;
        end
        else begin
            if (sel == 1'b0) begin
                lfsr_reg <= parallel_in;
            end
            else begin
                lfsr_reg <= {lfsr_reg[4:0], feedback};
            end
        end
    end
    always @(*) begin
        parallel_out = lfsr_reg;
    end

endmodule
