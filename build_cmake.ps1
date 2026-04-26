# WSP Running Game CMake Build Script
Write-Host "WSP Running Game CMake Build Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# 创建build目录
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Name "build" -Force | Out-Null
    Write-Host "Created build directory" -ForegroundColor Yellow
    Write-Host ""
}

# 进入build目录
Set-Location "build"
Write-Host "Changed to build directory" -ForegroundColor Yellow
Write-Host ""

# 运行CMake
Write-Host "Running CMake..." -ForegroundColor Yellow
Write-Host ""
try {
    cmake ..
    if ($LASTEXITCODE -eq 0) {
        Write-Host "CMake configuration successful!" -ForegroundColor Green
        Write-Host ""
        
        # 构建项目
        Write-Host "Building project..." -ForegroundColor Yellow
        Write-Host ""
        cmake --build . --config Release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Build successful!" -ForegroundColor Green
            Write-Host ""
            
            # 运行游戏
            Write-Host "Running game..." -ForegroundColor Yellow
            Write-Host ""
            if (Test-Path "Release\game.exe") {
                & .\Release\game.exe
            } else {
                Write-Host "Error: game.exe not found!" -ForegroundColor Red
            }
        } else {
            Write-Host "Build failed!" -ForegroundColor Red
        }
    } else {
        Write-Host "CMake configuration failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# 返回项目根目录
Set-Location ".."
Write-Host "" -ForegroundColor White
Write-Host "Press Enter to exit..." -ForegroundColor Yellow
Read-Host
