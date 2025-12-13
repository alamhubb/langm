# 实现计划 (Rust 版本)

- [x] 1. 项目初始化和基础结构
  - [x] 1.1 初始化 Rust 项目
    - 创建 `Cargo.toml`，配置依赖
    - 添加依赖: `clap`（CLI 框架）、`dialoguer`（交互式选择）、`serde` + `serde_json`（JSON）、`dirs`（用户目录）
    - 配置 release profile 优化体积
    - 创建 `rust-src/` 目录结构
    - _Requirements: 4.1_

- [x] 2. 核心服务: config
  - [x] 2.1 实现 config 配置管理模块
    - 实现 `Config::load()`: 从 `~/.langm/config.json` 加载配置
    - 实现 `Config::save()`: 保存配置到文件
    - 实现 `Config::add_runtime()`: 添加运行时
    - 实现 `Config::get_runtimes()`: 获取所有运行时
    - 实现 `Config::get_runtimes_by_capability()`: 按能力过滤运行时
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 3. 核心服务: detector
  - [x] 3.1 实现 detector 能力检测模块
    - 实现 `detect()`: 扫描目录检测 `bin/node.exe` 和 `bin/java.exe`
    - 实现 `directory_exists()`: 检查目录是否存在
    - 返回检测到的能力列表
    - _Requirements: 1.6, 1.7, 1.8_

- [x] 4. 核心服务: symlink
  - [x] 4.1 实现 symlink 软链接管理模块
    - 实现 `switch_to()`: 创建/替换 `~/.langm/current` 软链接
    - 实现 `get_current()`: 获取当前激活的路径
    - 处理权限错误，提示用户
    - _Requirements: 3.4, 3.6_

- [x] 5. 命令实现: add
  - [x] 5.1 实现 add 命令
    - 使用 clap 定义命令和参数
    - 解析参数: `langm add <路径>` 或 `langm add <路径> --node/--java`
    - 支持简写: `-n` (node), `-j` (java)
    - 调用 detector 检测能力（如未手动指定）
    - 自动生成运行时名称（基于目录名）
    - 调用 config 保存
    - 处理错误: 目录不存在、无法识别能力
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.9_

- [x] 6. 命令实现: list
  - [x] 6.1 实现 list 命令
    - 使用 clap 定义命令
    - 支持别名 `ls`
    - 解析参数: `langm list` 或 `langm list node/java`
    - 调用 config 获取运行时列表
    - 按能力过滤（如指定）
    - 按语言分组，缩进格式输出
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 7. 命令实现: use
  - [x] 7.1 实现 use 命令
    - 使用 clap 定义命令
    - 解析参数: `langm use` 或 `langm use node/java`
    - 调用 config 获取运行时列表
    - 按能力过滤（如指定）
    - 使用 dialoguer 库显示交互式选择菜单
    - 调用 symlink 切换软链接
    - 更新 config 中的 current
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 8. CLI 入口整合
  - [x] 8.1 实现 CLI 入口
    - 在 `main.rs` 中使用 clap 定义根命令
    - 注册 add、list、use 子命令
    - 添加 --help 和 --version 支持
    - _Requirements: 1.1, 2.1, 3.1_

- [x] 9. 构建与测试
  - [x] 9.1 编译并测试
    - 运行 `cargo build --release` 编译
    - 测试各命令功能
    - 验证 exe 体积: **458 KB** ✓
    - _Requirements: 全部_

---

## 分发与打包

- [x] 10. MSI 安装包
  - [x] 10.1 配置 WiX Toolset
    - 安装 `cargo-wix`
    - 运行 `cargo wix init` 生成 `wix/main.wxs`
    - 配置 Cargo.toml 添加 WiX 元数据
  - [x] 10.2 构建 MSI 安装包
    - 下载 WiX 3.14 便携版
    - 运行 `cargo wix` 生成 MSI
    - 输出: `target/wix/langm-0.1.0-x86_64.msi` (512 KB)

- [x] 11. ZIP 便携版
  - [x] 11.1 创建 ZIP 打包脚本
    - 将 `langm.exe` 打包为 `langm-0.1.0-windows-x64.zip`
    - 包含 README 说明文件
  - [x] 11.2 输出到 `dist/` 目录

- [x] 12. 一键构建脚本
  - [x] 12.1 创建 `scripts/build-release.ps1`
    - 编译 Release 版本
    - 生成 MSI 安装包 (支持 `-WixBinPath` 参数)
    - 生成 ZIP 便携版
    - 输出所有文件到 `dist/` 目录
    - 显示 SHA256 哈希值

- [x] 13. Scoop Manifest
  - [x] 13.1 创建 `scoop/langm.json`
    - 配置下载地址、hash、bin 路径
    - 支持 `scoop install langm`

- [x] 14. GitHub Release 准备
  - [x] 14.1 创建 `RELEASE.md` 说明模板
    - 版本号、功能特性
    - 下载说明
  - [x] 14.2 准备发布文件清单
    - `langm-0.1.0-x86_64.msi` - 安装包 (512 KB)
    - `langm-0.1.0-windows-x64.zip` - 便携版 (232 KB)

---

---

## 跨平台支持

- [x] 15. 跨平台代码修改
  - [x] 15.1 修改 detector.rs
    - 使用 `cfg!(windows)` 判断平台
    - Windows: `bin/node.exe`, `bin/java.exe`
    - Linux/macOS: `bin/node`, `bin/java`
  - [x] 15.2 修改 symlink.rs
    - Windows: `std::os::windows::fs::symlink_dir`
    - Unix: `std::os::unix::fs::symlink`
  - [x] 15.3 修改提示信息
    - 根据平台显示不同的 PATH 配置提示

- [x] 16. 跨平台构建
  - [x] 16.1 创建 `scripts/build-all-platforms.sh`
    - Linux/macOS 本地构建脚本
  - [x] 16.2 创建 `.github/workflows/release.yml`
    - GitHub Actions 自动构建所有平台
    - Windows x64
    - Linux x64, x64-musl, arm64
    - macOS x64, arm64

- [x] 17. 一键安装脚本
  - [x] 17.1 创建 `scripts/install.sh`
    - 自动检测 OS (Linux/macOS)
    - 自动检测架构 (x64/arm64)
    - 下载对应版本
    - 安装到 /usr/local/bin
    - 提示配置 PATH

---

## 完成状态

✅ **全部完成**

### 最终产物

**Windows:**
- `langm-0.1.0-x86_64.msi` - MSI 安装包
- `langm-0.1.0-windows-x64.zip` - 便携版

**Linux:**
- `langm-0.1.0-linux-x64.tar.gz`
- `langm-0.1.0-linux-x64-musl.tar.gz`
- `langm-0.1.0-linux-arm64.tar.gz`

**macOS:**
- `langm-0.1.0-macos-x64.tar.gz`
- `langm-0.1.0-macos-arm64.tar.gz`

### 构建方式

```powershell
# Windows 本地构建
.\scripts\build-release.ps1 -SkipMsi

# Linux/macOS 本地构建
./scripts/build-all-platforms.sh

# GitHub Actions 自动构建
# 推送 tag 触发: git tag v0.1.0 && git push --tags
```
