`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ayleen Perez & Billy Domingo
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module score_display(
    input wire clk,               // 100 MHz system clock
    input wire reset,             // Reset signal
    input wire alien_hit,         // Signal when alien is hit
    output wire [15:0] led,       // 16 LEDs on FPGA
    output reg a, b, c, d, e, f, g, // 7-segment display segments
    output reg dp,                // Decimal point
    output reg [7:0] an           // 8 Digit enable signals (ACTIVE LOW)
);
    // Define score counter (up to 15 aliens)
    reg [4:0] score;
    
    // Slow clock for display multiplexing
    reg [19:0] refresh_counter = 0;
    wire [2:0] digit_select;      // 3 bits needed for 8 display positions
    reg [3:0] current_digit;
    
    // Score update logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            score <= 0;
        else if (alien_hit && score < 5'd15)
            score <= score + 1;
    end
    
    // Connect score to LEDs
    assign led = {11'b0, score};
    
    // Refreshing counter (for multiplexing 7-segment display)
    always @(posedge clk or posedge reset) begin
        if (reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end
    
    // Extract bits from the counter for digit selection (0-7)
    assign digit_select = refresh_counter[19:17];
    
    // Digit multiplexing using active LOW anodes
    // We'll only enable the two rightmost digits
    always @(*) begin
        // Default: all displays off
        an = 8'b11111111;
        
        case (digit_select)
            7'b0000000: begin
                // Rightmost digit (ones place)
                an = 8'b11111110; // Only rightmost digit active
                if (score < 10)
                    current_digit = score[3:0];
                else
                    current_digit = score - 10; // For scores 10-15
            end
            7'b0000001: begin
                // Second digit from right (tens place)
                an = 8'b11111101; // Only second-from-right digit active
                if (score < 10)
                    current_digit = 0;
                else
                    current_digit = 1; // For scores 10-15
            end
            default: begin
                // All other digit positions (not used)
                an = 8'b11111111; // All digits off
                current_digit = 0;
            end
        endcase
    end
    
    // 7-segment decoder for current digit
    always @(*) begin
        // Default off (active LOW)
        {a, b, c, d, e, f, g} = 7'b1111111;
        dp = 1'b1; // Decimal point off
        
        // Decode current digit to 7-segment display
        case (current_digit)
            4'd0: {a, b, c, d, e, f, g} = 7'b0000001; // 0
            4'd1: {a, b, c, d, e, f, g} = 7'b1001111; // 1
            4'd2: {a, b, c, d, e, f, g} = 7'b0010010; // 2
            4'd3: {a, b, c, d, e, f, g} = 7'b0000110; // 3
            4'd4: {a, b, c, d, e, f, g} = 7'b1001100; // 4
            4'd5: {a, b, c, d, e, f, g} = 7'b0100100; // 5
            4'd6: {a, b, c, d, e, f, g} = 7'b0100000; // 6
            4'd7: {a, b, c, d, e, f, g} = 7'b0001111; // 7
            4'd8: {a, b, c, d, e, f, g} = 7'b0000000; // 8
            4'd9: {a, b, c, d, e, f, g} = 7'b0000100; // 9
            default: {a, b, c, d, e, f, g} = 7'b1111111; // All segments off
        endcase
    end
endmodule
