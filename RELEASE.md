# LangM v0.1.0

基于能力的多语言运行时管理器 - 首个发布版本

## 功能特性

- 一个 GraalVM 可同时作为 Java 和 Node 运行时使用
- 自动检测运行时能力 (node/java)
- 交互式运行时切换
- 支持手动指定能力 (`-n`/`-j` 标志)
- 跨平台支持 (Windows/Linux/macOS)

## 下载

### Windows

- `langm-0.1.0-x86_64.msi` - 安装包 (推荐)
  - 自动配置 PATH 环境变量
  - 支持卸载
- `langm-0.1.0-windows-x64.zip` - 便携版

### Linux

- `langm-0.1.0-linux-x64.tar.gz` - x86_64
- `langm-0.1.0-linux-x64-musl.tar.gz` - x86_64 静态链接 (Alpine 等)
- `langm-0.1.0-linux-arm64.tar.gz` - ARM64

### macOS

- `langm-0.1.0-macos-x64.tar.gz` - Intel Mac
- `langm-0.1.0-macos-arm64.tar.gz` - Apple Silicon

## 安装

### Linux / macOS (一键安装)

```bash
curl -fsSL https://raw.githubusercontent.com/user/langm/main/scripts/install.sh | bash
```

自动检测系统架构，下载并安装到 `/usr/local/bin`。

### Windows (MSI)

运行 MSI 安装包，自动配置 PATH。

### Windows (ZIP)

1. 解压到任意目录
2. 将目录添加到 PATH
3. 将 `%USERPROFILE%\.langm\current\bin` 添加到 PATH

### Linux / macOS (手动)

```bash
# 解压
tar -xzf langm-0.1.0-linux-x64.tar.gz

# 移动到 bin 目录
sudo mv langm /usr/local/bin/

# 添加运行时路径到 PATH (在 ~/.bashrc 或 ~/.zshrc)
export PATH="$HOME/.langm/current/bin:$PATH"
```

## 快速开始

```bash
# 添加运行时
langm add /path/to/graalvm

# 查看已添加的运行时
langm list

# 切换运行时
langm use
```

## 包管理器安装

### Scoop (Windows)

```powershell
scoop bucket add langm https://github.com/user/scoop-langm
scoop install langm
```

### Homebrew (macOS/Linux) - 计划中

```bash
brew install langm
```
