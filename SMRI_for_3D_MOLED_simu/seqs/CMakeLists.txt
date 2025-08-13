cmake_minimum_required(VERSION 3.18)

project(allSeq)

file(GLOB ALL_SEQ */*.cpp)

set(fileNameList2 "")

if(MSVC)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
    set(BUILD_SHARED_LIBS TRUE)
    add_definitions(-DUNICODE -D_UNICODE)
endif()

if(WIN32)
    # https://stackoverflow.com/questions/47251874/cmake-shared-library-in-subdirectory
    # https://stackoverflow.com/questions/44909846/cmake-exe-cant-find-dll
    # https://stackoverflow.com/questions/28533012/how-to-set-runtime-path-for-cmake-custom-command-on-windows
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
endif()

foreach(vcpp ${ALL_SEQ})
    # message(${vcpp})
    string(REGEX MATCH "^\/.*(\/)" vcppInclude ${vcpp})
    # this is call "parenthesis-delimited subexpressions"
    string(REGEX REPLACE ".+/(.+)\\..*" "\\1" vcppName ${vcpp} )
    # message(${fileNameList2})
    list(APPEND fileNameList2 ${vcppName})

    # message(STATUS ${vcppInclude})
    # message(STATUS ${vcppName})

    add_library(${vcppName} SHARED
        ${vcpp}
    )
    add_library(
        seq::${vcppName} ALIAS ${vcppName}
    )
    target_include_directories(${vcppName}
        PUBLIC
            ${vcppInclude}
    )
    target_link_libraries(${vcppName}
        PUBLIC
            baseSeq
            parse
    )
    INCLUDE_DIRECTORIES(${vcppInclude})
    
endforeach()
set(fileNameList ${fileNameList2} PARENT_SCOPE)
# message(STATUS  ${fileNameList2})
# foreach(v ${fileNameList2})
#     message(${v})
# endforeach()

