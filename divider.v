/*
* module:div_rill
* file name:div_rill.v
* syn:yes
* author:network
* modify:rill
* date:2012-09-07
*/

module divider
(
input[31:0] a, 
input[31:0] b,

output reg [31:0] quotient
);

reg[31:0] tempa;
reg[31:0] tempb;
reg[63:0] temp_a;
reg[63:0] temp_b;

integer i;

always @(a or b)
begin
    tempa <= a;
    tempb <= b;
end

always @(tempa or tempb)
begin
    temp_a = {32'h00000000,tempa};
    temp_b = {tempb,32'h00000000}; 
    for(i = 0;i < 32;i = i + 1)
        begin
            temp_a = {temp_a[62:0],1'b0};
            if(temp_a[63:32] >= tempb)
                temp_a = temp_a - temp_b + 1'b1;
            else
				temp_a = temp_a;
        end

    quotient <= temp_a[31:0];
end

endmodule