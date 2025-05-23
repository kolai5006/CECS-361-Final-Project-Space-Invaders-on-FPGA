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
module lebron_credit(
    input wire video_on,
    input wire [10:0] pixel_x, pixel_y,
    output reg [4:0] rgb_out
);

    // Screen dimensions - standard VGA 640x480
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    
    // Colors
    localparam COLOR_BLACK = 5'b00000;
    localparam COLOR_WHITE = 5'b11111;  // White color for the text
    
    // Small letter dimensions
    localparam SMALL_LETTER_HEIGHT = 16;  // Smaller than the "SWITCH TO START" text
    localparam SMALL_LETTER_WIDTH = 11;
    localparam SMALL_LETTER_SPACING = 3;
    
    // Position - lower the text a bit
    localparam LEBRON_Y_START = 440;  // Lowered from 430 to 440
    localparam LEBRON_Y_END = LEBRON_Y_START + SMALL_LETTER_HEIGHT;
    
    // Calculate starting X position to center "? LEBRON VER ?" (14 characters with extra space)
    localparam LEBRON_TOTAL_WIDTH = 14 * SMALL_LETTER_WIDTH + 13 * SMALL_LETTER_SPACING;
    localparam LEBRON_X_START = (SCREEN_WIDTH - LEBRON_TOTAL_WIDTH) / 2;
    
    // Heart shape variables (moved outside function to avoid synthesis issues)
    reg [10:0] center_x, center_y;
    reg [10:0] dist_x1, dist_y1, dist_x2, dist_y2;
    reg dist_bottom;
    
    // Temporary variables for letter drawing
    reg in_lebron_row;
    reg [4:0] current_char;
    reg [10:0] char_x; // Position within current character
    
    // Variables for "? LEBRON VER ?" text
    reg [10:0] char_start_x;
    reg [4:0] i;  // Counter for the for loop
    
    // Main drawing logic
    always @(*) begin
        // Default color is black
        rgb_out = COLOR_BLACK;
        
        if (video_on) begin
            // Check if we're in the "? LEBRON VER ?" row
            in_lebron_row = (pixel_y >= LEBRON_Y_START && pixel_y < LEBRON_Y_END);
            
            // Initialize to invalid character
            current_char = 31;
            
            // Draw "? LEBRON VER ?" text
            if (in_lebron_row) begin
                // Check each character position manually
                for (i = 0; i < 14; i = i + 1) begin // Changed from 13 to 14 characters
                    char_start_x = LEBRON_X_START + i * (SMALL_LETTER_WIDTH + SMALL_LETTER_SPACING);
                    if (pixel_x >= char_start_x && pixel_x < char_start_x + SMALL_LETTER_WIDTH) begin
                        current_char = get_lebron_char(i);
                        char_x = pixel_x - char_start_x;
                    end
                end
                
                // If we found a valid character, draw it
                if (current_char != 31) begin
                    rgb_out = draw_small_char(current_char, char_x, pixel_y - LEBRON_Y_START);
                end
            end
        end
    end
    
    // Function to map position 
    function [4:0] get_lebron_char;
        input [4:0] pos;
        begin
            case (pos)
                0: get_lebron_char = 20;  // square
                1: get_lebron_char = 31;  // ' ' (space)
                2: get_lebron_char = 11;  // 'L'
                3: get_lebron_char = 4;   // 'E'
                4: get_lebron_char = 1;   // 'B'
                5: get_lebron_char = 17;  // 'R'
                6: get_lebron_char = 16;  // 'O'
                7: get_lebron_char = 13;  // 'N'
                8: get_lebron_char = 31;  // ' ' (space)
                9: get_lebron_char = 21;  // 'V'
                10: get_lebron_char = 4;  // 'E'
                11: get_lebron_char = 17; // 'R'
                12: get_lebron_char = 31; // ' ' (space) 
                13: get_lebron_char = 20; // square
                default: get_lebron_char = 31; // Invalid
            endcase
        end
    endfunction
    
    // Function to draw individual small characters
    function [4:0] draw_small_char;
        input [4:0] char_id;   // Which character to draw
        input [10:0] x;        // X position within the character
        input [10:0] y;        // Y position within the character
        
        // Character geometry parameters
        localparam CHAR_BORDER = 2;  // Smaller border for small characters
        localparam MID_HEIGHT = 2;   // Smaller middle section
        
        begin
            // Default color is black
            draw_small_char = COLOR_BLACK;
            
            case (char_id)
                1: begin // 'B'
                    if (y < CHAR_BORDER || 
                        (y >= (SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||
                        y >= (SMALL_LETTER_HEIGHT - CHAR_BORDER) ||
                        x < CHAR_BORDER) begin
                        draw_small_char = COLOR_WHITE;
                    end
                    else if ((x >= (SMALL_LETTER_WIDTH - CHAR_BORDER)) && 
                             ((y < (SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2)) || 
                              (y >= (SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2)))) begin
                        draw_small_char = COLOR_WHITE;
                    end
                end
                
                4: begin // 'E'
                    if (y < CHAR_BORDER || 
                        (y >= (SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||
                        y >= (SMALL_LETTER_HEIGHT - CHAR_BORDER) ||
                        x < CHAR_BORDER) begin
                        draw_small_char = COLOR_WHITE;
                    end
                end
                
                11: begin // 'L'
                    if (y >= (SMALL_LETTER_HEIGHT - CHAR_BORDER) ||
                        x < CHAR_BORDER) begin
                        draw_small_char = COLOR_WHITE;
                    end
                end
                
                13: begin // 'N'
                    if (x < CHAR_BORDER || 
                        x >= (SMALL_LETTER_WIDTH - CHAR_BORDER)) begin
                        draw_small_char = COLOR_WHITE;
                    end
                    else if (x >= y && x <= y + CHAR_BORDER) begin
                        draw_small_char = COLOR_WHITE;
                    end
                end
                
                16: begin // 'O'
                    if ((y < CHAR_BORDER) ||
                        (y >= (SMALL_LETTER_HEIGHT - CHAR_BORDER)) ||
                        (x < CHAR_BORDER) ||
                        (x >= (SMALL_LETTER_WIDTH - CHAR_BORDER))) begin
                        draw_small_char = COLOR_WHITE;
                    end
                end
                
                17: begin // 'R'
                    if (x < CHAR_BORDER ||
                        y < CHAR_BORDER ||
                        (x >= (SMALL_LETTER_WIDTH - CHAR_BORDER) && 
                         y < SMALL_LETTER_HEIGHT/2) ||
                        (y >= (SMALL_LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (SMALL_LETTER_HEIGHT/2 + MID_HEIGHT/2))) begin
                        draw_small_char = COLOR_WHITE;
                    end
                    else if (y >= SMALL_LETTER_HEIGHT/2) begin
                        if (x >= (CHAR_BORDER + ((y - SMALL_LETTER_HEIGHT/2) * (SMALL_LETTER_WIDTH - 2*CHAR_BORDER)) / (SMALL_LETTER_HEIGHT/2)) && 
                            x < (CHAR_BORDER + ((y - SMALL_LETTER_HEIGHT/2) * (SMALL_LETTER_WIDTH - 2*CHAR_BORDER)) / (SMALL_LETTER_HEIGHT/2) + CHAR_BORDER)) begin
                            draw_small_char = COLOR_WHITE;
                        end
                    end
                end
                
                21: begin // 'V'
                    if ((x < CHAR_BORDER && y < SMALL_LETTER_HEIGHT/2) ||
                        (x >= (SMALL_LETTER_WIDTH - CHAR_BORDER) && y < SMALL_LETTER_HEIGHT/2)) begin
                        draw_small_char = COLOR_WHITE;
                    end
                    else if (y >= SMALL_LETTER_HEIGHT/2) begin
                        // Converging lines for bottom half of 'V'
                        if ((x >= (SMALL_LETTER_WIDTH/2 - CHAR_BORDER/2 - (SMALL_LETTER_HEIGHT - y) * (SMALL_LETTER_WIDTH/2 - CHAR_BORDER/2) / (SMALL_LETTER_HEIGHT/2)) && 
                             x <= (SMALL_LETTER_WIDTH/2 - CHAR_BORDER/2 - (SMALL_LETTER_HEIGHT - y) * (SMALL_LETTER_WIDTH/2 - CHAR_BORDER/2) / (SMALL_LETTER_HEIGHT/2) + CHAR_BORDER)) ||
                            (x >= (SMALL_LETTER_WIDTH/2 + CHAR_BORDER/2 + (SMALL_LETTER_HEIGHT - y) * (SMALL_LETTER_WIDTH/2 - CHAR_BORDER/2) / (SMALL_LETTER_HEIGHT/2) - CHAR_BORDER) && 
                             x <= (SMALL_LETTER_WIDTH/2 + CHAR_BORDER/2 + (SMALL_LETTER_HEIGHT - y) * (SMALL_LETTER_WIDTH/2 - CHAR_BORDER/2) / (SMALL_LETTER_HEIGHT/2)))) begin
                            draw_small_char = COLOR_WHITE;
                        end
                    end
                end
                
                20: begin // '?' (heart) - Improved heart shape
                    // Heart shape centered in character space
                    center_x = SMALL_LETTER_WIDTH / 2;
                    center_y = SMALL_LETTER_HEIGHT / 3;
                    
                    // Improved heart shape with better proportions
                    // First lobe calculation
                    if (x < center_x)
                        dist_x1 = center_x - x - SMALL_LETTER_WIDTH/6; // Adjusted from /4 to /6
                    else
                        dist_x1 = 0;
                        
                    if (y < center_y)
                        dist_y1 = center_y - y;
                    else
                        dist_y1 = 0; // Changed to avoid interaction with bottom part
                        
                    // Second lobe calculation
                    if (x >= center_x)
                        dist_x2 = x - center_x - SMALL_LETTER_WIDTH/6; // Adjusted from /4 to /6
                    else
                        dist_x2 = 0;
                        
                    if (y < center_y)
                        dist_y2 = center_y - y;
                    else
                        dist_y2 = 0; // Changed to avoid interaction with bottom part
                    
                    // Triangle bottom calculation - improved to make more visible
                    if (y >= center_y - 1 && // Allow slight overlap with circles
                        x >= center_x - (SMALL_LETTER_WIDTH * 3/5) * (SMALL_LETTER_HEIGHT - y) / (SMALL_LETTER_HEIGHT - center_y) && 
                        x <= center_x + (SMALL_LETTER_WIDTH * 3/5) * (SMALL_LETTER_HEIGHT - y) / (SMALL_LETTER_HEIGHT - center_y))
                        dist_bottom = 1;
                    else
                        dist_bottom = 0;
                    
                    // Final heart shape check with enlarged lobes
                    if ((dist_x1*dist_x1 + dist_y1*dist_y1 <= (SMALL_LETTER_WIDTH/3)*(SMALL_LETTER_WIDTH/3)) || 
                        (dist_x2*dist_x2 + dist_y2*dist_y2 <= (SMALL_LETTER_WIDTH/3)*(SMALL_LETTER_WIDTH/3)) ||
                        (dist_bottom == 1)) begin
                        draw_small_char = COLOR_WHITE;
                    end
                end
                
                // If it's a space or invalid character, return black
                default: draw_small_char = COLOR_BLACK;
            endcase
        end
    endfunction
    
endmodule
