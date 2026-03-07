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
    input  wire scrambler_enable, 
    output wire [WIDTH_DOUT-1:0] data_out
);

    parameter IDLE = 2'b00,
              LOAD = 2'b01,
              SCRAMBLE = 2'b10,
              OUTPUT = 2'b11;

    wire [63:0] scrambler_reg; // 64bit scrambler register
    wire [1:0] sync_header; // 2bit sync header for 64b/66b encoding    
    reg [1:0] lfsr_cnt; // LFSR enable signal, 可以根據需要使用這個信號來控制何時更新LFSR狀態
    reg [63:0] data_in_64b;
    reg [7:0] cont_in_8b;
    wire lfsr_enable;

    assign sync_header = (|control_in)? 2'b01 : 2'b10; // control_in任一為1則sync header為01(表示control symbol), 否則為10(表示data symbol)
    assign data_out = {sync_header, scrambler_reg}; // 64b/66b 編碼: sync header + scrambled data



    // make data_in to 64bits for scrambler
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            data_in_64b <= 64'h0; // reset data input to scrambler
            cont_in_8b <= 8'h0; // reset control input to scramb
        end else if (scrambler_enable) begin
            data_in_64b <= {data_in_64b[31:0], data_in}; // 將32bit的data_in複製成64bit輸入給scrambler
            cont_in_8b <= {cont_in_8b[3:0], control_in}; // 將4bit的control_in複製成8bit輸入給gearbox
        end
        else begin
            data_in_64b <= data_in_64b; // 保持原值
            cont_in_8b <= cont_in_8b; // 保持原值
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_cnt <= 0; // reset LFSR enable signal
        end else begin
            lfsr_cnt <= lfsr_cnt + 2'b1; // 每次scrambler_enable為1時，增加LFSR enable信號的值，這樣可以控制LFSR在每個時鐘週期更新狀態
        end
    end

    
    reg [1:0] state;
    reg [1:0] nxt_state;
    // state machine for controlling scrambler operation, 可以根據需要添加更多的狀態來控制scrambler的行為，例如根據control_in的值來決定是否更新scrambler_reg
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 2'b00; // reset
        end else begin
            state <= nxt_state; // update state
        end
    end
    
    // nex_state logic for state machine, 可以根據需要添加更多的條件來控制狀態轉移，例如根據control_in的值來決定是否更新scrambler_reg
    always @(*) begin
        case (state)
            IDLE: begin
                nxt_state = scrambler_enable ? LOAD : IDLE; // transition to LOAD state when scrambler_enable is high
            end
            LOAD: begin
                nxt_state = SCRAMBLE; // transition to LOAD state when scrambler_enable is high
            end
            SCRAMBLE: begin
                nxt_state = scrambler_enable? LOAD: IDLE; // transition to LOAD state when scrambler_enable is high
            end
            default: nxt_state = IDLE; // default case to handle unexpected states, transition back to state 0    
        endcase
    end

    assign lfsr_enable = (state == SCRAMBLE) ? 1'b1 : 1'b0; // LFSR enable signal is high when in SCRAMBLE state
    

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