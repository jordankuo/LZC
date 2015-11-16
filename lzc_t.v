module stimulus;
	parameter cyc = 10, width = 8, word = 4;
	
	reg clk, rst_n, Ivalid, mode;
	reg [width-1 : 0] data;
	wire [$clog2(width*word) : 0] zeros;
	wire Ovalid;
	
	
	lzc LZC(.clk(clk), 
			.rst_n(rst_n), 
			.data(data), 
			.Ivalid(Ivalid), 
			.mode(mode),
			.zeros(zeros), 
			.Ovalid(Ovalid));
	
	always #(cyc/2) clk = ~clk;
	
	initial begin
		$fsdbDumpfile("lzc.fsdb");
		$fsdbDumpvars;
	end
	
	initial begin
		clk = 1;
		#(cyc) rst_n = 0;
		#(cyc) rst_n = 1;
		#(cyc) mode = 0;
		
		//contiuous input
		#(cyc) data = 8'b0000_0001;
		#(cyc) Ivalid = 1;
		#(cyc*4) Ivalid = 0;
		
		//discontiuous input
		#(cyc) data = 8'b0011_1111;Ivalid = 1;
		#(cyc) Ivalid = 0;
		#(cyc) Ivalid = 1;
		#(cyc) Ivalid = 0;
		#(cyc) Ivalid = 1;
		#(cyc) Ivalid = 0;
		#(cyc) data = 8'b0000_0000; Ivalid = 1; 
		#(cyc) Ivalid = 0;
		
		//contiuous diff. input
		#(cyc) data = 8'b0001_0000;Ivalid = 1;
		#(cyc) data = 8'b0011_1111;
		#(cyc) data = 8'b1111_1111;
		#(cyc) data = 8'b0000_0000;
		#(cyc) Ivalid = 0;
		
		//contiuous zero
		#(cyc) data=8'b0000_0000; Ivalid = 1;
		#(cyc*4) Ivalid = 0; 
		
		//discontiuous zero
		#(cyc) data = 8'b0000_0000;Ivalid = 1;
		#(cyc) Ivalid = 0;
		#(cyc) Ivalid = 1;
		#(cyc) Ivalid = 0;
		#(cyc) Ivalid = 1;
		#(cyc) Ivalid = 0;
		#(cyc) Ivalid = 1;
		#(cyc) Ivalid = 0;
		
		
		#100;
		$finish;
	end
	
endmodule