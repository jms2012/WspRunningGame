@echo off

REM WSP Running Game CMake Build Script
echo WSP Running Game CMake Build Script
echo =================================
echo.

REM 创建build目录
if not exist "build" mkdir build
echo Created build directory
echo.

REM 进入build目录
cd build
echo Changed to build directory
echo.

REM 运行CMake
echo Running CMake...
echo.
cmake ..
if %errorlevel% neq 0 (
    echo CMake configuration failed!
echo.
    goto end
)
echo CMake configuration successful!
echo.

REM 构建项目
echo Building project...
echo.
cmake --build . --config Release
if %errorlevel% neq 0 (
    echo Build failed!
echo.
    goto end
)
echo Build successful!
echo.

REM 运行游戏
echo Running game...
echo.
Release\game.exe

:end
cd ..
echo Press any key to exit...
pause >nul
