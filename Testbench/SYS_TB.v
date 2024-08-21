`timescale 1ns/1ps
module SYS_TB();

//**********Parameters**********
parameter UART_Clock_Period = 271.26736;
parameter TX_Clock_Period = UART_Clock_Period * 32;
parameter REF_Clock_Period = 20;
parameter DATA_WIDTH = 8;

//**********Signals*************
reg RST_N_TB;
reg UART_CLK_TB;
reg REF_CLK_TB;
reg UART_RX_IN_TB;
wire UART_TX_OUT_TB;
wire Parity_Error_TB;
wire Framing_Error_TB;

integer i;
reg [DATA_WIDTH-1:0] test_in;

//************Clock Generation***********
initial begin
    UART_CLK_TB = 0;
    forever #(UART_Clock_Period/2) UART_CLK_TB = ~UART_CLK_TB;
end

initial begin
    REF_CLK_TB = 0;
    forever #(REF_Clock_Period/2) REF_CLK_TB = ~REF_CLK_TB;
end

//************DUT instantiation************
SYS_TOP DUT (
    .RST_N (RST_N_TB),
    .UART_CLK (UART_CLK_TB),
    .REF_CLK (REF_CLK_TB),
    .UART_RX_IN (UART_RX_IN_TB),
    .UART_TX_OUT (UART_TX_OUT_TB),
    .Parity_Error (Parity_Error_TB),
    .Framing_Error (Framing_Error_TB)
);

//*************Initial Block*************
initial begin
    $dumpfile("SYS_TOP.vcd");
    $dumpvars;
//initialize
    RST_N_TB = 'b1;
    UART_RX_IN_TB = 'b1;

//reset
    reset();
    //*******************First Operation******************

    /*Pass_Data('hAA);

    #(2*TX_Clock_Period)

    Pass_Data('h05);

    #(2*TX_Clock_Period)

    Pass_Data('h0A);

    #(2*TX_Clock_Period)*/

    SEND_WR_CMD('h05,'h0A);

    CHECK_WR('h05,'h0A);

    //*****************Second Operation*******************

    /*Pass_Data('hBB);

    #(2*TX_Clock_Period)

    Pass_Data('h05);*/

    SEND_RD_CMD('h05);

    CHECK_RD('h05);

    #(20*TX_Clock_Period)

    //******************Third Operation*********************

    /*Pass_Data('hCC);

    #(2*TX_Clock_Period)

    Pass_Data('h01);

    #(2*TX_Clock_Period)

    Pass_Data('h02);

    #(2*TX_Clock_Period)

    Pass_Data('h00);*/

    SEND_ALU_W_OP_CMD('h01,'h02,'h00);
    
    CHECK_ALU('h00,'h03);
    #(30*TX_Clock_Period)

    //********************Fourth Operation**********************

    /*Pass_Data('hDD);

    #(2*TX_Clock_Period)

    Pass_Data('h02);*/

    SEND_ALU_W_NOP_CMD('h02);

    CHECK_ALU('h02,'h02);

    #(30*TX_Clock_Period)
    $finish;
end

//Tasks
task Pass_Data;
    input reg [DATA_WIDTH-1:0] Data_Vector;
    integer i;
    begin
        UART_RX_IN_TB = 'b0;
        for (i = 0; i < 8 ; i = i + 1)
        begin
            #(TX_Clock_Period)
            UART_RX_IN_TB = Data_Vector[i];
        end
        if(DUT.U0_RegFile.REG2[0])
        begin
            #(TX_Clock_Period)
            case(DUT.U0_RegFile.REG2[1])
                1'b0 : UART_RX_IN_TB <= ^Data_Vector  ;     // Even Parity
                1'b1 : UART_RX_IN_TB <= ~^Data_Vector ;     // Odd Parity
            endcase
        end
        #(TX_Clock_Period)
        UART_RX_IN_TB = 1;
    end
endtask

task reset;
begin
    //reset
    #(REF_Clock_Period)
    RST_N_TB = 0;
    #(REF_Clock_Period)
    RST_N_TB = 1;
    #(3*REF_Clock_Period) ;
end
endtask

//Write command
task SEND_WR_CMD ;
 input  [DATA_WIDTH-1:0]  ADDR ;
 input  [DATA_WIDTH-1:0]  DATA ;
 
 begin
	Pass_Data('hAA) ;   // Load Write Command
    #(2*TX_Clock_Period)
	Pass_Data(ADDR)   ;   // Load Write Address
    #(2*TX_Clock_Period)
	Pass_Data(DATA)	 ;   // Load Write Data
 end
endtask

//check write command
task CHECK_WR ;
 input  [DATA_WIDTH-1:0]  ADDR ;
 input  [DATA_WIDTH-1:0]  DATA ;
 
 begin
	wait(DUT.U0_RegFile.WrEn)
	repeat(2) @(posedge REF_CLK_TB); 
	if(DUT.U0_RegFile.mem[ADDR[3:0]] == DATA)
		begin
			$display("Write Operation is succeeded with configurations PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d  :)",DUT.U0_RegFile.REG2[0],DUT.U0_RegFile.REG2[1],DUT.U0_RegFile.REG2[7:2]);
		end
	else
		begin
			$display("Write Operation is failed with configurations PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d  :(",DUT.U0_RegFile.REG2[0],DUT.U0_RegFile.REG2[1],DUT.U0_RegFile.REG2[7:2]);
		end	
 end
endtask

//send read command
task SEND_RD_CMD ;
 input  [DATA_WIDTH-1:0]  ADDR ;
 
 begin
	Pass_Data('hBB) ;   // Load Write Command
    #(2*TX_Clock_Period)
	Pass_Data(ADDR)   ;   // Load Write Address
 end
endtask

//check read command
task CHECK_RD ;
 input [DATA_WIDTH-1:0] ADDR;

 reg [10:0] gener_out ,expec_out; //for parity enable = 1
 reg parity_bit;

 integer i;

 begin
    @(posedge DUT.U0_UART.TX_OUT_V)
    for(i = 0; i < 11; i = i + 1)
    begin
        @(negedge DUT.U0_UART.TX_CLK) gener_out[i] = UART_TX_OUT_TB;
    end

    if(DUT.U0_RegFile.REG2[1])
		parity_bit = ~^DUT.U0_RegFile.mem[ADDR[3:0]] ;
	else
		parity_bit = ^DUT.U0_RegFile.mem[ADDR[3:0]] ;

    expec_out = {1'b1,parity_bit,DUT.U0_RegFile.mem[ADDR[3:0]],1'b0} ;

    if(gener_out == expec_out) 
		begin
			$display("Read Operation is succeeded with configurations PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d  :)",DUT.U0_RegFile.REG2[0],DUT.U0_RegFile.REG2[1],DUT.U0_RegFile.REG2[7:2]);
		end
	else
		begin
			$display("Read Operation is failed with configurations PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d  :(",DUT.U0_RegFile.REG2[0],DUT.U0_RegFile.REG2[1],DUT.U0_RegFile.REG2[7:2]);
		end
        
 end
endtask

//Send ALU with OP command
task SEND_ALU_W_OP_CMD ;
 input  [DATA_WIDTH-1:0]  OPA ;
 input  [DATA_WIDTH-1:0]  OPB ;
 input  [DATA_WIDTH-1:0]  FUN ;
 
 begin
	Pass_Data('hCC) ;   // Load Write Command
    #(2*TX_Clock_Period)
	Pass_Data(OPA)   ;   // Load Write OPA
    #(2*TX_Clock_Period)
	Pass_Data(OPB)   ;   // Load Write OPB
    #(2*TX_Clock_Period)
	Pass_Data(FUN)   ;   // Load Write Function
 end
endtask

//Check ALU with OP command
task CHECK_ALU ;
 input [DATA_WIDTH-1:0] FUN;
 input [DATA_WIDTH-1:0] expec_out;

 reg [10:0] gener_out,expec_gener_out ; //for parity enable = 1
 reg parity_bit;

 integer i;

 begin
    @(posedge DUT.U0_UART.TX_OUT_V)
    for(i = 0; i < 11; i = i + 1)
    begin
        @(negedge DUT.U0_UART.TX_CLK) gener_out[i] = UART_TX_OUT_TB;
    end

    if(DUT.U0_RegFile.REG2[1])
		parity_bit = ~^expec_out ;
	else
		parity_bit = ^expec_out ;

    expec_gener_out = {1'b1,parity_bit,expec_out,1'b0} ;

    if(gener_out == expec_gener_out) 
		begin
			$display("ALU Operation is succeeded with OUT=%d and configurations PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d  :)",expec_out,DUT.U0_RegFile.REG2[0],DUT.U0_RegFile.REG2[1],DUT.U0_RegFile.REG2[7:2]);
		end
	else
		begin
			$display("ALU Operation is failed with OUT=%b configurations PARITY_ENABLE=%d PARITY_TYPE=%d  PRESCALE=%d  :(",expec_gener_out,DUT.U0_RegFile.REG2[0],DUT.U0_RegFile.REG2[1],DUT.U0_RegFile.REG2[7:2]);
		end
        
 end
endtask

task SEND_ALU_W_NOP_CMD ;
 input  [DATA_WIDTH-1:0]  FUN ;
 
 begin
	Pass_Data('hDD) ;   // Load Write Command
    #(2*TX_Clock_Period)
	Pass_Data(FUN)   ;   // Load Write Function
 end
endtask


endmodule
