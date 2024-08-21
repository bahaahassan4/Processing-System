module DF_SYNC #(parameter PTR_WIDTH = 3)
(
    input wire      CLK,
    input wire      RST,
    input wire [PTR_WIDTH:0]    IN,
    output reg [PTR_WIDTH:0]    OUT
);

reg [PTR_WIDTH:0] q;

always @(posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        q <= 'b0;
        OUT <= 'b0;
    end
    else
    begin
        q <= IN;
        OUT <= q;
    end
end
endmodule 