# ====================================================================
# MAKEFILE TỐI ƯU: CẤU TRÚC THƯ MỤC MỚI (rtl/ và tb/)
# ====================================================================

# 1. Thư mục chứa mã nguồn (Đã cập nhật)
SRC_DIR = rtl
TB_DIR  = tb

# Tự động lấy tất cả file .v trong thư mục rtl
SRCS := $(wildcard $(SRC_DIR)/*.v)

VIVADO_SETTINGS = /home/nguyen-van-thuc/ic_workspace/vanthuc/downloads/tools/Vivado/2023.2/settings64.sh

VIVADO_XPR = ./vivado/project_data/vivado_work.xpr

# 2. Chọn bài test mặc định (nếu không truyền tham số)
TEST ?= decode

# 3. Định tuyến file testbench dựa trên tên khối
ifeq ($(TEST), fetch)
    TB_FILE = $(TB_DIR)/tb_fetch_stage.v
    TOP_MOD = tb_fetch_stage
    VCD_FILE = fetch_stage_tb.vcd
else ifeq ($(TEST), decode)
    TB_FILE = $(TB_DIR)/tb_decode_stage.v
    TOP_MOD = tb_decode_stage
    VCD_FILE = decode_stage_tb.vcd
else ifeq ($(TEST), execute)
    TB_FILE = $(TB_DIR)/tb_execute_stage.v
    TOP_MOD = tb_execute_stage
    VCD_FILE = execute_stage_tb.vcd
else ifeq ($(TEST), memory)
    TB_FILE = $(TB_DIR)/tb_memory_stage.v
    TOP_MOD = tb_memory_stage
    VCD_FILE = memory_stage_tb.vcd
else ifeq ($(TEST), writeback)
    TB_FILE = $(TB_DIR)/tb_writeback_stage.v
    TOP_MOD = tb_writeback_stage
    VCD_FILE = writeback_stage_tb.vcd
else ifeq ($(TEST), pipeline)
    TB_FILE = $(TB_DIR)/tb_riscv_pipeline.v
    TOP_MOD = tb_riscv_pipeline
    VCD_FILE = riscv_pipeline_tb.vcd
endif

# ====================================================================
# LUỒNG 1: ICARUS VERILOG (Khối nhỏ)
# ====================================================================
wave:
	@echo "========= [GTKWAVE] BIÊN DỊCH & CHẠY ========="
	iverilog -o simulation.vvp $(SRCS) $(TB_FILE)
	vvp simulation.vvp
	@echo "========= [GTKWAVE] MỞ SÓNG ========="
	gtkwave $(VCD_FILE)

# ====================================================================
# LUỒNG 2: VIVADO SIMULATOR (Dành cho Top CPU)
# ====================================================================
init_vivado:
	@echo "========== [VIVADO] ĐANG KHỞI TẠO DỰ ÁN TRONG THƯ MỤC VIVADO/ =========="
	@bash -c "source $(VIVADO_SETTINGS) && vivado -mode batch -source vivado/create_proj.tcl"

open_vivado:
	@echo "========== [VIVADO] ĐANG MỞ DỰ ÁN CŨ =========="
	@bash -c "source $(VIVADO_SETTINGS) && vivado $(VIVADO_XPR) &"

# ====================================================================
# DỌN DẸP
# ====================================================================
clean:
	@echo "========= XÓA FILE TẠM ========="
	rm -rf xsim.dir .Xil/ *.jou *.log *.pb *.vvp *.vcd *.wdb *.str 