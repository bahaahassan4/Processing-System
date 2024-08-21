module UART_RX #(parameter  prescale_width = 6,
                            edge_cnt_width = 6,
                            bit_cnt_width = 4)
(
    input wire RX_IN,
    input wire [prescale_width-1:0] prescale,
    input wire PAR_EN,
    input wire PAR_TYP,
    input wire CLK,RST,
    output wire data_valid,
    output wire [7:0] P_DATA,
    output wire Parity_Error,
    output wire Stop_Error
);

//internal signals
wire dat_samp_en,enable,deser_en,stp_chk_en,strt_chk_en,par_chk_en;
wire [edge_cnt_width-1:0] edge_cnt;
wire [bit_cnt_width-1:0] bit_cnt;
wire sampled_bit,par_err,strt_glitch,stp_err,odd_number_flag;

//FSM
FSM_RX U_FSM(
    .CLK (CLK),
    .RST (RST),
    .PAR_EN (PAR_EN),
    .bit_cnt (bit_cnt),
    .edge_cnt (edge_cnt),
    .RX_IN (RX_IN),
    .par_err (par_err),
    .strt_glitch (strt_glitch),
    .stp_err (stp_err),
    .prescale (prescale),
    .par_chk_en (par_chk_en),
    .strt_chk_en (strt_chk_en),
    .stp_chk_en (stp_chk_en),
    .dat_samp_en (dat_samp_en),
    .deser_en (deser_en),
    .enable (enable),
    .data_valid (data_valid),
    .Parity_Error (Parity_Error),
    .Stop_Error (Stop_Error)
);

//Stop Check
Stop_Check U_Stop_Check(
    .stp_chk_en (stp_chk_en),
    .sampled_bit (sampled_bit),
    .stp_err (stp_err),
    .prescale (prescale),
    .edge_cnt (edge_cnt)
);

//strt Check
strt_Check U_strt_Check(
    .strt_chk_en (strt_chk_en),
    .sampled_bit (sampled_bit),
    .strt_glitch (strt_glitch),
    .prescale (prescale),
    .edge_cnt (edge_cnt)
);

//Parity Check
PARITY_CHECK U_PARITY_CHECK(
    .par_chk_en (par_chk_en),
    .PAR_TYP (PAR_TYP),
    .odd_number_flag (odd_number_flag),
    .par_err (par_err)
);

//Edge bit counter
Edge_bit_counter U_Edge_bit_counter(
    .CLK (CLK),
    .RST (RST),
    .enable (enable),
    .prescale (prescale),
    .PAR_EN (PAR_EN),
    .bit_cnt (bit_cnt),
    .edge_cnt (edge_cnt)
);

//data sampler
data_sampling U_data_sampling(
    .RX_IN (RX_IN),
    .CLK (CLK),
    .prescale (prescale),
    .dat_samp_en (dat_samp_en),
    .edge_cnt (edge_cnt),
    .sampled_bit (sampled_bit)
);

//deserializer
deserializer U_deserializer(
    .sampled_bit (sampled_bit),
    .CLK (CLK),
    .RST (RST),
    .deser_en (deser_en),
    .data_valid (data_valid),
    .bit_cnt (bit_cnt),
    .P_DATA (P_DATA),
    .odd_number_flag (odd_number_flag),
    .edge_cnt (edge_cnt),
    .prescale (prescale)
);

endmodule