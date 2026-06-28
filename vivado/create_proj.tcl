# 1. Tạo dự án nằm gọn bên trong thư mục ./vivado/project_data
# Cờ -force để ghi đè nếu đã tồn tại
create_project -force vivado_work ./vivado/project_data

# 2. Quét dữ liệu từ thư mục gốc (vì lệnh gọi từ thư mục gốc)
add_files [glob ./rtl/*.v]
add_files -fileset sim_1 [glob ./tb/*.v]
add_files -fileset sim_1 [glob ./*.mem]

# 3. Thiết lập các module Top
set_property top riscv_pipeline [current_fileset]
set_property top tb_riscv_pipeline [get_filesets sim_1]

# 4. Cập nhật cây thư mục thiết kế
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

