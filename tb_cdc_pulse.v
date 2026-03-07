// testbench for CDC_pulse
`timescale 1ns/1ps

`include "./cdc_pulse.v"
`include "./cdc_pulse_fifo_sync.v"

`define cdc_async_fifo 

module tb_cdc_pulse;
    reg rst_n;
    reg fast_rst_n;
    reg slow_rst_n;
    reg osc_fast;
    reg osc_slow;
    reg pulse_in;
    wire pulse_out;
 
    // Instantiate the CDC pulse module
    `ifdef cdc_async_fifo
    cdc_pulse_fifo_sync dut_fifo_sync (
        .fast_rst_n(fast_rst_n),
        .slow_rst_n(slow_rst_n),
        .osc_fast(osc_fast),
        .osc_slow(osc_slow),
        .pulse_in(pulse_in),
        .pulse_out(pulse_out)
    );
    `else
    cdc_pulse dut (
        .rst_n(rst_n),
        .osc_fast(osc_fast),
        .osc_slow(osc_slow),
        .pulse_in(pulse_in),
        .pulse_out(pulse_out)
    );
    `endif

    // Clock generation
    initial begin
        osc_fast = 0;
        forever #5 osc_fast = ~osc_fast; // 100MHz clock
    end

    // Clock generation
    initial begin
        osc_slow = 0;
        forever #10 osc_slow = ~osc_slow; // 50MHz clock
    end

    // Reset and stimulus
    initial begin
        // waveform
        $dumpfile("./fsdb/tb_cdc_pulse.vcd");
        $dumpvars(0, tb_cdc_pulse);
 
        // Initialize signals
        rst_n = 0;
        fast_rst_n = 0;
        slow_rst_n = 0;
        pulse_in = 0;
 
        // Apply reset
        #15;
        rst_n = 1; // Release reset after 20ns
        fast_rst_n = 1;
        slow_rst_n = 1;

        // Random pulse generation (Randomized delay)
        #30 pulse_in = 1; // First pulse
        #10 pulse_in = 0; // End first pulse
        #60 pulse_in = 1; // Second pulse
        #10 pulse_in = 0; // End second pulse

        // Fail case: Fast consecutive pulses (間隔 < 慢時脈週期)
        #10 pulse_in = 1; // First pulse
        #10 pulse_in = 0; // End first pulse
        #20 pulse_in = 1; // Second pulse
        #10 pulse_in = 0; // End second pulse
        // Fail case: Fast consecutive pulses (間隔 < 慢時脈週期)
        #10 pulse_in = 1; // First pulse
        #10 pulse_in = 0; // End first pulse
        #20 pulse_in = 1; // Second pulse
        #10 pulse_in = 0; // End second pulse
        // Fail case: Fast consecutive pulses (間隔 < 慢時脈週期)
        #10 pulse_in = 1; // First pulse
        #10 pulse_in = 0; // End first pulse
        #20 pulse_in = 1; // Second pulse
        #10 pulse_in = 0; // End second pulse
        // Fail case: Fast consecutive pulses (間隔 < 慢時脈週期)
        #10 pulse_in = 1; // First pulse
        #10 pulse_in = 0; // End first pulse
        #20 pulse_in = 1; // Second pulse
        #10 pulse_in = 0; // End second pulse
        // Fail case: Fast consecutive pulses (間隔 < 慢時脈週期)
        #10 pulse_in = 1; // First pulse
        #10 pulse_in = 0; // End first pulse
        #20 pulse_in = 1; // Second pulse
        #10 pulse_in = 0; // End second pulse

        #100_0; // Wait for some time to observe outputs


        
 
        $finish; // End simulation
    end

endmodule