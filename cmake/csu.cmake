set(RC_ARCHS "armv6;armv7")
set(OFLAG -Os)

set(CMAKE_C_COMPILER clang)
set(BASE_C_FLAGS 
    ${OFLAG}
    -Wall
    --target=arm-apple-ios
    -B${SDK_PATH}/usr/bin
    -I${SDK_PATH}/usr/include
)

set(OS_MIN_V2 -miphoneos-version-min=2.0)
set(OS_MIN_V3 -miphoneos-version-min=2.0)
set(OS_MIN_V4 -miphoneos-version-min=3.1)

set(USRLIBDIR /usr/lib)
set(LOCLIBDIR /usr/local/lib)

# Function to add architecture flags target var
function(get_arch_flags out_var)
    set(arch_flags "")
    foreach(arch ${RC_ARCHS})
        list(APPEND arch_flags "-arch" ${arch})
    endforeach()
    set(${out_var} ${arch_flags} PARENT_SCOPE)
endfunction()

get_arch_flags(ARCH_FLAGS)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/crt1.v1.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V1} 
            -mdynamic-no-pic -nostdlib -keep_private_externs 
            ${CSU_SOURCE}/start.s ${CSU_SOURCE}/crt.c ${CSU_SOURCE}/dyld_glue.s 
            -o ${CMAKE_BINARY_DIR}/crt1.v1.o 
            -DCRT -DOLD_LIBSYSTEM_SUPPORT
    COMMENT "Building crt1.v1.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/crt1.v2.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V3} 
            -nostdlib -keep_private_externs 
            ${CSU_SOURCE}/start.s ${CSU_SOURCE}/crt.c ${CSU_SOURCE}/dyld_glue.s 
            -o ${CMAKE_BINARY_DIR}/crt1.v2.o 
            -DCRT

    COMMENT "Building crt1.v2.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/crt1.v3.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V2} 
            -nostdlib -keep_private_externs 
            ${CSU_SOURCE}/start.s ${CSU_SOURCE}/crt.c
            -o ${CMAKE_BINARY_DIR}/crt1.v3.o 
            -DADD_PROGRAM_VARS

    COMMENT "Building crt1.v3.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/crt1.v4.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V4}
            -nostdlib -keep_private_externs
            ${CSU_SOURCE}/start.s ${CSU_SOURCE}/crt.c
            -o ${CMAKE_BINARY_DIR}/crt1.v4.o
            -DADD_PROGRAM_VARS
    COMMENT "Building crt1.v4.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/gcrt1.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V1}
            -nostdlib -keep_private_externs
            ${CSU_SOURCE}/start.s ${CSU_SOURCE}/crt.c ${CSU_SOURCE}/dyld_glue.s
            -o ${CMAKE_BINARY_DIR}/gcrt1.o
            -DGCRT -DOLD_LIBSYSTEM_SUPPORT
    COMMENT "Building gcrt1.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/crt0.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS}
            -static -Wl,-new_linker -nostdlib -keep_private_externs
            ${CSU_SOURCE}/start.s ${CSU_SOURCE}/crt.c
            -o ${CMAKE_BINARY_DIR}/crt0.o
    COMMENT "Building crt0.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/dylib1.v1.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V1}
            -nostdlib -keep_private_externs
            ${CSU_SOURCE}/dyld_glue.s ${CSU_SOURCE}/icplusplus.c
            -o ${CMAKE_BINARY_DIR}/dylib1.v1.o
            -DCFM_GLUE
    COMMENT "Building dylib1.v1.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/dylib1.v2.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V2}
            -nostdlib -keep_private_externs
            ${CSU_SOURCE}/dyld_glue.s
            -o ${CMAKE_BINARY_DIR}/dylib1.v2.o
            -DCFM_GLUE
    COMMENT "Building dylib1.v2.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/bundle1.v1.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V1}
            -nostdlib -keep_private_externs
            ${CSU_SOURCE}/dyld_glue.s
            -o ${CMAKE_BINARY_DIR}/bundle1.v1.o
    COMMENT "Building bundle1.v1.o"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/lazydylib1.o
    COMMAND ${CMAKE_C_COMPILER} -r ${ARCH_FLAGS} ${BASE_C_FLAGS} ${OS_MIN_V3}
            -nostdlib -keep_private_externs
            ${CSU_SOURCE}/lazy_dylib_helper.s ${CSU_SOURCE}/lazy_dylib_loader.c
            -o ${CMAKE_BINARY_DIR}/lazydylib1.o
    COMMENT "Building lazydylib1.o"
)


add_custom_target(csu ALL DEPENDS
    ${CMAKE_BINARY_DIR}/crt1.v1.o
    ${CMAKE_BINARY_DIR}/crt1.v2.o
    ${CMAKE_BINARY_DIR}/crt1.v3.o
    ${CMAKE_BINARY_DIR}/crt1.v4.o
    ${CMAKE_BINARY_DIR}/gcrt1.o
    ${CMAKE_BINARY_DIR}/crt0.o
    ${CMAKE_BINARY_DIR}/dylib1.v1.o
    ${CMAKE_BINARY_DIR}/dylib1.v2.o
    ${CMAKE_BINARY_DIR}/bundle1.v1.o
    ${CMAKE_BINARY_DIR}/lazydylib1.o
)

install(FILES
    ${CMAKE_BINARY_DIR}/crt1.v2.o
    DESTINATION ${SDK_PATH}/usr/lib
    RENAME crt1.o
)

install(FILES
    ${CMAKE_BINARY_DIR}/crt1.v4.o
    DESTINATION ${SDK_PATH}/usr/lib
    RENAME crt1.3.1.o
)

install(FILES
    ${CMAKE_BINARY_DIR}/dylib1.v2.o
    DESTINATION ${SDK_PATH}/usr/lib
    RENAME dylib1.o
)

install(FILES
    ${CMAKE_BINARY_DIR}/bundle1.v1.o
    DESTINATION ${SDK_PATH}/usr/lib
    RENAME bundle1.o
)

install(FILES
    ${CMAKE_BINARY_DIR}/lazydylib1.o
    DESTINATION ${SDK_PATH}/usr/lib
    RENAME lazydylib1.o
)

install(FILES
    ${CMAKE_BINARY_DIR}/gcrt1.o
    DESTINATION ${SDK_PATH}/usr/lib
    RENAME gcrt1.o
)

install(FILES
    ${CMAKE_BINARY_DIR}/crt0.o
    DESTINATION ${SDK_PATH}/usr/local/lib
    RENAME crt0.o
)