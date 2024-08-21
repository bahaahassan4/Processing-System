module deserializer #(parameter bit_cnt_width = 4,

                                edge_cnt_width = 6,

                                prescale_width = 6)

(

    input wire sampled_bit,CLK,RST,deser_en,data_valid,

    input wire [bit_cnt_width-1:0] bit_cnt,

    input wire [edge_cnt_width-1:0]   edge_cnt,

    input wire [prescale_width-1:0] prescale,

    output reg [7:0] P_DATA,

    output reg odd_number_flag

);



reg [7:0] data_bits;



always@(posedge CLK or negedge RST)

begin

    if(!RST)

    begin

        data_bits <= 'b0;
	odd_number_flag <= 'b0;

    end

    else

    begin

        //if(data_valid)

        //begin

            //P_DATA <= data_bits;

          //  odd_number_flag <= ^(data_bits);

        //end

        if(deser_en && edge_cnt == (prescale-1))

        begin

            data_bits[bit_cnt-2] <= sampled_bit;

            odd_number_flag <= ^(data_bits);

        end

        else

        begin

            odd_number_flag <= 0;

        end

    end

end



always @(*)

if(data_valid)

begin

    P_DATA = data_bits;

end

else

begin

    P_DATA = 0;

end

endmodule