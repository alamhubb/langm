# LangM 安装包构建指南

## 方案对比

| 方案 | 格式 | 优点 | 缺点 |
|------|------|------|------|
| **WiX Toolset** | MSI | Windows 官方格式，企业部署友好 | 需要安装 WiX 3.x |
| **Inno Setup** | EXE | 简单易用，功能完善 | 非官方格式 |

## 方案一：MSI 安装包 (推荐)

### 前置条件

1. 以管理员身份运行 PowerShell
2. 安装 WiX Toolset 3.x：
   ```powershell
   winget install WiXToolset.WiXToolset
   ```
3. 重新打开终端

### 构建命令

```bash
cargo wix
```

输出：`target/wix/langm-0.1.0-x86_64.msi`

## 方案二：EXE 安装包

### 前置条件

1. 下载安装 [Inno Setup 6](https://jrsoftware.org/isdl.php)

### 构建命令

双击运行 `installer/build.bat`

输出：`dist/LangM-Setup-0.1.0.exe`

## 安装包功能

两种方案都支持：
- ✅ 自动安装到 Program Files
- ✅ 自动添加 `langm` 到系统 PATH
- ✅ 自动添加 `~/.langm/current/bin` 到 PATH
- ✅ 卸载时自动清理

## 用户使用流程

1. 双击安装包
2. 按提示完成安装
3. **重新打开终端**
4. 输入 `langm --help` 验证

## 静默安装

MSI:
```powershell
msiexec /i langm-0.1.0-x86_64.msi /quiet
```

EXE (Inno Setup):
```powershell
LangM-Setup-0.1.0.exe /VERYSILENT /NORESTART
```
