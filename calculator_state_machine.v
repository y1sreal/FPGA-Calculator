module calculator_state_machine(display, decimal_point, in, clock, reset)
	output[31:0] display;
	output[5:0]  decimal_point;
	input [3:0]	 in;
	input		 clock, reset;
	wire  [31:0] previous;
	wire  [31:0] res, res_next; //result
	
	wire in_is_num = ~((in[2] | in[1]) & in[3]);
	wire is_add    = (in == 4'b1010);
	wire is_sub    = (in == 4'b1011);
	wire is_mult   = (in == 4'b1100);
	wire is_output = (in == 4'b1101);
	wire is_mem    = (in == 4'b1110);
	
	wire sInput;
	wire sInput_next = in_is_num & ~reset;
	dffe fsInput(sInput, sInput_next, clock, 1'b1, 1'b0);
	
	wire [31:0] res_next_input_partial, res_next_input;
	// res_next = res * 10 + in
	alu32 nextRes_input_partial(res_next_input_partial, , , , {res[28:0], 3'b0}, {res[30:0], 1'b0}, `ALU_ADD);
	alu32 nextRes_input(res_next_input, , , , res_next_input_partial, in, `ALU_ADD);
	
	//calculaion unit
		// addition or subtraction
		wire [31:0] res_next_calc_simple;
		wire sAdd;
		wire sAdd_next = sInput & (~sAdd) & is_add;
		wire sSub;
		wire sSub_next = sInput & (~sSub) & is_sub;
		dffe fsAdd(sAdd, sAdd_next, clock, 1'b1, reset);
		dffe fsSub(sSub, sSub_next, clock, 1'b1, reset);
		
		wire control = sAdd ? `ALU_ADD : sSub? `ALU_SUB : 3'h0;
		alu32 nextRes_calc_simple(res_next_calc_simple, , , , res, previous, control);
	
		// only multiplication for now
		wire [31:0] res_next_calc_complex;
		wire [31:0] multRes;
		wire sMult;
		wire sMult_next = sInput & (~sMult) & is_mult;
		dffe fsMult(sMult, sMult_next, clock, 1'b1, reset);
		mult16 mult(previous, res, multRes);
		
		assign res_next_calc_complex = multRes;
		
		wire [31:0] calcRes;
		
	mux2v simple_complex(calcRes, res_next_calc_complex, res_next_calc_simple, sAdd | sSub);
	dffe  updateLastRes(previous, calcRes, clock, 1'b1, 1'b0);
	
	// output
	wire sOut;
	wire sOut_next = is_output;
	dffe fsOut(sOut, sOut_next, clock, 1'b1, reset);
	
	// stack memory
	wire sMem;
	wire sMem_next = is_mem;
	dffe fsOut(sMem, sMem_next, clock, 1'b1, reset);
	
	wire [4:0] stack_top;
	register #(5) stack_Increment(stack_top, stack_top + 5'b1, clock, sOut, reset);
	wire [4:0] pointer;
	register #(5) pointer_Increment(pointer, sMem ? pointer - 5'b1 : stack_top, clock, 1'b1, reset);
	
	wire mem_out;
	regfile mem(mem_out, , pointer, , stack_top, res, sOut, clock, reset);
	
	assign res_next = sInput ? res_next_input 
						: sMem ? mem_out 
						: sOut ? res 
						: calcRes;
						
	dffe fRes(res, res_next, clock, 1'b1, 1'b0);
	
	assign display = res;
	
endmodule