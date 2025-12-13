---
layout: home

hero:
  name: LangM
  text: 多语言运行时管理器
  tagline: 一个 GraalVM，同时作为 Java 和 Node 使用
  actions:
    - theme: brand
      text: 快速开始
      link: /guide/getting-started
    - theme: alt
      text: GitHub
      link: https://github.com/user/langm

features:
  - icon: 🚀
    title: 基于能力
    details: 一个运行时可以同时具备多种能力。GraalVM 既是 Java 也是 Node。
  - icon: ⚡
    title: 极速切换
    details: 通过软链接实现毫秒级运行时切换，无需修改环境变量。
  - icon: 🎯
    title: 自动检测
    details: 自动识别运行时类型，也支持手动指定能力。
  - icon: 💻
    title: 跨平台
    details: 支持 Windows、Linux、macOS，一键安装。
---

## 快速安装

::: code-group

```sh [Linux / macOS]
curl -fsSL https://raw.githubusercontent.com/user/langm/main/scripts/install.sh | bash
```

```powershell [Windows]
# 下载并运行 MSI 安装包
# https://github.com/user/langm/releases
```

:::

## 快速开始

```bash
# 添加运行时
langm add /path/to/graalvm

# 查看已添加的运行时
langm list

# 交互式切换
langm use

# 按能力筛选
langm use node
langm use java
```
