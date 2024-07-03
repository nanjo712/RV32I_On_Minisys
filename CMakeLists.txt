cmake_minimum_required(VERSION 3.20)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)

project(rv32i_on_minisys LANGUAGES C CXX ASM)

# set language standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# set compiler
set(CMAKE_C_COMPILER riscv32-unknown-elf-gcc)
set(CMAKE_CXX_COMPILER riscv32-unknown-elf-g++)
set(CMAKE_ASM_COMPILER riscv32-unknown-elf-gcc)
set(CMAKE_AR riscv32-unknown-elf-ar)
set(CMAKE_LINKER riscv32-unknown-elf-ld)
set(CMAKE_OBJCOPY riscv32-unknown-elf-objcopy)
set(CMAKE_OBJDUMP riscv32-unknown-elf-objdump)
set(SIZE riscv32-unknown-elf-size)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# set flags
set(CMAKE_C_FLAGS "-Wall -O2 -Werror -march=rv32i_zicsr -mabi=ilp32 -nostartfiles -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS "-Wall -O2 -Werror -march=rv32i_zicsr -mabi=ilp32 -nostartfiles -ffunction-sections -fdata-sections")
set(CMAKE_ASM_FLAGS "-Wall -O2 -Werror -march=rv32i_zicsr -mabi=ilp32 -nostartfiles -ffunction-sections -fdata-sections")

set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/scripts/linker.ld)
add_link_options(-Wl,--gc-sections,--print-map,--defsym=_pmem_start=0x80000000,-melf32lriscv)
add_link_options(-T ${LINKER_SCRIPT})

add_library(
    abstract_machine 
    STATIC
    am/src/trm.c
    am/src/uart_lite.c
    am/src/start.S
)
target_include_directories(abstract_machine PRIVATE am/include)
target_include_directories(abstract_machine PUBLIC core/include)

add_executable(
    ${PROJECT_NAME}.elf
    core/src/main.c 
)
target_include_directories(${PROJECT_NAME}.elf PRIVATE core/include)
target_link_libraries(${PROJECT_NAME}.elf PRIVATE abstract_machine)

set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

file(COPY ${CMAKE_SOURCE_DIR}/util/bin2coe DESTINATION ${PROJECT_BINARY_DIR})

add_custom_command(
    TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
    COMMAND ${SIZE} $<TARGET_FILE:${PROJECT_NAME}.elf>
    COMMAND ./bin2coe ${BIN_FILE} ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.coe
    COMMAND ${CMAKE_OBJDUMP} -d $<TARGET_FILE:${PROJECT_NAME}.elf> > ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.txt
    COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.coe /mnt/c/Users/john/Documents/RV32I/
    COMMENT "Building ${HEX_FILE} \nBuilding ${BIN_FILE}"
)


