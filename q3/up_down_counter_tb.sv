// tb_up_down_counter.sv
`timescale 1ns/1ps
module tb_up_down_counter;

  localparam int N = 4;

  logic             clk;
  logic             rst_n;
  logic             up_down;
  logic             load;
  logic [N-1:0]     input_load;
  logic [N-1:0]     count_out;
  logic             carry_out;

  // DUT
  up_down_counter #(.N(N)) dut (
    .clk, .rst_n, .up_down, .load, .input_load, .count_out, .carry_out
  );

  // clock
  initial clk = 0;
  always #5 clk = ~clk;

  // simple monitors
  logic [N-1:0] prev_count;
  always_ff @(posedge clk) begin
    prev_count <= count_out;
    if (carry_out)
      $display("[%0t] carry_out=1 (wrap)  dir=%0d  count=%0d", $time, up_down, count_out);
  end

  // helpers
  task pulse_load(input logic [N-1:0] val);
    begin
      input_load = val;
      load = 1'b1;
      @(posedge clk);
      load = 1'b0;
    end
  endtask

  task run_cycles(input int k);
    begin
      repeat (k) @(posedge clk);
    end
  endtask

  // checks: carry must pulse only on wrap
  always_ff @(posedge clk) begin
    if (rst_n && !load) begin
      if (up_down) begin
        if (prev_count == {N{1'b1}})
          assert(carry_out) else $error("Expected carry on up-wrap");
        else
          assert(!carry_out) else $error("Unexpected carry when counting up");
      end else begin
        if (prev_count == '0)
          assert(carry_out) else $error("Expected carry on down-wrap");
        else
          assert(!carry_out) else $error("Unexpected carry when counting down");
      end
    end
  end

  // stimulus
  initial begin
    rst_n = 0;
    up_down = 1;     // start up
    load = 0;
    input_load = '0;

    run_cycles(2);
    rst_n = 1;

    // load a value and count up through a wrap
    pulse_load(4'd14);
    run_cycles(4);      // 14,15,0,1 -> one wrap expected at 15->0

    // switch to down and force a wrap at 0->MAX
    up_down = 0;
    run_cycles(4);      // should see another wrap when 0->15

    // load mid value and count down a bit
    pulse_load(4'd3);
    run_cycles(6);

    // back to up, load 0, run across two wraps
    up_down = 1;
    pulse_load(4'd0);
    run_cycles(20);

    $display("Test finished at %0t", $time);
    $finish;
  end

endmodule
