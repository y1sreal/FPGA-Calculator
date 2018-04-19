`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2016 04:15:30 PM
// Design Name: 
// Module Name: wallace_tb
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


module wallace_tb(
    );
    reg [3:0] a, b;
    wire [7:0] c;
    
    wallace w(.a(a), .b(b), .p(c));
    
    initial
    begin
        a=4'b1011;
        b=4'b1111;
        #20;
        
        a=4'b1111;
        b=4'b1111;
        #20;
        
        a=4'b1101;
        b=4'b1011;
        #20;
    end
endmodule
