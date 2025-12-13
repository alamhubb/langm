# 添加运行时

使用 `langm add` 命令注册运行时目录。

## 基本用法

```bash
langm add <路径>
```

## 自动检测

LangM 会自动扫描目录，检测运行时能力：

```bash
langm add /opt/graalvm-21
```

检测逻辑：
- 存在 `bin/java` (或 Windows 上的 `bin/java.exe`) → 具备 `java` 能力
- 存在 `bin/node` (或 Windows 上的 `bin/node.exe`) → 具备 `node` 能力

输出示例：
```
✓ 已注册运行时: graalvm-21
  路径: /opt/graalvm-21
  能力: ["java", "node"]
```

## 手动指定能力

如果自动检测失败，可以手动指定：

```bash
# 指定为 Node 运行时
langm add /path/to/runtime --node
langm add /path/to/runtime -n

# 指定为 Java 运行时
langm add /path/to/runtime --java
langm add /path/to/runtime -j

# 同时指定多个能力
langm add /path/to/runtime --node --java
langm add /path/to/runtime -n -j
```

## 运行时命名

运行时名称自动取自目录名：

```bash
langm add /opt/graalvm-21      # 名称: graalvm-21
langm add /opt/node-20.10.0    # 名称: node-20.10.0
langm add /opt/jdk-17          # 名称: jdk-17
```

## 常见运行时

### GraalVM

```bash
langm add /opt/graalvm-jdk-21
# 能力: java, node
```

### OpenJDK

```bash
langm add /opt/jdk-21
# 能力: java
```

### Node.js

```bash
langm add /opt/node-20
# 能力: node
```

### 自定义运行时

```bash
langm add /path/to/custom --node --java
```
