module SYS_TOP #(parameter OP_WIDTH = 8, ADDR = 4)
(
    input wire          RST_N,
    input wire          UART_CLK,
    input wire          REF_CLK,
    input wire          UART_RX_IN,
    output wire         UART_TX_OUT,
    output wire         Parity_Error,
    output wire         Framing_Error
);

//internal signals
wire                    SYNC_UART_RST;
wire                    SYNC_REF_RST;

wire                    CLKG_EN;
wire                    ALU_CLK;

wire                    CLKDIV_EN;
wire    [OP_WIDTH-1:0]  DIV_Ratio;
wire    [OP_WIDTH-1:0]  DIV_Ratio_RX;
wire                    UART_TX_CLK;
wire                    UART_RX_CLK;
wire    [OP_WIDTH-1:0]  UART_Config;

wire                    RF_WrEn;
wire                    RF_RdEn;
wire    [OP_WIDTH-1:0]  RF_WrData;
wire    [ADDR-1:0]      RF_Address;
wire    [OP_WIDTH-1:0]  RF_RdData;
wire                    RF_RdData_Valid;
wire    [OP_WIDTH-1:0]  OperandA;
wire    [OP_WIDTH-1:0]  OperandB;

wire                    ALU_EN;
wire    [3:0]           ALU_FUN;
wire    [OP_WIDTH*2-1:0] ALU_OUT;
wire                    ALU_OUT_VALID;

wire                    UART_TX_D_VLD;
wire                    RD_INC;
wire    [OP_WIDTH-1:0]  UART_TX_P_Data;
wire                    FIFO_FULL;
wire                    FIFO_EMPTY;
wire    [OP_WIDTH-1:0]  UART_TX_SYNC_Data;

wire                    Busy;

wire                    UART_RX_D_VLD;
wire    [OP_WIDTH-1:0]  UART_RX_P_Data;

wire    [OP_WIDTH-1:0]  UART_RX_SYNC_Data;
wire                    UART_RX_SYNC_VLD;

//Reset Synchronizer
RST_SYNC #(.NUM_STAGES(2)) U0_RST_SYNC(
    .RST (RST_N),
    .CLK (UART_CLK),
    .SYNC_RST (SYNC_UART_RST)
);

RST_SYNC #(.NUM_STAGES(2)) U1_RST_SYNC(
    .RST (RST_N),
    .CLK (REF_CLK),
    .SYNC_RST (SYNC_REF_RST)
);

//Clock Gating
CLK_GATE U0_CLK_GATE(
    .CLK_EN (CLKG_EN),
    .CLK (REF_CLK),
    .GATED_CLK (ALU_CLK)
);

//TX Clock Divider
CLK_DIV U0_CLK_DIV(
    .i_ref_clk (UART_CLK),
    .i_rst_n (SYNC_UART_RST),
    .i_clk_en (CLKDIV_EN),
    .i_div_ratio (DIV_Ratio),
    .o_div_clk (UART_TX_CLK)
);

//MUX
CLKDIV_MUX U0_CLKDIV_MUX(
    .IN (UART_Config[7:2]),
    .OUT (DIV_Ratio_RX)
);

//RX Clock Divider
CLK_DIV U1_CLK_DIV(
    .i_ref_clk (UART_CLK),
    .i_rst_n (SYNC_UART_RST),
    .i_clk_en (CLKDIV_EN),
    .i_div_ratio (DIV_Ratio_RX),
    .o_div_clk (UART_RX_CLK)
);

//Register File
RegFile U0_RegFile(
    .RdEn (RF_RdEn),
    .WrEn (RF_WrEn),
    .CLK (REF_CLK),
    .RST (SYNC_REF_RST),
    .WrData (RF_WrData),
    .Address (RF_Address),
    .RdData (RF_RdData),
    .RdData_VLD (RF_RdData_Valid),
    .REG0 (OperandA),
    .REG1 (OperandB),
    .REG2 (UART_Config),
    .REG3 (DIV_Ratio)
);

//ALU
ALU U0_ALU(
    .A (OperandA),
    .B (OperandB),
    .EN (ALU_EN),
    .ALU_FUN (ALU_FUN),
    .CLK (ALU_CLK),
    .RST (SYNC_REF_RST),
    .ALU_OUT (ALU_OUT),
    .OUT_VALID (ALU_OUT_VALID)
);

//Asynchronous FIFO
FIFO_Top U0_FIFO_Top(
    .wclk (REF_CLK),
    .wrst_n (SYNC_REF_RST),
    .rclk (UART_TX_CLK),
    .rrst_n (SYNC_UART_RST),
    .winc (UART_TX_D_VLD),
    .rinc (RD_INC),
    .wdata (UART_TX_P_Data),
    .wfull (FIFO_FULL),
    .rempty (FIFO_EMPTY),
    .rdata (UART_TX_SYNC_Data)
);

//Pulse generator
PULSE_GEN U0_PULSE_GEN (
    .clk (UART_TX_CLK),
    .rst (SYNC_UART_RST),
    .lvl_sig (Busy),
    .pulse_sig (RD_INC)
);

//UART
UART U0_UART (
    .RST (SYNC_UART_RST),
    .TX_CLK (UART_TX_CLK),
    .RX_CLK (UART_RX_CLK),
    .PAR_TYP (UART_Config[1]),
    .PAR_EN (UART_Config[0]),
    .TX_IN_V (!FIFO_EMPTY),
    .TX_IN_P (UART_TX_SYNC_Data),
    .TX_OUT_S (UART_TX_OUT),
    .TX_OUT_V (Busy),
    .RX_IN_S (UART_RX_IN),
    .prescale (UART_Config[7:2]),
    .RX_OUT_V (UART_RX_D_VLD),
    .RX_OUT_P (UART_RX_P_Data),
    .Parity_Error (Parity_Error),
    .Framing_Error (Framing_Error)
);

//Data Synchronizer
DATA_SYNC #(.NUM_STAGES(2), .BUS_WIDTH(8)) U0_DATA_SYNC (
    .unsync_bus (UART_RX_P_Data),
    .bus_enable (UART_RX_D_VLD),
    .CLK (REF_CLK),
    .RST (SYNC_REF_RST),
    .sync_bus (UART_RX_SYNC_Data),
    .enable_pulse (UART_RX_SYNC_VLD)
);

//System Control
SYS_CTRL U0_SYS_CTRL (
    .ALU_OUT (ALU_OUT),
    .ALU_OUT_Valid (ALU_OUT_VALID),
    .UART_RX_P_Data (UART_RX_SYNC_Data),
    .UART_RX_D_VLD (UART_RX_SYNC_VLD),
    .RF_RdData (RF_RdData),
    .RF_RdData_Valid (RF_RdData_Valid),
    .CLK (REF_CLK),
    .RST (SYNC_REF_RST),
    .FIFO_FULL (FIFO_FULL),
    .ALU_EN (ALU_EN),
    .ALU_FUN (ALU_FUN),
    .CLKG_EN (CLKG_EN),
    .RF_Address (RF_Address),
    .RF_WrEn (RF_WrEn),
    .RF_RdEn (RF_RdEn),
    .RF_WrData (RF_WrData),
    .UART_TX_P_Data (UART_TX_P_Data),
    .UART_TX_D_VLD (UART_TX_D_VLD),
    .clk_div_en (CLKDIV_EN)
);

endmodule
