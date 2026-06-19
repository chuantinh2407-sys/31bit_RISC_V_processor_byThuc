// FETCH STAGE - IF
module fetch_stage (
    input  wire        CLK,
    input  wire        RESET,

    // From EX stage
    input  wire [1:0]  PCSrcE,
    input  wire [31:0] PCTargetE,   // PC + imm (branch/JAL)
    input  wire [31:0] ResultE,     // ALU result (JALR)

    // Hazard signals
    input  wire        enableF,     // 0=stall
    input  wire        enableD,     // 0=stall
    input  wire        clearD,      // 1=flush IF/ID register
    // Outputs to ID stage 
    output reg  [31:0] InStrD,
    output reg  [31:0] PCD,
    output reg  [31:0] PCPlus4D
);

    // PC register
    reg  [31:0] PC_reg;
    wire [31:0] PC_next;
    wire [31:0] PC_current;
    wire [31:0] PCPlus4F;
    wire [31:0] InStrF;

    assign PC_current = PC_reg;
    assign PCPlus4F   = PC_current + 32'd4;

    // 3-to-1 MUX 
    assign PC_next = (PCSrcE == 2'b10) ? ResultE   :
                     (PCSrcE == 2'b01) ? PCTargetE :
                                         PCPlus4F;

    // PC register update
    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            PC_reg <= 32'h0000_0000;
        else if (enableF)
            PC_reg <= PC_next;
    end

    // Instruction Memory (ROM)

    reg [31:0] imem [0:255];

   initial begin
        $readmemh("imem32.mem", imem, 8'd0, 8'd31);
    end 

    assign InStrF = imem[PC_current[9:2]]; // word-addressed

    //   IF/ID Pipeline Register 
    always @(posedge CLK or posedge RESET) begin
        if (RESET || clearD) begin
            InStrD   <= 32'h0000_0013; // NOP 
            PCD      <= 32'd0;
            PCPlus4D <= 32'd0;
        end else if (enableD) begin
            InStrD   <= InStrF;
            PCD      <= PC_current;
            PCPlus4D <= PCPlus4F;
        end
    end

endmodule
