module cdc_pulse_fifo_sync #(
    parameter ADDR_WIDTH = 4  
)(
    input  osc_fast,    
    input  fast_rst_n,
    input  pulse_in,    
    
    input  osc_slow, 
    input  slow_rst_n,
    output reg pulse_out 
);


    reg [ADDR_WIDTH:0] wptr_bin;
    reg [ADDR_WIDTH:0] wptr_gray;
    wire [ADDR_WIDTH:0] wptr_bin_next = wptr_bin + 1'b1;
    wire [ADDR_WIDTH:0] wptr_gray_next = (wptr_bin_next >> 1) ^ wptr_bin_next;

    always @(posedge osc_fast or negedge fast_rst_n) begin
        if (!fast_rst_n) begin
            wptr_bin  <= 0;
            wptr_gray <= 0;
        end else if (pulse_in) begin
            wptr_bin  <= wptr_bin_next;
            wptr_gray <= wptr_gray_next;
        end
    end

    // CDC synchronizer for write pointer (slow clock domain)
    reg [ADDR_WIDTH:0] wptr_gray_s1, wptr_gray_s2;
    always @(posedge osc_slow or negedge slow_rst_n) begin
        if (!slow_rst_n) begin
            wptr_gray_s1 <= 0;
            wptr_gray_s2 <= 0;
        end else begin
            wptr_gray_s1 <= wptr_gray;
            wptr_gray_s2 <= wptr_gray_s1;
        end
    end

 
    reg [ADDR_WIDTH:0] rptr_bin;
    reg [ADDR_WIDTH:0] rptr_gray;
    wire [ADDR_WIDTH:0] rptr_bin_next = rptr_bin + 1'b1;
    wire [ADDR_WIDTH:0] rptr_gray_next = (rptr_bin_next >> 1) ^ rptr_bin_next;

    wire fifo_empty = (rptr_gray == wptr_gray_s2);
    
    // state machine: 0: output pulse, 1: force pulse_out to zero when pulse_out is high, to ensure each pulse_out is one clock cycle wide
    reg state; 

    always @(posedge osc_slow or negedge slow_rst_n) begin
        if (!slow_rst_n) begin
            rptr_bin  <= 0;
            rptr_gray <= 0;
            pulse_out <= 1'b0;
            state     <= 1'b0;
        end else begin
            case (state)
                1'b0: begin
                    if (!fifo_empty) begin
                        pulse_out <= 1'b1;       // 發出一個週期的脈衝
                        rptr_bin  <= rptr_bin_next;
                        rptr_gray <= rptr_gray_next;
                        state     <= 1'b1;       // 跳轉到休息狀態
                    end else begin
                        pulse_out <= 1'b0;
                    end
                end
                
                1'b1: begin
                    pulse_out <= 1'b0;           // 強制拉低，產生間隔
                    state     <= 1'b0;           // 下一拍回到等待狀態
                end
            endcase
        end
    end

endmodule