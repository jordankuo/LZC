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
	
	reg [$clog2(width*word) : 0]  zeros_next,i;
	reg [1:0] state, state_next;
	reg reg_mode;
	reg [width-1 : 0] data_next;
	reg [$clog2(word) : 0] counter_in, inc_in;
	reg [$clog2(width):0] counter_d;
	reg [width*word-1 : 0] sum;
	
	//main
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			Ovalid <= 0;
			zeros <= 0;
			counter_in <= 0;
			state <= IDLE;
			data_next <= 0;
		end else begin
			state <= state_next;
			reg_mode <= mode;
			counter_in <= inc_in;
			data_next <= data;
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
				
			end
		end else begin
			if(counter_in == word)begin
				inc_in = 0;
			end else begin
				inc_in = counter_in;
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
				if(Ovalid)begin
					zeros = zeros_next;
					state_next = IDLE;
				end else begin
					state_next = state;
				end
			end
		endcase
	end
endmodule