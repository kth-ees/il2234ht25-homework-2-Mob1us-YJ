`timescale 1ns / 1ps

module shift_register_tb(
    );
    parameter N = 4;
    parameter CLK_PERIOD = 10;
    
    logic clk;
    logic rst_n;
    logic serial_parallel;
    logic load_enable;
    logic serial_in;
    logic [N-1:0] parallel_in;
    logic [N-1:0] parallel_out;
    logic serial_out;
    
    shift_register #(
        .N(N)
    ) dut(
        .clk(clk),
        .rst_n(rst_n),
        .serial_parallel(serial_parallel),
        .load_enable(load_enable),
        .serial_in(serial_in),
        .parallel_in(parallel_in),
        .serial_out(serial_out),
        .parallel_out(parallel_out)    
    );
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // test case
    initial begin
        rst_n = 1;
        serial_parallel = 0;
        load_enable = 0;
        serial_in = 0;
        parallel_in = 0;
        
        @(posedge clk);
        
        rst_n = 0;  
        #(CLK_PERIOD * 2);  
        
        rst_n = 1;  
        @(posedge clk);

        serial_parallel = 0;  
        load_enable = 1;      
        
        serial_in = 1;
        @(posedge clk);
        serial_in = 1;
        serial_in = 0;
        @(posedge clk);
        serial_in = 1;
        @(posedge clk);
        serial_in = 0;  
        repeat(4) begin
            @(posedge clk);
        end
        
        load_enable = 0;  
        serial_in = 1;    
        @(posedge clk);
        // parallel test
        load_enable = 1;       
        serial_parallel = 1;  
        parallel_in = 4'b1010; 
        
        @(posedge clk);
        
        parallel_in = 4'b0110; 
        @(posedge clk);
        parallel_in = 4'b1111;
        @(posedge clk);       
        serial_parallel = 0;
        serial_in = 0;
        @(posedge clk);
        
        serial_parallel = 1;
        parallel_in = 4'b0000;
        @(posedge clk);
        
        parallel_in = 4'b1111;
        @(posedge clk);   
        #100; 
        $finish;
    end

    initial begin
        $monitor("%0t | clk=%b rst_n=%b load_en=%b ser_par=%b ser_in=%b par_in=%b | ser_out=%b par_out=%b", 
                 $time, clk, rst_n, load_enable, serial_parallel, serial_in, parallel_in, serial_out, parallel_out);
    end

    initial begin
        $dumpfile("shift_register_tb.vcd");
        $dumpvars(0, shift_register_tb);
    end
    
endmodule
