#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/nguyen-van-thuc/ic_workspace/vanthuc/downloads/tools/Vivado/2023.2/ids_lite/ISE/bin/lin64:/home/nguyen-van-thuc/ic_workspace/vanthuc/downloads/tools/Vivado/2023.2/bin
else
  PATH=/home/nguyen-van-thuc/ic_workspace/vanthuc/downloads/tools/Vivado/2023.2/ids_lite/ISE/bin/lin64:/home/nguyen-van-thuc/ic_workspace/vanthuc/downloads/tools/Vivado/2023.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/nguyen-van-thuc/ic_workspace/vanthuc/mini_projects/projects_document/prj_vscode/32_bit_Pipelining_RISC_V_Processor/vivado/project_data/vivado_work.runs/impl_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log riscv_pipeline.vdi -applog -m64 -product Vivado -messageDb vivado.pb -mode batch -source riscv_pipeline.tcl -notrace


