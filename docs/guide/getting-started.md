# 快速开始

LangM 是一个基于能力的多语言运行时管理器。与传统的版本管理器不同，LangM 允许一个运行时同时具备多种能力。

## 核心概念

### 能力 (Capability)

传统工具把 Java 和 Node 当作完全独立的东西管理。但 GraalVM 既能运行 Java，也能运行 Node.js。

LangM 引入"能力"概念：
- 一个运行时可以有多个能力
- GraalVM = `java` + `node`
- OpenJDK = `java`
- Node.js = `node`

### 工作原理

```
~/.langm/
├── config.json      # 配置文件
└── current/         # 软链接 → 当前运行时
    └── bin/
        ├── java
        └── node
```

将 `~/.langm/current/bin` 添加到 PATH 后，切换运行时只需更新软链接，无需修改环境变量。

## 基本用法

### 1. 添加运行时

```bash
# 自动检测能力
langm add /path/to/graalvm

# 手动指定能力
langm add /path/to/custom-runtime --node --java
```

### 2. 查看运行时

```bash
# 列出所有
langm list

# 按能力筛选
langm list node
langm list java
```

### 3. 切换运行时

```bash
# 交互式选择
langm use

# 按能力筛选后选择
langm use node
```

## 下一步

- [安装指南](/guide/installation) - 详细安装说明
- [能力系统](/guide/capabilities) - 深入了解能力概念
