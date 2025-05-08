`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ayleen Perez
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module flick_switch_text(
    input wire video_on,
    input wire [10:0] pixel_x, pixel_y,
    output reg [4:0] rgb_out
);

    // Screen dimensions - standard VGA 640x480
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    
    // Colors
    localparam COLOR_BLACK = 5'b00000;
    localparam COLOR_PURPLE = 5'b11001;  // For "SWITCH TO START" text
    
    // Small letter dimensions
    localparam SMALL_LETTER_HEIGHT = 20;
    localparam SMALL_LETTER_WIDTH = 14;
    localparam SMALL_LETTER_SPACING = 4;
    
    // "SWITCH TO START" position - at the bottom center
    localparam FLICK_SWITCH_Y_START = 400;
    localparam FLICK_SWITCH_Y_END = FLICK_SWITCH_Y_START + SMALL_LETTER_HEIGHT;
    
    // Calculate starting X position to center "SWITCH TO START" (15 letters)
    localparam FLICK_SWITCH_TOTAL_WIDTH = 15 * SMALL_LETTER_WIDTH + 14 * SMALL_LETTER_SPACING;
    localparam FLICK_SWITCH_X_START = (SCREEN_WIDTH - FLICK_SWITCH_TOTAL_WIDTH) / 2;
    
    // Temporary variables for letter drawing
    reg in_flick_switch_row;
    reg [4:0] current_letter;
    reg [10:0] letter_x; // Position within current letter
    
    // Variables for "SWITCH TO START" text
    reg [10:0] letter_start_x;
    reg [4:0] i;  // Counter for the for loop
    
    // Main drawing logic
    always @(*) begin
        // Default color is black
        rgb_out = COLOR_BLACK;
        
        if (video_on) begin
            // Check if we're in the "SWITCH TO START" row
            in_flick_switch_row = (pixel_y >= FLICK_SWITCH_Y_START && pixel_y < FLICK_SWITCH_Y_END);
            
            // Initialize to invalid letter
            current_letter = 31;
            
            // Draw "SWITCH TO START" text at the bottom
            if (in_flick_switch_row) begin
                // Check each letter position manually
                for (i = 0; i < 15; i = i + 1) begin
                    letter_start_x = FLICK_SWITCH_X_START + i * (SMALL_LETTER_WIDTH + SMALL_LETTER_SPACING);
                    if (pixel_x >= letter_start_x && pixel_x < letter_start_x + SMALL_LETTER_WIDTH) begin
                        current_letter = get_switch_start_letter(i);
                        letter_x = pixel_x - letter_start_x;
                    end
                end
                
                // If we found a valid letter, draw it
                if (current_letter != 31) begin
                    rgb_out = draw_small_letter(current_letter, letter_x, pixel_y - FLICK_SWITCH_Y_START, COLOR_PURPLE);
                end
            end
        end
    end
    
    // Function to map position to letter for "SWITCH TO START"
    function [4:0] get_switch_start_letter;
        input [4:0] pos;
        begin
            case (pos)
                0: get_switch_start_letter = 0;   // 'S'
                1: get_switch_start_letter = 13;  // 'W'
                2: get_switch_start_letter = 5;   // 'I'
                3: get_switch_start_letter = 14;  // 'T'
                4: get_switch_start_letter = 3;   // 'C'
                5: get_switch_start_letter = 15;  // 'H'
                6: get_switch_start_letter = 31;  // ' ' (space)
                7: get_switch_start_letter = 14;  // 'T'
                8: get_switch_start_letter = 16;  // 'O'
                9: get_switch_start_letter = 31;  // ' ' (space)
                10: get_switch_start_letter = 0;  // 'S'
                11: get_switch_start_letter = 14; // 'T'
                12: get_switch_start_letter = 2;  // 'A'
                13: get_switch_start_letter = 17; // 'R'
                14: get_switch_start_letter = 14; // 'T'
                default: get_switch_start_letter = 31; // Invalid
            endcase
        end
    endfunction
    
    // Function to draw individual small letters
    function [4:0] draw_small_letter;
        input [4:0] letter_id;  // Which letter to draw
        input [10:0] x;         // X position within the letter
        input [10:0] y;         // Y position within the letter
        input [4:0] color;      // Color to use if pixel is part of the letter
        
        // Letter geometry parameters
        localparam LETTER_BORDER = 3;  // Smaller border for small letters
        localparam MID_HEIGHT = 3;     // Smaller middle section
        
        begin
            draw_small_letter = COLOR_BLACK; // Default: background
            
            case (letter_id)
                0: begin // 'S'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        (y >= (SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||           // Middle horizontal
                        y >= (SMALL_LETTER_HEIGHT - LETTER_BORDER)) begin         // Bottom horizontal
                        draw_small_letter = color;
                    end
                    else if ((y < SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2) && x < LETTER_BORDER) begin  // Upper left vertical
                        draw_small_letter = color;
                    end
                    else if ((y >= SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2) && 
                              x >= (SMALL_LETTER_WIDTH - LETTER_BORDER)) begin    // Lower right vertical
                        draw_small_letter = color;
                    end
                end
                
                2: begin // 'A'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        (y >= (SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||           // Middle horizontal
                        (x < LETTER_BORDER && y >= LETTER_BORDER) ||              // Left vertical
                        (x >= (SMALL_LETTER_WIDTH - LETTER_BORDER) && 
                         y >= LETTER_BORDER)) begin                               // Right vertical
                        draw_small_letter = color;
                    end
                end
                
                3: begin // 'C'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        x < LETTER_BORDER ||                                      // Left vertical
                        y >= (SMALL_LETTER_HEIGHT - LETTER_BORDER)) begin         // Bottom horizontal
                        draw_small_letter = color;
                    end
                end
                
                5: begin // 'I'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        y >= (SMALL_LETTER_HEIGHT - LETTER_BORDER) ||             // Bottom horizontal
                        (x >= (SMALL_LETTER_WIDTH/2 - LETTER_BORDER/2) && 
                         x < (SMALL_LETTER_WIDTH/2 + LETTER_BORDER/2))) begin     // Middle vertical
                        draw_small_letter = color;
                    end
                end
                
                13: begin // 'W'
                    if ((x < LETTER_BORDER) ||                                    // Left vertical
                        (x >= (SMALL_LETTER_WIDTH - LETTER_BORDER))) begin        // Right vertical
                        draw_small_letter = color;
                    end
                    else if ((x >= (SMALL_LETTER_WIDTH/2 - LETTER_BORDER/2) && 
                               x < (SMALL_LETTER_WIDTH/2 + LETTER_BORDER/2) && 
                               y >= SMALL_LETTER_HEIGHT/2)) begin                 // Middle vertical (bottom half)
                        draw_small_letter = color;
                    end
                end
                
                14: begin // 'T'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        (x >= (SMALL_LETTER_WIDTH/2 - LETTER_BORDER/2) && 
                         x < (SMALL_LETTER_WIDTH/2 + LETTER_BORDER/2))) begin     // Middle vertical
                        draw_small_letter = color;
                    end
                end
                
                15: begin // 'H'
                    if ((x < LETTER_BORDER) ||                                    // Left vertical
                        (x >= (SMALL_LETTER_WIDTH - LETTER_BORDER)) ||            // Right vertical
                        (y >= (SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2))) begin       // Middle horizontal
                        draw_small_letter = color;
                    end
                end
                
                16: begin // 'O'
                    if ((y < LETTER_BORDER) ||                                    // Top horizontal
                        (y >= (SMALL_LETTER_HEIGHT - LETTER_BORDER)) ||           // Bottom horizontal
                        (x < LETTER_BORDER) ||                                    // Left vertical
                        (x >= (SMALL_LETTER_WIDTH - LETTER_BORDER))) begin        // Right vertical
                        draw_small_letter = color;
                    end
                end
                
                17: begin // 'R'
                    if (x < LETTER_BORDER ||                                      // Left vertical
                        y < LETTER_BORDER ||                                      // Top horizontal
                        (x >= (SMALL_LETTER_WIDTH - LETTER_BORDER) && 
                         y < SMALL_LETTER_HEIGHT/2) ||                            // Upper right vertical
                        (y >= (SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2))) begin       // Middle horizontal
                        draw_small_letter = color;
                    end
                    else if (y >= SMALL_LETTER_HEIGHT/2) begin
                        // Diagonal without variable declaration
                        if (x >= (LETTER_BORDER + ((y - SMALL_LETTER_HEIGHT/2) * (SMALL_LETTER_WIDTH - 2*LETTER_BORDER)) / (SMALL_LETTER_HEIGHT/2)) && 
                            x < (LETTER_BORDER + ((y - SMALL_LETTER_HEIGHT/2) * (SMALL_LETTER_WIDTH - 2*LETTER_BORDER)) / (SMALL_LETTER_HEIGHT/2) + LETTER_BORDER)) begin
                            draw_small_letter = color;
                        end
                    end
                end
                
                // If it's a space or invalid letter, return black
                default: draw_small_letter = COLOR_BLACK;
            endcase
        end
    endfunction
endmodule
