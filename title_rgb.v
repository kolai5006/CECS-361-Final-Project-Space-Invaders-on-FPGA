module title_rgb(
    input wire video_on,
    input wire [10:0] pixel_x, pixel_y,
    input wire [1:0] frame_tick,  // For flickering effect
    input wire clk,
    output reg [4:0] vga_rgb
);
    // Screen dimensions - standard VGA 640x480
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    
    // Colors - using 5-bit RGB
    localparam COLOR_BLACK = 5'b00000;
    localparam COLOR_GREEN = 5'b00111; // For "INVADERS"
    localparam COLOR_RED = 5'b11000;   // For "SPACE"
    localparam COLOR_PURPLE = 5'b11001; // For "SWITCH TO START"
    localparam COLOR_WHITE = 5'b11111; // For "? LEBRON VER ?"
    
    // Wires for title_letters, flick_switch and lebron_credit outputs
    wire [4:0] title_rgb;
    wire [4:0] flick_rgb;
    wire [4:0] lebron_rgb;
    
    // Instantiate the title_letters module
    title_letters title_text(
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .frame_tick(frame_tick),
        .rgb_out(title_rgb)
    );
    
    // Instantiate the flick_switch module
    flick_switch_text flick_text(
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .rgb_out(flick_rgb)
    );
    
    // Instantiate the lebron_credit module
    lebron_credit lebron_text(
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .rgb_out(lebron_rgb)
    );
    
    // Main drawing logic
    always @(*) begin
        // Default color is black
        vga_rgb = COLOR_BLACK;
        
        if (video_on) begin
            // Check if title_letters module is showing text (highest priority)
            if (title_rgb != COLOR_BLACK) begin
                vga_rgb = title_rgb;
            end
            // Check if flick_switch module is showing text (medium priority)
            else if (flick_rgb != COLOR_BLACK) begin
                vga_rgb = flick_rgb;
            end
            // Check if lebron_credit module is showing text (lowest priority)
            else if (lebron_rgb != COLOR_BLACK) begin
                vga_rgb = lebron_rgb;
            end
        end
    end
endmodule
