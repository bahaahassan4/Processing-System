module PARITY_CHECK 
(
input wire par_chk_en,PAR_TYP,odd_number_flag,
output reg par_err
);

always@(*)
begin
    if(par_chk_en)
    begin
        if(PAR_TYP)
        begin
            if(odd_number_flag)
            begin
                par_err = 'b0;
            end
            else
            begin
                par_err = 'b1;
            end
        end
        else
        begin
            if(odd_number_flag)
            begin
                par_err = 'b1;
            end
            else
            begin
                par_err = 'b0;
            end
        end
    end
    else
        par_err = 'b0;
end
endmodule
