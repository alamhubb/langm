# 需求文档

## 简介

LangM 是一个基于 **Rust** 构建的多语言运行时管理器，专为 Windows 开发者设计。核心特点是"基于能力的智能切换"——一个 GraalVM 可以同时作为 Java 和 Node 使用。

一句话介绍："用最快的速度，在 Node.js、JDK 和 GraalVM 之间自由切换。"

## 术语表

- **LangM**: 本产品名称
- **运行时 (Runtime)**: 运行时环境，如 Node.js、JDK、GraalVM
- **能力 (Capability)**: 运行时提供的功能标签，如 `node`、`java`
- **混合运行时 (Hybrid)**: 同时提供多种能力的运行时，如 GraalVM
- **配置文件**: 存储在 `~/.langm/config.json`，记录所有已注册的运行时信息

## 需求

### 需求 1: 运行时注册

**用户故事:** 作为开发者，我希望将本地运行时目录注册到 LangM，以便管理现有安装而无需移动文件。

#### 验收标准

1. WHEN 用户执行 `langm add <路径>` THEN LangM SHALL 自动扫描目录检测能力并注册
2. WHEN 自动检测成功 THEN LangM SHALL 根据目录名自动生成运行时名称并注册
3. WHEN 自动检测无法识别能力 THEN LangM SHALL 显示错误信息提示用户手动指定语言类型
4. WHEN 用户执行 `langm add <路径> --node` 或 `langm add <路径> -n` THEN LangM SHALL 将该目录注册为 node 能力
5. WHEN 用户执行 `langm add <路径> --java` 或 `langm add <路径> -j` THEN LangM SHALL 将该目录注册为 java 能力
6. WHEN 用户执行 `langm add <路径> -n -j` THEN LangM SHALL 同时添加 node 和 java 能力
7. WHEN 目录包含 `bin/node.exe` THEN LangM SHALL 自动识别为 `node` 能力
8. WHEN 目录包含 `bin/java.exe` THEN LangM SHALL 自动识别为 `java` 能力
9. WHEN 目录同时包含 `bin/node.exe` 和 `bin/java.exe` THEN LangM SHALL 同时添加 `node` 和 `java` 能力
10. WHEN 用户尝试注册不存在的目录 THEN LangM SHALL 显示错误信息并拒绝注册

### 需求 2: 运行时列表

**用户故事:** 作为开发者，我希望查看所有已注册的运行时，以便了解可用环境。

#### 验收标准

1. WHEN 用户执行 `langm list` THEN LangM SHALL 按语言分组显示所有已注册运行时
2. WHEN 显示列表时 THEN LangM SHALL 使用缩进格式展示，语言作为分组标题，版本作为子项
3. WHEN 用户执行 `langm list node` THEN LangM SHALL 只显示具有 node 能力的运行时
4. WHEN 用户执行 `langm list java` THEN LangM SHALL 只显示具有 java 能力的运行时
5. WHEN 没有注册任何运行时 THEN LangM SHALL 显示提示信息

### 需求 3: 基于能力的环境切换

**用户故事:** 作为开发者，我希望通过能力切换环境（如 `langm use node`），以便看到所有提供该能力的运行时并选择一个。

#### 验收标准

1. WHEN 用户执行 `langm use` THEN LangM SHALL 按语言分组显示所有运行时并支持交互式选择
2. WHEN 用户执行 `langm use node` THEN LangM SHALL 筛选并显示所有具有 node 能力的运行时供选择
3. WHEN 用户执行 `langm use java` THEN LangM SHALL 筛选并显示所有具有 java 能力的运行时供选择
4. WHEN 用户从菜单选择运行时 THEN LangM SHALL 自动创建软链接 `~/.langm/current` 指向该运行时目录
5. WHEN 没有运行时提供该能力 THEN LangM SHALL 显示提示信息建议使用 `langm add`
6. WHEN 软链接创建因权限失败 THEN LangM SHALL 显示错误信息，建议开启开发者模式或以管理员身份运行

### 需求 4: 配置持久化

**用户故事:** 作为开发者，我希望 LangM 持久化我的配置，以便设置在终端会话和系统重启后保留。

#### 验收标准

1. WHEN LangM 启动时 THEN LangM SHALL 从 `~/.langm/config.json` 加载配置文件
2. WHEN 配置文件不存在 THEN LangM SHALL 创建包含默认空结构的新配置文件
3. WHEN 任何操作修改状态 THEN LangM SHALL 立即将更改持久化到配置文件
4. WHEN 配置文件损坏或无效 THEN LangM SHALL 显示错误信息
