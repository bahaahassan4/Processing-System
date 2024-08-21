module UART_TX #(parameter OP_WIDTH = 8)
(
    input wire [OP_WIDTH-1:0]   P_DATA,
    input wire                  Data_Valid,
    input wire                  PAR_EN,
    input wire                  PAR_TYP,
    input wire                  CLK,RST,
    output wire                 TX_OUT,
    output wire                 busy
);

//internal connections
wire ser_done,ser_en,par_bit,ser_data;
wire parity_flag;
wire [2:0]   mux_sel;

//Serializer block
Serializer U_Serializer(
    .P_DATA(P_DATA),
    .ser_en(ser_en),
    .CLK(CLK),
    .RST(RST),
	.Data_Valid(Data_Valid),
	.busy(busy),
    .ser_done(ser_done),
    .ser_data(ser_data)
);

//PARITY_CALC block
PARITY_CALC U_PARITY_CALC(
    .P_DATA(P_DATA),
    .Data_Valid(Data_Valid),
    .PAR_TYP(PAR_TYP),
    .par_bit(par_bit),
	.CLK (CLK),
	.RST (RST),
	.PAR_FLAG (parity_flag)
);

//FSM
FSM_TX U_FSM(
    .CLK(CLK),
    .RST(RST),
    .Data_Valid(Data_Valid),
    .PAR_EN(PAR_EN),
    .ser_done(ser_done),
    .ser_en(ser_en),
    .busy(busy),
    .mux_sel(mux_sel),
	.parity_flag (parity_flag)
);

//MUX
MUX U_MUX(
    //.CLK(CLK),
    //.RST(RST),
    .mux_sel(mux_sel),
    .ser_data(ser_data),
    .par_bit(par_bit),
    .TX_OUT(TX_OUT)
);
endmodule
