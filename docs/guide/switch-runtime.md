# 切换运行时

使用 `langm use` 命令切换当前使用的运行时。

## 交互式选择

```bash
langm use
```

显示所有已注册的运行时，使用方向键选择：

```
? 请选择要使用的运行时
> graalvm-21 (/opt/graalvm-21)
  node-20 (/opt/node-20)
  jdk-17 (/opt/jdk-17)
```

## 按能力筛选

只显示具有特定能力的运行时：

```bash
# 只显示 Node 运行时
langm use node

# 只显示 Java 运行时
langm use java
```

## 切换原理

切换运行时时，LangM 会更新 `~/.langm/current` 软链接：

```
~/.langm/current → /opt/graalvm-21
```

由于 `~/.langm/current/bin` 已在 PATH 中，切换后立即生效。

## 查看当前运行时

```bash
langm list
```

当前使用的运行时会标记 `*`：

```
java:
  graalvm-21 *
    /opt/graalvm-21
  jdk-17
    /opt/jdk-17
node:
  graalvm-21 *
    /opt/graalvm-21
  node-20
    /opt/node-20
```

## Windows 注意事项

Windows 上创建软链接需要：
- 开启开发者模式，或
- 以管理员身份运行终端

如果遇到权限错误，LangM 会提示解决方法。
