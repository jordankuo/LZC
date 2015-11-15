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
	
	reg [$clog2(width*word) : 0]  zeros_next;
	reg [1:0] state, state_next;
	reg Ovalid_next, reg_mode, finish_in, finish_d;
	reg [$clog2(word) : 0] counter_in, inc_in;
	reg [$clog2(width):0] counter_d;
	
	//main
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			state <= IDLE;
			Ovalid <= 0;
			zeros <= 0;
			zeros_next <= 0;
			finish_in <= 0;
			finish_d <= 0;
			counter_d <= 0;
			counter_in <= 0;
			inc_in <= 0;
		end else begin
			state <= state_next;			
			zeros <= zeros_next;
			finish_in <= finish_d;
			counter_in <= inc_in;
		end
	end
	
	//lzc for a data
	always @* begin
		if(Ivalid) begin
			inc_in = counter_in + 1;
			if(!finish_in)begin
				for(counter_d=0;counter_d<width;counter_d=counter_d+1)begin
					if(data[width-1-counter_d] == 0)begin
						zeros_next = zeros_next + 1;
					end else begin
						finish_d = 1;
					end
				end
			end else begin
				if(inc_in == word)begin
					finish_d = 1;
				end else begin
					finish_d = 0;
				end
			end
		end else begin
			inc_in = counter_in;
		end
	end
	
	//FSM
	always @* begin
		reg_mode = 0;
		
		case(state)			
			IDLE: begin
				Ovalid = 0;
				zeros_next = 0;
				if(Ivalid) begin
					state_next = CALC;
				end else begin
					state_next = IDLE;
				end
			end
			
			CALC: begin
				reg_mode = mode;
				
				if(!reg_mode) begin //Normal mode 
					if(finish_in && counter_in == word) begin
						Ovalid = 1;
						finish_d = 0;
						inc_in = 0;
						state_next = IDLE;
					end else begin
						state_next = CALC;
					end
				end else begin //Turbo mode
					if(finish_in)begin
						Ovalid = 1;
						finish_d = 0;
						inc_in = 0;
						state_next = IDLE;
					end else begin
						state_next = CALC;
					end
				end
				
			end
		endcase
	end
endmodule