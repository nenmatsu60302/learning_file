// Topic: Gearbox
// Description: 將scramble後+header的66bits訊號換成64bits的輸入寬度

module gearbox#(
    parameter integer WIDTH_DATA = 66,
    parameter integer WIDTH_DOUT = 64
) (
    input wire clk,
    input wire rst_n,
    input wire [WIDTH_DATA-1:0] data_in, // 66bit input data
    output wire [WIDTH_DOUT-1:0] data_out // 64bit output data
);

   

endmodule