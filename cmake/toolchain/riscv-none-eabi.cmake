# =============================================================================
#  RISC-V 交叉工具链：MounRiver 自带的 riscv-none-embed-gcc
#  用法：
#    cmake -S . -B build -G Ninja \
#          -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/riscv-none-embed-gcc.cmake \
#          -DRISCV_TOOLCHAIN_BIN="C:/MounRiver/MounRiver_Studio/toolchain/RISC-V Embedded GCC/bin"
#  省略 -DRISCV_TOOLCHAIN_BIN 时，会到 PATH 里查找 riscv-none-embed-gcc。
# =============================================================================

set(CMAKE_SYSTEM_NAME      Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)

# 交叉环境下的编译器探测只做静态库链接，避免因无可用 crt/链接脚本而失败
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(RISCV_TOOLCHAIN_PREFIX "riscv-none-embed-" CACHE STRING "工具链前缀")

# find_program(_RV_GCC
#         NAMES ${RISCV_TOOLCHAIN_PREFIX}gcc
#         HINTS "${RISCV_TOOLCHAIN_BIN}"
#         REQUIRED)
# get_filename_component(_RV_BIN "${_RV_GCC}" DIRECTORY)

set(CMAKE_C_COMPILER   "${RISCV_TOOLCHAIN_PREFIX}gcc")
set(CMAKE_ASM_COMPILER "${RISCV_TOOLCHAIN_PREFIX}gcc")
set(CMAKE_CXX_COMPILER "${RISCV_TOOLCHAIN_PREFIX}g++")

set(CMAKE_OBJCOPY "${RISCV_TOOLCHAIN_PREFIX}objcopy" CACHE FILEPATH "")
set(CMAKE_OBJDUMP "${RISCV_TOOLCHAIN_PREFIX}objdump" CACHE FILEPATH "")
set(CMAKE_SIZE    "${RISCV_TOOLCHAIN_PREFIX}size"    CACHE FILEPATH "")
set(CMAKE_AR      "${RISCV_TOOLCHAIN_PREFIX}ar"      CACHE FILEPATH "")
set(CMAKE_RANLIB  "${RISCV_TOOLCHAIN_PREFIX}ranlib"  CACHE FILEPATH "")

# 裸机 ELF：固定后缀，避免 CMake 对 Generic 系统猜成 .exe / 无后缀
set(CMAKE_EXECUTABLE_SUFFIX ".elf")

# -----------------------------------------------------------------------------
# 架构/ABI 选项：等价于 makefile 中每条 gcc / ld 命令行前面的
#   -march=rv32imac -mabi=ilp32 -mcmodel=medany -msmall-data-limit=8 -mno-save-restore
# 放在 *_INIT 里，编译、汇编、链接三条路径都自动带上。
# -----------------------------------------------------------------------------
set(RISCV_ARCH_FLAGS
        "-march=rv32imac -mabi=ilp32 -mcmodel=medany -msmall-data-limit=8 -mno-save-restore"
        CACHE STRING "RISC-V 架构/ABI 选项")

set(CMAKE_C_FLAGS_INIT              "${RISCV_ARCH_FLAGS}")
set(CMAKE_ASM_FLAGS_INIT            "${RISCV_ARCH_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT     "${RISCV_ARCH_FLAGS}")

# 主机端工具（cmake 自身等）不去目标根路径里找
# set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
# set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
