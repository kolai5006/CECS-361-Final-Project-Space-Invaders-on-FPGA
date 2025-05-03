`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 12:46:05 PM
// Design Name: 
// Module Name: shot
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
module shot (
    input s_clk, clk_0, en,
    input [10:0] orig_x, orig_y,
    input [10:0] pixel_x, pixel_y,
    input ship_pixel,         // Now used to detect ship collisions
    input alien_hit,          // New input signal from alien_controller
    output reg shot_pixel,
    output shot_active        // Signal to indicate if shot is active
);
    
    reg [10:0] shot_x, shot_y;
    reg enabled;              // Track if shot is enabled
    
    parameter shot_speed = 2;
    parameter SHOT_HEIGHT = 10;
    parameter SHOT_WIDTH = 4;
    
    // Output active state based on enabled state
    assign shot_active = enabled;
     
    // Shot position update
    always @(posedge clk_0) begin
        if (!enabled && en) begin
            // Initialize new shot when enabled and previous shot is inactive
            shot_x <= orig_x;
            shot_y <= orig_y;
            enabled <= 1'b1;
        end
        else if (enabled) begin
            if (alien_hit) begin
                // Alien was hit by this shot, deactivate immediately
                enabled <= 1'b0;
            end
            else if (shot_y <= shot_speed) begin
                // Shot reached top of screen
                enabled <= 1'b0;  // Disable shot when it reaches top
            end
            else begin
                // Continue moving shot upward
                shot_y <= shot_y - shot_speed; // Shot moves up towards enemies
            end
            
            // Handle collision with ship (if implementing ship-shot collisions)
            if (ship_pixel && shot_pixel) begin
                enabled <= 1'b0;  // Disable shot on ship collision
            end
        end
    end
    
    // Shot pixel rendering
    always @(*) begin
        if(enabled) begin
            if (pixel_y >= shot_y - SHOT_HEIGHT && pixel_y < shot_y) begin
                if (pixel_x >= shot_x && pixel_x < shot_x + SHOT_WIDTH)
                    shot_pixel = 1'b1;
                else
                    shot_pixel = 1'b0;
            end
            else
                shot_pixel = 1'b0;
        end
        else
            shot_pixel = 1'b0;
    end
    
endmodule