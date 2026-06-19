// Testbench for 32 bit Pipelining RISCV Processor
`timescale 1ns/1ps

module tb_riscv_pipeline;

    reg CLK, RESET;

    riscv_pipeline dut (
        .CLK   (CLK),
        .RESET (RESET)
    );

    // Clock
    initial CLK = 0;
    always #5 CLK = ~CLK;

    initial begin
        $display("Loading instruction memory...");
             
        RESET = 1;
        @(posedge CLK); #1;
        @(posedge CLK); #1;
        RESET = 0;

        repeat (30) @(posedge CLK);
        check_results();

        $display("\n=== Simulation Complete ===");
        $finish;
    end

    // Dump waveforms 
    initial begin
        $dumpfile("riscv_pipeline.vcd");
        $dumpvars(0, tb_riscv_pipeline);
    end

    // Result checker - reads register file directly
    task check_results;
	begin
        $display("\n========================================");
        $display("  Register File State After Execution");
        $display("========================================");
        $display("x0  = %0d (expect 0)",  dut.u_id.u_regfile.regs[0]);
        $display("x1  = %0d (expect 5)",  dut.u_id.u_regfile.regs[1]);
        $display("x2  = %0d (expect 3)",  dut.u_id.u_regfile.regs[2]);
        $display("x3  = %0d (expect 8)",  dut.u_id.u_regfile.regs[3]);
        $display("x4  = %0d (expect 5)",  dut.u_id.u_regfile.regs[4]);
        $display("x5  = %0d (expect 1)",  dut.u_id.u_regfile.regs[5]);
        $display("x6  = %0d (expect 7)",  dut.u_id.u_regfile.regs[6]);
        $display("x7  = %0d (expect 6)",  dut.u_id.u_regfile.regs[7]);
        $display("x8  = %0d (expect 40)", dut.u_id.u_regfile.regs[8]);
        $display("x9  = %0d (expect 100)",dut.u_id.u_regfile.regs[9]);
        $display("x10 = %0d (expect 6)",  dut.u_id.u_regfile.regs[10]);
        $display("x11 = %0d (expect 0)",  dut.u_id.u_regfile.regs[11]);
        $display("x12 = %0d (expect 0, flushed)", dut.u_id.u_regfile.regs[12]);
        $display("x13 = %0d (expect 42)", dut.u_id.u_regfile.regs[13]);
        $display("x14 = %0d (expect 7)",  dut.u_id.u_regfile.regs[14]);
        $display("x15 = %0d (expect 0, flushed)", dut.u_id.u_regfile.regs[15]);
        $display("x16 = %0d (expect 55)", dut.u_id.u_regfile.regs[16]);
        $display("x17 = %0d (expect 84=0x54)", dut.u_id.u_regfile.regs[17]);
        $display("x18 = %0d (expect 0, flushed)", dut.u_id.u_regfile.regs[18]);
        $display("x19 = %0d (expect 77)", dut.u_id.u_regfile.regs[19]);
        $display("Data memory[100] = %0d (expect 5)", dut.u_ma.dmem[25]); 
        $display("========================================\n");

        // Pass/Fail assertions
        if (dut.u_id.u_regfile.regs[1]  !== 32'd5)  $display("FAIL: x1");  else $display("PASS: x1=5");
        if (dut.u_id.u_regfile.regs[2]  !== 32'd3)  $display("FAIL: x2");  else $display("PASS: x2=3");
        if (dut.u_id.u_regfile.regs[3]  !== 32'd8)  $display("FAIL: x3");  else $display("PASS: x3=8");
        if (dut.u_id.u_regfile.regs[4]  !== 32'd5)  $display("FAIL: x4");  else $display("PASS: x4=5");
        if (dut.u_id.u_regfile.regs[5]  !== 32'd1)  $display("FAIL: x5");  else $display("PASS: x5=1");
        if (dut.u_id.u_regfile.regs[6]  !== 32'd7)  $display("FAIL: x6");  else $display("PASS: x6=7");
        if (dut.u_id.u_regfile.regs[7]  !== 32'd6)  $display("FAIL: x7");  else $display("PASS: x7=6");
        if (dut.u_id.u_regfile.regs[8]  !== 32'd40) $display("FAIL: x8");  else $display("PASS: x8=40");
        if (dut.u_id.u_regfile.regs[10] !== 32'd6)  $display("FAIL: x10"); else $display("PASS: x10=6 (load-use stall ok)");
        if (dut.u_id.u_regfile.regs[12] !== 32'd0)  $display("FAIL: x12 should be 0 (flushed)"); else $display("PASS: x12=0 (control hazard flush ok)");
        if (dut.u_id.u_regfile.regs[13] !== 32'd42) $display("FAIL: x13"); else $display("PASS: x13=42");
        if (dut.u_id.u_regfile.regs[16] !== 32'd55) $display("FAIL: x16"); else $display("PASS: x16=55");
        if (dut.u_id.u_regfile.regs[19] !== 32'd77) $display("FAIL: x19"); else $display("PASS: x19=77");
    end endtask

    // Pipeline state monitor 
    integer cycle_count;
    initial cycle_count = 0;

    always @(posedge CLK) begin
        if (!RESET) begin
            cycle_count = cycle_count + 1;
            $display("C%0d | PC=%0h | InstrF=%0h | InstrD=%0h | StallF=%b StallD=%b FlushD=%b FlushE=%b | FwdA=%b FwdB=%b",
                cycle_count,
                dut.u_if.PC_reg,
                dut.u_if.InStrF,
                dut.u_if.InStrD,
                dut.u_haz.StallF,
                dut.u_haz.StallD,
                dut.u_haz.FlushD,
                dut.u_haz.FlushE,
                dut.u_haz.ForwardAE,
                dut.u_haz.ForwardBE
            );
        end
    end

endmodule
