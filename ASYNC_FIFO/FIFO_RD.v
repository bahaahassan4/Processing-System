module FIFO_RD #(parameter PTR_WIDTH = 3)
(
    input wire      rinc,
    input wire      rclk,
    input wire      rrst_n,
    input wire [PTR_WIDTH:0] rq2_wptr,
    output reg      rempty,
    output reg [PTR_WIDTH:0] rptr,
    output wire [PTR_WIDTH-1:0] raddr
);

//************Signals************
reg [PTR_WIDTH:0] raddr_next;
wire               empty_c;
reg [PTR_WIDTH:0] raddr_c;
wire [PTR_WIDTH:0] gray_raddr;

//**********binary to gray convertion*********
assign gray_raddr = (raddr_next) ^ (raddr_next>>1); //gray coding for the next address

//**********combinitional block**********
always @ (*)
begin
    if(rinc && !rempty)
    begin
        raddr_next = raddr_c + 1;  //incremental to point for the next address that should be write on
    end
    else
    begin
        raddr_next = raddr_c;
    end
end

//**********sequential block for address************
always @ (posedge rclk or negedge rrst_n)
begin
    if(!rrst_n)
    begin
        raddr_c <= 0;
        rptr <= 0;
    end
    else
    begin
        raddr_c <= raddr_next;
        rptr <= gray_raddr;
    end
end

assign raddr = raddr_c [PTR_WIDTH-1:0] ;  //assigning the address

//*********assign statment for empty flag**************
assign empty_c = (rq2_wptr == gray_raddr);

//**********sequential block for full flag*************
always @ (posedge rclk or negedge rrst_n)
begin
    if(!rrst_n)
    begin
        rempty <= 1;  //when reset bin is triggered the empty flag will be one
    end
    else
    begin
        rempty <= empty_c;
    end
end

endmodule