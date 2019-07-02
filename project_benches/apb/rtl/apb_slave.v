/***************            Created by : Dhriti Iddya                    *******************/
/*************** Verilog module for implementation of APB slave protocol *******************/

module apb_slave(PRESET,PCLK,PSEL,PENABLE,PREADY,PADDR,PWRITE,PWDATA,PRDATA);
	
	parameter ADDR_WIDTH = 8;
	parameter DATA_WIDTH = 32;
	parameter [1:0]
		IDLE    = 2'b00,
		WRITE   = 2'b01,
		READ    = 2'b10,
		ILLEGAL = 2'b11;

	//-------------------------- Input signals ------------------------//
	
	input PRESET;
	input PCLK;
	input PSEL;
	input PENABLE;
	input PWRITE;
	input [ADDR_WIDTH-1:0] PADDR;
    input [DATA_WIDTH-1:0] PWDATA;

	//------------------------- Output signals --------------------------//

	output reg PREADY;
	output reg [DATA_WIDTH-1:0] PRDATA;

	//------------------------- Nets and Registers ----------------------//

  reg [1:0] current_state,next_state = 0;
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
  always@(*)
	begin
    PRDATA = 0;
    PREADY = 0;
	case (current_state)
		IDLE: begin
          if(PSEL && !PENABLE) begin
				if(PWRITE)
					next_state = WRITE;
              else if (!PWRITE)
					next_state = READ;
			end
		end
		
		WRITE: begin
			if (PSEL && PENABLE && PWRITE) begin
				PREADY = 1;
				RAM[PADDR] = PWDATA;
			end
          	next_state = IDLE;
		end
		
		READ: begin
			if (PSEL && PENABLE && !PWRITE) begin
				PREADY = 1;
				PRDATA = RAM[PADDR];
			end
          	next_state = IDLE;
		end
		
		ILLEGAL: begin
			next_state = IDLE;
		end
		
		default: next_state = IDLE;
    endcase
    end

endmodule