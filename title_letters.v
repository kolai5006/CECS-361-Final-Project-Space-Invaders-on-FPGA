// title_letters.v - Contains the rendering logic for the "SPACE INVADERS" text

module title_letters(
    input wire video_on,
    input wire [10:0] pixel_x, pixel_y,
    input wire [1:0] frame_tick,  // No longer used for flickering
    output reg [4:0] rgb_out
);

    // Screen dimensions - standard VGA 640x480
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    
    // Colors - using 5-bit RGB
    localparam COLOR_BLACK = 5'b00000;
    localparam COLOR_GREEN = 5'b00111;
    localparam COLOR_RED = 5'b11000;
    
    // Letter dimensions
    localparam LETTER_HEIGHT = 60;
    localparam LETTER_WIDTH = 40;
    localparam LETTER_SPACING = 8;
    
    // "SPACE" position
    localparam SPACE_Y_START = 160;
    localparam SPACE_Y_END = SPACE_Y_START + LETTER_HEIGHT;
    
    // "INVADERS" position
    localparam INVADERS_Y_START = 280;
    localparam INVADERS_Y_END = INVADERS_Y_START + LETTER_HEIGHT;
    
    // Calculate starting X position to center "SPACE" (5 letters)
    localparam SPACE_TOTAL_WIDTH = 5 * LETTER_WIDTH + 4 * LETTER_SPACING;
    localparam SPACE_X_START = (SCREEN_WIDTH - SPACE_TOTAL_WIDTH) / 2;
    
    // Calculate starting X position to center "INVADERS" (8 letters)
    localparam INVADERS_TOTAL_WIDTH = 8 * LETTER_WIDTH + 7 * LETTER_SPACING;
    localparam INVADERS_X_START = (SCREEN_WIDTH - INVADERS_TOTAL_WIDTH) / 2;
    
    // Temporary variables for letter drawing
    reg in_space_row;
    reg in_invaders_row;
    reg [4:0] current_letter;
    reg [10:0] letter_x;
    
    // FIXED: Removed flickering logic - title always visible
    wire title_visible;
    assign title_visible = 1'b1; // Always visible
    
    // Main drawing logic
    always @(*) begin
        // Default color is black
        rgb_out = COLOR_BLACK;
        
        if (video_on) begin
            // Check if we're in the "SPACE" row
            in_space_row = (pixel_y >= SPACE_Y_START && pixel_y < SPACE_Y_END);
            
            // Check if we're in the "INVADERS" row
            in_invaders_row = (pixel_y >= INVADERS_Y_START && pixel_y < INVADERS_Y_END);
            
            // Initialize to invalid letter
            current_letter = 31;
            letter_x = 0;
            
            // Draw "SPACE" text with no flickering
            if (in_space_row && title_visible) begin
                // "SPACE" - efficient letter detection
                if (pixel_x >= SPACE_X_START && pixel_x < SPACE_X_START + 5*LETTER_WIDTH + 4*LETTER_SPACING) begin
                    if (pixel_x < SPACE_X_START + LETTER_WIDTH) begin
                        // 'S' letter
                        current_letter = 0;
                        letter_x = pixel_x - SPACE_X_START;
                    end
                    else if (pixel_x >= SPACE_X_START + LETTER_WIDTH + LETTER_SPACING && 
                             pixel_x < SPACE_X_START + 2*LETTER_WIDTH + LETTER_SPACING) begin
                        // 'P' letter
                        current_letter = 1;
                        letter_x = pixel_x - (SPACE_X_START + LETTER_WIDTH + LETTER_SPACING);
                    end
                    else if (pixel_x >= SPACE_X_START + 2*LETTER_WIDTH + 2*LETTER_SPACING && 
                             pixel_x < SPACE_X_START + 3*LETTER_WIDTH + 2*LETTER_SPACING) begin
                        // 'A' letter
                        current_letter = 2;
                        letter_x = pixel_x - (SPACE_X_START + 2*LETTER_WIDTH + 2*LETTER_SPACING);
                    end
                    else if (pixel_x >= SPACE_X_START + 3*LETTER_WIDTH + 3*LETTER_SPACING && 
                             pixel_x < SPACE_X_START + 4*LETTER_WIDTH + 3*LETTER_SPACING) begin
                        // 'C' letter
                        current_letter = 3;
                        letter_x = pixel_x - (SPACE_X_START + 3*LETTER_WIDTH + 3*LETTER_SPACING);
                    end
                    else if (pixel_x >= SPACE_X_START + 4*LETTER_WIDTH + 4*LETTER_SPACING && 
                             pixel_x < SPACE_X_START + 5*LETTER_WIDTH + 4*LETTER_SPACING) begin
                        // 'E' letter
                        current_letter = 4;
                        letter_x = pixel_x - (SPACE_X_START + 4*LETTER_WIDTH + 4*LETTER_SPACING);
                    end
                    
                    // Draw "SPACE" in red color if we have a valid letter
                    if (current_letter != 31) begin
                        rgb_out = draw_letter(current_letter, letter_x, pixel_y - SPACE_Y_START, COLOR_RED);
                    end
                end
            end
            
            // Draw "INVADERS" text with no flickering
            else if (in_invaders_row && title_visible) begin
                // "INVADERS" - efficient letter detection
                if (pixel_x >= INVADERS_X_START && pixel_x < INVADERS_X_START + 8*LETTER_WIDTH + 7*LETTER_SPACING) begin
                    if (pixel_x < INVADERS_X_START + LETTER_WIDTH) begin
                        // 'I' letter
                        current_letter = 5;
                        letter_x = pixel_x - INVADERS_X_START;
                    end
                    else if (pixel_x >= INVADERS_X_START + LETTER_WIDTH + LETTER_SPACING && 
                             pixel_x < INVADERS_X_START + 2*LETTER_WIDTH + LETTER_SPACING) begin
                        // 'N' letter
                        current_letter = 6;
                        letter_x = pixel_x - (INVADERS_X_START + LETTER_WIDTH + LETTER_SPACING);
                    end
                    else if (pixel_x >= INVADERS_X_START + 2*LETTER_WIDTH + 2*LETTER_SPACING && 
                             pixel_x < INVADERS_X_START + 3*LETTER_WIDTH + 2*LETTER_SPACING) begin
                        // 'V' letter
                        current_letter = 7;
                        letter_x = pixel_x - (INVADERS_X_START + 2*LETTER_WIDTH + 2*LETTER_SPACING);
                    end
                    else if (pixel_x >= INVADERS_X_START + 3*LETTER_WIDTH + 3*LETTER_SPACING && 
                             pixel_x < INVADERS_X_START + 4*LETTER_WIDTH + 3*LETTER_SPACING) begin
                        // 'A' letter
                        current_letter = 2;  // Reusing the 'A' drawing
                        letter_x = pixel_x - (INVADERS_X_START + 3*LETTER_WIDTH + 3*LETTER_SPACING);
                    end
                    else if (pixel_x >= INVADERS_X_START + 4*LETTER_WIDTH + 4*LETTER_SPACING && 
                             pixel_x < INVADERS_X_START + 5*LETTER_WIDTH + 4*LETTER_SPACING) begin
                        // 'D' letter
                        current_letter = 8;
                        letter_x = pixel_x - (INVADERS_X_START + 4*LETTER_WIDTH + 4*LETTER_SPACING);
                    end
                    else if (pixel_x >= INVADERS_X_START + 5*LETTER_WIDTH + 5*LETTER_SPACING && 
                             pixel_x < INVADERS_X_START + 6*LETTER_WIDTH + 5*LETTER_SPACING) begin
                        // 'E' letter
                        current_letter = 4;  // Reusing the 'E' drawing
                        letter_x = pixel_x - (INVADERS_X_START + 5*LETTER_WIDTH + 5*LETTER_SPACING);
                    end
                    else if (pixel_x >= INVADERS_X_START + 6*LETTER_WIDTH + 6*LETTER_SPACING && 
                             pixel_x < INVADERS_X_START + 7*LETTER_WIDTH + 6*LETTER_SPACING) begin
                        // 'R' letter
                        current_letter = 9;
                        letter_x = pixel_x - (INVADERS_X_START + 6*LETTER_WIDTH + 6*LETTER_SPACING);
                    end
                    else if (pixel_x >= INVADERS_X_START + 7*LETTER_WIDTH + 7*LETTER_SPACING && 
                             pixel_x < INVADERS_X_START + 8*LETTER_WIDTH + 7*LETTER_SPACING) begin
                        // 'S' letter
                        current_letter = 0;  // Reusing the 'S' drawing
                        letter_x = pixel_x - (INVADERS_X_START + 7*LETTER_WIDTH + 7*LETTER_SPACING);
                    end
                    
                    // Draw "INVADERS" in green color if we have a valid letter
                    if (current_letter != 31) begin
                        rgb_out = draw_letter(current_letter, letter_x, pixel_y - INVADERS_Y_START, COLOR_GREEN);
                    end
                end
            end
        end
    end
    
    // Function to draw individual large letters
    function [4:0] draw_letter;
        input [3:0] letter_id;  // Which letter to draw
        input [10:0] x;         // X position within the letter (0-39)
        input [10:0] y;         // Y position within the letter (0-59)
        input [4:0] color;      // Color to use if pixel is part of the letter
        
        // Letter geometry parameters
        localparam LETTER_BORDER = 8;
        localparam MID_HEIGHT = 8;
        
        begin
            draw_letter = COLOR_BLACK; // Default: background
            
            case (letter_id)
                0: begin // 'S'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        (y >= (LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||                 // Middle horizontal
                        y >= (LETTER_HEIGHT - LETTER_BORDER)) begin                // Bottom horizontal
                        draw_letter = color;
                    end
                    else if ((y < LETTER_HEIGHT/2 - MID_HEIGHT/2) && x < LETTER_BORDER) begin  // Upper left vertical
                        draw_letter = color;
                    end
                    else if ((y >= LETTER_HEIGHT/2 + MID_HEIGHT/2) && 
                              x >= (LETTER_WIDTH - LETTER_BORDER)) begin          // Lower right vertical
                        draw_letter = color;
                    end
                end
                
                1: begin // 'P'
                    if (x < LETTER_BORDER ||                                      // Left vertical
                        y < LETTER_BORDER ||                                      // Top horizontal
                        (x >= (LETTER_WIDTH - LETTER_BORDER) && 
                         y < LETTER_HEIGHT/2) ||                                  // Upper right vertical
                        (y >= (LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (LETTER_HEIGHT/2 + MID_HEIGHT/2))) begin             // Middle horizontal
                        draw_letter = color;
                    end
                end
                
                2: begin // 'A'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        (y >= (LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||                 // Middle horizontal
                        (x < LETTER_BORDER && y >= LETTER_BORDER) ||              // Left vertical
                        (x >= (LETTER_WIDTH - LETTER_BORDER) && 
                         y >= LETTER_BORDER)) begin                               // Right vertical
                        draw_letter = color;
                    end
                end
                
                3: begin // 'C'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        x < LETTER_BORDER ||                                      // Left vertical
                        y >= (LETTER_HEIGHT - LETTER_BORDER)) begin               // Bottom horizontal
                        draw_letter = color;
                    end
                end
                
                4: begin // 'E'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        (y >= (LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (LETTER_HEIGHT/2 + MID_HEIGHT/2)) ||                 // Middle horizontal
                        y >= (LETTER_HEIGHT - LETTER_BORDER) ||                   // Bottom horizontal
                        x < LETTER_BORDER) begin                                  // Left vertical
                        draw_letter = color;
                    end
                end
                
                5: begin // 'I'
                    if (y < LETTER_BORDER ||                                      // Top horizontal
                        y >= (LETTER_HEIGHT - LETTER_BORDER) ||                   // Bottom horizontal
                        (x >= (LETTER_WIDTH/2 - LETTER_BORDER/2) && 
                         x < (LETTER_WIDTH/2 + LETTER_BORDER/2))) begin           // Middle vertical
                        draw_letter = color;
                    end
                end
                
                6: begin // 'N' - Simplified calculation
                    if (x < LETTER_BORDER ||                                      // Left vertical
                        x >= (LETTER_WIDTH - LETTER_BORDER)) begin                // Right vertical
                        draw_letter = color;
                    end
                    else begin
                        // Simplified diagonal line
                        if (x >= ((y * (LETTER_WIDTH - 2*LETTER_BORDER)) / LETTER_HEIGHT + LETTER_BORDER) && 
                            x < ((y * (LETTER_WIDTH - 2*LETTER_BORDER)) / LETTER_HEIGHT + 2*LETTER_BORDER)) begin
                            draw_letter = color;
                        end
                    end
                end
                
                7: begin // 'V' - Simplified calculation
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
                
                8: begin // 'D' - Simplified curved edge
                    if (x < LETTER_BORDER ||                                      // Left vertical
                        y < LETTER_BORDER ||                                      // Top horizontal
                        y >= (LETTER_HEIGHT - LETTER_BORDER)) begin               // Bottom horizontal
                        draw_letter = color;
                    end
                    else if (x >= (LETTER_WIDTH - LETTER_BORDER)) begin           // Right vertical simplified
                        draw_letter = color;
                    end
                end
                
                9: begin // 'R' - Simplified diagonal
                    if (x < LETTER_BORDER ||                                      // Left vertical
                        y < LETTER_BORDER ||                                      // Top horizontal
                        (x >= (LETTER_WIDTH - LETTER_BORDER) && 
                         y < LETTER_HEIGHT/2) ||                                  // Upper right vertical
                        (y >= (LETTER_HEIGHT/2 - MID_HEIGHT/2) && 
                         y < (LETTER_HEIGHT/2 + MID_HEIGHT/2))) begin             // Middle horizontal
                        draw_letter = color;
                    end
                    else if (y >= LETTER_HEIGHT/2) begin
                        // Diagonal
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
