module lzc(
	clk, rst_n, data, Ivalid, mode,
	zeros, Ovalid,
);
	
	parameter width = 8, word = 4;
	parameter IDLE = 1'b0, CALC = 1'b1;
	
	input clk,rst_n,Ivalid,mode;
	input [width-1 : 0] data;
	output reg [$clog2(width*word) : 0] zeros;
	output reg Ovalid;
	
	reg [width-1 : 0] data_next;
	reg [$clog2(width*word) : 0]  zeros_next;
	reg [1:0] state, state_next;
	reg Ovalid_next, reg_mode, finish_in;
	reg [$clog2(word)-1 : 0] counter_in, inc_in;
	reg [$clog2(width)-1:0] counter_d, inc_d;
	
	always @(posedge clk, negedge rst_n) begin
		//main
		if(!rst_n) begin
			state <= IDLE;
			Ovalid <= 0;
			zeros <= 0;
			finish_in <= 0;
			counter_d <= width-1;
			counter_in <= 0;
		end else begin
			state <= state_next;
			Ovalid <= Ovalid_next;			
			zeros <= zeros_next;
			counter_in <= inc_in;
		end
		
		//fatch data
		if(Ivalid)begin
			data_next = data;
		end else begin
			data_next = 1;
		end
	end
	
	//lzc for a data
	always @* begin
		if(Ivalid && !finish_in) begin
			if(data_next[counter_d] == 0 && counter_d > 0)begin
				zeros_next = zeros + 1;
				inc_d = counter_d - 1;
			end else begin// data_next[counter_d] != 0 || counter_d == 0
				inc_in = counter_in + 1;
				if(counter_d == 0)begin
					inc_d = width-1;
					finish_in = 0;
				end else begin
					finish_in = 1;
				end
			end
		end else begin// !Ivalid || finish_in
			
		end
	end
	
	//FSM
	always @* begin
		Ovalid_next = 0;
		reg_mode = 0;
		
		case(state)			
			IDLE: begin
				if(Ivalid) begin
					state_next = CALC;
				end else begin
					state_next = IDLE;
				end
			end
			
			CALC: begin
				reg_mode = mode;
				counter_d = inc_d;
				if(finish_in || counter_in == word)begin
					counter_in <= 0;
				end else begin
					counter_in <= inc_in;
				end
				if(!reg_mode) begin //Normal mode 
					if(finish_in && counter_in == word) begin
						inc_in = 0;
						Ovalid_next = 1;
						state_next = IDLE;
					end else begin
						inc_in = counter_in;
						state_next = CALC;
					end
				end else begin //Turbo mode
					if(finish_in)begin
						inc_in = 0;
						Ovalid_next = 1;
						state_next = IDLE;
					end else begin
						inc_in = counter_in;
						state_next = CALC;
					end
				end
			end
		endcase
	end
endmodule