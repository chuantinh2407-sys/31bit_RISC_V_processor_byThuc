`timescale 1ns / 1ps

module tb_memory_stage;
    reg         CLK;
    reg         RESET;
    reg         RegWriteM;
    reg  [1:0]  ResultSrcM;
    reg         MemWriteM;
    reg  [31:0] AluResultM;
    reg  [31:0] WriteDataM;
    reg  [4:0]  RDM;
    reg  [31:0] PCPlus4M;

    wire        RegWriteW;
    wire [1:0]  ResultSrcW;
    wire [31:0] AluResultW;
    wire [31:0] ReaddataW;
    wire [4:0]  RDW;
    wire [31:0] PCPlus4W;

    // Instantiate Unit Under Test
    memory_stage uut (
        .CLK(CLK), .RESET(RESET),
        .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM), .AluResultM(AluResultM),
        .WriteDataM(WriteDataM), .RDM(RDM), .PCPlus4M(PCPlus4M),
        .RegWriteW(RegWriteW), .ResultSrcW(ResultSrcW),
        .AluResultW(AluResultW), .ReaddataW(ReaddataW),
        .RDW(RDW), .PCPlus4W(PCPlus4W)
    );

    always #5 CLK = ~CLK;

    initial begin
        $dumpfile("memory_stage_tb.vcd");
        $dumpvars(0, tb_memory_stage);

        CLK = 0; RESET = 1;
        RegWriteM = 0; ResultSrcM = 0; MemWriteM = 0;
        AluResultM = 0; WriteDataM = 0; RDM = 0; PCPlus4M = 0;

        #10 RESET = 0;

        // Test 1: Đọc giá trị đã load từ dmem32.mem (ví dụ địa chỉ 0)
        #10 AluResultM = 32'd0; 
        #10 $display("Gia tri tai addr 0: %h (Expected: AA)", ReaddataW);

        // Test 2: Ghi dữ liệu mới vào địa chỉ 10
        #10 MemWriteM = 1; AluResultM = 32'd10; WriteDataM = 32'hDEADBEEF;
        #10 MemWriteM = 0; // Tắt write
        #10 AluResultM = 32'd10; // Đọc lại dữ liệu vừa ghi
        #10 $display("Gia tri tai addr 10: %h (Expected: DEADBEEF)", ReaddataW);

        #20 $finish;
    end
endmodule