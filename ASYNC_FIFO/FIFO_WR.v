module FIFO_WR #(parameter PTR_WIDTH = 3)
(
    input wire      winc,
    input wire      wclk,
    input wire      wrst_n,
    input wire [PTR_WIDTH:0] wq2_rptr,
    output reg      wfull,
    output reg [PTR_WIDTH:0] wptr,
    output wire [PTR_WIDTH-1:0] waddr
);
//**********Signals************
reg [PTR_WIDTH:0] waddr_next;
wire               full_c;
reg [PTR_WIDTH:0] waddr_c;
wire [PTR_WIDTH:0] gray_waddr;

//**********binary to gray convertion*********
assign gray_waddr = (waddr_next) ^ (waddr_next>>1); //gray coding for the next address

//**********combinitional block***********
always @ (*)
begin
    if(winc && !wfull)
    begin
        waddr_next = waddr_c + 1;  //incremental to point for the next address that should be write on
    end
    else
    begin
        waddr_next = waddr_c;
    end
end

//**********sequential block for address************
always @ (posedge wclk or negedge wrst_n)
begin
    if(!wrst_n)
    begin
        waddr_c <= 0;
        wptr <= 0;
    end
    else
    begin
        waddr_c <= waddr_next;
        wptr <= gray_waddr;
    end
end

assign waddr = waddr_c [PTR_WIDTH-1:0] ;  //assigning the address

//*********assign statment for full flag************
assign full_c = ((wq2_rptr[PTR_WIDTH] != gray_waddr[PTR_WIDTH]) && (wq2_rptr[PTR_WIDTH-1] != gray_waddr[PTR_WIDTH-1]) && (wq2_rptr[PTR_WIDTH-2:0] == gray_waddr[PTR_WIDTH-2:0]));

//**********sequential block for full flag************
always @ (posedge wclk or negedge wrst_n)
begin
    if(!wrst_n)
    begin
        wfull <= 0;
    end
    else
    begin
        wfull <= full_c;
    end
end

endmodule
