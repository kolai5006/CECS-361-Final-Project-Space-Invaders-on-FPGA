`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Aylen Perez
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module game_over_text(
    input wire video_on,
    input wire [10:0] pixel_x, pixel_y,
    output reg [4:0] vga_rgb
);

    // Screen dimensions - standard VGA 640x480
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    
    // Colors - using 5-bit RGB (common for simple VGA implementations)
    localparam COLOR_BLACK = 5'b00000;
    localparam COLOR_RED = 5'b11000;   // Reduced intensity to avoid saturation
    localparam COLOR_WHITE = 5'b11111; // White color for the skull
    
    // Letter dimensions - adjusted for "GAME OVER" text
    localparam LETTER_HEIGHT = 70;
    localparam LETTER_WIDTH = 45;
    localparam LETTER_SPACING = 10;
    
    // "GAME OVER" position - MOVED LOWER on screen
    localparam GAME_OVER_Y_START = 280; // Changed from 200 to 280
    localparam GAME_OVER_Y_END = GAME_OVER_Y_START + LETTER_HEIGHT;
    
    // Calculate starting X position to center "GAME OVER" (9 letters including space)
    localparam GAME_OVER_TOTAL_WIDTH = 9 * LETTER_WIDTH + 8 * LETTER_SPACING;
    localparam GAME_OVER_X_START = (SCREEN_WIDTH - GAME_OVER_TOTAL_WIDTH) / 2;

    // Skull dimensions and position
    localparam SKULL_SIZE = 80;
    localparam SKULL_X_START = (SCREEN_WIDTH - SKULL_SIZE) / 2;
    localparam SKULL_Y_START = 150; // Position above the game over text
    
    // Temporary variables for letter drawing
    reg in_game_over_row;
    reg [3:0] current_letter;
    reg [10:0] letter_x; // Position within current letter
    
    // Variables needed for skull drawing
    wire [10:0] skull_x;
    wire [10:0] skull_y;
    
    // Calculate position within the skull
    assign skull_x = pixel_x - SKULL_X_START;
    assign skull_y = pixel_y - SKULL_Y_START;
    
    // Main drawing logic
    always @(*) begin
        // Default color is black
        vga_rgb = COLOR_BLACK;
        
        if (video_on) begin
            // Check if we're in the "GAME OVER" row
            in_game_over_row = (pixel_y >= GAME_OVER_Y_START && pixel_y < GAME_OVER_Y_END);
            
            // Initialize to invalid letter
            current_letter = 15;
            letter_x = 0;
            
            // Draw the skull if within the skull area
            if (pixel_x >= SKULL_X_START && pixel_x < SKULL_X_START + SKULL_SIZE &&
                pixel_y >= SKULL_Y_START && pixel_y < SKULL_Y_START + SKULL_SIZE) begin
                
                // Draw pixelated skull using the new function
                if (draw_pixelated_skull(skull_x, skull_y, SKULL_SIZE)) begin
                    vga_rgb = COLOR_WHITE;
                end
            end
            // Draw "GAME OVER" text
            else if (in_game_over_row) begin
                // "GAME OVER" - Efficient letter detection
                if (pixel_x >= GAME_OVER_X_START && pixel_x < GAME_OVER_X_START + 9*LETTER_WIDTH + 8*LETTER_SPACING) begin
                    if (pixel_x < GAME_OVER_X_START + LETTER_WIDTH) begin
                        // 'G' letter
                        current_letter = 0;
                        letter_x = pixel_x - GAME_OVER_X_START;
                    end
                    else if (pixel_x >= GAME_OVER_X_START + LETTER_WIDTH + LETTER_SPACING && 
                             pixel_x < GAME_OVER_X_START + 2*LETTER_WIDTH + LETTER_SPACING) begin
                        // 'A' letter
                        current_letter = 1;
                        letter_x = pixel_x - (GAME_OVER_X_START + LETTER_WIDTH + LETTER_SPACING);
                    end
                    else if (pixel_x >= GAME_OVER_X_START + 2*LETTER_WIDTH + 2*LETTER_SPACING && 
                             pixel_x < GAME_OVER_X_START + 3*LETTER_WIDTH + 2*LETTER_SPACING) begin
                        // 'M' letter
                        current_letter = 2;
                        letter_x = pixel_x - (GAME_OVER_X_START + 2*LETTER_WIDTH + 2*LETTER_SPACING);
                    end
                    else if (pixel_x >= GAME_OVER_X_START + 3*LETTER_WIDTH + 3*LETTER_SPACING && 
                             pixel_x < GAME_OVER_X_START + 4*LETTER_WIDTH + 3*LETTER_SPACING) begin
                        // 'E' letter
                        current_letter = 3;
                        letter_x = pixel_x - (GAME_OVER_X_START + 3*LETTER_WIDTH + 3*LETTER_SPACING);
                    end
                    else if (pixel_x >= GAME_OVER_X_START + 4*LETTER_WIDTH + 4*LETTER_SPACING && 
                             pixel_x < GAME_OVER_X_START + 5*LETTER_WIDTH + 4*LETTER_SPACING) begin
                        // ' ' letter (space)
                        current_letter = 15; // Space is just background
                        letter_x = pixel_x - (GAME_OVER_X_START + 4*LETTER_WIDTH + 4*LETTER_SPACING);
                    end
                    else if (pixel_x >= GAME_OVER_X_START + 5*LETTER_WIDTH + 5*LETTER_SPACING && 
                             pixel_x < GAME_OVER_X_START + 6*LETTER_WIDTH + 5*LETTER_SPACING) begin
                        // 'O' letter
                        current_letter = 4;
                        letter_x = pixel_x - (GAME_OVER_X_START + 5*LETTER_WIDTH + 5*LETTER_SPACING);
                    end
                    else if (pixel_x >= GAME_OVER_X_START + 6*LETTER_WIDTH + 6*LETTER_SPACING && 
                             pixel_x < GAME_OVER_X_START + 7*LETTER_WIDTH + 6*LETTER_SPACING) begin
                        // 'V' letter
                        current_letter = 5;
                        letter_x = pixel_x - (GAME_OVER_X_START + 6*LETTER_WIDTH + 6*LETTER_SPACING);
                    end
                    else if (pixel_x >= GAME_OVER_X_START + 7*LETTER_WIDTH + 7*LETTER_SPACING && 
                             pixel_x < GAME_OVER_X_START + 8*LETTER_WIDTH + 7*LETTER_SPACING) begin
                        // 'E' letter
                        current_letter = 3; // Reusing the 'E' drawing
                        letter_x = pixel_x - (GAME_OVER_X_START + 7*LETTER_WIDTH + 7*LETTER_SPACING);
                    end
                    else if (pixel_x >= GAME_OVER_X_START + 8*LETTER_WIDTH + 8*LETTER_SPACING && 
                             pixel_x < GAME_OVER_X_START + 9*LETTER_WIDTH + 8*LETTER_SPACING) begin
                        // 'R' letter
                        current_letter = 6;
                        letter_x = pixel_x - (GAME_OVER_X_START + 8*LETTER_WIDTH + 8*LETTER_SPACING);
                    end
                    
                    // Draw "GAME OVER" in red color if we have a valid letter
                    if (current_letter != 15) begin
                        vga_rgb = draw_letter(current_letter, letter_x, pixel_y - GAME_OVER_Y_START, COLOR_RED);
                    end
                end
            end
        end
    end
    
    // Function to draw pixelated skull that matches the image
    function draw_pixelated_skull;
        input [10:0] x;         // X position within the skull
        input [10:0] y;         // Y position within the skull
        input [10:0] size;      // Size of the skull
        
        // Define the grid scale - divides the skull size into a grid
        // For a proper pixelated look, we want a 16x16 grid
        reg [10:0] grid_size;
        reg [10:0] grid_x, grid_y;
        
        begin
            // Default: not part of the skull
            draw_pixelated_skull = 0;
            
            // Calculate the size of each grid cell
            grid_size = size / 16;
            
            // Convert pixel coordinates to grid coordinates (0-15)
            grid_x = x / grid_size;
            grid_y = y / grid_size;
            
            // Based on the pixelated skull image, define which grid cells should be white
            // The pattern follows the example image with a 16x16 grid
            
            // Top row (row 0)
            if (grid_y == 0 && (grid_x >= 4 && grid_x <= 11))
                draw_pixelated_skull = 1;
                
            // Row 1
            else if (grid_y == 1 && ((grid_x >= 2 && grid_x <= 3) || (grid_x >= 12 && grid_x <= 13)))
                draw_pixelated_skull = 1;
                
            // Row 2
            else if (grid_y == 2 && ((grid_x == 1) || (grid_x == 14)))
                draw_pixelated_skull = 1;
                
            // Row 3
            else if (grid_y == 3 && ((grid_x == 0) || (grid_x == 15)))
                draw_pixelated_skull = 1;
                
            // Rows 4-8 - outline and fill pattern
            else if ((grid_y >= 4 && grid_y <= 8) && ((grid_x == 0) || (grid_x == 15) || 
                    ((grid_x >= 1 && grid_x <= 14) && !(grid_y >= 5 && grid_y <= 7 && 
                    ((grid_x >= 3 && grid_x <= 6) || (grid_x >= 9 && grid_x <= 12))))))
                draw_pixelated_skull = 1;
                
            // Row 9 - nose area
            else if (grid_y == 9 && ((grid_x == 0) || (grid_x == 15) || 
                    ((grid_x >= 1 && grid_x <= 14) && !(grid_x >= 7 && grid_x <= 8))))
                draw_pixelated_skull = 1;
                
            // Row 10
            else if (grid_y == 10 && ((grid_x == 0) || (grid_x == 15) || (grid_x >= 1 && grid_x <= 14)))
                draw_pixelated_skull = 1;
                
            // Row 11 - teeth row starts
            else if (grid_y == 11 && ((grid_x == 0) || (grid_x == 15) || (grid_x >= 1 && grid_x <= 14)))
                draw_pixelated_skull = 1;
                
            // Row 12 - teeth pattern
            else if (grid_y == 12 && ((grid_x == 0) || (grid_x == 15) || 
                    (grid_x == 2) || (grid_x == 4) || (grid_x == 6) || (grid_x == 9) || 
                    (grid_x == 11) || (grid_x == 13)))
                draw_pixelated_skull = 1;
                
            // Row 13
            else if (grid_y == 13 && ((grid_x == 1) || (grid_x == 14)))
                draw_pixelated_skull = 1;
                
            // Row 14
            else if (grid_y == 14 && ((grid_x >= 2 && grid_x <= 3) || (grid_x >= 12 && grid_x <= 13)))
                draw_pixelated_skull = 1;
                
            // Row 15 (bottom row)
            else if (grid_y == 15 && (grid_x >= 4 && grid_x <= 11))
                draw_pixelated_skull = 1;
        end
    endfunction
    
    // Function to draw individual letters
    function [4:0] draw_letter;
        input [3:0] letter_id;  // Which letter to draw
        input [10:0] x;         // X position within the letter (0-44)
        input [10:0] y;         // Y position within the letter (0-69)
        input [4:0] color;      // Color to use if pixel is part of the letter
        
        // Letter geometry parameters
        localparam LETTER_BORDER = 9;
        localparam MID_HEIGHT = 10;
        
        begin
            draw_letter = COLOR_BLACK; // Default: background
            
            case (letter_id)
                0: begin // 'G'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        x < LETTER_BORDER ||                                      // Left vertical
                        y >= (LETTER_HEIGHT - LETTER_BORDER)) begin                // Bottom horizontal
                        draw_letter = color;
                    end
                    else if (x >= (LETTER_WIDTH - LETTER_BORDER) && 
                             (y >= LETTER_HEIGHT/2 || y >= (LETTER_HEIGHT - 2*LETTER_BORDER))) begin 
                        // Right vertical (bottom half only)
                        draw_letter = color;
                    end
                    else if (y >= LETTER_HEIGHT/2 && 
                             y < (LETTER_HEIGHT/2 + LETTER_BORDER) && 
                             x >= LETTER_WIDTH/2) begin
                        // Middle horizontal (half width)
                        draw_letter = color;
                    end
                end
                
                1: begin // 'A'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        (y >= (LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||                 // Middle horizontal
                        (x < LETTER_BORDER && y >= LETTER_BORDER) ||              // Left vertical
                        (x >= (LETTER_WIDTH - LETTER_BORDER) && 
                         y >= LETTER_BORDER)) begin                               // Right vertical
                        draw_letter = color;
                    end
                end
                
                2: begin // 'M'
                    if (x < LETTER_BORDER ||                                      // Left vertical
                        x >= (LETTER_WIDTH - LETTER_BORDER)) begin                 // Right vertical
                        draw_letter = color;
                    end
                    else begin
                        // Left diagonal (top to middle)
                        if (y < LETTER_HEIGHT/2 && 
                            x >= ((y * (LETTER_WIDTH/2 - LETTER_BORDER)) / (LETTER_HEIGHT/2) + LETTER_BORDER) && 
                            x < ((y * (LETTER_WIDTH/2 - LETTER_BORDER)) / (LETTER_HEIGHT/2) + 2*LETTER_BORDER)) begin
                            draw_letter = color;
                        end
                        // Right diagonal (top to middle)
                        else if (y < LETTER_HEIGHT/2 && 
                                 x >= (LETTER_WIDTH - 2*LETTER_BORDER - (y * (LETTER_WIDTH/2 - LETTER_BORDER)) / (LETTER_HEIGHT/2)) && 
                                 x < (LETTER_WIDTH - LETTER_BORDER - (y * (LETTER_WIDTH/2 - LETTER_BORDER)) / (LETTER_HEIGHT/2))) begin
                            draw_letter = color;
                        end
                    end
                end
                
                3: begin // 'E'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        (y >= (LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||                 // Middle horizontal
                        y >= (LETTER_HEIGHT - LETTER_BORDER) ||                    // Bottom horizontal
                        x < LETTER_BORDER) begin                                  // Left vertical
                        draw_letter = color;
                    end
                end
                
                4: begin // 'O'
                    if ((y < LETTER_BORDER || y >= (LETTER_HEIGHT - LETTER_BORDER)) && 
                        x >= LETTER_BORDER && x < (LETTER_WIDTH - LETTER_BORDER)) begin
                        // Top and bottom horizontals
                        draw_letter = color;
                    end
                    else if ((x < LETTER_BORDER || x >= (LETTER_WIDTH - LETTER_BORDER)) && 
                              y >= LETTER_BORDER && y < (LETTER_HEIGHT - LETTER_BORDER)) begin
                        // Left and right verticals
                        draw_letter = color;
                    end
                end
                
                5: begin // 'V' - Simplified calculation
                    // Left diagonal (top-left to bottom-center)
                    if (x >= ((y * (LETTER_WIDTH/2 - LETTER_BORDER/2)) / LETTER_HEIGHT) && 
                        x < ((y * (LETTER_WIDTH/2 - LETTER_BORDER/2)) / LETTER_HEIGHT + LETTER_BORDER)) begin
                        draw_letter = color;
                    end
                    // Right diagonal (top-right to bottom-center)
                    else if (x >= (LETTER_WIDTH - LETTER_BORDER - (y * (LETTER_WIDTH/2 - LETTER_BORDER/2)) / LETTER_HEIGHT) && 
                             x < (LETTER_WIDTH - (y * (LETTER_WIDTH/2 - LETTER_BORDER/2)) / LETTER_HEIGHT)) begin
                        draw_letter = color;
                    end
                end
                
                6: begin // 'R'
                    if (x < LETTER_BORDER ||                                      // Left vertical
                        y < LETTER_BORDER ||                                      // Top horizontal
                        (x >= (LETTER_WIDTH - LETTER_BORDER) && 
                         y < LETTER_HEIGHT/2) ||                                  // Upper right vertical
                        (y >= (LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (LETTER_HEIGHT/2 + MID_HEIGHT/2))) begin             // Middle horizontal
                        draw_letter = color;
                    end
                    else if (y >= LETTER_HEIGHT/2) begin
                        // Diagonal without variable declaration
                        if (x >= (LETTER_BORDER + ((y - LETTER_HEIGHT/2) * (LETTER_WIDTH - 2*LETTER_BORDER)) / (LETTER_HEIGHT/2)) && 
                            x < (LETTER_BORDER + ((y - LETTER_HEIGHT/2) * (LETTER_WIDTH - 2*LETTER_BORDER)) / (LETTER_HEIGHT/2) + LETTER_BORDER)) begin
                            draw_letter = color;
                        end
                    end
                end
                
                default: draw_letter = COLOR_BLACK;
            endcase
        end
    endfunction
endmodule
