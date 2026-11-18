# 由 CMakeLists.txt 的 POST_BUILD 以 `cmake -P` 方式调用：
#   cmake -DOBJDUMP=... -DELF=... -DOUTPUT=... -P cmake/gen_listing.cmake
# 原 makefile：
#   riscv-none-embed-objdump --source --all-headers --demangle \
#       --line-numbers --wide "bleKeyboard.elf" > "bleKeyboard.lst"

foreach(_v OBJDUMP ELF OUTPUT)
    if(NOT DEFINED ${_v} OR "${${_v}}" STREQUAL "")
        message(FATAL_ERROR "gen_listing.cmake: 缺少参数 ${_v}")
    endif()
endforeach()

message(STATUS "objdump: ${ELF}")
message(STATUS "   -> ${OUTPUT}")

execute_process(
        COMMAND "${OBJDUMP}"
                --source --all-headers --demangle --line-numbers --wide
                "${ELF}"
        OUTPUT_FILE    "${OUTPUT}"
        RESULT_VARIABLE _rc)

if(NOT _rc EQUAL 0)
    message(FATAL_ERROR "objdump 执行失败，返回码 ${_rc}")
endif()
