`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ayleen Perez
// 
// Create Date: 05/02/2025 05:16:14 PM
// Design Name: 
// Module Name: win_screen
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


module win_screen(
    input wire video_on,
    input wire [10:0] pixel_x, pixel_y,
    input wire [27:0] frame_count,     // Frame counter for star animation
    output reg [4:0] vga_rgb
);

    // Screen dimensions - standard VGA 640x480
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    
    // Colors - using 5-bit RGB (common for simple VGA implementations)
    localparam COLOR_BLACK = 5'b00000;
    localparam COLOR_WHITE = 5'b11111;
    localparam COLOR_YELLOW = 5'b11110;  // Yellow for stars
    
    // Letter dimensions - adjusted for "WIN" text
    localparam LETTER_HEIGHT = 100;
    localparam LETTER_WIDTH = 60;
    localparam LETTER_SPACING = 20;
    
    // "WIN" position - centered on screen
    localparam WIN_Y_START = 180;
    localparam WIN_Y_END = WIN_Y_START + LETTER_HEIGHT;
    
    // Calculate starting X position to center "WIN" (3 letters)
    localparam WIN_TOTAL_WIDTH = 3 * LETTER_WIDTH + 2 * LETTER_SPACING;
    localparam WIN_X_START = (SCREEN_WIDTH - WIN_TOTAL_WIDTH) / 2;

    // Star parameters
    localparam STAR_COUNT = 12;             // Number of stars
    localparam STAR_SIZE = 20;              // Size of the stars
    
    // Arrays to hold star positions (initialized with different positions around screen)
    reg [10:0] star_x_positions[0:STAR_COUNT-1];
    reg [10:0] star_y_positions[0:STAR_COUNT-1];
    
    // Temporary variables for drawing
    reg in_win_row;
    reg [3:0] current_letter;
    reg [10:0] letter_x;
    
    // Variables for star drawing and animation
    reg [10:0] dist_x, dist_y, distance_sq;
    reg in_star;
    reg [3:0] star_phase;
    reg [3:0] i;
    
    // Main drawing logic
    always @(*) begin
        // Default color is black
        vga_rgb = COLOR_BLACK;
        
        // Initialize positions for stars
        star_x_positions[0] = 80;    star_y_positions[0] = 60;
        star_x_positions[1] = 180;   star_y_positions[1] = 90;
        star_x_positions[2] = 300;   star_y_positions[2] = 50;
        star_x_positions[3] = 400;   star_y_positions[3] = 70;
        star_x_positions[4] = 540;   star_y_positions[4] = 100;
        star_x_positions[5] = 120;   star_y_positions[5] = 380;
        star_x_positions[6] = 220;   star_y_positions[6] = 400;
        star_x_positions[7] = 350;   star_y_positions[7] = 420;
        star_x_positions[8] = 450;   star_y_positions[8] = 360;
        star_x_positions[9] = 560;   star_y_positions[9] = 380;
        star_x_positions[10] = 100;  star_y_positions[10] = 200;
        star_x_positions[11] = 520;  star_y_positions[11] = 220;

        // Calculate animation phase (0-7) for twinkling effect based on frame count
        star_phase = frame_count[25:23]; // Changes roughly every ~0.17 seconds at 60Hz
        
        if (video_on) begin
            // Check if we're in the "WIN" row
            in_win_row = (pixel_y >= WIN_Y_START && pixel_y < WIN_Y_END);
            
            // Initialize to invalid letter
            current_letter = 15;
            letter_x = 0;
            
            // First check if in a star
            in_star = 0;
            for (i = 0; i < STAR_COUNT; i = i + 1) begin
                // Calculate distance from star center (using squared distance to avoid square root)
                dist_x = (pixel_x > star_x_positions[i]) ? (pixel_x - star_x_positions[i]) : (star_x_positions[i] - pixel_x);
                dist_y = (pixel_y > star_y_positions[i]) ? (pixel_y - star_y_positions[i]) : (star_y_positions[i] - pixel_y);
                
                // Simple star shape based on distance and phase
                if (dist_x < STAR_SIZE/2 && dist_y < STAR_SIZE/2) begin
                    // Central diamond part of star
                    if (dist_x + dist_y < STAR_SIZE/2) begin
                        in_star = 1;
                        // Make stars twinkle by varying brightness based on star_phase and star index
                        if ((i + star_phase) % 8 < 6) begin
                            vga_rgb = COLOR_YELLOW;
                        end else begin
                            vga_rgb = 5'b10100; // Dimmer yellow for twinkling effect
                        end
                    end
                    // Star points
                    else if ((dist_x < STAR_SIZE/4 || dist_y < STAR_SIZE/4) && 
                             dist_x + dist_y < STAR_SIZE) begin
                        in_star = 1;
                        if ((i + star_phase) % 8 < 6) begin
                            vga_rgb = COLOR_YELLOW;
                        end else begin
                            vga_rgb = 5'b10100; // Dimmer yellow for twinkling effect
                        end
                    end
                end
            end
            
            // If not in a star, check if in "WIN" text area
            if (!in_star && in_win_row) begin
                if (pixel_x >= WIN_X_START && pixel_x < WIN_X_START + 3*LETTER_WIDTH + 2*LETTER_SPACING) begin
                    if (pixel_x < WIN_X_START + LETTER_WIDTH) begin
                        // 'W' letter
                        current_letter = 0;
                        letter_x = pixel_x - WIN_X_START;
                    end
                    else if (pixel_x >= WIN_X_START + LETTER_WIDTH + LETTER_SPACING && 
                             pixel_x < WIN_X_START + 2*LETTER_WIDTH + LETTER_SPACING) begin
                        // 'I' letter
                        current_letter = 1;
                        letter_x = pixel_x - (WIN_X_START + LETTER_WIDTH + LETTER_SPACING);
                    end
                    else if (pixel_x >= WIN_X_START + 2*LETTER_WIDTH + 2*LETTER_SPACING && 
                             pixel_x < WIN_X_START + 3*LETTER_WIDTH + 2*LETTER_SPACING) begin
                        // 'N' letter
                        current_letter = 2;
                        letter_x = pixel_x - (WIN_X_START + 2*LETTER_WIDTH + 2*LETTER_SPACING);
                    end
                    
                    // Draw "WIN" in white color if we have a valid letter
                    if (current_letter != 15) begin
                        vga_rgb = draw_letter(current_letter, letter_x, pixel_y - WIN_Y_START, COLOR_WHITE);
                    end
                end
            end
        end
    end
    
    // Function to draw individual letters
    function [4:0] draw_letter;
        input [3:0] letter_id;  // Which letter to draw
        input [10:0] x;         // X position within the letter (0-59)
        input [10:0] y;         // Y position within the letter (0-99)
        input [4:0] color;      // Color to use if pixel is part of the letter
        
        // Letter geometry parameters
        localparam LETTER_BORDER = 12;
        
        begin
            draw_letter = COLOR_BLACK; // Default: background
            
            case (letter_id)
                0: begin // 'W'
                    // Left diagonal (top-left to bottom-center-left)
                    if (x >= (y * (LETTER_WIDTH/4) / LETTER_HEIGHT) && 
                        x < (y * (LETTER_WIDTH/4) / LETTER_HEIGHT + LETTER_BORDER)) begin
                        draw_letter = color;
                    end
                    // First middle diagonal (top-center-left to bottom-center)
                    else if (x >= (LETTER_WIDTH/4 + (y * (LETTER_WIDTH/4) / LETTER_HEIGHT)) && 
                             x < (LETTER_WIDTH/4 + (y * (LETTER_WIDTH/4) / LETTER_HEIGHT) + LETTER_BORDER) &&
                             y >= LETTER_HEIGHT/2) begin
                        draw_letter = color;
                    end
                    // Second middle diagonal (top-center-right to bottom-center)
                    else if (x >= (LETTER_WIDTH/2 + LETTER_BORDER - (y * (LETTER_WIDTH/4) / LETTER_HEIGHT)) && 
                             x < (LETTER_WIDTH/2 + 2*LETTER_BORDER - (y * (LETTER_WIDTH/4) / LETTER_HEIGHT)) &&
                             y >= LETTER_HEIGHT/2) begin
                        draw_letter = color;
                    end
                    // Right diagonal (top-right to bottom-center-right)
                    else if (x >= (LETTER_WIDTH - LETTER_BORDER - (y * (LETTER_WIDTH/4) / LETTER_HEIGHT)) && 
                             x < (LETTER_WIDTH - (y * (LETTER_WIDTH/4) / LETTER_HEIGHT))) begin
                        draw_letter = color;
                    end
                end
                
                1: begin // 'I'
                    if (y < LETTER_BORDER ||                                     // Top horizontal
                        y >= (LETTER_HEIGHT - LETTER_BORDER) ||                  // Bottom horizontal
                        (x >= (LETTER_WIDTH/2 - LETTER_BORDER/2) && 
                         x < (LETTER_WIDTH/2 + LETTER_BORDER/2))) begin         // Middle vertical
                        draw_letter = color;
                    end
                end
                
                2: begin // 'N'
                    if (x < LETTER_BORDER ||                                     // Left vertical
                        x >= (LETTER_WIDTH - LETTER_BORDER)) begin               // Right vertical
                        draw_letter = color;
                    end
                    else begin
                        // Diagonal (top-left to bottom-right)
                        if (x >= (y * (LETTER_WIDTH - 2*LETTER_BORDER) / LETTER_HEIGHT + LETTER_BORDER) && 
                            x < (y * (LETTER_WIDTH - 2*LETTER_BORDER) / LETTER_HEIGHT + 2*LETTER_BORDER)) begin
                            draw_letter = color;
                        end
                    end
                end
                
                default: draw_letter = COLOR_BLACK;
            endcase
        end
    endfunction
endmodule
