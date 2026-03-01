// Topic: Linear Feedback Shift Register (LFSR)
// LFSR 是一個由暫存器組成的電路，它會不斷把位元往後推移，並將特定位置的數值進行 XOR 運算後，把結果回饋到最前面的輸入端。這樣就能產生一串循環極長、看起來像隨機的數列。
// Fibonacci LFSR將選定位置的data做XOR後插回到LSB
// Galois LFSR則是將MSB作為輸出並根據其值決定是否對特定位置的data進行XOR (1: do XOR + shift left, 0: no XOR + shift left)
// LFSR廣泛應用於隨機數生成、加密、錯誤檢測等領域

// for 64b/66b encoding, G(x) = x^58 + x^39 + 1
// for loop version
/*
module lfsr #(
    parameter integer TX_WIDTH = 64
)
(
    input wire clk,          // 時鐘信號
    input wire rst_n,        // 非同步復位信號，低有效
    input wire [TX_WIDTH-1:0] data_in,  // TX數據_in
    input wire mode,         // 0: Fibonacci LFSR, 1: Galois LFSR
    output reg [TX_WIDTH-1:0] data_out     // TX數據_out with scrambling
);

    reg [TX_WIDTH-1:0] scramble_data;
    reg [57:0] lfsr_reg; // 57位LFSR寄存器, for G(x) = x^58 + x^39 + 1
    reg [57:0] lfsr_seq; // 用來產生scramble_data的LFSR數列

    // data_in的每個bit都需要被打亂, 且用來打亂的數列也是每打亂一個bit就更新一次數列, 保證每個bit都是由不同的數列XOR後打亂的
    always @(*) begin
        lfsr_reg = lfsr_seq; // 先將lfsr_seq的值賦給lfsr_reg，這樣在計算scramble_data時就能使用當前的LFSR狀態
        for (integer i = 0; i < TX_WIDTH; i = i + 1) begin
            scramble_data[i] = data_in[i] ^ lfsr_reg[57] ^ lfsr_reg[38]; // Scramble data_in with LFSR output
            lfsr_reg = {lfsr_reg[56:0], scramble_data[i] }; // 更新lfsr_reg數列
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_seq <= {56'd0, 1'b1}; // reset 為 nonzero值，避免全0鎖死
            data_out <= 0; // reset output
        end else begin
            data_out <= scramble_data; // 輸出打亂後的數據
            lfsr_seq <= lfsr_reg; // 更新lfsr_seq為新的LFSR狀態
        end
    end


endmodule
*/

