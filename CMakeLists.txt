# =============================================================================
#  ProgrammableKeyboardKeys / bleKeyboard  (CH58x, RV32IMAC)
#  CMake 版构建脚本：由 MounRiver Studio 的
#    obj/makefile  +  obj/sources.mk  +  obj/objects.mk  +  obj/*/subdir.mk
#  等价改写而来（覆盖 object 列表、编译选项、链接脚本、hex/lst/size 后处理）。
# =============================================================================
cmake_minimum_required(VERSION 3.18)
include(cmake/toolchain/riscv-none-eabi.cmake)

project(bleKeyboard LANGUAGES C ASM)


add_subdirectory(hal)

# -----------------------------------------------------------------------------
# 1. 编译开关（与 subdir.mk 中每一条 gcc 命令行一一对应）
#    原命令：riscv-none-embed-gcc <RISCV_ARCH_FLAGS> -Os -fmessage-length=0
#            -fsigned-char -ffunction-sections -fdata-sections -fno-common -g
#            -DDEBUG=1 -I"../StdPeriphDriver/inc" -I"../RVMSIS" -std=gnu99 ...
#    其中 <RISCV_ARCH_FLAGS> 由工具链文件通过 CMAKE_C_FLAGS_INIT 注入：
#            -march=rv32imac -mabi=ilp32 -mcmodel=medany
#            -msmall-data-limit=8 -mno-save-restore
# -----------------------------------------------------------------------------
set(PROJECT_C_OPTIONS
        -std=gnu99
        -Os
        -g                              # = -g，保留调试信息（原 makefile 有）
        -fmessage-length=0
        -fsigned-char
        -ffunction-sections
        -fdata-sections
        -fno-common)

# 生成物目录：默认 build 目录。
# 若想让 MRS 的“下载/复位”按钮继续按 obj/bleKeyboard.hex 找固件，
# 可加 -DARTIFACT_DIR=${CMAKE_SOURCE_DIR}/obj
set(ARTIFACT_DIR "${CMAKE_BINARY_DIR}" CACHE PATH
        "elf/hex/map/lst 输出目录（默认 CMake 二进制目录）")

set(SRC_APP
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Main.c)

# ble/subdir.mk
set(SRC_BLE
        ${CMAKE_CURRENT_SOURCE_DIR}/ble/MCU.c
        ${CMAKE_CURRENT_SOURCE_DIR}/ble/RTC.c
        ${CMAKE_CURRENT_SOURCE_DIR}/ble/SLEEP.c
        ${CMAKE_CURRENT_SOURCE_DIR}/ble/cfg.c)

add_executable(${PROJECT_NAME}
        ${SRC_APP}
        # ${SRC_BLE}
)

# -----------------------------------------------------------------------------
# 3. 头文件路径 / 宏定义
#    原：-I"../StdPeriphDriver/inc" -I"../RVMSIS"   -DDEBUG=1（仅 C，startup.S 不带）
# -----------------------------------------------------------------------------
target_include_directories(${PROJECT_NAME} PRIVATE
)

target_link_libraries(${PROJECT_NAME} PRIVATE
ch58x
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
        $<$<COMPILE_LANGUAGE:C>:DEBUG=1>)

target_compile_options(${PROJECT_NAME} PRIVATE
        $<$<COMPILE_LANGUAGE:C>:${PROJECT_C_OPTIONS}>)

# -----------------------------------------------------------------------------
# 4. 链接选项（对应 makefile 里 bleKeyboard.elf 的链接命令行）
#    -T "../Ld/Link.ld" -nostartfiles -Xlinker --gc-sections
#    -L"../" -L"../StdPeriphDriver" -Xlinker --print-memory-usage
#    -Wl,-Map,"bleKeyboard.map" --specs=nano.specs --specs=nosys.specs
# -----------------------------------------------------------------------------
target_link_options(${PROJECT_NAME} PRIVATE
        -T${CMAKE_CURRENT_SOURCE_DIR}/Ld/Link.ld
        -nostartfiles
        -Wl,--gc-sections
        -Wl,--print-memory-usage
        -Wl,-Map=${ARTIFACT_DIR}/bleKeyboard.map
        --specs=nano.specs
        --specs=nosys.specs)

# -----------------------------------------------------------------------------
# 5. 输出文件名：bleKeyboard.elf（与原 -o "bleKeyboard.elf" 一致）
# -----------------------------------------------------------------------------
set_target_properties(${PROJECT_NAME} PROPERTIES
        OUTPUT_NAME               "bleKeyboard"
        SUFFIX                    ".elf"
        RUNTIME_OUTPUT_DIRECTORY  "${ARTIFACT_DIR}"
        LINK_DEPENDS              "${CMAKE_CURRENT_SOURCE_DIR}/Ld/Link.ld")

# -----------------------------------------------------------------------------
# 6. 后处理（对应 makefile 的 secondary-outputs：hex / lst / siz）
# -----------------------------------------------------------------------------
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${ARTIFACT_DIR}"

        # SECONDARY_FLASH：objcopy -O ihex
        COMMAND ${CMAKE_OBJCOPY} -O ihex
                "$<TARGET_FILE:${PROJECT_NAME}>"
                "${ARTIFACT_DIR}/bleKeyboard.hex"

        # SECONDARY_LIST：objdump 反汇编清单（用 -P 脚本做重定向，跨平台）
        COMMAND ${CMAKE_COMMAND}
                -DOBJDUMP=${CMAKE_OBJDUMP}
                -DELF=$<TARGET_FILE:${PROJECT_NAME}>
                -DOUTPUT=${ARTIFACT_DIR}/bleKeyboard.lst
                -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/gen_lst.cmake"

        # SECONDARY_SIZE：size --format=berkeley（只打印，不落盘）
        COMMAND ${CMAKE_SIZE} --format=berkeley "$<TARGET_FILE:${PROJECT_NAME}>"

        COMMENT "POST_BUILD: bleKeyboard.hex / bleKeyboard.lst / size"
        VERBATIM)

# clean 时一并清理后处理产物（CMake 不会自动跟踪它们）
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES
        "${ARTIFACT_DIR}/bleKeyboard.hex"
        "${ARTIFACT_DIR}/bleKeyboard.lst"
        "${ARTIFACT_DIR}/bleKeyboard.map"
        "${ARTIFACT_DIR}/bleKeyboard.elf")

# -----------------------------------------------------------------------------
# 7. 便捷目标
# -----------------------------------------------------------------------------
add_custom_target(clean-all
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean
        COMMAND ${CMAKE_COMMAND} -E rm -f
                "${ARTIFACT_DIR}/bleKeyboard.elf" "${ARTIFACT_DIR}/bleKeyboard.hex"
                "${ARTIFACT_DIR}/bleKeyboard.lst" "${ARTIFACT_DIR}/bleKeyboard.map"
        COMMENT "clean build tree + artifacts")
