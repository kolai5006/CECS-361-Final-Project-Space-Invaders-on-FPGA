    `timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 04/27/2025 09:34:40 PM
    // Design Name: 
    // Module Name: alien_controller
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
    
    
module alien_controller(
        input wire clk,
        input wire reset,
        input wire [10:0] pixel_x, pixel_y,    // VGA pixel position
        input wire shot_active,                // Is player's shot active
        input wire [10:0] shot_x, shot_y,      // Position of player's shot
        output reg alien_on,                   // Alien pixel is visible
        output reg [11:0] alien_rgb,           // Color output (12-bit RGB)
        output reg shot_hit,                   // Pulse high when an alien is hit
        output reg game_over                   // Signal when aliens reach bottom
    );
    
        // Parameters defined inside the module
        parameter N_ROWS = 3;
        parameter N_COLS = 5;
        parameter ALIEN_WIDTH = 24;            // Doubled from 11
        parameter ALIEN_HEIGHT = 16;           // Doubled from 8
        parameter X_START = 100;
        parameter Y_START = 80;                // Starting Y position of aliens
        parameter X_LEFT = 32;                 // Increased left border (was 32)
        parameter X_RIGHT = 608;               // Decreased right border (was 608)
        parameter Y_BOTTOM = 400;              // Bottom border for game over
        parameter X_GAP = 12;                  // Space between aliens horizontally
        parameter Y_GAP = 12;                  // Space between aliens vertically
        parameter ALIEN_VELOCITY = 1;          // Pixels per move
        
        // Variables for alien block
        reg [10:0] x_offset, y_offset;         // Top-left corner of alien block
        reg dir;                               // 0 = right, 1 = left
        reg alive [0:N_ROWS-1][0:N_COLS-1];    // 2D alive flags
        reg any_aliens_alive;                  // Check if any aliens remain
        
        // Alien block dimensions
        localparam BLOCK_WIDTH = N_COLS * (ALIEN_WIDTH + X_GAP) - X_GAP;
        localparam BLOCK_HEIGHT = N_ROWS * (ALIEN_HEIGHT + Y_GAP) - Y_GAP;
        
        // Movement counters (for slow motion)
        reg [21:0] move_counter;
        parameter MOVE_INTERVAL = 800000;      // Clock cycles between moves (adjust for speed)
        wire move_tick;
        assign move_tick = (move_counter == MOVE_INTERVAL);
        
        // Refresh tick for shot collision detection (once per frame)
        reg [9:0] refresh_counter;
        parameter REFRESH_INTERVAL = 833;      // ~60Hz at 50MHz clock
        wire refresh_tick;
        assign refresh_tick = (refresh_counter == REFRESH_INTERVAL);
        
        // Shot collision detection variables
        reg [10:0] alien_left, alien_top;
        reg [10:0] alien_right, alien_bottom;
        wire shot_collision;
        
        // Alien sprite ROM connection
        reg [4:0] sprite_col;
        reg [3:0] sprite_row;
        wire [11:0] rom_color;
        
        // Instantiate the alien ROM
        AlienTwo_rom alien_rom_inst (
            .clk(clk),
            .row(sprite_row),
            .col(sprite_col),
            .color_data(rom_color)
        );
        
        // --- INITIALIZATION AND MOVEMENT LOGIC ---
        integer r, c;  // Row, col loop variables
        integer aliens_count;
        
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                // Initialize position
                x_offset <= X_START;
                y_offset <= Y_START;  
                dir <= 0;             // Start moving right
                move_counter <= 0;
                refresh_counter <= 0;
                shot_hit <= 0;
                game_over <= 0;
                any_aliens_alive <= 1;
        
                // Initialize all aliens to alive
                for (r = 0; r < N_ROWS; r = r + 1)
                    for (c = 0; c < N_COLS; c = c + 1)
                        alive[r][c] <= 1'b1;
            end else begin
                // Increment counters
                if (move_counter == MOVE_INTERVAL)
                    move_counter <= 0;
                else
                    move_counter <= move_counter + 1;
                    
                if (refresh_counter == REFRESH_INTERVAL)
                    refresh_counter <= 0;
                else
                    refresh_counter <= refresh_counter + 1;
                
                // Reset shot_hit signal (pulse)
                shot_hit <= 0;
                
                // Check if any aliens are still alive
                aliens_count = 0;
                for (r = 0; r < N_ROWS; r = r + 1)
                    for (c = 0; c < N_COLS; c = c + 1)
                        if (alive[r][c])
                            aliens_count = aliens_count + 1;
                
                any_aliens_alive <= (aliens_count > 0);
        
                // Move aliens based on move_tick
                if (move_tick && any_aliens_alive) begin
                    if (!dir) begin // Moving right
                        // Check if reaching right boundary (with safety margin)
                        if (x_offset + BLOCK_WIDTH <= X_RIGHT - 4)
                            x_offset <= x_offset + ALIEN_VELOCITY;
                        else begin
                            dir <= 1; // Hit right wall, change direction
                            y_offset <= y_offset + 8; // Move down
                        end
                    end else begin // Moving left
                        // Check if reaching left boundary (with safety margin)
                        if (x_offset >= X_LEFT + 4)
                            x_offset <= x_offset - ALIEN_VELOCITY;
                        else begin
                            dir <= 0; // Hit left wall, change direction
                            y_offset <= y_offset + 8; // Move down
                        end
                    end
                    
                    // Check if aliens reached bottom (game over)
                    if (y_offset + BLOCK_HEIGHT >= Y_BOTTOM)
                        game_over <= 1;
                end
                
                // Shot collision detection (once per frame to avoid multiple hits)
                if (refresh_tick && shot_active) begin
                    for (r = 0; r < N_ROWS; r = r + 1) begin
                        for (c = 0; c < N_COLS; c = c + 1) begin
                            if (alive[r][c]) begin
                                alien_left = x_offset + c * (ALIEN_WIDTH + X_GAP);
                                alien_top = y_offset + r * (ALIEN_HEIGHT + Y_GAP);
                                alien_right = alien_left + ALIEN_WIDTH - 1; // Adjust to be inclusive
                                alien_bottom = alien_top + ALIEN_HEIGHT - 1; // Adjust to be inclusive
                                
                                // Check if shot hits this alien
                                if ((shot_x >= alien_left) && (shot_x <= alien_right) &&
                                    (shot_y >= alien_top) && (shot_y <= alien_bottom)) begin
                                    alive[r][c] <= 0;    // Kill alien
                                    shot_hit <= 1;       // Signal hit detected
                                end
                            end
                        end
                    end
                end
            end
        end
        
        // --- DRAW LOGIC ---
        always @(*) begin
            alien_on = 0;
            alien_rgb = 12'h000;
            sprite_col = 0;
            sprite_row = 0;
        
            for (r = 0; r < N_ROWS; r = r + 1) begin
                for (c = 0; c < N_COLS; c = c + 1) begin
                    if (alive[r][c]) begin
                        alien_left = x_offset + c * (ALIEN_WIDTH + X_GAP);
                        alien_top = y_offset + r * (ALIEN_HEIGHT + Y_GAP);
        
                        // Only draw if within valid screen boundaries
                        if ((pixel_x >= alien_left) && (pixel_x < alien_left + ALIEN_WIDTH) &&
                            (pixel_y >= alien_top) && (pixel_y < alien_top + ALIEN_HEIGHT) &&
                            // Ensure within VGA display area (typical 640x480)
                            (pixel_x < 640) && (pixel_y < 480)) begin
                            
                            // Calculate sprite position
                            sprite_col = pixel_x - alien_left;
                            sprite_row = pixel_y - alien_top;
                            
                            // Only show non-transparent pixels
                            if (rom_color != 12'h000) begin
                                alien_on = 1;
                                alien_rgb = rom_color;
                            end
                        end
                    end
                end
            end
        end
        
    endmodule