// Without for loop version
module lfsr #(
    parameter integer TX_WIDTH = 64
)
(
    input wire clk,          // 時鐘信號
    input wire rst_n,        // 非同步復位信號，低有效
    input wire [TX_WIDTH-1:0] data_in,  // TX數據_in
    input wire lfsr_enable, // LFSR enable signal, 可以根據需要使用這個信號來控制何時更新LFSR狀態
    //input wire mode,         // 0: Fibonacci LFSR, 1: Galois LFSR
    output reg [TX_WIDTH-1:0] data_out     // TX數據_out with scrambling
);

    reg [57:0] lfsr_seq; // 用來產生scramble_data的LFSR數列
    wire [TX_WIDTH-1:0] scramble_data_test;

    // data_in的每個bit都需要被打亂, 且用來打亂的數列也是每打亂一個bit就更新一次數列, 保證每個bit都是由不同的數列XOR後打亂的
    assign scramble_data_test[0] = data_in[0] ^ lfsr_seq[57] ^ lfsr_seq[38];
    assign scramble_data_test[1] = data_in[1] ^ lfsr_seq[56] ^ lfsr_seq[37];
    assign scramble_data_test[2] = data_in[2] ^ lfsr_seq[55] ^ lfsr_seq[36];
    assign scramble_data_test[3] = data_in[3] ^ lfsr_seq[54] ^ lfsr_seq[35];
    assign scramble_data_test[4] = data_in[4] ^ lfsr_seq[53] ^ lfsr_seq[34];
    assign scramble_data_test[5] = data_in[5] ^ lfsr_seq[52] ^ lfsr_seq[33];
    assign scramble_data_test[6] = data_in[6] ^ lfsr_seq[51] ^ lfsr_seq[32];
    assign scramble_data_test[7] = data_in[7] ^ lfsr_seq[50] ^ lfsr_seq[31];
    assign scramble_data_test[8] = data_in[8] ^ lfsr_seq[49] ^ lfsr_seq[30];
    assign scramble_data_test[9] = data_in[9] ^ lfsr_seq[48] ^ lfsr_seq[29];
    assign scramble_data_test[10] = data_in[10] ^ lfsr_seq[47] ^ lfsr_seq[28];
    assign scramble_data_test[11] = data_in[11] ^ lfsr_seq[46] ^ lfsr_seq[27];
    assign scramble_data_test[12] = data_in[12] ^ lfsr_seq[45] ^ lfsr_seq[26];
    assign scramble_data_test[13] = data_in[13] ^ lfsr_seq[44] ^ lfsr_seq[25];
    assign scramble_data_test[14] = data_in[14] ^ lfsr_seq[43] ^ lfsr_seq[24];
    assign scramble_data_test[15] = data_in[15] ^ lfsr_seq[42] ^ lfsr_seq[23];
    assign scramble_data_test[16] = data_in[16] ^ lfsr_seq[41] ^ lfsr_seq[22];
    assign scramble_data_test[17] = data_in[17] ^ lfsr_seq[40] ^ lfsr_seq[21];
    assign scramble_data_test[18] = data_in[18] ^ lfsr_seq[39] ^ lfsr_seq[20];
    assign scramble_data_test[19] = data_in[19] ^ lfsr_seq[38] ^ lfsr_seq[19];
    assign scramble_data_test[20] = data_in[20] ^ lfsr_seq[37] ^ lfsr_seq[18];
    assign scramble_data_test[21] = data_in[21] ^ lfsr_seq[36] ^ lfsr_seq[17];
    assign scramble_data_test[22] = data_in[22] ^ lfsr_seq[35] ^ lfsr_seq[16];
    assign scramble_data_test[23] = data_in[23] ^ lfsr_seq[34] ^ lfsr_seq[15];
    assign scramble_data_test[24] = data_in[24] ^ lfsr_seq[33] ^ lfsr_seq[14];
    assign scramble_data_test[25] = data_in[25] ^ lfsr_seq[32] ^ lfsr_seq[13];
    assign scramble_data_test[26] = data_in[26] ^ lfsr_seq[31] ^ lfsr_seq[12];
    assign scramble_data_test[27] = data_in[27] ^ lfsr_seq[30] ^ lfsr_seq[11];
    assign scramble_data_test[28] = data_in[28] ^ lfsr_seq[29] ^ lfsr_seq[10];
    assign scramble_data_test[29] = data_in[29] ^ lfsr_seq[28] ^ lfsr_seq[9];
    assign scramble_data_test[30] = data_in[30] ^ lfsr_seq[27] ^ lfsr_seq[8];
    assign scramble_data_test[31] = data_in[31] ^ lfsr_seq[26] ^ lfsr_seq[7];
    assign scramble_data_test[32] = data_in[32] ^ lfsr_seq[25] ^ lfsr_seq[6];
    assign scramble_data_test[33] = data_in[33] ^ lfsr_seq[24] ^ lfsr_seq[5];
    assign scramble_data_test[34] = data_in[34] ^ lfsr_seq[23] ^ lfsr_seq[4];
    assign scramble_data_test[35] = data_in[35] ^ lfsr_seq[22] ^ lfsr_seq[3];
    assign scramble_data_test[36] = data_in[36] ^ lfsr_seq[21] ^ lfsr_seq[2];
    assign scramble_data_test[37] = data_in[37] ^ lfsr_seq[20] ^ lfsr_seq[1];
    assign scramble_data_test[38] = data_in[38] ^ lfsr_seq[19] ^ lfsr_seq[0];
    assign scramble_data_test[39] = data_in[39] ^ lfsr_seq[18] ^ scramble_data_test[0];
    assign scramble_data_test[40] = data_in[40] ^ lfsr_seq[17] ^ scramble_data_test[1];
    assign scramble_data_test[41] = data_in[41] ^ lfsr_seq[16] ^ scramble_data_test[2];
    assign scramble_data_test[42] = data_in[42] ^ lfsr_seq[15] ^ scramble_data_test[3];
    assign scramble_data_test[43] = data_in[43] ^ lfsr_seq[14] ^ scramble_data_test[4];
    assign scramble_data_test[44] = data_in[44] ^ lfsr_seq[13] ^ scramble_data_test[5];
    assign scramble_data_test[45] = data_in[45] ^ lfsr_seq[12] ^ scramble_data_test[6];
    assign scramble_data_test[46] = data_in[46] ^ lfsr_seq[11] ^ scramble_data_test[7];
    assign scramble_data_test[47] = data_in[47] ^ lfsr_seq[10] ^ scramble_data_test[8];
    assign scramble_data_test[48] = data_in[48] ^ lfsr_seq[9] ^ scramble_data_test[9];
    assign scramble_data_test[49] = data_in[49] ^ lfsr_seq[8] ^ scramble_data_test[10];
    assign scramble_data_test[50] = data_in[50] ^ lfsr_seq[7] ^ scramble_data_test[11];
    assign scramble_data_test[51] = data_in[51] ^ lfsr_seq[6] ^ scramble_data_test[12];
    assign scramble_data_test[52] = data_in[52] ^ lfsr_seq[5] ^ scramble_data_test[13];
    assign scramble_data_test[53] = data_in[53] ^ lfsr_seq[4] ^ scramble_data_test[14];
    assign scramble_data_test[54] = data_in[54] ^ lfsr_seq[3] ^ scramble_data_test[15];
    assign scramble_data_test[55] = data_in[55] ^ lfsr_seq[2] ^ scramble_data_test[16];
    assign scramble_data_test[56] = data_in[56] ^ lfsr_seq[1] ^ scramble_data_test[17];
    assign scramble_data_test[57] = data_in[57] ^ lfsr_seq[0] ^ scramble_data_test[18];
    assign scramble_data_test[58] = data_in[58] ^ scramble_data_test[0] ^ scramble_data_test[19];
    assign scramble_data_test[59] = data_in[59] ^ scramble_data_test[1] ^ scramble_data_test[20];
    assign scramble_data_test[60] = data_in[60] ^ scramble_data_test[2] ^ scramble_data_test[21];
    assign scramble_data_test[61] = data_in[61] ^ scramble_data_test[3] ^ scramble_data_test[22];
    assign scramble_data_test[62] = data_in[62] ^ scramble_data_test[4] ^ scramble_data_test[23];
    assign scramble_data_test[63] = data_in[63] ^ scramble_data_test[5] ^ scramble_data_test[24];




    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_seq <= 58'h3FFFFFFFFFFFFFF; // reset 為 nonzero值，避免全0鎖死
            data_out <= 0; // reset output
        end else if (lfsr_enable) begin
            data_out <= scramble_data_test; // 輸出打亂後的數據
            for (integer k = 0; k < 58; k = k + 1) begin  // 更新lfsr_seq為新的LFSR狀態, 取更新後的data_in的前58bit作為新的LFSR狀態
                lfsr_seq[k] <= scramble_data_test[63-k];
            end
        end
        else begin
            data_out <= data_out; // 保持原來的輸出不變
            lfsr_seq <= lfsr_seq; // 保持原來的LFSR狀態不變
        end
    end


endmodule