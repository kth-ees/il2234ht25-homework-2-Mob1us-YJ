module shift_register #(parameter N=4)
                      (input logic clk,
                       input logic rst_n,
                       input logic serial_parallel,
                       input logic load_enable,
                       input logic serial_in,
                       input logic [N-1:0] parallel_in,
                       output logic [N-1:0] parallel_out,
                       output logic serial_out);
    logic [N-1:0] shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            shift_reg <= 0;
        end
        else if (load_enable) begin
            if (serial_parallel == 1'b0) begin
                // serial_in -> MSB -> ... -> LSB -> serial_out
                shift_reg <= {serial_in, shift_reg[N-1:1]};
            end
            else begin
                shift_reg <= parallel_in;
            end
        end
    end
    
    assign serial_out = shift_reg[0];
    assign parallel_out = shift_reg;
endmodule