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
    
    wire [11:0] rgb_next;
    wire [11:0] title_rgb_next; // RGB output from title screen
    wire [11:0] game_rgb_next;  // RGB output from game
    wire w_reset;
    wire w_game_over, w_alien_hit;
    
    reg [11:0] rgb_reg;
    reg [1:0] frame_counter = 0; // For title screen flickering
    
    reg[3:0] game_status;
    
    // Connect inputs to internal wires
    assign w_pause = pause;
    assign w_game_start = game_start;
    
    // Frame counter for title screen flickering effect
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)
            frame_counter <= 0;
        else if (w_p_tick && w_y == 481 && w_x == 0)  // End of frame
            frame_counter <= frame_counter + 1;
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
        .alien_hit(w_alien_hit)
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
    
    // Convert 5-bit title RGB to 12-bit
    wire [4:0] title_rgb_5bit;
    assign title_rgb_next = {
        {title_rgb_5bit[4:3], 2'b00},   // Red (4-bit)
        {title_rgb_5bit[2:1], 2'b00},   // Green (4-bit)
        {title_rgb_5bit[0], 3'b000}     // Blue (4-bit)
    };
    
    // Select RGB output based on game_start switch
    assign rgb_next = w_game_start ? game_rgb_next : title_rgb_next;
                 
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
