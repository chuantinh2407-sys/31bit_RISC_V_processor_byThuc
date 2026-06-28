`timescale 1ns / 1ps

module tb_writeback_stage;

    // ---------------------------------------------------------
    // 1. Signal Declarations
    // ---------------------------------------------------------
    // Inputs (Declared as regs to drive values)
    reg         RegWriteW;
    reg  [1:0]  ResultSrcW;
    reg  [31:0] AluResultW;
    reg  [31:0] ReaddataW;
    reg  [31:0] PCPlus4W;
    reg  [4:0]  RDW_in;

    // Outputs (Declared as wires to monitor)
    wire [31:0] ResultW;
    wire [4:0]  RDW;
    wire        RegWriteW_out;

    // ---------------------------------------------------------
    // 2. Unit Under Test (UUT) Instantiation
    // ---------------------------------------------------------
    writeback_stage uut (
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .AluResultW(AluResultW),
        .ReaddataW(ReaddataW),
        .PCPlus4W(PCPlus4W),
        .RDW_in(RDW_in),
        .ResultW(ResultW),
        .RDW(RDW),
        .RegWriteW_out(RegWriteW_out)
    );

    // ---------------------------------------------------------
    // 3. Test Stimulus Process
    // ---------------------------------------------------------
    initial begin
        // --- Step 1: System Initialization ---
        RegWriteW  = 1'b0;
        ResultSrcW = 2'b00;
        // Set unique mock data values for each source to prevent false positives
        AluResultW = 32'hAAAA_1111; // Source 00
        ReaddataW  = 32'hBBBB_2222; // Source 01
        PCPlus4W   = 32'hCCCC_3333; // Source 10
        RDW_in     = 5'd0;

        #10; // Small delay for system settle

        $display("==================================================");
        $display("   STARTING TESTBENCH: WRITEBACK STAGE            ");
        $display("==================================================");

        // -------------------------------------------------------------
        // Scenario 1: Route ALU Result (ResultSrcW = 2'b00)
        // Common for R-type and I-type arithmetic instructions
        // -------------------------------------------------------------
        $display("\n[Scenario 1] Testing ALU Result Selection (ResultSrcW = 00)");
        ResultSrcW = 2'b00;
        #5; // Combinational propagation delay

        if (ResultW === 32'hAAAA_1111)
            $display(" -> SUCCESS: ResultW correctly selected AluResultW.");
        else
            $display(" -> FAILURE: MUX error! ResultW=%h", ResultW);


        // -------------------------------------------------------------
        // Scenario 2: Route Data Memory Read (ResultSrcW = 2'b01)
        // Used exclusively for Load instructions (e.g., LW)
        // -------------------------------------------------------------
        $display("\n[Scenario 2] Testing Memory Read Data Selection (ResultSrcW = 01)");
        ResultSrcW = 2'b01;
        #5;

        if (ResultW === 32'hBBBB_2222)
            $display(" -> SUCCESS: ResultW correctly selected ReaddataW.");
        else
            $display(" -> FAILURE: MUX error! ResultW=%h", ResultW);


        // -------------------------------------------------------------
        // Scenario 3: Route Return Address (ResultSrcW = 2'b10)
        // Used for Jump and Link instructions (JAL / JALR) to save link pointer
        // -------------------------------------------------------------
        $display("\n[Scenario 3] Testing PC+4 Selection (ResultSrcW = 10)");
        ResultSrcW = 2'b10;
        #5;

        if (ResultW === 32'hCCCC_3333)
            $display(" -> SUCCESS: ResultW correctly selected PCPlus4W.");
        else
            $display(" -> FAILURE: MUX error! ResultW=%h", ResultW);


        // -------------------------------------------------------------
        // Scenario 4: Direct Pass-through Check (Control & Destination Reg)
        // Verify RegWriteW and RDW pass directly out to feed back to RegFile
        // -------------------------------------------------------------
        $display("\n[Scenario 4] Testing Control and Destination Register Pass-through");
        RegWriteW = 1'b1;
        RDW_in    = 5'd19; // Destination register x19
        #5;

        if (RegWriteW_out === 1'b1 && RDW === 5'd19)
            $display(" -> SUCCESS: Hazard/Feedback signals (RegWriteW_out, RDW) passed through safely.");
        else
            $display(" -> FAILURE: Pass-through path broken! RegWriteW_out=%b, RDW=%d", RegWriteW_out, RDW);


        // --- End Simulation ---
        $display("\n==================================================");
        $display("   TESTBENCH COMPLETED: WRITEBACK STAGE           ");
        $display("==================================================");
        $finish;
    end

    // ---------------------------------------------------------
    // 4. GTKWave Structural Trace Setup
    // ---------------------------------------------------------
    initial begin
        $dumpfile("writeback_stage_tb.vcd");
        $dumpvars(0, tb_writeback_stage);
    end

endmodule