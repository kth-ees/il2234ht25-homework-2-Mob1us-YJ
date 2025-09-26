`timescale 1ns / 1ps

module lfsr_6bit_tb;

    parameter CLK_PERIOD = 10;   

    reg        clk;
    reg        rstn;
    reg        sel;
    reg  [5:0] parallel_in;
    wire [5:0] parallel_out;

    lfsr_6bit dut (
        .clk(clk),
        .rstn(rstn),
        .sel(sel),
        .parallel_in(parallel_in),
        .parallel_out(parallel_out)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;  
    end

    initial begin      
        rstn = 1;
        sel = 0;
        parallel_in = 6'b000000;
        
        @(posedge clk);       
        rstn = 0;  
        #(CLK_PERIOD * 2);
        
        rstn = 1;  
        @(posedge clk); 
        sel = 0;  
        parallel_in = 6'b100001;
        @(posedge clk);
        
        parallel_in = 6'b101010;
        @(posedge clk);
        
        sel = 0;
        parallel_in = 6'b100001;  
        @(posedge clk);       
        sel = 1;

        repeat(15) begin
            @(posedge clk);
                    ($time - 80)/CLK_PERIOD, parallel_out, parallel_out);
        end
        
        sel = 0;
        parallel_in = 6'b111111;
        @(posedge clk);
        sel = 1;
        repeat(8) begin
            @(posedge clk);
        end

        sel = 0;
        parallel_in = 6'b010101;
        @(posedge clk);
        
        sel = 1;
        repeat(8) begin
            @(posedge clk);
        end
        
        sel = 0;
        parallel_in = 6'b000000;  
        @(posedge clk);
        
        sel = 1;
        repeat(5) begin
            @(posedge clk);
        end
        
        $finish;
    end

    initial begin
        $monitor("@%0t: clk=%b rstn=%b sel=%b parallel_in=%06b | parallel_out=%06b (%2d)", 
                 $time, clk, rstn, sel, parallel_in, parallel_out, parallel_out);
    end

    initial begin
        $dumpfile("lfsr_6bit_tb.vcd");
        $dumpvars(0, lfsr_6bit_tb);
    end

endmodule