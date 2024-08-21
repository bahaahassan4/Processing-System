module strt_Check #(parameter edge_cnt_width = 6,

                              prescale_width = 6)

(

    input wire strt_chk_en,

    input wire sampled_bit,

    input wire [edge_cnt_width-1:0] edge_cnt,

    input wire [prescale_width-1:0] prescale,

    output reg strt_glitch

    );



always@(*)

begin

    if(strt_chk_en)

    begin

        if(!sampled_bit && edge_cnt == prescale-1)

            strt_glitch = 'b0;

        else if(sampled_bit && edge_cnt == prescale-1)

            strt_glitch = 'b1;
        else
            strt_glitch = 'b0;

    end

    else

    begin

        strt_glitch = 'b0;

    end

end

endmodule
