`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nicholai Agdeppa
// 
// Create Date: 04/28/2025
// Design Name: 
// Module Name: shot
// Project Name: Space Invaders
// Target Devices: 
// Tool Versions: 
// Description: Player shot module with one-alien-per-shot limit
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module shot(
    input wire s_clk,           // System clock
    input wire clk_0,           // Refresh tick (60Hz)
    input wire pause,           // Add pause input signal
    input wire en,              // Enable signal to fire a new shot
    input wire [9:0] orig_x,    // Origin X position (from player)
    input wire [9:0] orig_y,    // Origin Y position (from player)
    input wire [9:0] pixel_x,   // Current pixel X for rendering
    input wire [9:0] pixel_y,   // Current pixel Y for rendering
    input wire ship_pixel,      // Player ship pixel (not used in this implementation)
    input wire alien_hit,       // Signal from alien controller when hit detected
    output reg shot_pixel,      // Current pixel is part of the shot (for display)
    output reg shot_active      // Shot is currently active in the game
);

    // Shot parameters
    parameter SHOT_WIDTH = 2;   // Width of the shot (reduced)
    parameter SHOT_HEIGHT = 8;  // Height of the shot (reduced)
    parameter SHOT_VELOCITY = 3; // Pixels per frame the shot moves (reduced)
    parameter Y_TOP_LIMIT = 40; // Top boundary where shot disappears (increased safety margin)
    
    // Screen boundaries
    parameter X_MIN = 32;       // Left boundary
    parameter X_MAX = 607;      // Right boundary
    parameter Y_MIN = 36;       // Top boundary
    parameter Y_MAX = 451;      // Bottom boundary

    // Shot position registers
    reg [9:0] shot_x_reg, shot_y_reg;
    reg [9:0] shot_x_next, shot_y_next;
    reg shot_active_next; // Next state for shot_active

    // Shot boundaries
    wire [9:0] shot_x_l, shot_x_r; // Left and right boundaries
    wire [9:0] shot_y_t, shot_y_b; // Top and bottom boundaries
    
    assign shot_x_l = shot_x_reg;
    assign shot_x_r = shot_x_reg + SHOT_WIDTH - 1;
    assign shot_y_t = shot_y_reg;
    assign shot_y_b = shot_y_reg + SHOT_HEIGHT - 1;

    // Initialize shot state
    initial begin
        shot_active = 0;
        shot_x_reg = 0;
        shot_y_reg = 0;
    end

    // Shot state update logic - now includes shot_active
    always @(posedge s_clk) begin
        if (!pause) begin        // Only update when not paused
            shot_x_reg <= shot_x_next;
            shot_y_reg <= shot_y_next;
            shot_active <= shot_active_next; // Update shot_active with next state
        end
    end

    // Shot movement and activation logic
    always @* begin
        // Default: maintain current position and state
        shot_x_next = shot_x_reg;
        shot_y_next = shot_y_reg;
        shot_active_next = shot_active; // Default: keep current active state

        // Deactivate shot immediately when alien is hit
        if (alien_hit && shot_active) begin
            shot_active_next = 0;
        end
        // Shot movement on refresh tick (once per frame)
        else if (clk_0 && !pause) begin
            if (shot_active) begin
                // Move shot upward
                shot_y_next = shot_y_reg - SHOT_VELOCITY;
                
                // Check if shot reaches top of screen
                if (shot_y_t <= Y_TOP_LIMIT) begin
                    shot_active_next = 0; // Deactivate when reaching top
                end
            end
            else if (en) begin
                // Activate new shot with strict boundary checks
                shot_active_next = 1;
                
                // Calculate centered shot position
                shot_x_next = orig_x - (SHOT_WIDTH/2);
                
                // Ensure shot stays within valid X boundaries
                if (shot_x_next < X_MIN) shot_x_next = X_MIN;
                if (shot_x_next > X_MAX - SHOT_WIDTH) shot_x_next = X_MAX - SHOT_WIDTH;
                
                // Start from player top with boundary check
                shot_y_next = orig_y - SHOT_HEIGHT;
                if (shot_y_next < Y_MIN) shot_y_next = Y_MIN;
            end
        end
    end

    // Shot rendering logic
    always @* begin
        // Default: pixel is not part of shot
        shot_pixel = 0;
        
        // Check if current pixel is within shot boundaries and shot is active
        // Add additional safety checks to prevent out-of-range issues
        if (shot_active &&
            pixel_x >= X_MIN && pixel_x <= X_MAX &&
            pixel_y >= Y_MIN && pixel_y <= Y_MAX &&
            pixel_x >= shot_x_l && pixel_x <= shot_x_r &&
            pixel_y >= shot_y_t && pixel_y <= shot_y_b) begin
            shot_pixel = 1;
        end
    end

endmodule
