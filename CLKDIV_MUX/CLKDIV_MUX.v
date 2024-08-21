
module CLKDIV_MUX #(parameter WIDTH = 8)  (
input    wire     [5:0]              IN,
output   reg      [WIDTH-1:0]        OUT
);


always @(*)
  begin
	case(IN) 
	6'b100000 : begin
				OUT = 'b1 ;
				end
	6'b010000 : begin
				OUT = 'b10 ;
				end	
	6'b001000 : begin
				OUT = 'b100 ;
				end	
	6'b000100 : begin
				OUT = 'b1000 ;
				end
	default   : begin
				OUT = 'b1 ;
				end					
	endcase
  end	
  
  
  
  
endmodule