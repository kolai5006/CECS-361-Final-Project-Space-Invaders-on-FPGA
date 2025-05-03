`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nicholai Agdeppa
// 
// Create Date: 04/15/2025 12:29:25 PM
// Design Name: 
// Module Name: pixel_generation
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


module pixel_generation(
    input clk,
    input video_on,
    input reset,
    input left,
    input right,
    input shoot,
    input [9:0] x, y,
    output reg [11:0] rgb,
    output wire game_over,
    output wire alien_hit     
    );
    
    //60hz Refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; 
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // RGB Color Values
    parameter RED    = 12'h00F;
    parameter GREEN  = 12'h0F0;
    parameter BLUE   = 12'hF00;
    parameter WHITE  = 12'hFFF;    
    parameter BLACK  = 12'h000;    

    //Player parameters
    parameter PLAYER_SIZE = 32;
    parameter X_START = 320;
    parameter Y_START = 422;
    
    //Player Boundaries:
    parameter X_LEFT = 32;
    parameter X_RIGHT = 608;
    parameter Y_TOP = 68;
    parameter Y_BOTTOM = 452;
    
    //player boundaries signals
    wire [9:0] x_plyr_L, x_plyr_R; //player horizontal boundaries
    wire [9:0] y_plyr_t, y_plyr_b; //player vertical boundaries
    reg [9:0] x_plyr_reg = X_START; //starting x position 
    reg [9:0] y_plyr_reg = Y_START; //starting y position
    reg [9:0] x_plyr_next; //the player buffer for the movement
    
    //rom boundary logic
    assign x_plyr_L = x_plyr_reg;
    assign x_plyr_R = x_plyr_L + PLAYER_SIZE - 1;
    assign y_plyr_t = y_plyr_reg;
    assign y_plyr_b = y_plyr_t + PLAYER_SIZE - 1;
    
    parameter PLYR_VELOCITY = 1; //how fast the player will be moving
    
    //Register control for the player
    always @(posedge clk or posedge reset)
        if(reset) begin
            x_plyr_reg <= X_START;
            //y_plyr_reg <= Y_START;
        end
        else begin
            x_plyr_reg <= x_plyr_next;
            //y_plyr_reg <= y_plyr_next;
        end
        
     //Player Control
     always @* begin
         x_plyr_next = x_plyr_reg;       // no move
         if(refresh_tick)                
             if(left & (x_plyr_L > PLYR_VELOCITY) & (x_plyr_L > (X_LEFT + PLYR_VELOCITY - 1)))
                 x_plyr_next = x_plyr_reg - PLYR_VELOCITY;   // move left
             else if(right & (x_plyr_R < (X_MAX - PLYR_VELOCITY)) & (x_plyr_R < (X_RIGHT - PLYR_VELOCITY)))
                 x_plyr_next = x_plyr_reg + PLYR_VELOCITY;   // move right
     end     
         
     //row and column wires for each rom
     wire [4:0] row, col; // right and left movement
    
    //assign rows and columns for the player
    assign col = x  - x_plyr_L;
    assign row = y  - y_plyr_t;
    
    //instantiate player roms
    wire [11:0] rom_data;
    Player_1_test_rom rom(.clk(clk), .row(row), .col(col), .color_data(rom_data));
    
    // Status signal for player
    wire player_on;
    assign player_on = (x_plyr_L <= x) && (x <= x_plyr_R) &&
                       (y_plyr_t <= y) && (y <= y_plyr_b);
    
    // === SHOOTING CONTROL ===
    
    reg shoot_pressed = 0;
        
    always @(posedge clk or posedge reset) begin
        if (reset)
            shoot_pressed <= 0;
        else if (refresh_tick) begin
            if (shoot && !shoot_pressed)
                shoot_pressed <= 1;  // Button was just pressed
            else if (!shoot)
                shoot_pressed <= 0;  // Button released
        end
    end
        
    // Shot control signal
    wire shot_pixel;
    wire shot_active;  // Active shot signal
    wire shot_hit;     // Indicates a shot hit an alien
    wire game_over_crtl; // Game over signal from alien controller
    
    // Track position of active shot for alien collision detection
    reg [10:0] shot_x_pos, shot_y_pos;
        
    // Enable shot when: button pressed AND not already pressed AND no active shot
    wire shot_enable = shoot && !shoot_pressed && !shot_active;
    
    // === ALIEN CONTROLLER ===
    
    wire alien_on;
    wire [11:0] alien_rgb;
    
    // Instantiate the updated alien controller
    alien_controller #(
        .Y_START(80),                // Adjust this value to change starting height
        .ALIEN_VELOCITY(1),          // Speed of movement
        .MOVE_INTERVAL(900000),      // Time between movements (lower = faster)
        .X_START(100)
    ) alien_ctrl_inst (
        .clk(clk),
        .reset(reset),
        .pixel_x(x),     
        .pixel_y(y),
        .shot_active(shot_active),
        .shot_x(shot_x_pos),
        .shot_y(shot_y_pos),
        .alien_on(alien_on),
        .alien_rgb(alien_rgb),
        .shot_hit(shot_hit),         // Output when a shot hits an alien
        .game_over(game_over_crtl)
    );
    
    // Connect module signals to outputs
    assign game_over = game_over_crtl;
    assign alien_hit = shot_hit;
    
    // Shot instance with proper connection to alien_hit
    shot player_shot (
        .s_clk(clk),                      // fast clock (pixel or VGA clock)
        .clk_0(refresh_tick),             // slow clock (1 tick per frame)
        .en(shot_enable),                 // Enable with our new logic
        .orig_x(x_plyr_reg + (PLAYER_SIZE / 2) - 2), // fire from middle of player
        .orig_y(y_plyr_t),                // top of player
        .pixel_x(x),
        .pixel_y(y),
        .ship_pixel(1'b0),                // Not using ship collision in this design
        .alien_hit(shot_hit),             // Connect to alien controller's shot_hit
        .shot_pixel(shot_pixel),
        .shot_active(shot_active)         // Track if shot is active
    );
    
    // Update shot position for collision detection only when active
    always @(posedge clk) begin
        if (shot_active && shot_pixel) begin
            shot_x_pos <= x;
            shot_y_pos <= y;
        end
    end
    
    // === GAME STATUS ===
    reg [7:0] score;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            score <= 0;
        else if (shot_hit)
            score <= score + 1;
    end

    //Game Border Positions and Code
    wire left_wall, right_wall, top_border, bottom_border, background;
    
    assign left_wall  = ((x >= 0) && (x < 32)  && (y >= 32) && (y < 452));
    assign right_wall = ((x >= 608) && (x < 640)  && (y >= 32) && (y < 452));
    assign bottom_border  = ((x >= 0)   && (x < 640)   &&  (y >= 452) && (y < 480));
    assign top_border = ((x >= 0)  && (x < 640)  &&  (y >= 0) && (y < 36)); 
    assign background = ((x >= 32) && (x < 608) && (y >= 36) && (y < 452));
    
    // === RENDERING LOGIC ===
    always @* begin
        if (~video_on)
            rgb = BLACK;
            
        else if (alien_on && background)
            //rgb = alien_rgb;
            if (&alien_rgb)
                rgb = BLACK;
            else
                rgb = alien_rgb;  
                 
        else if (shot_pixel && background)
            rgb = WHITE;
            
        // Draw player 
        else if (player_on && background)  // any non-zero bits in rom_data means visible
            if (&rom_data)
                rgb = BLACK;
            else
                rgb = rom_data;
    
        //Walls and Borders
        else if (left_wall || right_wall || bottom_border || top_border)
            rgb = WHITE;
    
        //  General background
        else if (background)
            rgb = BLACK;
    
        // Fallback: nothing else is here
        else
            rgb = BLACK;
    end
    
endmodule