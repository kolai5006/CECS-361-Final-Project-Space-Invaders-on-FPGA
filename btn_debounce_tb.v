`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ayleen Perez & Billy Domingo
// 
// Create Date: 05/05/2025 09:39:58 PM
// Design Name: 
// Module Name: player_shot_tb
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

module btn_debounce_tb;
    // Test signals
    reg clk;
    reg btn_in;
    wire btn_out;
    
    // Instantiate the button debounce module
    btn_debounce dut(
        .clk(clk),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period (100MHz)
    end
    
    // Test sequence
    initial begin
        // Initialize button input
        btn_in = 0;
        
        // Wait a bit
        #100;
        
        // Press button and observe debounced output
        btn_in = 1;
        #100;
        
        // Release button
        btn_in = 0;
        #100;
        
        // Generate a bouncy signal
        btn_in = 1;
        #10;
        btn_in = 0;
        #5;
        btn_in = 1;
        #8;
        btn_in = 0;
        #3;
        btn_in = 1;
        #100;
        btn_in = 0;
        
        // End simulation
        #100;
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t, btn_in=%b, btn_out=%b", $time, btn_in, btn_out);
    end
endmodule
