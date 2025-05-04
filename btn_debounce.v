`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nicholai Agdeppa
// 
// Create Date: 04/22/2025 01:43:30 PM
// Design Name: 
// Module Name: btn_debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module btn_debounce(
    input clk,
    input btn_in,
    output btn_out
    );
    
    reg a, b, c;
    
    always @(posedge clk) begin
        a <= btn_in;
        b <= a;
        c <= b;
    end
    
    assign btn_out = c;
    
endmodule
