`timescale 1ns / 1ps

module tb_riscv_pipeline;

    // =================================================================
    // 1. EXTERNAL SIGNALS & PROBES DECLARATION
    // =================================================================
    reg CLK;
    reg RESET;

    // Datapath Wires
    wire [31:0] w_pc_decode;
    wire [31:0] w_instr_decode;
    wire [31:0] w_alu_result_exec;
    wire [31:0] tb_cpu_srcAE;
    wire [31:0] tb_cpu_srcBE;
    wire [31:0] tb_Imm_Ext_E;
    wire [31:0] w_mem_write_data;
    wire [31:0] w_wb_result;
    wire [4:0]  w_wb_rd;

    // Control Wires
    wire        w_ctrl_regwrite;
    wire        w_ctrl_memwrite;
    wire        w_ctrl_branch;
    wire        w_ctrl_memtoreg;
    wire        w_ctrl_alusrc;

    // Hazard Wires
    wire        w_haz_stallF;
    wire        w_haz_stallD;
    wire        w_haz_flushD;
    wire        w_haz_flushE;
    wire [1:0]  w_haz_forwardAE;
    wire [1:0]  w_haz_forwardBE;

    // Cycle counter for debugging
    integer cycle_count;

    // =================================================================
    // 2. UNIT UNDER TEST (UUT) INSTANTIATION
    // =================================================================
    riscv_pipeline uut (
        .CLK                (CLK),
        .RESET              (RESET),

        // Datapath

        .o_pc_decode        (w_pc_decode),
        .o_instr_decode     (w_instr_decode),
        .o_cpu_srcAE        (tb_cpu_srcAE),
        .o_cpu_srcBE        (tb_cpu_srcBE),
        .o_Imm_Ext_E        (tb_Imm_Ext_E),
        .o_alu_result_exec  (w_alu_result_exec),
        .o_wb_result        (w_wb_result),
        .o_mem_write_data   (w_mem_write_data),
        .o_wb_rd            (w_wb_rd),

        // Control
        .o_ctrl_regwrite    (w_ctrl_regwrite),
        .o_ctrl_memwrite    (w_ctrl_memwrite),
        .o_ctrl_branch      (w_ctrl_branch),
        .o_ctrl_memtoreg    (w_ctrl_memtoreg),
        .o_ctrl_alusrc      (w_ctrl_alusrc),

        // Hazard
        .o_haz_stallF       (w_haz_stallF),
        .o_haz_stallD       (w_haz_stallD),
        .o_haz_flushD       (w_haz_flushD),
        .o_haz_flushE       (w_haz_flushE),
        .o_haz_forwardAE    (w_haz_forwardAE),
        .o_haz_forwardBE    (w_haz_forwardBE)
    );

    // =================================================================
    // 3. CLOCK GENERATION (10ns Period -> 100MHz)
    // =================================================================
    always #5 CLK = ~CLK;

    // =================================================================
    // 4. SIMULATION STIMULUS
    // =================================================================
    initial begin
        CLK = 0;
        RESET = 1;
        cycle_count = 0;

        #15;
        RESET = 0;
        
        $display("\n=======================================================================================");
        $display("          [START SIMULATION] ADVANCED PIPELINE TRACKER USING OUTPUT PROBES             ");
        $display("=======================================================================================");
        
        // Run for 120 cycles
        #1200;
        
        $display("\n=======================================================================================");
        $display("                       [SIMULATION TIMEOUT] END OF ANALYSIS                            ");
        $display("=======================================================================================");
        $finish;
    end

    // Cycle Counter
    always @(posedge CLK) begin
        if (!RESET) begin
            cycle_count = cycle_count + 1;
        end
    end

    // =================================================================
    // 5. WAVEFORM DUMP GENERATION
    // =================================================================
    initial begin
        $dumpfile("vivado/project_data/riscv_pipeline_wave.vcd");
        $dumpvars(0, tb_riscv_pipeline);
    end

    // =================================================================
    // 6. PIPELINE TRACKER - DISPLAYING DATA FROM OUTPUT PORTS
    // =================================================================
    // Using negedge to print logs after posedge data has stabilized
    always @(negedge CLK) begin
        if (!RESET) begin
            $display("\n[CYCLE %0d]", cycle_count);
            
            // --- STAGE: FETCH ---
            $display("  [IF]  StallF: %b", w_haz_stallF);
            
            // --- STAGE: DECODE ---
            $display("  [ID]  PC: 0x%h | Inst: 0x%h | StallD: %b | FlushD: %b", 
                     w_pc_decode, w_instr_decode, w_haz_stallD, w_haz_flushD);
            
            // --- STAGE: EXECUTE ---
            $display("  [EX]  ALUOut: 0x%h | FwdAE: %b, FwdBE: %b | FlushE: %b | BranchCtrl: %b", 
                     w_alu_result_exec, w_haz_forwardAE, w_haz_forwardBE, w_haz_flushE, w_ctrl_branch);
            
            // --- STAGE: MEMORY ---
            $display("  [MEM] WriteData: 0x%h | MemWriteEn: %b", 
                     w_mem_write_data, w_ctrl_memwrite);
            
            // --- STAGE: WRITEBACK ---
            $display("  [WB]  RD(Target): %d | WritebackData: 0x%h | RegWriteEn: %b", 
                     w_wb_rd, w_wb_result, w_ctrl_regwrite);
                     
            $display("  -------------------------------------------------------------------------------------");
        end
    end

endmodule
