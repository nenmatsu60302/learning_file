// Topic: scarmbler_64b66b
// Description: 打亂input data, 讓data排序不會出現一連串的0或1出現DC balance跟CDR難拆分data,clock
// 64b/66b encoding的scrambler使用的LFSR多項式所選定要運算的位置為58,39: G(x) = x^58 + x^39 + 1
// 設定data payload是64bits, 但送進來的線是32bits

`include "./gearbox_test.v"
`include "./LFSR_test.v"

module scarmbler_64b66b #(
    parameter integer WIDTH_DATA = 32,
    parameter integer WIDTH_CONT = 4,
    parameter integer WIDTH_DOUT = 66
) (
    input  wire clk,
    input  wire rst_n,
    input  wire [WIDTH_DATA-1:0] data_in,     // 32bit data input
    input  wire [WIDTH_CONT-1:0] control_in,  // 4bit control input (e.g., for indicating data vs control symbols)
    output wire [WIDTH_DOUT-1:0] data_out
);
    wire [63:0] scrambler_reg; // 64bit scrambler register
    wire [1:0] sync_header; // 2bit sync header for 64b/66b encoding    
    reg lfsr_enable; // LFSR enable signal, 可以根據需要使用這個信號來控制何時更新LFSR狀態
    reg [63:0] data_in_64b;
    reg [7:0] cont_in_8b;

    assign sync_header = (|control_in)? 2'b01 : 2'b10; // control_in任一為1則sync header為01(表示control symbol), 否則為10(表示data symbol)
    assign data_out = {sync_header, scrambler_reg}; // 64b/66b 編碼: sync header + scrambled data



    // make data_in to 64bits for scrambler
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            data_in_64b <= 64'h0; // reset data input to scrambler
            cont_in_8b <= 8'h0; // reset control input to scramb
        end else begin
            // 可以在這裡根據需要添加其他條件來控制何時更新scrambler_reg，例如根據control_in的值來決定是否更新scrambler_reg
            data_in_64b <= {data_in_64b[31:0], data_in}; // 將32bit的data_in複製成64bit輸入給scrambler
            cont_in_8b <= {cont_in_8b[3:0], control_in}; // 將4bit的control_in複製成8bit輸入給gearbox
        end
    end

    // scramble enable
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            lfsr_enable <= 0; // reset lfsr_enable signal
        end else if ((lfsr_enable == 1)) 
            lfsr_enable <= 0; // Reset lfsr_enable signal when max
        else
            lfsr_enable <= lfsr_enable + 1'b1; // Enable scrambling after reset, 可以根據需要修改這個條件來控制何時啟用scrambling
    end

    // state machine for: 1. 
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            lfsr_enable <= 0; // reset lfsr_enable signal
        end else if ((lfsr_enable == 1)) 
            lfsr_enable <= 0; // Reset lfsr_enable signal when max
        else
            lfsr_enable <= lfsr_enable + 1'b1; // Enable scrambling after reset, 可以根據需要修改這個條件來控制何時啟用scrambling
    end

    // Search control bytes in data_in, 
    

    // Instantiate the scrambler module
    lfsr #(
        .TX_WIDTH(WIDTH_DATA*2) // 64bit for control_out
    )
    scrambler_64b66b (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in_64b),
        .lfsr_enable(lfsr_enable), // 使用gearbox的enable_out來控制scrambler的運作
        .data_out(scrambler_reg)
    );

    

endmodule