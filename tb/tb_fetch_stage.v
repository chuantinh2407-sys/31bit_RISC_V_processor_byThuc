`timescale 1ns / 1ps

module tb_fetch_stage;

    // --- Inputs to the module ---
    reg        CLK;
    reg        RESET;
    reg  [1:0] PCSrcE;      // 00: PC+4, 01: Branch/JAL, 10: JALR
    reg [31:0] PCTargetE;   // Target address for branch/jump
    reg [31:0] ResultE;     // ALU result for JALR
    reg        enableF;     // PC enable signal
    reg        enableD;     // IF/ID register enable
    reg        clearD;      // IF/ID register flush (clear)

    // --- Outputs from the module ---
    wire [31:0] InStrD;
    wire [31:0] PCD;
    wire [31:0] PCPlus4D;

    // Instantiate the Unit Under Test (UUT)
    fetch_stage uut (
        .CLK(CLK), 
        .RESET(RESET),
        .PCSrcE(PCSrcE), 
        .PCTargetE(PCTargetE), 
        .ResultE(ResultE),
        .enableF(enableF), 
        .enableD(enableD), 
        .clearD(clearD),
        .InStrD(InStrD), 
        .PCD(PCD), 
        .PCPlus4D(PCPlus4D)
    );

    // Clock generation: 10ns period
    always #5 CLK = ~CLK;

    initial begin
        // --- Initialization ---
        CLK = 0;
        RESET = 1;
        PCSrcE = 2'b00;
        PCTargetE = 0;
        ResultE = 0;
        enableF = 1;
        enableD = 1;
        clearD = 0;

        // Apply reset for 20ns
        #20 RESET = 0;

        // --- 1. Normal Execution Phase ---
        $display("--- Starting Normal Execution ---");
        // Allow the PC to increment freely for 10 cycles
        repeat(10) @(posedge CLK);

        // --- 2. Stall Phase ---
        $display("--- Testing Stall (enableF=0, enableD=0) ---");
        enableF = 0; // PC stops incrementing
        enableD = 0; // Pipeline register freezes
        repeat(3) @(posedge CLK);
        
        // Resume operation
        enableF = 1;
        enableD = 1;
        repeat(2) @(posedge CLK);

        // --- 3. Branch/Jump Phase ---
        $display("--- Testing Branch (PCSrcE=01) ---");
        PCSrcE = 2'b01;
        PCTargetE = 32'h0000_0040; // Target branch address
        @(posedge CLK);
        
        // Return to normal execution after branch
        PCSrcE = 2'b00;
        repeat(3) @(posedge CLK);

        // --- 4. Flush Phase ---
        $display("--- Testing Flush (clearD=1) ---");
        clearD = 1; // Clear instruction in ID stage
        @(posedge CLK);
        clearD = 0; // Disable clear
        repeat(3) @(posedge CLK);

        // --- Finish simulation ---
        $display("--- Simulation Completed Successfully ---");
        #20 $finish;
    end

    // Monitor for terminal output
    initial begin
        $dumpfile("fetch_stage_tb.vcd");
        $dumpvars(0, tb_fetch_stage);
        
        // Print status on every clock edge
        $monitor("Time=%0t | PC=%h | Instr=%h | PCSrcE=%b | clearD=%b", 
                  $time, PCD, InStrD, PCSrcE, clearD);
    end

endmodule