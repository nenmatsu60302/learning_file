// Topic: Finite Impulse Response (FIR)
// FIR 有限脈衝響應濾波器: 一種數位濾波器，其脈衝響應在有限時間內衰減至零。它使用前向差分方程來計算輸出，通常用於信號處理中以濾除不需要的頻率成分。
module FIR_Filter (
    input wire clk,          // 時鐘信號
    input wire rst_n,        // 非同步復位信號，低有效
    input wire [7:0] x_in,  // 8位輸入信號
    output reg [15:0] y_out  // 16位輸出信號
);

    // FIR濾波器係數 (假設為5階濾波器)
    reg [7:0] coeff [0:4];  // 5個8位係數
    reg [7:0] x_reg [0:4];   // 5個8位寄存器存儲輸入信號

    integer i;

    // 初始化濾波器係數 (這裡使用一些示例值，實際應根據需求設置)
    initial begin
        coeff[0] = 8'h01; // 1
        coeff[1] = 8'h02; // 2
        coeff[2] = 8'h03; // 3
        coeff[3] = 8'h02; // 2
        coeff[4] = 8'h01; // 1
    end

    // FIR濾波器運算
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y_out <= 16'b0; // 復位時輸出清零
            for (i = 0; i < 5; i = i + 1) begin
                x_reg[i] <= 8'b0; // 清零輸入寄存器
            end
        end else begin
            // 移動輸入寄存器的值
            for (i = 4; i > 0; i = i - 1) begin
                x_reg[i] <= x_reg[i-1];
            end
            x_reg[0] <= x_in; // 新的輸入值存入寄存器

            // 計算FIR濾波器的輸出
            y_out <= (x_reg[0] * coeff[0]) + 
                     (x_reg[1] * coeff[1]) + 
                     (x_reg[2] * coeff[2]) + 
                     (x_reg[3] * coeff[3]) + 
                     (x_reg[4] * coeff[4]); 
        end
    end
endmodule