# 安装

## Linux / macOS

### 一键安装 (推荐)

```bash
curl -fsSL https://raw.githubusercontent.com/user/langm/main/scripts/install.sh | bash
```

脚本会自动：
- 检测操作系统和架构
- 下载对应版本
- 安装到 `/usr/local/bin`

::: tip 为什么使用 bash？
我们使用 `| bash` 而不是 `| sh`，因为：
- `bash` 在 Linux 和 macOS 上行为一致
- `sh` 在不同系统可能是不同实现（Ubuntu 用 dash，Alpine 用 ash）
- 与 nvm、bun、rustup 等主流工具保持一致
:::

### 手动安装

1. 从 [Releases](https://github.com/user/langm/releases) 下载对应版本

2. 解压并安装
```bash
tar -xzf langm-0.1.0-linux-x64.tar.gz
sudo mv langm /usr/local/bin/
```

3. 配置 PATH

在 `~/.bashrc` 或 `~/.zshrc` 中添加：
```bash
export PATH="$HOME/.langm/current/bin:$PATH"
```

然后重新加载：
```bash
source ~/.bashrc
```

## Windows

### MSI 安装包 (推荐)

1. 从 [Releases](https://github.com/user/langm/releases) 下载 `langm-x.x.x-x86_64.msi`
2. 双击运行安装
3. 安装程序会自动配置 PATH

### 便携版

1. 下载 `langm-x.x.x-windows-x64.zip`
2. 解压到任意目录
3. 将目录添加到系统 PATH
4. 将 `%USERPROFILE%\.langm\current\bin` 添加到 PATH

### Scoop

```powershell
scoop bucket add langm https://github.com/user/scoop-langm
scoop install langm
```

## 验证安装

```bash
langm --version
```

## 下载链接

| 平台 | 架构 | 下载 |
|------|------|------|
| Windows | x64 | [MSI](https://github.com/user/langm/releases) / [ZIP](https://github.com/user/langm/releases) |
| Linux | x64 | [tar.gz](https://github.com/user/langm/releases) |
| Linux | arm64 | [tar.gz](https://github.com/user/langm/releases) |
| macOS | x64 (Intel) | [tar.gz](https://github.com/user/langm/releases) |
| macOS | arm64 (Apple Silicon) | [tar.gz](https://github.com/user/langm/releases) |
