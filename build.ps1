# 构建脚本 - 支持MSVC和GCC编译器

Write-Host "WSP Running Game Build Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# 检查MSVC编译器
$msvcPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"
$msvcFound = Test-Path $msvcPath

# 检查GCC编译器
$gccFound = $false
try {
    g++ --version | Out-Null
    $gccFound = $true
} catch {
    $gccFound = $false
}

# 显示编译器状态
Write-Host "Compiler Status:" -ForegroundColor Yellow
if ($msvcFound) {
    Write-Host "- MSVC: Found"
} else {
    Write-Host "- MSVC: Not found"
}
if ($gccFound) {
    Write-Host "- GCC: Found"
} else {
    Write-Host "- GCC: Not found"
}
Write-Host ""

# 选择编译器
if ($msvcFound) {
    Write-Host "Using MSVC compiler (recommended for Windows)" -ForegroundColor Green
    
    # 检查Raylib库
    $raylibFound = $false
    $includePath = ""
    $libPath = ""
    
    # 检查项目文件夹中的Raylib
    if (Test-Path ".\raylib\include\raylib.h") {
        if (Test-Path ".\raylib\lib\raylib.lib") {
            $includePath = ".\raylib\include"
            $libPath = ".\raylib\lib"
            $raylibFound = $true
        } elseif (Test-Path ".\raylib\src\raylib.lib") {
            $includePath = ".\raylib\include"
            $libPath = ".\raylib\src"
            $raylibFound = $true
        }
    }
    
    # 检查系统安装的Raylib
    if (-not $raylibFound) {
        if (Test-Path "C:\raylib\raylib\src\raylib.h") {
            $includePath = "C:\raylib\raylib\src"
            $libPath = "C:\raylib\raylib\src"
            $raylibFound = $true
        } elseif (Test-Path "C:\raylib\include\raylib.h") {
            if (Test-Path "C:\raylib\lib\raylib.lib") {
                $includePath = "C:\raylib\include"
                $libPath = "C:\raylib\lib"
                $raylibFound = $true
            }
        }
    }
    
    # 编译游戏
    if ($raylibFound) {
        Write-Host "Compiling with MSVC..." -ForegroundColor Yellow
        cl main.cpp /EHsc /std:c++17 /I"$includePath" /LIBPATH:"$libPath" raylib.lib opengl32.lib gdi32.lib winmm.lib /Fe:game.exe
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Compilation successful!" -ForegroundColor Green
            Write-Host "Running game..."
            .\game.exe
        } else {
            Write-Host "Compilation failed!" -ForegroundColor Red
        }
    } else {
        Write-Host "Error: Raylib library not found!" -ForegroundColor Red
        Write-Host "Please install Raylib to .\raylib\ or C:\raylib\" -ForegroundColor Yellow
    }
} else {
    if ($gccFound) {
        Write-Host "Using GCC compiler" -ForegroundColor Green
        
        # 检查Raylib库
        $raylibFound = $false
        $includePath = ""
        $libPath = ""
        
        # 检查项目文件夹中的Raylib
        if (Test-Path ".\raylib\include\raylib.h") {
            if (Test-Path ".\raylib\lib\libraylib.a") {
                $includePath = ".\raylib\include"
                $libPath = ".\raylib\lib"
                $raylibFound = $true
            } elseif (Test-Path ".\raylib\src\libraylib.a") {
                $includePath = ".\raylib\include"
                $libPath = ".\raylib\src"
                $raylibFound = $true
            } elseif (Test-Path ".\raylib\lib\raylib.lib") {
                $includePath = ".\raylib\include"
                $libPath = ".\raylib\lib"
                $raylibFound = $true
            } elseif (Test-Path ".\raylib\src\raylib.lib") {
                $includePath = ".\raylib\include"
                $libPath = ".\raylib\src"
                $raylibFound = $true
            }
        }
        
        # 检查系统安装的Raylib
        if (-not $raylibFound) {
            if (Test-Path "C:\raylib\raylib\src\raylib.h") {
                $includePath = "C:\raylib\raylib\src"
                $libPath = "C:\raylib\raylib\src"
                $raylibFound = $true
            } elseif (Test-Path "C:\raylib\include\raylib.h") {
                if (Test-Path "C:\raylib\lib\libraylib.a") {
                    $includePath = "C:\raylib\include"
                    $libPath = "C:\raylib\lib"
                    $raylibFound = $true
                } elseif (Test-Path "C:\raylib\lib\raylib.lib") {
                    $includePath = "C:\raylib\include"
                    $libPath = "C:\raylib\lib"
                    $raylibFound = $true
                }
            }
        }
        
        # 编译游戏
        if ($raylibFound) {
            Write-Host "Compiling with GCC..." -ForegroundColor Yellow
            g++ main.cpp -std=c++11 -I"$includePath" -L"$libPath" -lraylib -lopengl32 -lgdi32 -lwinmm -o game.exe
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Compilation successful!" -ForegroundColor Green
                Write-Host "Running game..."
                .\game.exe
            } else {
                Write-Host "Compilation failed!" -ForegroundColor Red
            }
        } else {
            Write-Host "Error: Raylib library not found!" -ForegroundColor Red
            Write-Host "Please install Raylib to .\raylib\ or C:\raylib\" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Error: No compiler found!" -ForegroundColor Red
        Write-Host "" -ForegroundColor White
        Write-Host "Please install one of the following:" -ForegroundColor Yellow
        Write-Host "1. Visual Studio 2022 Community (recommended)"
        Write-Host "   https://visualstudio.microsoft.com/vs/community/"
        Write-Host "" -ForegroundColor White
        Write-Host "2. MinGW-w64 (GCC)"
        Write-Host "   https://sourceforge.net/projects/mingw-w64/"
        Write-Host "   Add C:\MinGW-w64\mingw64\bin to system PATH"
    }
}

Read-Host "Press Enter to exit..."
