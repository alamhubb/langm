# 设计文档

## 概述

LangM 是一个基于 **Rust** 构建的多语言运行时管理器，采用"注册式"而非"托管式"管理模式。核心创新点是"基于能力的智能切换"——一个 GraalVM 目录可以同时作为 Java 和 Node 运行时使用。

### 设计目标

1. **零侵入**: 不移动用户文件，只记录路径引用
2. **智能识别**: 自动检测运行时能力（node/java）
3. **灵活切换**: 支持按能力筛选和交互式选择
4. **简单持久**: JSON 配置文件，可手动编辑
5. **轻量分发**: 单文件 exe，约 3-5MB

### 技术选型

- **语言**: Rust 1.70+
- **CLI 框架**: clap（业界标准）
- **交互式选择**: dialoguer
- **JSON 序列化**: serde + serde_json
- **编译目标**: Windows amd64

## 架构

```
┌─────────────────────────────────────────────────────────┐
│                      CLI 入口                            │
│                    (main.rs)                            │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │   add   │  │  list   │  │   use   │
   │commands │  │commands │  │commands │
   └────┬────┘  └────┬────┘  └────┬────┘
        │            │            │
        └─────────────┼─────────────┘
                      ▼
        ┌─────────────────────────────┐
        │        核心服务层            │
        │  ┌───────────────────────┐  │
        │  │      detector.rs      │  │
        │  │      (能力检测)        │  │
        │  └───────────────────────┘  │
        │  ┌───────────────────────┐  │
        │  │      config.rs        │  │
        │  │      (配置管理)        │  │
        │  └───────────────────────┘  │
        │  ┌───────────────────────┐  │
        │  │      symlink.rs       │  │
        │  │      (软链接管理)      │  │
        │  └───────────────────────┘  │
        └─────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │     ~/.langm/               │
        │  ├── config.json            │
        │  └── current -> 目标目录    │
        └─────────────────────────────┘
```

## 项目结构

```
langm/
├── Cargo.toml              # Rust 项目配置
├── Cargo.lock              # 依赖锁定
└── rust-src/
    ├── main.rs             # 入口 + CLI 定义
    ├── config.rs           # 配置管理
    ├── detector.rs         # 能力检测
    └── symlink.rs          # 软链接管理
```

## 命令行接口

### add 命令

注册运行时目录到 LangM。

```
langm add <路径> [选项]

选项:
  -n, --node    指定为 node 能力
  -j, --java    指定为 java 能力
  -h, --help    显示帮助信息
```

**示例:**
```bash
langm add D:\soft\node-v20           # 自动检测能力
langm add D:\soft\node-v20 -n        # 手动指定为 node（简写）
langm add D:\soft\node-v20 --node    # 手动指定为 node（完整）
langm add D:\soft\jdk-17 -j          # 手动指定为 java
langm add D:\soft\graalvm -n -j      # 同时指定 node 和 java
```

### list 命令

列出已注册的运行时。

```
langm list [能力]
langm ls [能力]              # 别名

参数:
  能力    可选，按能力过滤 (node/java)
```

**示例:**
```bash
langm list                   # 列出所有运行时
langm list node              # 只列出 node 运行时
langm ls java                # 只列出 java 运行时
```

### use 命令

切换运行时。

```
langm use [能力]

参数:
  能力    可选，按能力过滤 (node/java)
```

**示例:**
```bash
langm use                    # 选择任意运行时
langm use node               # 选择 node 运行时
langm use java               # 选择 java 运行时
```

## 组件与接口

### 1. Detector (能力检测器)

负责扫描目录并检测运行时能力。

```rust
// detector.rs

/// 检测目录的能力
pub fn detect(path: &Path) -> Vec<String>

/// 检查目录是否存在
pub fn directory_exists(path: &Path) -> bool
```

**检测逻辑:**
- 检查 `bin/node.exe` 存在 → 添加 `node` 能力
- 检查 `bin/java.exe` 存在 → 添加 `java` 能力
- 两者都不存在 → 返回空数组（需用户手动指定）

### 2. Config (配置管理器)

负责配置文件的读写操作。

```rust
// config.rs

#[derive(Serialize, Deserialize)]
pub struct Config {
    pub current: Option<String>,
    pub runtimes: Vec<Runtime>,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Runtime {
    pub name: String,
    pub path: String,
    pub capabilities: Vec<String>,
}

impl Config {
    /// 加载配置文件
    pub fn load() -> Result<Self, Error>
    
    /// 保存配置文件
    pub fn save(&self) -> Result<(), Error>
    
    /// 添加运行时
    pub fn add_runtime(&mut self, rt: Runtime) -> Result<(), Error>
    
    /// 按能力过滤运行时
    pub fn get_runtimes_by_capability(&self, cap: &str) -> Vec<&Runtime>
}
```

