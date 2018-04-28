module divider(  
   input      clk,  
   input      reset,  
   input      start,  
   input [31:0]  A,  
   input [31:0]  B,  
   output [31:0]  D,  
   output [31:0]  R,  
   output     ok ,   // =1 when ready to get the result   
   output err  
   );  
   wire       active;   // True if the divider is running  
   wire [4:0]    cycle;   // Number of cycles to go  
   wire [4:0] cycle_d;  
   wire [31:0]denom_d,work_d,result_d;  
   wire [31:0]   result;   // Begin with A, end with D  
   wire [31:0]   denom;   // B  
   wire [31:0]   work;    // Running R  
       wire clr,active_d;  
   // Calculate the current digit  
   wire [32:0]   sub = { work[30:0], result[31] } - denom;  
       assign err = !B;  
   // Send the results to our master  
   assign D = result;  
   assign R = work;  
   assign ok = ~active;  
       assign clr = reset | ~start;
       dffe u1(active, active_d, clk, 1'b1,clr);  
       assign active_d = active ? ((cycle==0)?1'b0:active): 1'b1;  
       register #(5) cycle_reg(cycle,cycle_d, clk, 1'b1, clr);  
       assign cycle_d = active?(cycle-5'd1):5'd31;  
       register reg32_denom(denom,denom_d, clk, 1'b1, clr);  
       assign denom_d = active?denom:B;  
       register reg32_work(work,work_d, clk, 1'b1, clr);  
       assign work_d = active?((sub[32]==0)?sub[31:0]:{work[30:0], result[31]}):0;  
       register reg32_result(result,result_d,clk, 1'b1, clr);  
       assign result_d = active==1 ?((sub[32]==0)?{result[30:0], 1'b1}:{result[30:0], 1'b0}):A;  
       
 endmodule  