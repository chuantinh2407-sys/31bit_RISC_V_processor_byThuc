`timescale 1ns / 1ps

module tb_decode_stage;

    // ---------------------------------------------------------
    // 1. Signal Declarations
    // ---------------------------------------------------------
    reg         CLK;
    reg         RESET;

    // Inputs from IF/ID stage
    reg  [31:0] InstrD;
    reg  [31:0] PCD;
    reg  [31:0] PCPlus4D;

    // Feedback inputs from WB (Writeback) stage
    reg         RegWriteW;
    reg  [4:0]  RDW;
    reg  [31:0] ResultW;
    
    // Pipeline flush signal
    reg         ClearE;

    // Outputs forwarded to EX (Execute) stage
    wire        RegWriteE;
    wire [1:0]  ResultSrcE;
    wire        MemWriteE;
    wire        MemtoRegE;
    wire        BranchE;
    wire        JalE;
    wire        JalrE;
    wire        ALUSrcE;
    wire [4:0]  ALUControlE;
    wire [4:0]  ShamtE;
    wire [31:0] RD1E;
    wire [31:0] RD2E;
    wire [31:0] PCE;
    wire [31:0] Imm_Ext_E;
    wire [31:0] PCPlus4E;
    wire [4:0]  RS1E;
    wire [4:0]  RS2E;
    wire [4:0]  RDE;

    // Outputs to Hazard Unit
    wire [4:0]  RS1D;
    wire [4:0]  RS2D;

    // ---------------------------------------------------------
    // 2. Unit Under Test (UUT) Instantiation
    // ---------------------------------------------------------
    decode_stage uut (
        .CLK(CLK),
        .RESET(RESET),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteW),
        .RDW(RDW),
        .ResultW(ResultW),
        .ClearE(ClearE),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .MemtoRegE(MemtoRegE),
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
        .RS1E(RS1E),
        .RS2E(RS2E),
        .RDE(RDE),
        .RS1D(RS1D),
        .RS2D(RS2D)
    );

    // ---------------------------------------------------------
    // 3. Clock Generation (10ns Period -> 100MHz)
    // ---------------------------------------------------------
    always #5 CLK = ~CLK;

    // ---------------------------------------------------------
    // 4. Test Stimulus Process
    // ---------------------------------------------------------
    initial begin
        // --- Step 1: System Initialization ---
        CLK = 0;
        RESET = 1;
        InstrD = 32'd0;
        PCD = 32'd0;
        PCPlus4D = 32'd0;
        RegWriteW = 0;
        RDW = 5'd0;
        ResultW = 32'd0;
        ClearE = 0;

        // Hold reset for 2 clock cycles for system stability
        #20;
        RESET = 0;
        #10;

        $display("==================================================");
        $display("   STARTING TESTBENCH: DECODE STAGE               ");
        $display("==================================================");

        // -------------------------------------------------------------
        // Scenario 1: Test R-type instruction (ADD x3, x1, x2)
        // Background: Your regfile initializes regs[1]=1, regs[2]=2.
        // Expected RISC-V machine code: 32'h002081B3
        // -------------------------------------------------------------
        $display("\n[Scenario 1] Testing R-type decoding: ADD x3, x1, x2");
        PCD      = 32'h00001000;
        PCPlus4D = 32'h00001004;
        InstrD   = 32'h002081B3; 
        #10; // Wait for the next rising edge of CLK to push data into ID/EX Reg
        
        if (RegWriteE === 1'b1 && ALUControlE === 5'b00110 && RD1E === 32'd1 && RD2E === 32'd2)
            $display(" -> SUCCESS: R-type instruction decoded correctly with accurate control signals.");
        else
            $display(" -> FAILURE: R-type error! RD1E=%d, RD2E=%d, ALUControlE=%b", RD1E, RD2E, ALUControlE);


        // -------------------------------------------------------------
        // Scenario 2: Test I-type immediate instruction (ADDI x4, x1, 10)
        // Expected machine code: 32'h00A08213 (Immediate = 10)
        // -------------------------------------------------------------
        $display("\n[Scenario 2] Testing I-type decoding: ADDI x4, x1, 10");
        InstrD   = 32'h00A08213;
        #10;
        
        if (ALUSrcE === 1'b1 && Imm_Ext_E === 32'd10 && RDE === 5'd4)
            $display(" -> SUCCESS: I-type instruction generated correct sign-extended immediate.");
        else
            $display(" -> FAILURE: I-type error! ALUSrcE=%b, Imm_Ext_E=%d", ALUSrcE, Imm_Ext_E);


        // -------------------------------------------------------------
        // Scenario 3: Test Internal Forwarding in RegFile (Simultaneous Read/Write)
        // Context: WB stage writes a new value (0xABCDEFFF) to x1.
        // Simultaneously, Decode stage attempts to read x1.
        // Your regfile design must bypass and output this new value immediately.
        // -------------------------------------------------------------
        $display("\n[Scenario 3] Testing Internal Forwarding (Simultaneous R/W on x1)");
        RegWriteW = 1'b1;
        RDW       = 5'd1;
        ResultW   = 32'hABCDEFFF;
        // Keep the same ADDI instruction so Decode continues to sample x1
        #10; 
        
        if (RD1E === 32'hABCDEFFF)
            $display(" -> SUCCESS: Internal forwarding (bypass) within RegFile works correctly.");
        else
            $display(" -> FAILURE: Forwarding data mismatch! RD1E=%h (Expected: ABCDEFFF)", RD1E);

        // Reset WB control signals
        RegWriteW = 1'b0;


        // -------------------------------------------------------------
        // Scenario 4: Test Load Word instruction (LW x5, 4(x2))
        // Expected machine code: 32'h00412283
        // -------------------------------------------------------------
        $display("\n[Scenario 4] Testing Load Word decoding: LW x5, 4(x2)");
        InstrD   = 32'h00412283;
        #10;
        
        if (MemtoRegE === 1'b1 && ResultSrcE === 2'b01 && RegWriteE === 1'b1)
            $display(" -> SUCCESS: Memory load control signals (MemtoReg, ResultSrc) are correctly asserted.");
        else
            $display(" -> FAILURE: Incorrect control signals for Load instruction.");


        // -------------------------------------------------------------
        // Scenario 5: Test ClearE pin (Pipeline Flush / Bubble insertion)
        // When ClearE is active, on the next rising clock edge, all ID/EX 
        // buffer values must clear back to 0.
        // -------------------------------------------------------------
        $display("\n[Scenario 5] Testing Pipeline Flush (ClearE / Flush)");
        ClearE = 1'b1;
        #10;
        
        if (RegWriteE === 1'b0 && MemWriteE === 1'b0 && RD1E === 32'd0 && RDE === 5'd0)
            $display(" -> SUCCESS: ID/EX pipeline register successfully flushed to 0.");
        else
            $display(" -> FAILURE: ClearE signal failed to flush EX stage data.");
        
        ClearE = 1'b0; // Disable flush after check


        // -------------------------------------------------------------
        // Scenario 6: Test B-type Branch instruction (BEQ x1, x2, offset 16)
        // Expected machine code: 32'h00208863
        // -------------------------------------------------------------
        $display("\n[Scenario 6] Testing Branch decoding: BEQ x1, x2, offset 16");
        InstrD   = 32'h00208863;
        #10;
        
        if (BranchE === 1'b1 && Imm_Ext_E === 32'd16)
            $display(" -> SUCCESS: B-type immediate extension generated accurately.");
        else
            $display(" -> FAILURE: Branch structural error! BranchE=%b, Imm_Ext_E=%d", BranchE, Imm_Ext_E);


        // --- End Simulation ---
        $display("\n==================================================");
        $display("   TESTBENCH COMPLETED: DECODE STAGE              ");
        $display("==================================================");
        $finish;
    end

    // (Optional) Dump Waveform for GTKWave/Vivado
    initial begin
        $dumpfile("decode_stage_tb.vcd");
        $dumpvars(0, tb_decode_stage);
    end

endmodule