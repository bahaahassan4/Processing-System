module Stop_Check #(parameter edge_cnt_width = 6,
                              prescale_width = 6)
(
    input wire stp_chk_en,
    input wire sampled_bit,
    input wire [edge_cnt_width-1:0] edge_cnt,
    input wire [prescale_width-1:0] prescale,
    output reg stp_err
    );

always@(*)
begin
    if(stp_chk_en)
    begin
        if(!sampled_bit && edge_cnt == prescale-1)
            stp_err = 'b1;
        else
            stp_err = 'b0;
    end
    else
    begin
        stp_err = 'b0;
    end
end
endmodule
