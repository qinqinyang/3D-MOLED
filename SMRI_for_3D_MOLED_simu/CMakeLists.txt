cmake_minimum_required(VERSION 3.18)
# set cxx complier
if(WIN32)
  message(STATUS"WIN32")
  set(CMAKE_CXX_COMPILER "cl.exe")
elseif(UNIX AND NOT APPLE AND NOT ANDROID)
  message(STATUS "LINUX")
  set(CMAKE_CXX_COMPILER "/home/yqq/Downloads/gcc/bin/g++")
  set(CMAKE_C_COMPILER "/home/yqq/Downloads/gcc/bin/gcc")
endif()

project(simu_bin LANGUAGES CUDA CXX)
project(make_seq LANGUAGES CUDA CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_STANDARD 14)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CMAKE_BUILD_TYPE Release)

if(MSVC)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
    set(BUILD_SHARED_LIBS TRUE)
    add_definitions(-DUNICODE -D_UNICODE)
endif()

INCLUDE_DIRECTORIES(./include)
INCLUDE_DIRECTORIES(./einclude/nlohmann)
INCLUDE_DIRECTORIES(./einclude/eigen-3.3.9)
INCLUDE_DIRECTORIES(./einclude)
INCLUDE_DIRECTORIES(/home/yqq/Env/MATLAB/extern/include)

link_directories(
    /home/yqq/Env/MATLAB/bin/glnxa64
)

add_library(tools SHARED
    src/tools.cpp
)

add_library(parse SHARED
    src/parse.cpp
)

add_library(baseSeq SHARED
    src/BaseSeq.cpp
)
target_link_libraries(baseSeq PRIVATE tools)
target_link_libraries(baseSeq PRIVATE parse)

add_library(parseMain SHARED
    src/parseMain.cpp
)

target_link_libraries(parseMain PRIVATE parse)

add_subdirectory(seqs)
# message(${fileNameList})
# foreach(v ${fileNameList})
#     message(${v})
# endforeach()

add_library(macMgr SHARED
    src/MacMgr.cpp
)


find_library(matlabLib NAMES mat mx mex eng PATHS /home/yqq/Env/MATLAB/bin/glnxa64)
add_library(objMgr SHARED
    src/ObjMgr.cpp
)

target_link_libraries(objMgr PRIVATE ${matlabLib})

# find_package(nlohmann_json 3.2.0 REQUIRED)
# target_link_libraries(parse PRIVATE nlohmann_json::nlohmann_json)

link_directories(
    /home/yqq/Env/MATLAB/bin/glnxa64
)

find_library(ml NAMES nvidia-ml PATHS /usr/local/cuda-12.2/lib64/)

add_executable(simu_bin
    src/simu.cu
)

set_target_properties(simu_bin PROPERTIES CUDA_ARCHITECTURES "72")

target_link_libraries(simu_bin
    PUBLIC 
        tools
        parseMain
        parse
        baseSeq
        objMgr
        macMgr
        ${ml}
)

foreach(v ${fileNameList})
    target_link_libraries(simu_bin
        PUBLIC 
            seq::${v}
    )
endforeach()


