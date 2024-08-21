module CLK_DIV (

    input wire i_ref_clk,i_rst_n,i_clk_en,

    input wire [7:0] i_div_ratio,

    output  reg o_div_clk

);



reg [6:0] counter;

reg odd_flag;
reg o_div_clk_c;

wire CLK_DIV_EN;

wire is_odd;



assign CLK_DIV_EN = i_clk_en && (i_div_ratio) && (i_div_ratio != 1);

assign is_odd = i_div_ratio[0];



always @(posedge i_ref_clk or negedge i_rst_n)

begin

    if(!i_rst_n)

    begin

        counter <= 0;

        o_div_clk_c <= 0;

        odd_flag <= 0;

    end

    else if(CLK_DIV_EN)

    begin

        if(!is_odd && (counter == (i_div_ratio >> 1)-1))

        begin

            counter <= 0;

            o_div_clk_c <= ~o_div_clk;

        end

        else if((is_odd && (counter == ((i_div_ratio) >> 1)-1) && !odd_flag) || (is_odd && (counter == (((i_div_ratio) >> 1))) && odd_flag))

        begin

            o_div_clk_c <= ~o_div_clk;

            odd_flag <= ~odd_flag;

            counter <= 0;

        end

        else

        begin

            counter <= counter + 1;

        end

    end

    else if(i_clk_en && !i_div_ratio)

        o_div_clk_c <= 0;

end



always @ (*)

begin

    if(i_clk_en && (i_div_ratio==1))

        o_div_clk = i_ref_clk;
    else if(i_clk_en && !(i_div_ratio==1))
	o_div_clk = o_div_clk_c;
    else
        o_div_clk = 'b0;

end

//assign o_div_clk = clk_en ? o_div_clk_c : i_ref_clk ;



endmodule
