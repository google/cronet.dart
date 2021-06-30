cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "cronet_sample")
project(${PROJECT_NAME} LANGUAGES C CXX)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(${PROJECT_NAME}
  "main.cc"
  "sample_executor.cc"
  "sample_url_request_callback.cc"
)

target_include_directories(${PROJECT_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../cronet/"

)

if (UNIX)
  set(CRONET_DIR "$ENV{CURRENTDIR}/.dart_tool/cronet/linux64")
  find_library(CRONET cronet.86.0.4240.198 ${CRONET_DIR})
  target_link_libraries(${PROJECT_NAME} pthread dl ${CRONET})
endif (UNIX)

if (WIN32)
  set(CRONET_DIR "$ENV{CURRENTDIR}\\.dart_tool\\cronet\\windows64")
  find_library(CRONET cronet.86.0.4240.198.dll ${CRONET_DIR})
  target_link_libraries(${PROJECT_NAME} ${CRONET})
endif (WIN32)
