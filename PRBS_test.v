// TOPIC: Pseudo Random Binary Sequence (PRBS)
// Description: Testbench for an 8-bit LFSR-based PRBS generator. The testbench initializes the LFSR, applies a reset, and observes the output sequence over time.

module PRBS_test;
    reg clk;
    reg rst_n;
    wire [7:0] prbs_out;
    // Instantiate the LFSR module
    lfsr #(
        .WIDTH(8),
        .POLY_GALOIS(8'h38), // x^8 + x^6 + x^5 + x^4 + 1
        .POLY_FIB(8'h71)    // x^8 + x^7 + x^6 + x^4 + 1
    ) prbs_gen (
        .clk(clk),
        .rst_n(rst_n),
        .mode(0), // 0 for Fibonacci mode
        .out(prbs_out)
    );
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end 
    // Test sequence
    initial begin
        rst_n = 0; // Apply reset
        #10 rst_n = 1; // Release reset
        #100; // Run for some time to observe PRBS output
        $finish; // End simulation
    end
endmodule