`define A 4'b1010
`define B 4'b1011
`define C 4'b1100
`define D 4'b1101
`define E 4'b1110
`define F 4'b1111

`define ALU_ADD    3'h2
`define ALU_SUB    3'h3
`define ALU_AND    3'h4
`define ALU_OR     3'h5
`define ALU_NOR    3'h6
`define ALU_XOR    3'h7

module calculator_state_machine(display, decimal_point, in, clock, reset, enable);
	output[31:0] display;
	output[5:0]  decimal_point;
	input [3:0]	 in;
	input		 clock, reset, enable;
	wire  [31:0] previous;
	wire  [31:0] res, res_next; //result
	
	wire in_is_num = ~((in[2] | in[1]) & in[3]);
	wire is_add    = (in == `A); //A
	wire is_sub    = (in == `B); //B
	wire is_mult   = (in == `C); //C
	wire is_output = (in == `D); //D
	wire is_mem    = (in == `E); //E
	wire is_div    = (in == `F); //F
	
	wire operationStart = is_add | is_sub | is_mult | is_div;
	wire operationChange = (sAdd_next != sAdd) | (sSub_next != sSub) | (sMult_next != sMult) | (sDiv_next != sDiv);
	
	wire sEnable;
	dffe fsEnable(sEnable, enable, clock, 1'b1, 1'b0);
	
	wire sClear; //In a state such that the previous result is cleared.
	wire sClear_next = operationChange | sMem;
	dffe fsClear(sClear, sClear_next, clock, sEnable, reset);
	
	wire sInput;
	wire sInput_next = ~reset;
	dffe fsInput(sInput, sInput_next, clock, sEnable, 1'b0);
	
	// output
	wire sOut;
	wire sOut_next = is_output & ~reset;
	dffe fsOut(sOut, sOut_next, clock, sEnable, reset);
	
	wire [31:0] res_next_input_partial, res_next_input_pre, res_next_input, source;
	// res_next = res * 10 + in
	assign source = sClear ? 32'h0 : res;
	alu32 nextRes_input_partial(res_next_input_partial, , , , {source[28:0], 3'b0}, {source[30:0], 1'b0}, `ALU_ADD);
	alu32 nextRes_input_pre(res_next_input_pre, , , , res_next_input_partial, {28'b0, in}, `ALU_ADD);
	mux2v nextRes_input(res_next_input, res_next_input_pre, res, operationStart);
	//mux2v nextRes_input(res_next_input, res, res_next_input_pre, in_is_num);
	
	//calculaion unit
		// addition or subtraction
		wire [31:0] res_next_calc_simple;
		wire sAdd;
		wire sAdd_next = (is_add | (sAdd & in_is_num)) & ~is_output | reset; // At a state of 0 + ... 
		wire sSub;
		wire sSub_next = (is_sub | (sSub & in_is_num)) & ~reset & ~is_output;
		dffe fsAdd(sAdd, sAdd_next, clock, sEnable, reset);
		dffe fsSub(sSub, sSub_next, clock, sEnable, reset);
		
		wire [2:0] control = sAdd ? `ALU_ADD : sSub? `ALU_SUB : 3'h0;
		alu32 nextRes_calc_simple(res_next_calc_simple, , , , previous, res, control);
	
		// multiplication
		wire [31:0] res_next_calc_complex;
		
		wire [31:0] multRes;
		wire sMult;
		wire sMult_next = (is_mult | (sMult & in_is_num)) & ~reset & ~is_output;
		dffe fsMult(sMult, sMult_next, clock, sEnable, reset);
		mult16 mult(previous, res, multRes);	
		
		//division
		wire [31:0] divRes;
		wire [15:0] divOut;
		wire sDiv;
		wire sDiv_next = (is_div | (sDiv & in_is_num)) & ~reset & ~is_output;
		dffe fsDiv(sDiv, sDiv_next, clock, sEnable, reset);
		divider div(previous, res, divRes);
		
		mux2v res_calc_complex_mux(res_next_calc_complex, multRes, divRes, sDiv);
		
		wire [31:0] calcRes, calcRes_pre;
		
	mux2v simple_complex(calcRes_pre, res_next_calc_complex, res_next_calc_simple, sAdd | sSub);
	mux2v idleOrNot(calcRes, res, calcRes_pre, sAdd | sSub | sMult | sDiv);
	
	// stack memory
	wire sMem;
	wire sMem_next = is_mem & ~reset;
	dffe fsMem(sMem, sMem_next, clock, sEnable, reset);
	
	wire [4:0] stack_top;
	register #(5) stack_Increment(stack_top, stack_top + 5'b1, clock, operationChange & sEnable, reset);
	wire [4:0] pointer;
	wire [4:0] pointer_next;
	//Moving the stack pointer according to the state.
	mux2v nextPointer(pointer_next, stack_top, pointer - 5'b1, sMem);
	register #(5) pointer_Increment(pointer, pointer_next, clock, sEnable, reset);
	
	wire [31:0] mem_out;
	regfile mem(mem_out, , pointer, , stack_top, previous, sEnable, clock, reset);
	
	assign res_next = 	reset ? 32'h0
						: sMem ? mem_out
						: ((sAdd | sSub | sMult | sDiv | sInput) & ~inOperationChain) ? res_next_input 
						: (sOut | operationChange) ? calcRes  
						: res;
						
	wire inOperationChain = (sAdd | sSub | sMult | sDiv) & operationChange;
	
	register update_prev(previous, res_next, clock, operationChange & sEnable, reset);
						
	register fRes(res, res_next, clock, sEnable, reset);
	
	assign display = res;
	
endmodule