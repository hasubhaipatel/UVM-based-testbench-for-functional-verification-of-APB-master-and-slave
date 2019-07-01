/***************            Created by : Dhriti Iddya                    *******************/
/*************** Verilog module for implementation of APB slave protocol *******************/

module APB_SLAVE(PRESET,PCLK,PSEL,PENABLE,PREADY,PADDR,PWRITE,PWDATA,PRDATA);
	
	parameter ADDR_WIDTH;
	parameter DATA_WIDTH;
	parameter [1:0]
		IDLE    = 2'b00;
		SETUP   = 2'b01;
		ACCESS  = 2'b10;
		ILLEGAL = 2'b11;

	//-------------------------- Input signals ------------------------//
	
	input PRESET;
	input CLK;
	input PSEL;
	input PENABLE;
	input PWRITE;
	input [ADDR_WIDTH-1:0] PADDR;
    input [DATA_WIDTH-1:0] PWDATA;

	//------------------------- Output signals --------------------------//

	output reg PREADY;
	output reg [DATA_WIDTH-1:0] PRDATA;

	//------------------------- Nets and Registers ----------------------//

	reg [1:0] current_state,next_state;
	reg [DATA_WIDTH-1:0] RAM [0:2**ADDR_WIDTH-1];  // Models storage in the slave for reading/writing data
	
	//------------------------- Sequential Logic -------------------------//
	
	always@(posedge PCLK or negedge PRESET)
	begin
		if(!PRESET)
			current_state <= IDLE;
		else
			current_state <= next_state;
	end
	
	//--------------------------- Next State and Output Logic -----------------------//
	always@(current_state)
	begin
	PRDATA = 0, PREADY = 0;
	case (current_state)
		IDLE: begin
			if(PSEL) next_state = SETUP;
			else next_state = IDLE;
		end
		
		SETUP: begin
			if(PSEL && PENABLE) next_state = ACCESS;
		end
		
		ACCESS: begin
			if (PSEL && PENABLE && PWRITE) begin
				PREADY = 1;
				RAM[PADDR] = PWDATA;
			end
			else if (PSEL && PENABLE && !PWRITE) begin
				PREADY = 1;
				PRDATA = RAM[PADDR];			
			end
			next_state = IDLE;
		end
		
		ILLEGAL: begin
			next_state = IDLE;
		end
		
		default: next_state = IDLE;
	end

endmodule