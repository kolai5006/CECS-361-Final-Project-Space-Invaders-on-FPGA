`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ayleen Perez & Billy Domingo
// 
// Create Date: 05/05/2025 10:05:34 PM
// Design Name: 
// Module Name: alien_controller_tb
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

module score_display_tb;
    // Basic signals
    reg clk_100MHz;
    reg reset;
    reg alien_hit;
    
    // Outputs from score display module
    wire [15:0] led;
    wire a, b, c, d, e, f, g;
    wire dp;
    wire [3:0] an;
    
    // Instantiate the score display module
    score_display dut(
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .alien_hit(alien_hit),
        .led(led),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .dp(dp),
        .an(an)
    );
    
    // Clock generation
    initial begin
        clk_100MHz = 0;
        forever #5 clk_100MHz = ~clk_100MHz; // 100MHz clock
    end
    
    // Test sequence
    initial begin
        // Initialize
        reset = 1;
        alien_hit = 0;
        
        // Release reset
        #100;
        reset = 0;
        
        // Wait a bit
        #100;
        
        // Simulate first alien hit
        alien_hit = 1;
        #20;
        alien_hit = 0;
        #100;
        
        // Simulate second alien hit
        alien_hit = 1;
        #20;
        alien_hit = 0;
        #100;
        
        // Simulate third alien hit
        alien_hit = 1;
        #20;
        alien_hit = 0;
        #100;
        
        // End simulation
        $finish;
    end
endmodule
