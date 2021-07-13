cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "cronet_sample")
project(${PROJECT_NAME} LANGUAGES C CXX)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 11)

add_executable(${PROJECT_NAME}
  "main.cc"
  "sample_executor.cc"
  "sample_url_request_callback.cc"
)

target_include_directories(${PROJECT_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../cronet/"

)

if (UNIX AND NOT APPLE)
  set(CRONET_DIR "$ENV{CURRENTDIR}/.dart_tool/cronet/linux64")
  find_library(CRONET cronet.86.0.4240.198 ${CRONET_DIR})
  target_link_libraries(${PROJECT_NAME} pthread dl ${CRONET})
endif (UNIX AND NOT APPLE)

if (APPLE)
  set(CRONET_DIR "$ENV{CURRENTDIR}/.dart_tool/cronet/macos64")
  find_library(CRONET cronet.86.0.4240.198 ${CRONET_DIR})
  target_link_libraries(${PROJECT_NAME} pthread dl ${CRONET})
endif (APPLE)

if (WIN32)
  set(CRONET_DIR "$ENV{CURRENTDIR}\\.dart_tool\\cronet\\windows64")
  find_library(CRONET cronet.86.0.4240.198.dll ${CRONET_DIR})
  target_link_libraries(${PROJECT_NAME} ${CRONET})
endif (WIN32)
