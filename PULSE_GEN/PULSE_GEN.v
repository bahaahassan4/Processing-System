module PULSE_GEN 
(
input    wire                      clk,
input    wire                      rst,
input    wire                      lvl_sig,
output   wire                      pulse_sig
);


reg              flop0  , 
                 flop1  ;
					 
					 
always @(posedge clk or negedge rst)
 begin
  if(!rst)      // active low
   begin
    flop0 <= 1'b0 ;
    flop1 <= 1'b0 ;	
   end
  else
   begin
    flop0 <= lvl_sig;   
    flop1 <= flop0;
   end  
 end
 
//----------------- pulse generator --------------------

assign pulse_sig = flop0 && !flop1 ;


endmodule
