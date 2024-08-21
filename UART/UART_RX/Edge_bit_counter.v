module Edge_bit_counter #(parameter prescale_width = 6,
                                    edge_cnt_width = 6,
                                    bit_cnt_width = 4)
    (
    input wire CLK,RST,
    input wire enable,
    input wire [prescale_width-1:0] prescale,
    input wire PAR_EN,
    output reg [bit_cnt_width-1:0] bit_cnt,
    output reg [edge_cnt_width-1:0] edge_cnt
    );

always @(posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        edge_cnt <= 6'b000001;
        bit_cnt <= 4'b0001;
    end
    else
    begin
        if(enable)
        begin
        if(edge_cnt == prescale)
        begin
            edge_cnt <= 6'b000001;
            if(PAR_EN && (bit_cnt == 'd11))
                bit_cnt <= 'd1;
            else if(!PAR_EN && (bit_cnt == 'd10))
                bit_cnt <= 'd1;
            else
                bit_cnt <= bit_cnt + 1;
        end
        else
            edge_cnt <= edge_cnt + 1;
        end
    end
end
endmodule
