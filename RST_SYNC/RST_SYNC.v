module RST_SYNC #(parameter NUM_STAGES = 2)
(
    input wire RST,
    input wire CLK,
    output wire SYNC_RST
);

//declare signals
integer i;
reg [NUM_STAGES-1:0] OUT;

//sequential block
always @ (posedge CLK or negedge RST)
begin
if(!RST)
begin
    OUT <= 'b0;
end
else
begin
    OUT[0] <= 'b1;
    for(i = 0; i< (NUM_STAGES-1); i = i+1)
    begin
        OUT[i+1] <= OUT[i];
    end
end
end

//assigning the output
assign SYNC_RST = OUT[NUM_STAGES-1];

endmodule
