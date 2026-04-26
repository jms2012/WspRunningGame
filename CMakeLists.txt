cmake_minimum_required(VERSION 3.10)
project(WspRunningGame)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# 检查是否使用Emscripten
if(EMSCRIPTEN)
    message(STATUS "Using Emscripten for Web build")
    # 设置Emscripten编译选项
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    set(EMSCriptEN_LINKER_FLAGS "-s USE_GLFW=3 -s ASYNCIFY -s ALLOW_MEMORY_GROWTH=1 -s WASM=1 -s EXPORT_NAME=\"createWspGame\" -s MODULARIZE=1")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${EMSCriptEN_LINKER_FLAGS}")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${EMSCriptEN_LINKER_FLAGS}")

    # 查找Emscripten版本的Raylib
    find_package(raylib REQUIRED)
else()
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
endif()

# 添加可执行文件
add_executable(game main.cpp)

# 链接Raylib库
if(EMSCRIPTEN)
    target_link_libraries(game raylib)
elseif(WIN32)
    target_link_libraries(game raylib opengl32 gdi32 winmm)
else()
    target_link_libraries(game raylib GL m pthread dl rt X11)
endif()

# 复制Raylib DLL到输出目录（如果需要）
if(WIN32 AND NOT EMSCRIPTEN AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/raylib/lib/raylib.dll")
    add_custom_command(TARGET game POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/raylib/lib/raylib.dll"
        $<TARGET_FILE_DIR:game>
    )
endif()

# 对于Emscripten构建，复制生成的文件到web目录
if(EMSCRIPTEN)
    add_custom_command(TARGET game POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_SOURCE_DIR}/web"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:game>"
        "${CMAKE_CURRENT_SOURCE_DIR}/web/"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE_DIR:game>/$<TARGET_FILE_BASE_NAME:game>.wasm"
        "${CMAKE_CURRENT_SOURCE_DIR}/web/"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE_DIR:game>/$<TARGET_FILE_BASE_NAME:game>.js"
        "${CMAKE_CURRENT_SOURCE_DIR}/web/"
    )
endif()
