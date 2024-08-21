module RegFile #(parameter OP_WIDTH = 8, DEPTH = 16, ADDR = 4)
(
  input wire WrEn,RdEn,
  input wire CLK,RST,
  input wire [OP_WIDTH-1:0] WrData,
  input wire [ADDR-1:0] Address,
  output reg [OP_WIDTH-1:0] RdData,
  output reg RdData_VLD,
  output wire [OP_WIDTH-1:0] REG0,
  output wire [OP_WIDTH-1:0] REG1,
  output wire [OP_WIDTH-1:0] REG2,
  output wire [OP_WIDTH-1:0] REG3
  );

//variable decleration
reg [OP_WIDTH-1:0] mem [DEPTH-1:0];
integer i;

always @(posedge CLK or negedge RST)
begin
  if(!RST)
  begin
    RdData_VLD <= 0;
    RdData <= 'b0;
    for (i = 0 ; i<DEPTH ; i = i + 1)
    begin
      if(i == 2)
      mem[i] <= 'b10000001;
      else if(i == 3)
      mem[i] <= 'b00100000;
      else
      mem[i] <= 'b0;
    end
  end
  else if(WrEn && !RdEn)
  begin
    mem[Address] <= WrData;
  end
  else if (RdEn && !WrEn)
  begin
    RdData <= mem[Address];
    RdData_VLD <= 'b1;
  end
  else
  begin
    RdData_VLD <= 'b0;
  end 
end

assign REG0 = mem[0];
assign REG1 = mem[1];
assign REG2 = mem[2];
assign REG3 = mem[3];

endmodule