// testbench for LFSR
`timescale 1ns/1ps

`include "./LFSR_test.v"
module tb_LFSR;
    reg clk;
    reg rst_n;
    reg lfsr_enable;
    reg [63:0] data_in;
    wire [63:0] data_out; // 64bit scrambler output
 
    // Instantiate the LFSR-based scrambler
    lfsr #(
        .TX_WIDTH(64)
    ) scrambler_inst (
        .clk(clk),
        .rst_n(rst_n),
        .lfsr_enable(lfsr_enable),
        .data_in(data_in), // Initialize with 0 for testing
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Reset and stimulus
    initial begin
        // waveform
        $dumpfile("tb_LFSR.vcd");
        $dumpvars(0, tb_LFSR);
 
        // Initialize signals
        rst_n = 0;
        lfsr_enable = 0;
 
        // Apply reset
        #20;
        rst_n = 1; // Release reset after 20ns
        data_in = 64'h0;
 
        // Enable LFSR and observe output
        #10;
        lfsr_enable = 1; // Enable LFSR after reset
        #50;
 
        // Run the simulation for a while to observe the output
        @(negedge clk); data_in <= 64'hA5A5A5A5A5A5A5A5;
        @(negedge clk); data_in <= 64'h5A5A5A5A5A5A5A5A;
        @(negedge clk); data_in <= 64'hFFFF0000FFFF0000;
 
        $finish; // End simulation
    end

    // Golden model for LFSR scrambling (for verification purposes)
    reg [57:0] golden_lfsr; // 58-bit LFSR state
    reg [63:0] expected_scrambled; // Expected scrambled output
    integer b;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            golden_lfsr <= 58'h3FFFFFFFFFFFFFF; // 初始種子
            expected_scrambled <= 64'd0;
        end else if (lfsr_enable) begin
            // 假設你的 collected_data 已經拼好了 64 bits
            // 模擬 64 次 bit-by-bit 更新
            for (b = 0; b < 64; b = b + 1) begin
                // 64b/66b 公式: x^58 + x^39 + 1
                // Scrambled_bit = Data ^ bit58 ^ bit39
                // 對應 index 為 57 和 38
                expected_scrambled[b] <= data_in[b] ^ golden_lfsr[57] ^ golden_lfsr[38];
            
                // Self-synchronizing: 將產生的結果塞回 LFSR
                golden_lfsr <= {golden_lfsr[56:0], expected_scrambled[b]};
            end
        end
        else begin
            expected_scrambled <= expected_scrambled; // 保持原來的 scrambled output 不變
            golden_lfsr <= golden_lfsr; // 保持原來的 LFSR 狀態不變
        end
    end
endmodule