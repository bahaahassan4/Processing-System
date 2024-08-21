module SYS_CTRL #(parameter OP_WIDTH = 8,ALU_OUT_WIDTH = 2*OP_WIDTH,ADDR = 4)
(
    input wire  [ALU_OUT_WIDTH-1:0]     ALU_OUT,
    input wire                          ALU_OUT_Valid,
    input wire  [OP_WIDTH-1:0]          UART_RX_P_Data,
    input wire                          UART_RX_D_VLD,
    input wire  [OP_WIDTH-1:0]          RF_RdData,
    input wire                          RF_RdData_Valid,
    input wire                          CLK,RST,
    input wire                          FIFO_FULL,
    output reg                          ALU_EN,
    output reg  [3:0]                   ALU_FUN,
    output reg                          CLKG_EN,
    output reg  [ADDR-1:0]              RF_Address,
    output reg                          RF_WrEn,
    output reg                          RF_RdEn,
    output reg  [OP_WIDTH-1:0]          RF_WrData,
    output reg  [OP_WIDTH-1:0]          UART_TX_P_Data,
    output reg                          UART_TX_D_VLD,
    output reg                          clk_div_en 
);

//state encoding
localparam IDLE = 3'b000;
localparam RF_Wr_Addr = 3'b001;
localparam RF_Wr_Data = 3'b010;
localparam RF_Rd_Addr = 3'b011;
localparam OperandA = 3'b100;
localparam OperandB = 3'b101;
localparam FUNC = 3'b110;

reg [2:0] current_state,next_state;

//internal signals
reg [ADDR-1:0] RF_Address_c;
reg RF_Address_flag;
wire [OP_WIDTH-1:0] ALU_CONT;
reg ALU_OUT_FLAG;
reg ALU_OUT_FLAG_C;

//state transition
always @ (posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        current_state <= IDLE;
    end
    else
    begin
        current_state <= next_state;
    end
end

//combintional block
always @ (*)
begin
    ALU_EN = 'b0;
    ALU_FUN = 'b0;
    CLKG_EN = 'b0;
    RF_Address = 'b0;
    RF_WrEn = 'b0;
    RF_RdEn = 'b0;
    RF_WrData = 'b0;
    UART_TX_P_Data = 'b0;
    UART_TX_D_VLD = 'b0;
    clk_div_en = 'b1;
    RF_Address_flag = 'b0;
    ALU_OUT_FLAG_C = 'b0;
    case (current_state)
    IDLE : begin
        ALU_EN = 'b0;
        ALU_FUN = 'b0;
        RF_Address = 'b0;
        RF_WrEn = 'b0;
        RF_RdEn = 'b0;
        RF_WrData = 'b0;
        UART_TX_P_Data = 'b0;
        UART_TX_D_VLD = 'b0;
        clk_div_en = 'b1;
        RF_Address_flag = 'b0;
        if(UART_RX_D_VLD)
        begin
            case(UART_RX_P_Data)
            8'hAA : begin
                next_state = RF_Wr_Addr;
            end
            8'hBB : begin
                next_state = RF_Rd_Addr;
            end
            8'hCC : begin
                next_state = OperandA;
            end
            8'hDD : begin
                next_state = FUNC;
                CLKG_EN = 'b1;
            end
            default : begin
                next_state = IDLE;
            end
            endcase
        end
        else
        begin
            next_state = IDLE;
        end
    end

    RF_Wr_Addr : begin
        if(UART_RX_D_VLD)
        begin
            RF_Address_flag = 'b1;
            next_state = RF_Wr_Data;
        end
        else
        begin
            next_state = RF_Wr_Addr;
        end
    end

    RF_Wr_Data : begin
        if(UART_RX_D_VLD)
        begin
            RF_WrEn = 'b1;
            RF_WrData = UART_RX_P_Data;
            RF_Address = RF_Address_c[3:0];
            next_state = IDLE;
        end
        else
        begin
            next_state = RF_Wr_Data;
        end
    end

    RF_Rd_Addr : begin
        if(UART_RX_D_VLD)
        begin
            RF_RdEn = 'b1;
            RF_Address = UART_RX_P_Data[3:0];
            UART_TX_D_VLD = 'b0;
            next_state = RF_Rd_Addr;
        end
        else if(RF_RdData_Valid && !FIFO_FULL)
        begin
            UART_TX_P_Data = RF_RdData;
            UART_TX_D_VLD  = 'b1;
            next_state = IDLE;
        end
        else
        begin
            next_state = RF_Rd_Addr;
            UART_TX_D_VLD = 'b0;
        end
    end

    OperandA : begin
        if (UART_RX_D_VLD)
        begin
            RF_WrEn = 'b1;
            RF_Address = 'b0;
            RF_WrData = UART_RX_P_Data;
            next_state = OperandB;
        end
        else
        begin
            next_state = OperandA;
        end
    end

    OperandB : begin
        if (UART_RX_D_VLD)
        begin
            RF_WrEn = 'b1;
            RF_Address = 'b1;
            RF_WrData = UART_RX_P_Data;
            CLKG_EN = 'b1;
            next_state = FUNC;
        end
        else
        begin
            next_state = OperandB;
        end
    end

    FUNC : begin
        CLKG_EN = 'b1;
        if (UART_RX_D_VLD)
        begin
            ALU_FUN = UART_RX_P_Data [3:0];
            ALU_EN = 'b1;
            next_state = FUNC;
            ALU_OUT_FLAG_C = 'b0;
            UART_TX_D_VLD = 'b0;
        end
        else if (ALU_OUT_Valid && !ALU_OUT_FLAG && !FIFO_FULL)
        begin
            ALU_OUT_FLAG_C = 'b1;
            UART_TX_P_Data = ALU_OUT[7:0];
            UART_TX_D_VLD = 'b1;
            next_state = FUNC;
        end
        else if (ALU_OUT_FLAG && !FIFO_FULL)
        begin
            ALU_OUT_FLAG_C = 'b0;
            UART_TX_P_Data = ALU_CONT;
            UART_TX_D_VLD = 'b1;
            next_state = IDLE;
        end
        else
        begin
            next_state = FUNC;
	    ALU_OUT_FLAG_C = 'b0;
        end
    end

    default : begin
        ALU_EN = 'b0;
        ALU_FUN = 'b0;
        CLKG_EN = 'b0;
        RF_Address = 'b0;
        RF_WrEn = 'b0;
        RF_RdEn = 'b0;
        RF_WrData = 'b0;
        UART_TX_P_Data = 'b0;
        UART_TX_D_VLD = 'b0;
        clk_div_en = 'b1;
        RF_Address_flag = 'b0;
        next_state = IDLE;
    end
    endcase
end

always @ (posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        RF_Address_c <= 'b0;
    end
    else
    begin
        if(RF_Address_flag)
        begin
            RF_Address_c <= UART_RX_P_Data;
        end
    end
end

always @ (posedge CLK or negedge RST)
begin
    if(!RST)
    begin
        ALU_OUT_FLAG <= 'b0;
    end
    else
    begin
        ALU_OUT_FLAG <= ALU_OUT_FLAG_C;
    end    
end

assign ALU_CONT = ALU_OUT[15:8];

endmodule
