@echo off
chcp 65001 >nul
echo ========================================
echo   LangM 安装包构建工具
echo ========================================
echo.

:: 检查 Inno Setup 是否安装
set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist %ISCC% (
    echo [错误] 未找到 Inno Setup 6
    echo.
    echo 请先下载安装 Inno Setup:
    echo   https://jrsoftware.org/isdl.php
    echo.
    pause
    exit /b 1
)

:: 检查 langm.exe 是否存在
if not exist "..\target\release\langm.exe" (
    echo [提示] 未找到 langm.exe，正在编译...
    echo.
    cd ..
    cargo build --release
    cd installer
    if not exist "..\target\release\langm.exe" (
        echo [错误] 编译失败
        pause
        exit /b 1
    )
)

:: 检查图标文件
if not exist "langm.ico" (
    echo [提示] 未找到 langm.ico，将使用默认图标
    echo 如需自定义图标，请将 langm.ico 放到 installer 目录
    echo.
)

:: 创建输出目录
if not exist "..\dist" mkdir "..\dist"

:: 显示文件大小
echo langm.exe 大小:
for %%A in ("..\target\release\langm.exe") do echo   %%~zA bytes (%%~zA / 1024 = ~KB)
echo.

:: 编译安装包
echo 正在生成安装包...
%ISCC% langm.iss

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   构建成功！
    echo ========================================
    echo.
    echo 安装包: dist\LangM-Setup-0.1.0.exe
    echo.
    for %%A in ("..\dist\LangM-Setup-0.1.0.exe") do echo 大小: %%~zA bytes
    echo.
) else (
    echo.
    echo [错误] 构建失败
)

pause