### 3. Symlink (软链接管理器)

负责创建和管理软链接。

```rust
// symlink.rs

/// 切换当前运行时（创建/替换软链接）
pub fn switch_to(target_path: &Path) -> Result<(), Error>

/// 获取当前激活的路径
pub fn get_current() -> Result<Option<PathBuf>, Error>
```

## 数据模型

### Config (配置文件结构)

```rust
#[derive(Serialize, Deserialize)]
pub struct Config {
    pub current: Option<String>,  // 当前激活的运行时名称
    pub runtimes: Vec<Runtime>,   // 所有已注册的运行时
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Runtime {
    pub name: String,             // 运行时名称
    pub path: String,             // 运行时目录路径
    pub capabilities: Vec<String>, // 能力列表
}
```

### 配置文件示例 (~/.langm/config.json)

```json
{
  "current": "graalvm-25",
  "runtimes": [
    {
      "name": "graalvm-25",
      "path": "D:\\soft\\graalvm-jdk-25",
      "capabilities": ["node", "java"]
    },
    {
      "name": "node-20",
      "path": "D:\\soft\\node-v20",
      "capabilities": ["node"]
    },
    {
      "name": "jdk-17",
      "path": "D:\\soft\\jdk-17",
      "capabilities": ["java"]
    }
  ]
}
```

## 正确性属性

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: 能力检测一致性
*For any* 目录路径，如果该目录包含 `bin/node.exe`，则检测结果必须包含 `node` 能力；如果包含 `bin/java.exe`，则必须包含 `java` 能力；如果两者都包含，则必须同时包含两种能力。
**Validates: Requirements 1.6, 1.7, 1.8**

### Property 2: 手动指定能力参数顺序无关性
*For any* 有效路径和能力类型，`langm add <路径> -<能力>` 和 `langm add -<能力> <路径>` 应产生相同的注册结果。
**Validates: Requirements 1.4, 1.5**

### Property 3: 配置往返一致性
*For any* 有效的 Config 对象，保存到文件后再加载，应得到等价的 Config 对象。
**Validates: Requirements 4.3**

### Property 4: 能力过滤正确性
*For any* 运行时列表和能力类型，按该能力过滤后的结果应只包含具有该能力的运行时，且不遗漏任何具有该能力的运行时。
**Validates: Requirements 2.3, 2.4, 3.2, 3.3**

### Property 5: 软链接切换正确性
*For any* 已注册的运行时，切换到该运行时后，`~/.langm/current` 软链接应指向该运行时的目录路径。
**Validates: Requirements 3.4**

## 错误处理

| 错误场景 | 处理方式 |
|---------|---------|
| 目录不存在 | 显示错误信息，拒绝注册 |
| 无法识别能力 | 提示用户使用 `--node/-n` 或 `--java/-j` 手动指定 |
| 软链接权限不足 | 提示开启开发者模式或以管理员身份运行 |
| 配置文件损坏 | 显示错误信息 |
| 配置文件不存在 | 自动创建默认空配置 |

## 测试策略

### 单元测试

使用 Rust 内置测试框架 (`cargo test`)：

- **detector**: 测试各种目录结构的能力检测
- **config**: 测试配置的读写操作
- **symlink**: 测试软链接的创建和切换

### 属性测试

使用 `proptest` 库进行属性测试：

- 每个属性测试运行至少 100 次迭代
- 测试注释格式: `**Feature: langm, Property {number}: {property_text}**`

**测试重点:**
1. 能力检测的一致性（Property 1）
2. 参数顺序无关性（Property 2）
3. 配置往返一致性（Property 3）
4. 能力过滤正确性（Property 4）
5. 软链接切换正确性（Property 5）

## 构建与分发

### 编译命令

```bash
# Release 编译（优化体积）
cargo build --release

# 进一步优化（在 Cargo.toml 中配置）
[profile.release]
opt-level = "z"     # 优化体积
lto = true          # 链接时优化
codegen-units = 1   # 单代码生成单元
panic = "abort"     # 精简 panic 处理
strip = true        # 去除符号
```

### 预期体积

- 编译后: ~0.5 MB (450KB)
- 比 Go 版本 (4.6MB) 小 10 倍
- 比 Bun 版本 (110MB) 小 244 倍
