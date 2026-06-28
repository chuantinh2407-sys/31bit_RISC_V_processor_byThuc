# 32-bit Pipelined RISC-V Processor

[![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)]()
[![Hardware Design](https://img.shields.io/badge/Domain-IC_Design-red.svg)]()

## Abstract
This repository hosts a robust implementation of a **32-bit Pipelined RISC-V Processor**. Engineered with a focus on high-throughput performance, the architecture follows classic RISC-V pipelining principles to optimize cycle efficiency and hardware resource utilization. As shown in image_4992c5.png, the project is structured for modularity and scalability.

## Core Architecture
The design utilizes a standard 5-stage pipeline to maximize instruction throughput:

*   **Instruction Fetch (IF)**: Efficient instruction retrieval from memory.
*   **Instruction Decode (ID)**: Accurate decoding and register file operand access.
*   **Execute (EX)**: High-speed ALU operations and effective address calculation.
*   **Memory Access (MEM)**: Data memory interface management.
*   **Write-Back (WB)**: Register file commit stage.
*   **Hazard Unit**: Implements advanced forwarding and stall logic to ensure data integrity across pipeline stages.

## Repository Structure
```text
.
├── Sources/            # RTL design modules (Verilog/SystemVerilog)
│   ├── fetch_stage.v
│   ├── decode_stage.v
│   ├── execute_stage.v
│   ├── memory_stage.v
│   ├── writeback_stage.v
│   └── hazard_unit.v
├── Testbench/          # Verification suite
│   └── tb_riscv_pipeline.v
└── Assembly_program.mem # Memory initialization for testing.
```

<<<<<<< HEAD


Getting Started
Requirements: Ensure you have an HDL simulation tool (e.g., ModelSim/QuestaSim or Vivado) configured for your environment.
=======
Technical Specifications & Workflow:
>>>>>>> 0e5b2e2693163ed5042aeb549aed81d043f3b184

Compile all modules within the Sources/ directory.

Instantiate the processor in tb_riscv_pipeline.v.

Execute simulation to monitor pipeline signal behavior and register file updates.

FPGA Readiness:
The RTL code is crafted with synthesis constraints in mind, ensuring compatibility with standard FPGA platforms (e.g., Xilinx Vivado flow).

Author & Contact
NGUYEN VAN THUC

Student at Ho Chi Minh City University of Technology and Education (HCMUTE)

For technical inquiries, collaboration, or feedback regarding the RISC-V implementation:

📧 Email: chuantinh2407@gmail.com

📱 Phone: +84 961 072 793

Disclaimer: Developed as part of advanced IC Design studies. All rights reserved.
