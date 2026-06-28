# 32-bit Pipelined RISC-V Processor

![Project Overview](image_4a89ec.png)

## Overview
This repository contains a high-performance **32-bit Pipelined RISC-V Processor** design, implemented using Verilog/SystemVerilog. The design focuses on optimizing instruction throughput through a classic pipelining architecture.

## Architecture Highlights
The processor implements a multi-stage pipeline designed to enhance performance and ensure efficient hardware utilization:

*   **Fetch Stage (`fetch_stage.v`)**: Instruction retrieval from memory.
*   **Decode Stage (`decode_stage.v`)**: Instruction decoding and register file access.
*   **Execute Stage (`execute_stage.v`)**: ALU operations and address calculation.
*   **Memory Stage (`memory_stage.v`)**: Data memory read/write operations.
*   **Writeback Stage (`writeback_stage.v`)**: Updating the register file.
*   **Hazard Unit (`hazard_unit.v`)**: Advanced hazard detection and forwarding logic to maintain pipeline integrity.

## Project Structure
```text
/
├── Sources/          # Core Verilog/SystemVerilog RTL modules
├── Testbench/        # Verification environment (tb_riscv_pipeline.v)
└── Assembly_program.mem # Memory initialization file for testing



Getting Started
Requirements: Ensure you have an HDL simulation tool (e.g., ModelSim/QuestaSim or Vivado) configured for your environment.

Simulation: Use the provided tb_riscv_pipeline.v to verify the design functionality.

Synthesis: The RTL is structured to be synthesis-friendly for FPGA implementation.

Contact
If you have any questions, suggestions, or would like to collaborate, feel free to reach out:

Name: NGUYEN VAN THUC

Phone: 0961072793

Email: chuantinh2407@gmail.com

Developed as part of advanced IC Design studies.