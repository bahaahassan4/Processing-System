    module FSM_RX #(parameter  prescale_width = 6,
                            edge_cnt_width = 6,
                            bit_cnt_width = 4)
    (
        //declare inputs and outputs
        input wire CLK,RST,
        input wire PAR_EN,
        input wire [bit_cnt_width-1:0] bit_cnt,
        input wire [edge_cnt_width-1:0] edge_cnt,
        input wire RX_IN,
        input wire par_err,
        input wire strt_glitch,
        input wire stp_err,
        input wire [prescale_width-1:0] prescale,
        output reg par_chk_en,
        output reg strt_chk_en,
        output reg stp_chk_en,
        output reg dat_samp_en,
        output reg deser_en,
        output reg enable,
        output reg data_valid,
        output reg Parity_Error,
        output reg Stop_Error
    );

    //state encoding
    localparam IDLE = 3'b000;
    localparam START = 3'b001;
    localparam DATA = 3'b011;
    localparam PARITY = 3'b010;
    localparam STOP = 3'b110;

    reg [2:0] current_state,next_state;

    //state transition
    always@(posedge CLK or negedge RST)
    begin
        if(!RST)
        begin
            current_state <= IDLE;
            Parity_Error <= 'b0;   //mmkn aktebha zy el outputs el tania keda keda hatb2a registered hyban f el testbench
            Stop_Error <= 'b0;
        end
        else
        begin
            current_state <= next_state;
            Parity_Error <= par_err;
            Stop_Error <= stp_err;
        end
    end


    //combintional block
    always@(*)
    begin
        par_chk_en = 'b0;
        strt_chk_en = 'b0;
        stp_chk_en = 'b0;
        dat_samp_en = 'b0;
        deser_en = 'b0;
        enable = 'b0;
        data_valid = 'b0;
        case(current_state)
        IDLE : begin
            par_chk_en = 'b0;
            strt_chk_en = 'b0;
            stp_chk_en = 'b0;
            dat_samp_en = 'b0;
            deser_en = 'b0;
            enable = 'b0;
            data_valid = 'b0;
            //next state
            if(RX_IN == 0)
                next_state = START;
            else
                next_state = IDLE;  
        end

        START : begin
            par_chk_en = 'b0;
            strt_chk_en = 'b1;
            stp_chk_en = 'b0;
            dat_samp_en = 'b1;
            deser_en = 'b0;
            enable = 'b1;
            data_valid = 'b0;
            //next state
            if(strt_glitch == 'b1 && edge_cnt == prescale)
                next_state = IDLE;
            else if(!strt_glitch && edge_cnt == prescale)
                next_state = DATA;
            else
                next_state = START;
        end

        DATA : begin
            par_chk_en = 'b0;
            strt_chk_en = 'b0;
            stp_chk_en = 'b0;
            dat_samp_en = 'b1;
            deser_en = 'b1;
            enable = 'b1;
            data_valid = 'b0;
            //next state
            if(bit_cnt == 9 && PAR_EN && edge_cnt == prescale)
                next_state = PARITY;
            else if (bit_cnt == 9 && !PAR_EN && edge_cnt == prescale)
                next_state = STOP;
            else
                next_state = DATA;
        end

        PARITY : begin
            par_chk_en = 'b1;
            strt_chk_en = 'b0;
            stp_chk_en = 'b0;
            dat_samp_en = 'b1;
            deser_en = 'b0;
            enable = 'b1;
            data_valid = 'b0;
            //next state
            if(edge_cnt == prescale)
            next_state = STOP;
	    else
            next_state = PARITY;
        end

        STOP : begin
            par_chk_en = 'b0;
            strt_chk_en = 'b0;
            stp_chk_en = 'b1;
            dat_samp_en = 'b1;
            deser_en = 'b0;
            enable = 'b1;
            if(!stp_err && !par_err && edge_cnt == prescale)
            begin
                data_valid = 'b1;
                if(RX_IN == 0)
                    next_state = START;
                else
                    next_state = IDLE;
            end
            else if((stp_err | par_err) && edge_cnt == prescale)
            begin
                data_valid = 'b0;
                if(RX_IN == 0)
                    next_state = START;
                else
                    next_state = IDLE;
            end
            else
            begin
                data_valid = 'b0;
                next_state = STOP;
            end
            //data_valid = 'b0;
            //next state
        end

        default : begin
            par_chk_en = 'b0;
            strt_chk_en = 'b0;
            stp_chk_en = 'b0;
            dat_samp_en = 'b0;
            deser_en = 'b0;
            enable = 'b0;
            data_valid = 'b0;
	        next_state = IDLE; 
        end
        endcase
    end
    endmodule
    