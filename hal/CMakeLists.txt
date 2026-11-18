cmake_minimum_required(VERSION 3.20)

project(ch58x)
enable_language(C)

add_library(ch58x INTERFACE)



# StdPeriphDriver/subdir.mk
set(SRC_STDPERIPH
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_clk.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_flash.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_gpio.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_i2c.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_pwr.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_spi1.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_sys.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_uart0.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_uart1.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_usb2dev.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_usb2hostBase.c
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver/CH58x_usb2hostClass.c)

# Startup/subdir.mk（.S 由 C 预处理器处理，gcc 按扩展名自动识别）
set(SRC_STARTUP
        ${CMAKE_CURRENT_SOURCE_DIR}/Startup/startup_CH583.S)

# RVMSIS/subdir.mk
set(SRC_CORE
        ${CMAKE_CURRENT_SOURCE_DIR}/RVMSIS/core_riscv.c)


# 库：objects.mk 里的 LIBS := -lISP583，配合 -L"../StdPeriphDriver"
# （原工程并未链接 ble/libCH58xBLE.a；若启用 BLE 协议栈，在这里再追加该 .a）
target_link_directories(ch58x INTERFACE
        # ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/StdPeriphDriver)

target_link_libraries(ch58x INTERFACE
        -lISP583)

target_compile_definitions(ch58x INTERFACE
)

target_include_directories(ch58x INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/StdPeriphDriver/inc
    ${CMAKE_CURRENT_LIST_DIR}/RVMSIS
)

target_sources(ch58x INTERFACE
    ${SRC_STDPERIPH}
    ${SRC_STARTUP}
    ${SRC_CORE}
)
