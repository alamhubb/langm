# LangM Release Build Script
# 一键构建所有分发格式: MSI + ZIP

param(
    [string]$Version = "0.1.0",
    [string]$WixBinPath = "",  # WiX bin 目录路径，如 "C:\wix314\bin"
    [switch]$SkipMsi = $false  # 跳过 MSI 构建
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LangM Release Build v$Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 创建 dist 目录
$distDir = "dist"
if (Test-Path $distDir) {
    Remove-Item -Recurse -Force $distDir
}
New-Item -ItemType Directory -Path $distDir | Out-Null
Write-Host "[1/4] Created dist directory" -ForegroundColor Green

# 编译 Release 版本
Write-Host "[2/4] Building release binary..." -ForegroundColor Yellow
cargo build --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
$exePath = "target\release\langm.exe"
$exeSize = (Get-Item $exePath).Length / 1KB
Write-Host "       Binary size: $([math]::Round($exeSize, 0)) KB" -ForegroundColor Gray

# 生成 MSI 安装包
if (-not $SkipMsi) {
    Write-Host "[3/4] Building MSI installer..." -ForegroundColor Yellow
    
    $wixArgs = @("wix", "--nocapture")
    if ($WixBinPath -ne "") {
        $wixArgs += @("-b", $WixBinPath)
    }
    
    & cargo @wixArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "MSI build failed! Try: -WixBinPath 'C:\path\to\wix\bin' or -SkipMsi" -ForegroundColor Red
        exit 1
    }
    $msiSource = "target\wix\langm-$Version-x86_64.msi"
    $msiDest = "$distDir\langm-$Version-x86_64.msi"
    Copy-Item $msiSource $msiDest
    $msiSize = (Get-Item $msiDest).Length / 1KB
    Write-Host "       MSI size: $([math]::Round($msiSize, 0)) KB" -ForegroundColor Gray
} else {
    Write-Host "[3/4] Skipping MSI build" -ForegroundColor Gray
}

# 生成 ZIP 便携版
Write-Host "[4/4] Creating ZIP portable..." -ForegroundColor Yellow
$zipName = "langm-$Version-windows-x64.zip"
$zipPath = "$distDir\$zipName"
$tempDir = "$distDir\langm-$Version"

# 创建临时目录并复制文件
New-Item -ItemType Directory -Path $tempDir | Out-Null
Copy-Item $exePath "$tempDir\langm.exe"

# 创建 README
$readmeContent = @"
# LangM v$Version - Portable Edition

基于能力的多语言运行时管理器

## 使用方法

1. 将 langm.exe 放到你喜欢的目录
2. 将该目录添加到系统 PATH 环境变量
3. 将 %USERPROFILE%\.langm\current\bin 添加到 PATH

## 快速开始

```
langm add C:\path\to\graalvm
langm list
langm use
```

## 更多信息

https://github.com/user/langm
"@
$readmeContent | Out-File -FilePath "$tempDir\README.txt" -Encoding UTF8

# 压缩
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force
Remove-Item -Recurse -Force $tempDir
$zipSize = (Get-Item $zipPath).Length / 1KB
Write-Host "       ZIP size: $([math]::Round($zipSize, 0)) KB" -ForegroundColor Gray

# 计算 SHA256 哈希
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output files in dist/:" -ForegroundColor White
Get-ChildItem $distDir | ForEach-Object {
    $size = [math]::Round($_.Length / 1KB, 0)
    $hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLower()
    Write-Host "  - $($_.Name)" -ForegroundColor Gray
    Write-Host "    Size: $size KB" -ForegroundColor DarkGray
    Write-Host "    SHA256: $hash" -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  .\scripts\build-release.ps1" -ForegroundColor Gray
Write-Host "  .\scripts\build-release.ps1 -WixBinPath 'C:\wix314\bin'" -ForegroundColor Gray
Write-Host "  .\scripts\build-release.ps1 -SkipMsi" -ForegroundColor Gray
Write-Host ""
