module divider(  
   input      clk,  
   input      reset,  
   input      start,  
   input [31:0]  A,  
   input [31:0]  B,  
   output [31:0]  D,  
   output [31:0]  R,  
   output     done   // =1 when ready to get the result   
   );  
   wire       running;   
   wire [4:0]    cycle;   // Number of cycles to go  
   wire [4:0] cycle_d;  
   wire [31:0]denom_d,work_d,result_d;  
   wire [31:0]   result;   // Begin with A, end with D  
   wire [31:0]   denom;   // B  
   wire [31:0]   work;    // Running R  
   wire clr,running_d;  
   // Calculate the current digit  
   wire [32:0]   sub = { work[30:0], result[31] } - denom;  

   assign D = result;  
   assign R = work;  
   assign done = ~running;  
   assign clr = reset | ~start;
   
   dffe u1(running, running_d, clk, 1'b1,clr);  
   assign running_d = running ? ( (cycle == 0) ? 1'b0 : running): 1'b1;  
   register #(5) cycle_reg(cycle, cycle_d, clk, 1'b1, clr);  
   assign cycle_d = running ? (cycle - 5'd1) : 5'd31;  
   register reg_denom(denom,denom_d, clk, 1'b1, clr);  
   assign denom_d = running ? denom : B;  
   register reg_work(work, work_d, clk, 1'b1, clr);  
   assign work_d = running?((sub[32] == 0) ? sub[31:0] : {work[30:0], result[31]}) : 0;  
   register reg_result(result, result_d, clk, 1'b1, clr);  
   assign result_d = running == 1 ? ((sub[32] == 0) ? {result[30:0], 1'b1} : {result[30:0], 1'b0}) : A;  
       
 endmodule  