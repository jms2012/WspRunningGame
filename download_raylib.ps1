# 下载并安装Raylib到项目文件夹

Write-Host "Downloading Raylib..." -ForegroundColor Yellow

# 下载Raylib预编译版本
$raylibUrl = 'https://github.com/raysan5/raylib/releases/download/4.5.0/raylib-4.5.0_win64_mingw-w64.zip'
$zipPath = 'raylib.zip'

try {
    Invoke-WebRequest -Uri $raylibUrl -OutFile $zipPath
    Write-Host "Download completed!" -ForegroundColor Green
    
    # 解压到项目文件夹
    Write-Host "Extracting Raylib..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath .
    
    # 重命名文件夹
    if (Test-Path 'raylib-4.5.0_win64_mingw-w64') {
        Rename-Item 'raylib-4.5.0_win64_mingw-w64' 'raylib'
        Write-Host "Raylib extracted to .\raylib\" -ForegroundColor Green
    }
    
    # 清理临时文件
    Remove-Item $zipPath
    
    Write-Host "Raylib installation completed!" -ForegroundColor Green
    Write-Host "You can now run build.ps1 to compile and run the game." -ForegroundColor Green
    
} catch {
    Write-Host "Error downloading Raylib: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}
