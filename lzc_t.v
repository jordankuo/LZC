module stimulus;
	parameter cyc = 10, width = 8, word = 4;
	
	reg clk, rst_n, Ivalid, mode;
	reg [width-1 : 0] data;
	wire [$clog2(width*word) : 0] zeros;
	wire Ovalid;
	
	
	lzc LZC(clk, rst_n, data, Ivalid, mode, zeros, Ovalid,);
	
	always #(cyc/2) clk = ~clk;
	
	initial begin
		$fsdbDumpfile("lzc.fsdb");
		$fsdbDumpvars;
	end
	
	initial begin
		clk = 1;
		#(cyc) rst_n = 0;
		#(cyc) rst_n = 1;
		
		#(cyc) data = 8'b0000_0001;
		#(cyc) Ivalid = 1;
		#(cyc) Ivalid = 0;
		
		#(cyc) data =8'b1111_1111;
		
		#100;
		$finish;
	end
	
endmodule