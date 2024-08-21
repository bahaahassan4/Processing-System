module FIFO_MEM_CNTRL #(parameter   PTR_WIDTH = 3,
                                    DATA_WIDTH = 8,
                                    DEPTH = 8)
(
    input wire  [DATA_WIDTH-1:0] wdata,
    input wire  [PTR_WIDTH-1:0]  waddr,raddr,
    input wire                   wclk,winc,wfull,
	input wire                   RST,
    output wire  [DATA_WIDTH-1:0] rdata
);

//**************signals***************
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
integer i;

//*************sequential block for writing*************
always @ (posedge wclk or negedge RST)
begin
	if(!RST)
	begin
		for (i = 0 ; i<DEPTH ; i = i + 1)
		begin
			mem[i] <= 'b0;
		end
	end
    else if(winc && !wfull)
    begin
        mem[waddr] <= wdata;
    end
end

//*************assign statment for reading*************
assign rdata = mem[raddr];

endmodule