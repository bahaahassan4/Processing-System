module FIFO_Top #(parameter     PTR_WIDTH = 3,
                                DATA_WIDTH = 8,
                                DEPTH = 8)
(
    input wire  wclk,wrst_n,rclk,rrst_n,
    input wire  winc,rinc,
    input wire  [DATA_WIDTH-1:0] wdata,
    output wire wfull,rempty,
    output wire  [DATA_WIDTH-1:0] rdata
);

//**********internal signals***********
wire [PTR_WIDTH-1:0] waddr,raddr;
wire [PTR_WIDTH:0]   wptr,rptr;
wire [PTR_WIDTH:0]   wq2_rptr,rq2_wptr;

FIFO_WR U_FIFO_WR(
    .wclk (wclk),
    .wrst_n (wrst_n),
    .winc (winc),
    .wq2_rptr (wq2_rptr),
    .wfull (wfull),
    .wptr (wptr),
    .waddr (waddr)
);

FIFO_RD U_FIFO_RD(
    .rinc (rinc),
    .rclk (rclk),
    .rrst_n (rrst_n),
    .rq2_wptr (rq2_wptr),
    .rempty (rempty),
    .rptr (rptr),
    .raddr (raddr)
);

FIFO_MEM_CNTRL U_FIFO_MEM_CNTRL(
    .wdata (wdata),
    .waddr (waddr),
    .raddr (raddr),
    .wclk (wclk),
    .winc (winc),
    .wfull (wfull),
    .rdata (rdata),
	.RST (rrst_n)
);

DF_SYNC sync_r2w(
    .CLK (wclk),
    .RST (wrst_n),
    .IN (rptr),
    .OUT (wq2_rptr)
);

DF_SYNC sync_w2r(
    .CLK (rclk),
    .RST (rrst_n),
    .IN (wptr),
    .OUT (rq2_wptr)
);

endmodule
