// Topic: Pulse signal transmit between different speed
// Description: 透過將pulse變成level的方式來實現不同時鐘域之間的pulse傳輸，並且在接收端使用兩級DFF來進行同步，最後通過XOR操作來產生輸出脈衝信號。這種方法可以有效地避免由於時鐘域不同步而導致的脈衝丟失或重複問題,
//              但此方法不適用於快時脈連續脈衝的間隔 < 慢時脈週期, 因為這樣會導致慢時脈無法捕捉到每個脈衝的變化，從而可能會丟失脈衝信號。
//              在不改變架構下要解決此問題需要控制pulse_in的頻率, 例如慢速module需要feedback收到的訊號給高速的module這種handshake才可以確保每個脈衝都被捕捉到, 或者使用Asynchronous FIFO實現跨時鐘域的可靠數據傳輸。

module cdc_pulse(
    input osc_fast,
    input rst_n,
    input osc_slow,
    input pulse_in,
    output pulse_out
);

reg level_fast;
always @(posedge osc_fast or negedge rst_n) begin
    if (!rst_n) begin
        level_fast <= 0;
    end else if (pulse_in) begin
        level_fast <= !level_fast;
    end else begin
        level_fast <= level_fast;
    end
end

// CDC synchronizer (2 DFF)
reg level_slow_1, level_slow_2, level_slow_3;
always @(posedge osc_slow or negedge rst_n) begin
    if (!rst_n) begin
        level_slow_1 <= 0;
        level_slow_2 <= 0;
        level_slow_3 <= 0;
    end else begin
        level_slow_1 <= level_fast;
        level_slow_2 <= level_slow_1;
        level_slow_3 <= level_slow_2;
    end
end

assign pulse_out = level_slow_3 ^ level_slow_2;

endmodule