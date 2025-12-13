# 能力系统

LangM 的核心创新是"能力"(Capability) 概念。

## 为什么需要能力？

传统的版本管理器（如 nvm、sdkman）把每种语言独立管理：

```
nvm use 20        # 切换 Node
sdk use java 21   # 切换 Java
```

但 GraalVM 同时包含 Java 和 Node.js。用传统工具管理时：
- 要么只能当 Java 用
- 要么只能当 Node 用
- 无法同时利用两种能力

## 能力模型

LangM 将运行时视为"能力"的集合：

| 运行时 | 能力 |
|--------|------|
| GraalVM | `java`, `node` |
| OpenJDK | `java` |
| Node.js | `node` |
| Deno | `deno` (未来支持) |

## 能力检测

LangM 通过检查 `bin/` 目录下的可执行文件来检测能力：

| 文件 | 能力 |
|------|------|
| `bin/java` | `java` |
| `bin/node` | `node` |

## 按能力筛选

### 列出运行时

```bash
# 所有运行时
langm list

# 只看 Node 运行时
langm list node

# 只看 Java 运行时
langm list java
```

### 切换运行时

```bash
# 从所有运行时中选择
langm use

# 只从 Node 运行时中选择
langm use node

# 只从 Java 运行时中选择
langm use java
```

## 实际场景

### 场景 1: 统一使用 GraalVM

```bash
langm add /opt/graalvm-21
langm use
```

现在 `java` 和 `node` 命令都指向 GraalVM。

### 场景 2: Java 用 GraalVM，Node 用原生

这种场景下，你需要选择一个主运行时。LangM 的设计是"一个 current"，不支持分别设置。

如果需要这种灵活性，建议：
- 使用 GraalVM 作为主运行时
- 或者使用传统的 nvm + sdkman 组合

### 场景 3: 多版本切换

```bash
langm add /opt/graalvm-21
langm add /opt/graalvm-22
langm add /opt/node-20
langm add /opt/jdk-17

# 切换到 GraalVM 22
langm use
# 选择 graalvm-22

# 只想换 Node 版本？筛选后选择
langm use node
```

## 未来计划

- 支持更多能力类型 (Python, Ruby, Deno 等)
- 能力别名 (如 `js` → `node`)
- 自定义能力检测规则
