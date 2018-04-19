module wallace(
		input  [3:0] a,
		input  [3:0] b,
		output [7:0] p);

	and p0(p[0], a[0], b[0]);
	wire a1b0 = a[1] & b[0];
	wire a0b1 = a[0] & b[1];
	wire a2b0 = a[2] & b[0];
	wire a1b1 = a[1] & b[1];
	wire a0b2 = a[0] & b[2];
	wire a3b0 = a[3] & b[0];
	wire a2b1 = a[2] & b[1];
	wire a1b2 = a[1] & b[2];
	wire a3b1 = a[3] & b[1];
	wire a2b2 = a[2] & b[2];
	wire a1b3 = a[1] & b[3];
	wire a3b2 = a[3] & b[2];
	wire a2b3 = a[2] & b[3];
	wire a3b3 = a[3] & b[3];
	wire a0b3 = a[0] & b[3];

	wire c1;
	halfadder a1(p[1], c1, a0b1, a1b0);

	wire s1;
	wire c2;
	fulladder a2(s1, c2, a0b2, a1b1, a2b0);
	wire c3;
	halfadder a3(p[2], c3, s1, c1);

	wire s2;
	wire c4;
	fulladder a4(s2, c4, a1b2, a2b1, a3b0);
	wire s3;
	wire c5;
	fulladder a5(s3, c5, a0b3, s2, c2);
	wire c6;
	halfadder a6(p[3], c6, s3, c3);

	wire s4;
	wire c7;
	fulladder a7(s4, c7, a1b3, a2b2, a3b1);
	wire s5;
	wire c8;
	halfadder a8(s5, c8, s4, c4);
	wire c9;
	fulladder a9(p[4], c9, s5, c5, c6);

	wire s6;
	wire c10;
	halfadder a10(s6, c10, a2b3, a3b2);
	wire s7;
	wire c11;
	halfadder a11(s7, c11, s6, c7);
	wire c12;
	fulladder a12(p[5], c12, s7, c8, c9);
	
	wire s8;
	wire c13;
	halfadder a13(s8, c13, a3b3, c10);
	wire c14;
	fulladder a14(p[6], c14, s8, c11, c12);
	
	halfadder a15(p[7], , c13, c14);

endmodule //wallace

