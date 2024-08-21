module data_sampling #(parameter    prescale_width = 6,
                                    edge_cnt_width = 6)
    (
    input wire RX_IN,
    input wire CLK,
    input wire [prescale_width-1:0] prescale,
    input wire dat_samp_en,
    input wire [edge_cnt_width-1:0] edge_cnt,
    output reg sampled_bit
    );

//wire decleration
reg sample_1,sample_2,sample_3;

always @(posedge CLK)
begin
    if(dat_samp_en)
    begin
        if(edge_cnt == (prescale/2)-1)
            sample_1 <= RX_IN;
        else if(edge_cnt == prescale/2)
            sample_2 <= RX_IN;
        else if(edge_cnt == (prescale/2)+1)
        begin
            sample_3 <= RX_IN;
            if(sample_1 == sample_2 == sample_3)
                sampled_bit <= sample_1;   
            else if(sample_1 == sample_2)
                sampled_bit <= sample_2;
            else if(sample_2 == sample_3)
                sampled_bit <= sample_2;
            else
                sampled_bit <= sample_3;
        end
       /* else
        begin
            sample_1 <= 'b0;
            sample_2 <= 'b0;
            sample_3 <= 'b0;
            sampled_bit <= 'b1;   //default value
        end*/
    end
end
endmodule
