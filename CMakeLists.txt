cmake_minimum_required(VERSION 3.10)
project(WspRunningGame)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# 搜索Raylib库
find_package(raylib QUIET)

if(NOT raylib_FOUND)
    # 尝试在项目文件夹中查找Raylib
    set(RAYLIB_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/raylib/include")
    set(RAYLIB_LIBRARY_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/raylib/lib")
    
    if(EXISTS ${RAYLIB_INCLUDE_DIRS}/raylib.h)
        message(STATUS "Found Raylib in project folder")
        include_directories(${RAYLIB_INCLUDE_DIRS})
        link_directories(${RAYLIB_LIBRARY_DIRS})
        set(raylib_FOUND TRUE)
    else()
        # 尝试在系统路径中查找Raylib
        set(RAYLIB_INCLUDE_DIRS "C:/raylib/include")
        set(RAYLIB_LIBRARY_DIRS "C:/raylib/lib")
        
        if(EXISTS ${RAYLIB_INCLUDE_DIRS}/raylib.h)
            message(STATUS "Found Raylib in system folder")
            include_directories(${RAYLIB_INCLUDE_DIRS})
            link_directories(${RAYLIB_LIBRARY_DIRS})
            set(raylib_FOUND TRUE)
        else()
            message(FATAL_ERROR "Raylib library not found! Please install Raylib to ./raylib/ or C:/raylib/")
        endif()
    endif()
else()
    message(STATUS "Found Raylib via find_package")
endif()

# 添加可执行文件
add_executable(game main.cpp)

# 链接Raylib库
if(WIN32)
    target_link_libraries(game raylib opengl32 gdi32 winmm)
else()
    target_link_libraries(game raylib GL m pthread dl rt X11)
endif()

# 复制Raylib DLL到输出目录（如果需要）
if(WIN32 AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/raylib/lib/raylib.dll")
    add_custom_command(TARGET game POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/raylib/lib/raylib.dll"
        $<TARGET_FILE_DIR:game>
    )
endif()
