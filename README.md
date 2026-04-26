# WSP Running Game

一款使用C++和Raylib开发的跑圈点击放置类游戏。

## 功能特性

- 可控制的小人角色，沿圆形路径自动循环跑动
- 经济系统：每完成一圈获得虚拟货币
- 升级系统：提升小人速度和赚钱效率
- 购买系统：添加更多小人同时跑动
- 直观的用户界面和视觉效果

## 安装依赖

### 1. 安装Raylib库

**方法1：项目文件夹安装（推荐）**
1. 从 https://www.raylib.com/ 下载Raylib
2. 解压到项目文件夹，并重命名为 `raylib`
3. 确保路径 `./raylib/include/raylib.h` 存在

**方法2：系统安装**
1. 从 https://www.raylib.com/ 下载Raylib
2. 安装到 `C:\raylib\` 目录
3. 确保路径 `C:\raylib\include\raylib.h` 存在

### 2. 安装CMake

1. 从 https://cmake.org/download/ 下载CMake
2. 安装CMake并添加到系统PATH

### 3. 安装编译器

**选项1：Visual Studio 2022 Community（推荐）**
- 从 https://visualstudio.microsoft.com/vs/community/ 下载
- 安装时选择"使用C++的桌面开发"

**选项2：MinGW-w64（GCC）**
- 从 https://sourceforge.net/projects/mingw-w64/ 下载
- 安装到 `C:\MinGW-w64\`
- 添加 `C:\MinGW-w64\mingw64\bin` 到系统PATH

## 构建和运行

### 使用CMake构建（推荐）

1. 双击运行 `build_cmake.ps1` 脚本
2. 或在PowerShell中执行：
   ```powershell
   powershell -ExecutionPolicy Bypass -File build_cmake.ps1
   ```

### 直接编译

1. 双击运行 `build.bat` 脚本
2. 或在命令提示符中执行：
   ```cmd
   build.bat
   ```

## 游戏操作

- **开始/暂停**：点击右上角的按钮
- **升级菜单**：点击右上角的"Upgrade"按钮
- **购买小人**：在升级菜单中点击"Buy"按钮
- **升级速度**：在升级菜单中点击"Upgrade"按钮
- **升级赚钱效率**：在升级菜单中点击"Upgrade"按钮

## 故障排除

### 常见错误

1. **Raylib library not found!**
   - 确保Raylib已正确安装到 `./raylib/` 或 `C:\raylib\` 目录

2. **No compiler found!**
   - 确保已安装Visual Studio或MinGW-w64
   - 确保编译器路径已添加到系统PATH

3. **cannot execute 'as': CreateProcess: No such file or directory**
   - 这是MinGW的汇编器缺失问题
   - 确保MinGW的bin目录已添加到系统PATH
   - 或使用Visual Studio编译器

4. **Compilation failed!**
   - 检查错误信息，确保所有依赖项都已正确安装
   - 确保代码没有语法错误

### 系统要求

- Windows 10/11
- 至少4GB RAM
- 支持OpenGL 3.3的显卡
- 1GHz以上处理器

## 项目结构

```
WspRunningGame/
├── main.cpp          # 主游戏文件
├── CMakeLists.txt    # CMake配置文件
├── build_cmake.ps1   # CMake构建脚本
├── build.bat         # 直接构建脚本
├── build.ps1         # PowerShell构建脚本
└── raylib/           # Raylib库文件夹（用户需要手动创建）
```
