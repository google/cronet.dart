cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "cronet")
project(${PROJECT_NAME} LANGUAGES C CXX)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 11)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "wrapper")

if(NOT ANDROID)
  add_compile_definitions(DART_SHARED_LIB)
endif (NOT ANDROID)

add_library(${PLUGIN_NAME} SHARED
  "wrapper.cc"
  "wrapper_utils.cc"
  "../third_party/cronet_impl/sample_executor.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart-sdk/dart_api_dl.c"
)

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart-sdk"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart-sdk/runtime"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/cronet"

)

if (MSVC)
  set(MSVC_DISABLED_WARNINGS_LIST
  "C4152" # nonstandard extension, function/data pointer conversion in expression
  "C4255"
  "C4820"
  "C4255"
  "C4668"
  )
  string(REPLACE "C" " -wd" MSVC_DISABLED_WARNINGS_STR ${MSVC_DISABLED_WARNINGS_LIST})
  set(CMAKE_C_FLAGS   "-utf-8 -Wall -WX ${MSVC_DISABLED_WARNINGS_STR}")
endif (MSVC)
