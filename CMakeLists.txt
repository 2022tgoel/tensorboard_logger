cmake_minimum_required(VERSION 3.16.3)
project(tensorboard_logger)

option(BUILD_TEST "Build test" OFF)

# list(APPEND CMAKE_PREFIX_PATH  "/home/gridsan/dliveoak/.local/protobuf/src")
# set(Protobuf_INCLUDE_DIR "/home/gridsan/dliveoak/.local/protobuf/src")
# set(Protobuf_PROTOC_EXECUTABLE "/home/gridsan/dliveoak/.local/bin/protoc")
# set(Protobuf_DEBUG true)

# find_package(Protobuf REQUIRED)

# -----------------------------------------------------------------------------
# Building the tensorboard_logger library
# -----------------------------------------------------------------------------

file(GLOB protos "proto/*.proto")

# manually doing stuff which is kind of stupid but works for now
set(PROTO_SRCS 
    "proto/event.pb.cc"  
    "proto/projector_config.pb.cc"  
    "proto/resource_handle.pb.cc"  
    "proto/summary.pb.cc"  
    "proto/tensor.pb.cc"  
    "proto/tensor_shape.pb.cc" 
    "proto/types.pb.cc")

set(Protobuf_LIBRARIES
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotobuf-lite.so.31"
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotobuf-lite.so"
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotobuf-lite.so.31.0.3"
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotobuf.so"
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotobuf.so.31"
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotobuf.so.31.0.3"
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotoc.so"
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotoc.so.31"
"/home/gridsan/dliveoak/.conda/envs/ml2/lib/libprotoc.so.31.0.3"
    )

# local and global includes
# set(PROTOBUF_INCLUDE_DIR  )
# protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${protos})

add_library(tensorboard_logger
    "src/crc.cc"
    "src/tensorboard_logger.cc"
    ${PROTO_SRCS}
)

target_compile_features(tensorboard_logger PRIVATE cxx_std_11)
target_compile_options(tensorboard_logger PRIVATE -Wall -O2)
# manually put include dirs 
include_directories(tensorboard_logger PRIVATE "/home/gridsan/dliveoak/.conda/envs/ml2/include" "${CMAKE_CURRENT_SOURCE_DIR}/proto/")
target_include_directories(tensorboard_logger
PUBLIC
    $<INSTALL_INTERFACE:include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROTOBUF_INCLUDE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)
target_link_libraries(tensorboard_logger PUBLIC ${Protobuf_LIBRARIES})

if (BUILD_TEST)
    add_executable(tensorboard_logger_test tests/test_tensorboard_logger.cc)
    target_compile_features(tensorboard_logger_test PRIVATE cxx_std_11)
    target_compile_options(tensorboard_logger_test PRIVATE -Wall -O2)
    target_include_directories(tensorboard_logger_test
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    )
    target_link_libraries(tensorboard_logger_test tensorboard_logger)
endif()

# -----------------------------------------------------------------------------
# Installing the tensorboard_logger library
# -----------------------------------------------------------------------------

message("Installing to ${CMAKE_INSTALL_PREFIX}")

install(
    TARGETS tensorboard_logger
    EXPORT tensorboard_logger_Targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    INCLUDES DESTINATION include
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${PROJECT_SOURCE_DIR}/cmake/tensorboard_loggerConfig.cmake.in"
    "${PROJECT_BINARY_DIR}/tensorboard_loggerConfig.cmake"
    INSTALL_DESTINATION
    ${CMAKE_INSTALL_PREFIX}/cmake
)

install(
    EXPORT tensorboard_logger_Targets
    FILE tensorboard_loggerTargets.cmake
    NAMESPACE tensorboard_logger::
    DESTINATION ${CMAKE_INSTALL_PREFIX}/cmake
)

install(
    FILES "${PROJECT_BINARY_DIR}/tensorboard_loggerConfig.cmake"
    DESTINATION ${CMAKE_INSTALL_PREFIX}/cmake
)

install(
    DIRECTORY include/
    DESTINATION include
)

install(
    DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/"
    DESTINATION include
    FILES_MATCHING
    PATTERN "*.pb.h"
    PATTERN "CMakeFiles" EXCLUDE
)
