module lzc(
	clk, rst_n, data, Ivalid, mode,
	zeros, Ovalid,
);
	parameter width = 8, word = 4;
	parameter IDLE=2'b00, NORMAL=2'b01,TURBO=2'b10;
	
	input clk;
	input rst_n;
	input [width-1 : 0] data;
	input Ivalid;
	input mode;
	output reg [$clog2(width*word) : 0] zeros;
	output reg Ovalid;
	
	reg [$clog2(width*word) : 0] zeros_next;
	reg [$clog2(width*word) : 0] i;
	reg [1:0] state, state_next;
	reg reg_mode;
	reg finish;
	reg finish_next;
	reg [width-1 : 0] data_next;
	reg [$clog2(word) : 0] counter_in;
	reg [$clog2(word) : 0] counter_tmp;
	reg [$clog2(word) : 0] inc_in;
	reg [$clog2(width*word)-1:0] counter_d;
	reg [width*word-1 : 0] sum;
	
	//main
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			Ovalid <= 0;
			zeros <= 0;
			counter_in <= 0;
			finish <= 0;
			state <= IDLE;
			data_next <= 0;
		end else begin
			state <= state_next;
			reg_mode <= mode;
			counter_in <= inc_in;
			data_next <= data;
			finish <= finish_next;
		end
		
		if(!Ovalid && finish_next)begin
			counter_tmp = counter_in;
		end else begin
			counter_tmp = 0;
		end
	end
	
	always @* begin
		if(Ivalid)begin
			if(!reg_mode)begin//NORMAL
				if(counter_in <= word -1)begin
					for(counter_d=0;counter_d<width;counter_d=counter_d+1)begin
						sum[width*word-1-counter_in*width-counter_d] = data_next[width-1-counter_d];
					end
					inc_in = counter_in + 1;
				end else begin
					inc_in = counter_in;
				end
			end else begin//TURBO
				if(counter_in == word-1) begin
					inc_in = 0;
					finish_next = 1;
				end else begin
					if(data_next == 0)begin
						inc_in = counter_in + 1;
						finish_next = 0;
					end else begin
						inc_in = 0;
						finish_next = 1;
					end
				end
			end
		end else begin
			if(counter_in == word)begin
				inc_in = 0;
				finish_next = 0;
			end else begin
				inc_in = counter_in;
				if(counter_in == 0)begin
					finish_next = 0;
				end else begin
					finish_next = finish;
				end
			end
		end
	end
	
	always @* begin
		case(state)
			IDLE: begin
				Ovalid = 0;
				if(Ivalid)begin
					if(!reg_mode)begin//NORMAL
						state_next = NORMAL;
					end else begin//TURBO
						state_next = TURBO;
					end
				end else begin
					state_next = IDLE;
				end
			end
			
			NORMAL: begin
				if(counter_in == word)begin
					Ovalid = 1;
					if(sum == 0)begin
						zeros_next = width*word;
					end else begin
						for(i=0;i<width*word;i=i+1)begin
							if(sum[i])begin
								zeros_next = width*word - 1 - i;
							end else begin
								zeros = zeros_next;
							end
						end
					end
					zeros = zeros_next;
					state_next = IDLE;
				end else begin
					state_next = state;
				end
			end
			
			TURBO: begin
				if(finish && counter_in != word)begin
					Ovalid = 1;
						for(counter_d=0;counter_d<width;counter_d=counter_d+1)begin
							if(data_next[counter_d])begin
								zeros_next = 8*counter_tmp + width-1-counter_d;
							end else begin
								zeros = zeros_next;
							end
						end
					state_next = IDLE;
				end else begin
					for(counter_d=0;counter_d<width;counter_d=counter_d+1)begin
						if(data_next[counter_d])begin
							zeros_next = 8*counter_tmp + width-1-counter_d;
						end else begin
							zeros = zeros_next;
						end
					end
					
					if(counter_in == word-1)begin
						zeros_next = width*word;
					end else begin
						zeros_next = zeros;
					end
				end
			end
			
			default: begin
				zeros_next = 0;
				state_next = IDLE;
			end
		endcase
	end
endmodule