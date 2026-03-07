`timescale 1ns/1ps

// Testbench for scarmbler_64b66b (scrambler_test.v)
// - 提供 clock / reset
// - 簡易 gearbox 與 lfsr 行為模型置於 testbench 內，確保可獨立模擬
// - 產生多組輸入並在每個時鐘週期觀察 data_out

`include "./scrambler_test.v"

module tb_scarmbler_64b66b;
    parameter integer WIDTH_DATA = 32;
    parameter integer WIDTH_CONT = 4;
    parameter integer WIDTH_DOUT = 66;

    reg clk;
    reg rst_n;
    reg [WIDTH_DATA-1:0] data_in;
    reg [WIDTH_CONT-1:0] control_in;
    wire [WIDTH_DOUT-1:0] data_out;
    reg scrambler_enable;

    // DUT
    scarmbler_64b66b #(
        .WIDTH_DATA(WIDTH_DATA),
        .WIDTH_CONT(WIDTH_CONT),
        .WIDTH_DOUT(WIDTH_DOUT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .control_in(control_in),
        .scrambler_enable(scrambler_enable), // Scrambler always enabled for testing
        .data_out(data_out)
    );

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    // reset and stimulus
    initial begin
        // waveform
        $dumpfile("./fsdb/tb_scambler.vcd");
        $dumpvars(0, tb_scarmbler_64b66b);

        // init
        rst_n = 0;
        data_in = 32'h0000_0000;
        control_in = 4'h0;
        scrambler_enable = 1'b0;
        #20;
        rst_n = 1;

        // apply a sequence of test vectors
        @(negedge clk); data_in <= 32'h0; control_in <= 4'h0; scrambler_enable <= 1'b0;
        @(negedge clk); data_in <= 32'h0; control_in <= 4'h0; scrambler_enable <= 1'b0;
        repeat (8) begin
            @(negedge clk);
            data_in <= $random;
            control_in <= $random & {{(WIDTH_CONT-1){1'b0}},1'b1};
            scrambler_enable <= 1'b1;
        end

        // toggles with some control symbols
        @(negedge clk); data_in <= 32'hA5A5A5A5; control_in <= 4'h0; scrambler_enable <= 1'b1;
        @(negedge clk); data_in <= 32'h5A5A5A5A; control_in <= 4'hF; scrambler_enable <= 1'b1;
        @(negedge clk); data_in <= 32'hFFFF0000; control_in <= 4'h1; scrambler_enable <= 1'b1;

        #100;
        $display("Simulation finished");
        $finish;
    end

    // Monitor output
    always @(posedge clk) begin
        if (rst_n)
            $display("%0t ns: data_in=%h control_in=%b -> data_out=%h", $time, data_in, control_in, data_out);
        else if (dut.lfsr_enable)
            if (golden_lfsr != data_out[63:0])
                $display("Mismatch at %0t ns: expected=%h, got=%h", $time, expected_scrambled, data_out[63:0]);
            else
                $display("Match at %0t ns: expected=%h, got=%h", $time, expected_scrambled, data_out[63:0]);
    end
    
    // Golden model for LFSR scrambling (for verification purposes)
    reg [57:0] golden_lfsr; // 58-bit LFSR state
    reg [63:0] expected_scrambled; // Expected scrambled output
    integer b;
    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        golden_lfsr <= {56'd0, 1'b1}; // 初始種子
        expected_scrambled <= 64'd0;
    end else if (dut.lfsr_enable) begin
        // 假設你的 collected_data 已經拼好了 64 bits
        // 模擬 64 次 bit-by-bit 更新
        for (b = 0; b < 64; b = b + 1) begin
            // 64b/66b 公式: x^58 + x^39 + 1
            // Scrambled_bit = Data ^ bit58 ^ bit39
            // 對應 index 為 57 和 38
            expected_scrambled[b] <= expected_scrambled[b] ^ golden_lfsr[57] ^ golden_lfsr[38];
            
            // Self-synchronizing: 將產生的結果塞回 LFSR
            golden_lfsr <= {golden_lfsr[56:0], expected_scrambled[b]};
        end
    end
    else begin
        expected_scrambled <= {expected_scrambled, data_in}; // 保持原來的 scrambled output 不變
        golden_lfsr <= golden_lfsr; // 保持原來的 LFSR 狀態不變
    end
end

endmodule
