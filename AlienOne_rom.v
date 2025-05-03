module AlienOne_rom
	(
		input wire clk,
		input wire [2:0] row,
		input wire [3:0] col,
		output reg [11:0] color_data
	);

	(* rom_style = "block" *)

	//signal declaration
	reg [2:0] row_reg;
	reg [3:0] col_reg;

	always @(posedge clk)
		begin
		row_reg <= row;
		col_reg <= col;
		end

	always @*
	case ({row_reg, col_reg})
		7'b0000000: color_data = 12'b111111111111;
		7'b0000001: color_data = 12'b111111111111;
		7'b0000010: color_data = 12'b011011010001;
		7'b0000011: color_data = 12'b111111111111;
		7'b0000100: color_data = 12'b111111111111;
		7'b0000101: color_data = 12'b111111111111;
		7'b0000110: color_data = 12'b111111111111;
		7'b0000111: color_data = 12'b111111111111;
		7'b0001000: color_data = 12'b011011010001;
		7'b0001001: color_data = 12'b111111111111;
		7'b0001010: color_data = 12'b111111111111;

		7'b0010000: color_data = 12'b111111111111;
		7'b0010001: color_data = 12'b111111111111;
		7'b0010010: color_data = 12'b111111111111;
		7'b0010011: color_data = 12'b011011010001;
		7'b0010100: color_data = 12'b111111111111;
		7'b0010101: color_data = 12'b111111111111;
		7'b0010110: color_data = 12'b111111111111;
		7'b0010111: color_data = 12'b011011010001;
		7'b0011000: color_data = 12'b111111111111;
		7'b0011001: color_data = 12'b111111111111;
		7'b0011010: color_data = 12'b111111111111;

		7'b0100000: color_data = 12'b111111111111;
		7'b0100001: color_data = 12'b111111111111;
		7'b0100010: color_data = 12'b011011010001;
		7'b0100011: color_data = 12'b011011010001;
		7'b0100100: color_data = 12'b011011010001;
		7'b0100101: color_data = 12'b011011010001;
		7'b0100110: color_data = 12'b011011010001;
		7'b0100111: color_data = 12'b011011010001;
		7'b0101000: color_data = 12'b011011010001;
		7'b0101001: color_data = 12'b111111111111;
		7'b0101010: color_data = 12'b111111111111;

		7'b0110000: color_data = 12'b111111111111;
		7'b0110001: color_data = 12'b011011010001;
		7'b0110010: color_data = 12'b011011010001;
		7'b0110011: color_data = 12'b111111111111;
		7'b0110100: color_data = 12'b011011010001;
		7'b0110101: color_data = 12'b011011010001;
		7'b0110110: color_data = 12'b011011010001;
		7'b0110111: color_data = 12'b111111111111;
		7'b0111000: color_data = 12'b011011010001;
		7'b0111001: color_data = 12'b011011010001;
		7'b0111010: color_data = 12'b111111111111;

		7'b1000000: color_data = 12'b011011010001;
		7'b1000001: color_data = 12'b011011010001;
		7'b1000010: color_data = 12'b011011010001;
		7'b1000011: color_data = 12'b011011010001;
		7'b1000100: color_data = 12'b011011010001;
		7'b1000101: color_data = 12'b011011010001;
		7'b1000110: color_data = 12'b011011010001;
		7'b1000111: color_data = 12'b011011010001;
		7'b1001000: color_data = 12'b011011010001;
		7'b1001001: color_data = 12'b011011010001;
		7'b1001010: color_data = 12'b011011010001;

		7'b1010000: color_data = 12'b011011010001;
		7'b1010001: color_data = 12'b111111111111;
		7'b1010010: color_data = 12'b011011010001;
		7'b1010011: color_data = 12'b011011010001;
		7'b1010100: color_data = 12'b011011010001;
		7'b1010101: color_data = 12'b011011010001;
		7'b1010110: color_data = 12'b011011010001;
		7'b1010111: color_data = 12'b011011010001;
		7'b1011000: color_data = 12'b011011010001;
		7'b1011001: color_data = 12'b111111111111;
		7'b1011010: color_data = 12'b011011010001;

		7'b1100000: color_data = 12'b011011010001;
		7'b1100001: color_data = 12'b111111111111;
		7'b1100010: color_data = 12'b011011010001;
		7'b1100011: color_data = 12'b111111111111;
		7'b1100100: color_data = 12'b111111111111;
		7'b1100101: color_data = 12'b111111111111;
		7'b1100110: color_data = 12'b111111111111;
		7'b1100111: color_data = 12'b111111111111;
		7'b1101000: color_data = 12'b011011010001;
		7'b1101001: color_data = 12'b111111111111;
		7'b1101010: color_data = 12'b011011010001;

		7'b1110000: color_data = 12'b111111111111;
		7'b1110001: color_data = 12'b111111111111;
		7'b1110010: color_data = 12'b111111111111;
		7'b1110011: color_data = 12'b011011010001;
		7'b1110100: color_data = 12'b011011010001;
		7'b1110101: color_data = 12'b111111111111;
		7'b1110110: color_data = 12'b011011010001;
		7'b1110111: color_data = 12'b011011010001;
		7'b1111000: color_data = 12'b111111111111;
		7'b1111001: color_data = 12'b111111111111;
		7'b1111010: color_data = 12'b111111111111;

		default: color_data = 12'b000000000000;
	endcase
endmodule