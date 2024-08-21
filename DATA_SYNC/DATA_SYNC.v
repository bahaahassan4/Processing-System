module DATA_SYNC #(parameter    NUM_STAGES = 2,
                                BUS_WIDTH = 8)
(
    input wire [BUS_WIDTH-1:0] unsync_bus,
    input wire bus_enable,
    input wire CLK,RST,
    output reg [BUS_WIDTH-1:0] sync_bus,
    output reg enable_pulse
);

//declare signals
wire enable_pulse_comb;
wire [BUS_WIDTH-1:0] sync_bus_comb;
reg enable_flop;
reg [NUM_STAGES-1:0] OUT;
integer i;

//sequential block for multi flipflop
always @ (posedge CLK or negedge RST)
begin
    if(!RST)
        OUT <= 'b0;
    else
    begin
        OUT[0] <= bus_enable;
        for(i = 0; i< (NUM_STAGES-1); i = i+1)
        begin
            OUT[i+1] <= OUT[i];
        end
    end
end

//sequential block for pulse generator
always @ (posedge CLK or negedge RST)
begin
    if(!RST)
        enable_flop <= 'b0;
    else
        enable_flop <= OUT[NUM_STAGES-1];
end

assign enable_pulse_comb = OUT[NUM_STAGES-1] && !enable_flop;

//enable pulse registeration
always @ (posedge CLK or negedge RST)
begin
    if(!RST)
        enable_pulse <= 'b0;
    else
        enable_pulse <= enable_pulse_comb;
end

//MUX
assign sync_bus_comb = enable_pulse_comb ? unsync_bus : sync_bus;

//sync bus regestiration
always @ (posedge CLK or negedge RST)
begin
    if(!RST)
        sync_bus <= 'b0;
    else
        sync_bus <= sync_bus_comb;
end
endmodule
