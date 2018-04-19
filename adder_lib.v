module halfadder(s, c, a, b);
    output s, c;
    input  a, b;
    wire   w1, w2, not_a, not_b;

    // the "c" output is just the AND of the two inputs
    and a1(c, a, b);

    // the "s" output is 1 only when exactly one of the inputs is 1
    not n1(not_a, a);
    not n2(not_b, b);
    and a2(w1, a, not_b);
    and a3(w2, b, not_a);
    or  o1(s, w1, w2);
endmodule 

module fulladder(s, cout, a, b, cin);
   output s, cout;
   input  a, b, cin;
   wire   partial_s, partial_c1, partial_c2;

   halfadder ha0(partial_s, partial_c1, a, b);
   halfadder ha1(s, partial_c2, partial_s, cin);
   or  o1(cout, partial_c1, partial_c2);
   
endmodule