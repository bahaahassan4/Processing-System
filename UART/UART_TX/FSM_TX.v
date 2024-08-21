module FSM_TX (
    //declare inputs and outputs
    input   wire        CLK,RST,
    input   wire        Data_Valid,
    input   wire        PAR_EN,
    input   wire        ser_done,
    output  reg         ser_en,
	output  reg         parity_flag,
    output  reg         busy,
    output  reg [2:0]   mux_sel
);

//state Encoding
localparam  IDLE = 3'b000,
            START = 3'b001,
            DATA = 3'b011,
            PARITY = 3'b010,
            STOP = 3'b110;

reg     [2:0]   current_state , next_state;
//reg             busy_comb;
//reg     [2:0]   mux_sel_comb;
//reg             ser_en_comb;

//state transition
always @(posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        current_state <= IDLE;
        //busy <= busy_comb;
        //mux_sel <= mux_sel_comb;
        //ser_en <= ser_en_comb;
    end
    else
    begin
        current_state <= next_state;
        //busy <= busy_comb;
        //mux_sel <= mux_sel_comb;
        //ser_en <= ser_en_comb;
    end
end

//combintional block
always @(*)
begin
    mux_sel = 'b000;
    busy = 'b0;
    ser_en = 'b0;
	parity_flag = 'b0;
    case(current_state)
    IDLE : begin
        busy = 'b0;
        mux_sel = 'b000; //output is 1
        ser_en = 'b0;
        //next state logic
        if(Data_Valid)
        begin
            next_state = START;
        end
        else
        begin
            next_state = IDLE;
        end
    end

    START : begin
        ser_en = 'b0;
        busy = 'b1;
        mux_sel = 'b001;  //start bit is 0
		parity_flag = 'b1;
        //next state logic
        next_state = DATA;
    end

    DATA : begin
        ser_en = 'b1;
        busy = 'b1;
        mux_sel = 'b010;  //serial data
        //next state logic
        if(ser_done && PAR_EN)
        begin
            next_state = PARITY;
        end
        else if(ser_done && !PAR_EN)
        begin
            next_state = STOP;
        end
        else
        begin
            next_state = DATA;
        end
    end

    PARITY : begin
        ser_en = 'b0;
        busy = 'b1;
        mux_sel = 'b011;   //parity bit
        //next state logic
        next_state = STOP;
    end

    STOP : begin
        ser_en = 'b0;
        busy = 'b1;
        mux_sel = 'b100;  //stop bit is 0
        //next state logic
        next_state = IDLE;
    end

    default : begin
        ser_en = 'b0;
        busy = 'b0;
        mux_sel = 'b000;
        next_state = IDLE;
		parity_flag = 'b0;
    end
    endcase
end
endmodule
