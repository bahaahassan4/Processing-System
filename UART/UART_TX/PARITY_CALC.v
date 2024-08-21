module PARITY_CALC #(parameter OP_WIDTH = 8)
(
    input   wire   [OP_WIDTH-1:0]   P_DATA,
	input   wire                    CLK,RST,
    input   wire                    Data_Valid,
    input   wire                    PAR_TYP,
	input   wire                    PAR_FLAG,
    output  wire                    par_bit 
);

reg par_bit_c;

/*always @ (*)
begin
    if(Data_Valid && !PAR_TYP)     //even parity
    begin
        par_bit_c = ^P_DATA;
    end
    else if(Data_Valid && PAR_TYP)  //odd parity
    begin
        par_bit_c = ~^P_DATA;
    end
    else
    begin
        par_bit_c = 'b0;
    end
end*/

assign par_bit = par_bit_c;

always @ (posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        par_bit_c <= 'b0;
    end
    else
    begin
        if(PAR_FLAG && Data_Valid && !PAR_TYP)
        begin
            par_bit_c <= ^P_DATA;
        end
		else if(PAR_FLAG && Data_Valid && PAR_TYP)
		begin
			par_bit_c <= ~^P_DATA;
		end
    end
end
endmodule