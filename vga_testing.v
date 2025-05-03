`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2025 05:29:19 PM
// Design Name: 
// Module Name: vga_testing
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


module vga_top(
	input clk_100MHz,      // nexys a7 clock speed
	input reset,
	
	input right,
	input left,
	input shoot,
	
	output hsync, 
	output vsync,
	output [11:0] rgb      // 12 FPGA pins for RGB(4 per color)
);
	
	// Signal Declaration
    wire w_video_on, w_p_tick;
    wire [9:0] w_x, w_y;
    wire w_shoot;
    
    wire [11:0] rgb_next;
    wire w_reset;
    wire w_game_over, w_alien_hit;
    
    reg [11:0] rgb_reg;
    
    reg[3:0] game_status;

    // Instantiate VGA Controller
    vga_testing_controller vc(.clk_100MHz(clk_100MHz), .reset(reset), .video_on(w_video_on), 
                      .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
                      
                      
    //instantiate images/ pixel generation
    pixel_generation pg(
            .clk(clk_100MHz), 
            .reset(reset), 
            .left(w_left), 
            .right(w_right), 
            .shoot(w_shoot), 
            .video_on(w_video_on), 
            .x(w_x), 
            .y(w_y), 
            .rgb(rgb_next),
            .game_over(w_game_over),  // Connect this signal
            .alien_hit(w_alien_hit)   // Connect this signal
        );

                 
    //instantiate button movement      
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
