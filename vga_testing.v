`timescale 1ns / 1ps
module vga_top(
    input clk_100MHz,      // nexys a7 clock speed
    input reset,
    
    input right,
    input left,
    input shoot,
    input pause,           // Pause input (connected to sw[0])
    input game_start,      // Game start input (connected to sw[2])
    
    output hsync, 
    output vsync,
    output [11:0] rgb      // 12 FPGA pins for RGB(4 per color)
);
    
    // Signal Declaration
    wire w_video_on, w_p_tick;
    wire [9:0] w_x, w_y;
    wire w_shoot, w_left, w_right;
    wire w_pause;          // Pause wire
    wire w_game_start;     // Game start wire
    
    reg [11:0] rgb_next;   // Changed from wire to reg since it's used in an always block
    wire [11:0] title_rgb_next; // RGB output from title screen
    wire [11:0] game_rgb_next;  // RGB output from game
    wire [11:0] win_rgb_next;   // RGB output from win screen
    wire [11:0] game_over_rgb_next; // RGB output from game over screen
    wire w_reset;
    wire w_game_over, w_alien_hit;
    wire w_win;            // Win signal
    
    reg [11:0] rgb_reg;
    reg [1:0] frame_counter = 0; // For title screen flickering
    
    // Define game states
    localparam TITLE_SCREEN = 2'b00;
    localparam PLAYING = 2'b01;
    localparam WIN_SCREEN = 2'b10;
    localparam GAME_OVER_SCREEN = 2'b11;
    
    reg [1:0] game_state = TITLE_SCREEN;
    
    // Frame counter for animations
    reg [27:0] frame_count;
    
    // Connect inputs to internal wires
    assign w_pause = pause;
    assign w_game_start = game_start;
    
    // Frame counter for title screen flickering effect and animations
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin
            frame_counter <= 0;
            frame_count <= 0;
        end
        else begin
            if (w_p_tick && w_y == 481 && w_x == 0)  // End of frame
                frame_counter <= frame_counter + 1;
                
            // Increment animation frame counter
            frame_count <= frame_count + 1;
        end
    end
    
    // Game state logic
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)
            game_state <= TITLE_SCREEN;
        else begin
            case (game_state)
                TITLE_SCREEN:
                    if (w_game_start)
                        game_state <= PLAYING;
                PLAYING:
                    if (w_win)
                        game_state <= WIN_SCREEN;
                    else if (w_game_over)
                        game_state <= GAME_OVER_SCREEN;
                WIN_SCREEN, GAME_OVER_SCREEN:
                    if (!w_game_start)  // Return to title when game_start is turned off
                        game_state <= TITLE_SCREEN;
            endcase
        end
    end
    
    // Instantiate VGA Controller
    vga_testing_controller vc(
        .clk_100MHz(clk_100MHz), 
        .reset(reset), 
        .pause(w_pause),
        .video_on(w_video_on), 
        .hsync(hsync), 
        .vsync(vsync), 
        .p_tick(w_p_tick), 
        .x(w_x), 
        .y(w_y)
    );
                      
    // Instantiate pixel generation (game screen)
    pixel_generation pg(
        .clk(clk_100MHz), 
        .reset(reset), 
        .pause(w_pause || !w_game_start),  // Freeze game when paused OR when not started
        .left(w_left), 
        .right(w_right), 
        .shoot(w_shoot), 
        .video_on(w_video_on), 
        .x(w_x), 
        .y(w_y), 
        .rgb(game_rgb_next),
        .game_over(w_game_over),
        .alien_hit(w_alien_hit),
        .win(w_win)                       // Connect win signal
    );
    
    // Instantiate title screen
    title_rgb title_screen(
        .video_on(w_video_on),
        .pixel_x({1'b0, w_x}),      // Convert 10-bit to 11-bit
        .pixel_y({1'b0, w_y}),      // Convert 10-bit to 11-bit
        .frame_tick(frame_counter),
        .clk(clk_100MHz),
        .vga_rgb(title_rgb_5bit)    // 5-bit RGB output
    );
    
    // Instantiate win screen
    win_screen win_screen_module(
        .video_on(w_video_on),
        .pixel_x({1'b0, w_x}),      // Convert 10-bit to 11-bit
        .pixel_y({1'b0, w_y}),      // Convert 10-bit to 11-bit
        .frame_count(frame_count),  // Pass animation frame counter
        .vga_rgb(win_screen_rgb)    // 5-bit RGB output
    );
    
    // Instantiate game over screen
    game_over_text game_over_screen(
        .video_on(w_video_on),
        .pixel_x({1'b0, w_x}),      // Convert 10-bit to 11-bit
        .pixel_y({1'b0, w_y}),      // Convert 10-bit to 11-bit
        .vga_rgb(game_over_rgb)     // 5-bit RGB output
    );
    
    // Convert 5-bit title RGB to 12-bit
    wire [4:0] title_rgb_5bit;
    assign title_rgb_next = {
        title_rgb_5bit[4:3], 2'b00,   // Red (4-bit)
        title_rgb_5bit[2:1], 2'b00,   // Green (4-bit)
        title_rgb_5bit[0], 3'b000     // Blue (4-bit)
    };
    
    // Convert 5-bit win screen RGB to 12-bit
    wire [4:0] win_screen_rgb;
    assign win_rgb_next = {
        win_screen_rgb[4:3], 2'b00,   // Red (4-bit)
        win_screen_rgb[2:1], 2'b00,   // Green (4-bit)
        win_screen_rgb[0], 3'b000     // Blue (4-bit)
    };
    
    // Convert 5-bit game over RGB to 12-bit
    wire [4:0] game_over_rgb;
    assign game_over_rgb_next = {
        game_over_rgb[4:3], 2'b00,    // Red (4-bit)
        game_over_rgb[2:1], 2'b00,    // Green (4-bit)
        game_over_rgb[0], 3'b000      // Blue (4-bit)
    };
    
    // Select RGB output based on game state
    always @* begin
        case (game_state)
            TITLE_SCREEN: 
                rgb_next = title_rgb_next;
            PLAYING: 
                rgb_next = game_rgb_next;
            WIN_SCREEN: 
                rgb_next = win_rgb_next;
            GAME_OVER_SCREEN: 
                rgb_next = game_over_rgb_next;
            default: 
                rgb_next = title_rgb_next;
        endcase
    end
                 
    // Instantiate button movement      
    btn_debounce dLeft(.clk(clk_100MHz), .btn_in(left), .btn_out(w_left));
    btn_debounce dRight(.clk(clk_100MHz), .btn_in(right), .btn_out(w_right));
    btn_debounce dShoot(.clk(clk_100MHz), .btn_in(shoot), .btn_out(w_shoot));
   
    // RGB Buffer
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_next;
    
    // Output
    assign rgb = rgb_reg;  
        
endmodule
