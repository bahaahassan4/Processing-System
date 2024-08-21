module UART #(parameter OP_WIDTH = 8)
(
    input wire RST,
    input wire TX_CLK,
    input wire RX_CLK,
    input wire PAR_TYP,
    input wire PAR_EN,
    input wire TX_IN_V,
    input wire [OP_WIDTH-1:0] TX_IN_P,
    output wire TX_OUT_S,
    output wire TX_OUT_V,
    input wire RX_IN_S,
    input wire [5:0] prescale,
    output wire RX_OUT_V,
    output wire [OP_WIDTH-1:0] RX_OUT_P,
    output wire Parity_Error,
    output wire Framing_Error
);

UART_TX U0_UART_TX(
    .CLK (TX_CLK),
    .RST (RST),
    .P_DATA (TX_IN_P),
    .Data_Valid (TX_IN_V),
    .PAR_EN (PAR_EN),
    .PAR_TYP (PAR_TYP),
    .TX_OUT (TX_OUT_S),
    .busy (TX_OUT_V)
);

UART_RX U0_UART_RX(
    .CLK (RX_CLK),
    .RST (RST),
    .RX_IN (RX_IN_S),
    .prescale (prescale),
    .PAR_EN (PAR_EN),
    .PAR_TYP (PAR_TYP),
    .data_valid (RX_OUT_V),
    .P_DATA (RX_OUT_P),
    .Parity_Error (Parity_Error),
    .Stop_Error (Framing_Error)
);

endmodule
