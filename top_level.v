module top_level(
	input  [7:0] sw,
	input  clk,
	output [6:0] seg,
	output [3:0] an
	);

	wire [3:0] ones;
	wire [3:0] tens;
	wire [3:0] hundreds;
	wire [3:0] display;
	wire clk_temp;
	
	clk_wiz div(clk, clk_temp);
	clock_divider #(5000) div1(clk_temp, clk_1);
	clock_divider #(2500) div2(clk_temp, clk_2);
	
	assign an[3] = 1'b1;
	assign an[2] = ~clk_2 | clk_1;
	assign an[1] = clk_2 | ~clk_1;
	assign an[0] = clk_2 | clk_1;
	
	wire [7:0] product;
	wallace wall(sw[3:0], sw[7:4], product);

	DecimalDigitDecoder ddd_one(product, hundreds, tens, ones);
	mux4v mux(display, ones, tens, hundreds, , {clk_2, clk_1});

	BCDToLED btl(display, seg);

endmodule //top_level


