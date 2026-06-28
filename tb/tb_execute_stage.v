`timescale 1ns / 1ps

module tb_execute_stage;

    // ---------------------------------------------------------
    // 1. Signal Declarations
    // ---------------------------------------------------------
    reg         CLK;
    reg         RESET;

    // Control Inputs from ID/EX Register
    reg         RegWriteE;
    reg  [1:0]  ResultSrcE;
    reg         MemWriteE;
    reg         BranchE;
    reg         JalE;
    reg         JalrE;
    reg         ALUSrcE;
    reg  [4:0]  ALUControlE;
    reg  [4:0]  ShamtE;

    // Data Inputs from ID/EX Register
    reg  [31:0] RD1E;
    reg  [31:0] RD2E;
    reg  [31:0] PCE;
    reg  [31:0] Imm_Ext_E;
    reg  [31:0] PCPlus4E;
    reg  [4:0]  RDE;
    reg  [4:0]  RS1E;
    reg  [4:0]  RS2E;

    // Inputs from Hazard Unit (Forwarding Selectors)
    reg  [1:0]  ForwardAE;
    reg  [1:0]  ForwardBE;

    // Forwarded Data Paths
    reg  [31:0] ALUResultM_fwd;  // From Memory Stage (EX/MA)
    reg  [31:0] ResultW_fwd;     // From Writeback Stage (MA/WB)

    // Outputs to Fetch (IF) Stage
    wire [1:0]  PCSrcE;
    wire [31:0] PCTargetE;
    wire [31:0] ResultE;

    // Outputs to EX/MA Pipeline Register
    wire [31:0] ALUResultM;
    wire [31:0] WriteDataM;
    wire        RegWriteM;
    wire        MemWriteM;
    wire [1:0]  ResultSrcM;
    wire [4:0]  RDM;
    wire [31:0] PCPlus4M;

    // ---------------------------------------------------------
    // 2. Unit Under Test (UUT) Instantiation
    // ---------------------------------------------------------
    execute_stage uut (
        .CLK(CLK),
        .RESET(RESET),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .BranchE(BranchE),
        .JalE(JalE),
        .JalrE(JalrE),
        .ALUSrcE(ALUSrcE),
        .ALUControlE(ALUControlE),
        .ShamtE(ShamtE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .Imm_Ext_E(Imm_Ext_E),
        .PCPlus4E(PCPlus4E),
        .RDE(RDE),
        .RS1E(RS1E),
        .RS2E(RS2E),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .ALUResultM_fwd(ALUResultM_fwd),
        .ResultW_fwd(ResultW_fwd),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .ResultE(ResultE),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RDM(RDM),
        .PCPlus4M(PCPlus4M)
    );

    // ---------------------------------------------------------
    // 3. Clock Generation (10ns Period -> 100MHz)
    // ---------------------------------------------------------
    always #5 CLK = ~CLK;

    // ---------------------------------------------------------
    // 4. Test Stimulus Process
    // ---------------------------------------------------------
    initial begin
        // --- Step 1: Initialize System Triggers ---
        CLK            = 0;
        RESET          = 1;
        RegWriteE      = 0;
        ResultSrcE     = 2'b00;
        MemWriteE      = 0;
        BranchE        = 0;
        JalE           = 0;
        JalrE          = 0;
        ALUSrcE        = 0;
        ALUControlE    = 5'b00000;
        ShamtE         = 5'd0;
        RD1E           = 32'd0;
        RD2E           = 32'd0;
        PCE            = 32'd0;
        Imm_Ext_E      = 32'd0;
        PCPlus4E       = 32'd0;
        RDE            = 5'd0;
        RS1E           = 5'd0;
        RS2E           = 5'd0;
        ForwardAE      = 2'b00;
        ForwardBE      = 2'b00;
        ALUResultM_fwd = 32'd0;
        ResultW_fwd    = 32'd0;

        // Apply Synchronous Reset
        #20;
        RESET = 0;
        #10;

        $display("==================================================");
        $display("   STARTING TESTBENCH: EXECUTE STAGE              ");
        $display("==================================================");

        // -------------------------------------------------------------
        // Scenario 1: Standard R-Type Operation (ADD x5 = x10 + x11)
        // No forwarding active (ForwardAE=00, ForwardBE=00)
        // -------------------------------------------------------------
        $display("\n[Scenario 1] Standard R-Type ADD (No Forwarding)");
        RegWriteE   = 1'b1;
        ResultSrcE  = 2'b00;
        ALUSrcE     = 1'b0;       // Choose register data (SrcB_reg_fwd)
        ALUControlE = 5'b00110;   // ADD code
        RD1E        = 32'd15;     // rs1 value
        RD2E        = 32'd25;     // rs2 value
        RDE         = 5'd5;       // rd identifier
        PCPlus4E    = 32'h1004;
        ForwardAE   = 2'b00;
        ForwardBE   = 2'b00;
        #10; // Trigger pipeline clock transition to register outputs

        if (ALUResultM === 32'd40 && WriteDataM === 32'd25 && RegWriteM === 1'b1)
            $display(" -> SUCCESS: ADD evaluated to 40 and correctly passed to EX/MA register.");
        else
            $display(" -> FAILURE: R-Type execution error! ALUResultM=%d", ALUResultM);


        // -------------------------------------------------------------
        // Scenario 2: Operand Forwarding from Memory Stage (ForwardAE = 2'b10)
        // Operand A should instantly intercept data from ALUResultM_fwd
        // -------------------------------------------------------------
        $display("\n[Scenario 2] Forwarding from Memory Stage to SrcA");
        ALUResultM_fwd = 32'd100; // Expected forwarded value
        ForwardAE      = 2'b10;   // Select ALUResultM_fwd
        ForwardBE      = 2'b00;   // Keep raw register value for SrcB (25)
        #10;

        if (ALUResultM === 32'd125) // 100 + 25 = 125
            $display(" -> SUCCESS: Memory stage forwarding bypass applied perfectly to SrcA.");
        else
            $display(" -> FAILURE: Forwarding A failed! ALUResultM=%d (Expected: 125)", ALUResultM);


        // -------------------------------------------------------------
        // Scenario 3: Operand Forwarding from Writeback Stage (ForwardBE = 2'b01)
        // Operand B should intercept data from ResultW_fwd
        // -------------------------------------------------------------
        $display("\n[Scenario 3] Forwarding from Writeback Stage to SrcB");
        ForwardAE   = 2'b00;   // Reset A back to raw register (15)
        ResultW_fwd = 32'd200; // Expected forwarded value
        ForwardBE   = 2'b01;   // Select ResultW_fwd
        #10;

        if (ALUResultM === 32'd215) // 15 + 200 = 215
            $display(" -> SUCCESS: Writeback stage forwarding bypass applied perfectly to SrcB.");
        else
            $display(" -> FAILURE: Forwarding B failed! ALUResultM=%d (Expected: 215)", ALUResultM);


        // -------------------------------------------------------------
        // Scenario 4: I-Type Processing with Immediate Offset (ALUSrcE = 1)
        // SrcB must switch over to Imm_Ext_E instead of register variants
        // -------------------------------------------------------------
        $display("\n[Scenario 4] Immediate Extension Evaluation (ALUSrcE = 1)");
        ALUSrcE   = 1'b1;         // Route Immediate 
        Imm_Ext_E = 32'd50;       // Offset value
        ForwardBE = 2'b00;       // Turn off forwarding selectors
        #10;

        if (ALUResultM === 32'd65) // 15 (RD1E) + 50 (Imm) = 65
            $display(" -> SUCCESS: Immediate routed successfully into ALU computation stream.");
        else
            $display(" -> FAILURE: Immediate mux selection failed! ALUResultM=%d", ALUResultM);


        // -------------------------------------------------------------
        // Scenario 5: Conditional Branch Evaluated True (BEQ Taken)
        // Setup Equal operands -> Zero=1 -> Branch Taken -> PCSrcE = 2'b01
        // -------------------------------------------------------------
        $display("\n[Scenario 5] Branch Condition Processing (BEQ Taken)");
        ALUSrcE     = 1'b0;
        ALUControlE = 5'b00001;   // BEQ substraction code
        RD1E        = 32'd77;
        RD2E        = 32'd77;     // Force matching records for equality
        BranchE     = 1'b1;
        PCE         = 32'h2000;
        Imm_Ext_E   = 32'h0010;   // Branch Offset (+16 bytes)
        #10;

        if (PCSrcE === 2'b01 && PCTargetE === 32'h2010)
            $display(" -> SUCCESS: BEQ evaluated taken. Control flagged PC jump target to 0x2010.");
        else
            $display(" -> FAILURE: Branch miscalculation! PCSrcE=%b, PCTargetE=%h", PCSrcE, PCTargetE);

        BranchE = 1'b0; // Clear flag


        // -------------------------------------------------------------
        // Scenario 6: Unconditional Jump Register Execution (JALR)
        // JALR instantly forces PCSrcE = 2'b10 and passes target via ResultE
        // -------------------------------------------------------------
        $display("\n[Scenario 6] JALR Unconditional Jump Evaluation");
        JalrE       = 1'b1;
        ALUControlE = 5'b00010;   // JALR address generation code (Base + Offset)
        RD1E        = 32'h3000;   // Base Address
        Imm_Ext_E   = 32'h0008;   // Immediate Offset
        #10;

        if (PCSrcE === 2'b10 && ResultE === 32'h3008)
            $display(" -> SUCCESS: JALR forced direct hardware PC redirect vector to 0x3008.");
        else
            $display(" -> FAILURE: JALR verification failed! PCSrcE=%b, ResultE=%h", PCSrcE, ResultE);


        // --- End Simulation ---
        $display("\n==================================================");
        $display("   TESTBENCH COMPLETED: EXECUTE STAGE             ");
        $display("==================================================");
        $finish;
    end

    // ---------------------------------------------------------
    // 6. GTKWave Structural Trace Setup
    // ---------------------------------------------------------
    initial begin
        $dumpfile("execute_stage_tb.vcd");
        // Dump all signals including inner ALU multiplexer nodes
        $dumpvars(0, tb_execute_stage);
    end

endmodule