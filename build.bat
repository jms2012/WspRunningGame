@echo off

REM WSP Running Game Build Script
echo WSP Running Game Build Script
echo ==============================
echo.

REM 检查编译器
echo Checking for compilers...
echo.

REM 检查MSVC
set HAVE_MSVC=0
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" set HAVE_MSVC=1

REM 检查GCC
set HAVE_GCC=0
g++ --version >nul 2>nul
if %errorlevel% equ 0 set HAVE_GCC=1

echo Compiler status:
echo - MSVC: %HAVE_MSVC%
echo - GCC: %HAVE_GCC%
echo.

REM 检查Raylib
echo Checking for Raylib library...
echo.

set HAVE_RAYLIB=0

REM 检查项目文件夹中的Raylib
if exist ".\raylib\include\raylib.h" (
    if exist ".\raylib\lib\raylib.lib" (
        set INCLUDE_DIR=./raylib/include
        set LIB_DIR=./raylib/lib
        set HAVE_RAYLIB=1
    ) else if exist ".\raylib\src\raylib.lib" (
        set INCLUDE_DIR=./raylib/include
        set LIB_DIR=./raylib/src
        set HAVE_RAYLIB=1
    ) else if exist ".\raylib\lib\libraylib.a" (
        set INCLUDE_DIR=./raylib/include
        set LIB_DIR=./raylib/lib
        set HAVE_RAYLIB=1
    ) else if exist ".\raylib\src\libraylib.a" (
        set INCLUDE_DIR=./raylib/include
        set LIB_DIR=./raylib/src
        set HAVE_RAYLIB=1
    )
)

REM 检查系统Raylib
if %HAVE_RAYLIB% equ 0 (
    if exist "C:\raylib\raylib\src\raylib.h" (
        set INCLUDE_DIR=C:/raylib/raylib/src
        set LIB_DIR=C:/raylib/raylib/src
        set HAVE_RAYLIB=1
    ) else if exist "C:\raylib\include\raylib.h" (
        if exist "C:\raylib\lib\raylib.lib" (
            set INCLUDE_DIR=C:/raylib/include
            set LIB_DIR=C:/raylib/lib
            set HAVE_RAYLIB=1
        ) else if exist "C:\raylib\lib\libraylib.a" (
            set INCLUDE_DIR=C:/raylib/include
            set LIB_DIR=C:/raylib/lib
            set HAVE_RAYLIB=1
        )
    )
)

if %HAVE_RAYLIB% equ 1 (
    echo Raylib found at:
    echo - Include: %INCLUDE_DIR%
    echo - Library: %LIB_DIR%
echo.
) else (
    echo Error: Raylib library not found!
echo.
    echo Please install Raylib to:
    echo 1. ./raylib/ folder (recommended)
    echo 2. C:/raylib/ folder
echo.
    goto end
)

REM 编译游戏
if %HAVE_MSVC% equ 1 (
    echo Using MSVC compiler
echo.
    echo Compiling...
    cl main.cpp /EHsc /std:c++17 /I"%INCLUDE_DIR%" /LIBPATH:"%LIB_DIR%" raylib.lib opengl32.lib gdi32.lib winmm.lib /Fe:game.exe
    if %errorlevel% equ 0 (
        echo Compilation successful!
echo.
        echo Running game...
        game.exe
    ) else (
        echo Compilation failed!
    )
) else if %HAVE_GCC% equ 1 (
    echo Using GCC compiler
echo.
    echo Compiling...
    g++ main.cpp -std=c++11 -I"%INCLUDE_DIR%" -L"%LIB_DIR%" -lraylib -lopengl32 -lgdi32 -lwinmm -o game.exe
    if %errorlevel% equ 0 (
        echo Compilation successful!
echo.
        echo Running game...
        game.exe
    ) else (
        echo Compilation failed!
    )
) else (
    echo Error: No compiler found!
echo.
    echo Please install:
    echo 1. Visual Studio 2022 Community (recommended)
    echo 2. MinGW-w64 (GCC)
echo.
)

:end
echo Press any key to exit...
pause >nul
