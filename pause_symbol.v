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
module pause_symbol(
    input wire video_on,
    input wire [10:0] pixel_x, pixel_y,
    input wire pause_active,
    output reg [4:0] vga_rgb
);

    // Screen dimensions - standard VGA 640x480
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    
    // Colors - reduced intensity to avoid out-of-range issues
    localparam COLOR_BLACK = 5'b00000;
    localparam COLOR_WHITE = 5'b10101;  // Slightly dimmed white to prevent signal issues
    
    // Pause symbol dimensions - simplified for better synthesis
    localparam SYMBOL_HEIGHT = 80;
    localparam LINE_WIDTH = 16;
    localparam LINE_SPACING = 24;
    
    // Center position of pause symbol - using constants
    localparam SYMBOL_CENTER_X = 320;  // Center of 640
    localparam SYMBOL_CENTER_Y = 240;  // Center of 480
    
    // Calculate position of the two lines - made synthesis-friendly
    localparam LEFT_LINE_X_START = 280;  // SYMBOL_CENTER_X - LINE_SPACING - LINE_WIDTH
    localparam LEFT_LINE_X_END = 296;    // SYMBOL_CENTER_X - LINE_SPACING
    localparam RIGHT_LINE_X_START = 344; // SYMBOL_CENTER_X + LINE_SPACING
    localparam RIGHT_LINE_X_END = 360;   // SYMBOL_CENTER_X + LINE_SPACING + LINE_WIDTH
    
    localparam LINES_Y_START = 200;      // SYMBOL_CENTER_Y - SYMBOL_HEIGHT/2
    localparam LINES_Y_END = 280;        // SYMBOL_CENTER_Y + SYMBOL_HEIGHT/2
    
    // Simplified logic to reduce complexity
    always @(*) begin
        // Default color is black
        vga_rgb = COLOR_BLACK;
        
        if (video_on && pause_active) begin
            // Left vertical line
            if (pixel_x >= LEFT_LINE_X_START && pixel_x < LEFT_LINE_X_END && 
                pixel_y >= LINES_Y_START && pixel_y < LINES_Y_END) begin
                vga_rgb = COLOR_WHITE;
            end
            // Right vertical line
            else if (pixel_x >= RIGHT_LINE_X_START && pixel_x < RIGHT_LINE_X_END && 
                     pixel_y >= LINES_Y_START && pixel_y < LINES_Y_END) begin
                vga_rgb = COLOR_WHITE;
            end
        end
    end
endmodule
