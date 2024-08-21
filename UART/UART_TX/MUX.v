module MUX (
    input   wire  [2:0]     mux_sel,
//    input   wire            CLK,RST,
    input   wire            ser_data,
    input   wire            par_bit,
    output  reg             TX_OUT
);

//reg TX_OUT_comb;

//sequential block
/*always @(posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        TX_OUT <= 'b1;
    end
    else
    begin
        TX_OUT <= TX_OUT_comb;
    end
end*/

//combintional block
always @(*)
begin
    case(mux_sel)
        3'b000 : TX_OUT = 'b1; //idle case
        3'b001 : TX_OUT = 'b0; //start bit
        3'b010 : TX_OUT = ser_data;
        3'b011 : TX_OUT = par_bit;
        3'b100 : TX_OUT = 'b1; //stop bit
        default : TX_OUT = 'b1; //idle case
    endcase
end
endmodule