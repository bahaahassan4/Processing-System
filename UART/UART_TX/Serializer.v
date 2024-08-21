module Serializer #(parameter OP_WIDTH = 8) //width is parameterized
(
    input  wire  [OP_WIDTH-1:0] P_DATA,
    input  wire                 ser_en,
    input  wire                 CLK,RST,
	input  wire 				Data_Valid,
	input  wire                 busy,
    output wire                 ser_done,
    output wire                 ser_data
);
//declare signals
reg [3:0]           counter;
reg [OP_WIDTH-1:0]  P_DATA_shifted;
//sequential block
always @ (posedge CLK or negedge RST)
begin
	if(!RST)
	begin
		P_DATA_shifted <= 'b0;
		counter <= 'b0;
	end
	else if(Data_Valid && !busy)
	begin
		P_DATA_shifted <= P_DATA;
		counter <= 'b0;
	end
	else if(ser_en)
	begin
		P_DATA_shifted <= P_DATA_shifted >> 1;
		counter <= counter + 'b1;
	end
end
/*always @ (posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        ser_data <= 'b0;
        P_DATA_shifted <= P_DATA;
        counter <= 0;
    end
    else if(ser_en && !Count_max)
    begin
        ser_data <= P_DATA_shifted[0];
        counter <= counter + 1;
        for(i=0;i<OP_WIDTH-1;i=i+1)
        begin
            P_DATA_shifted[i] <= P_DATA_shifted[i+1];
        end
        P_DATA_shifted[7] <= 'b0;
    end
    else if(ser_en && Count_max)
    begin
        //ser_done <= 'b1;
        counter <= 0;
        ser_data <= 0;
    end
    else
    begin
        ser_data <= 'b0;
        //ser_done <= 'b0;
        counter <= 0;
    end
end*/

assign ser_data = P_DATA_shifted[0];
assign ser_done = (counter == 'b111);

endmodule
