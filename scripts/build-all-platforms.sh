#!/bin/bash
# LangM Cross-Platform Build Script
# 构建 Linux 和 macOS 版本

set -e

VERSION="${1:-0.1.0}"
DIST_DIR="dist"

echo "========================================"
echo "  LangM Cross-Platform Build v$VERSION"
echo "========================================"
echo ""

# 创建 dist 目录
mkdir -p "$DIST_DIR"

# 定义目标平台
TARGETS=(
    "x86_64-unknown-linux-gnu:linux-x64"
    "x86_64-unknown-linux-musl:linux-x64-musl"
    "aarch64-unknown-linux-gnu:linux-arm64"
    "x86_64-apple-darwin:macos-x64"
    "aarch64-apple-darwin:macos-arm64"
)

build_target() {
    local target=$1
    local name=$2
    
    echo "[BUILD] $target -> $name"
    
    # 检查是否安装了目标
    if ! rustup target list --installed | grep -q "$target"; then
        echo "  Installing target $target..."
        rustup target add "$target"
    fi
    
    # 编译
    cargo build --release --target "$target"
    
    # 打包
    local bin_path="target/$target/release/langm"
    local tar_name="langm-$VERSION-$name.tar.gz"
    local temp_dir="$DIST_DIR/langm-$VERSION"
    
    mkdir -p "$temp_dir"
    cp "$bin_path" "$temp_dir/langm"
    chmod +x "$temp_dir/langm"
    
    # 创建 README
    cat > "$temp_dir/README.txt" << EOF
# LangM v$VERSION

基于能力的多语言运行时管理器

## 安装

1. 将 langm 复制到 /usr/local/bin 或 ~/.local/bin
2. 添加 ~/.langm/current/bin 到 PATH

   在 ~/.bashrc 或 ~/.zshrc 中添加:
   export PATH="\$HOME/.langm/current/bin:\$PATH"

## 快速开始

langm add /path/to/graalvm
langm list
langm use

## 更多信息

https://github.com/user/langm
EOF
    
    # 压缩
    tar -czf "$DIST_DIR/$tar_name" -C "$DIST_DIR" "langm-$VERSION"
    rm -rf "$temp_dir"
    
    local size=$(du -h "$DIST_DIR/$tar_name" | cut -f1)
    echo "  Created: $tar_name ($size)"
}

# 检测当前平台并构建
CURRENT_OS=$(uname -s)
CURRENT_ARCH=$(uname -m)

echo "Current platform: $CURRENT_OS $CURRENT_ARCH"
echo ""

# 本地构建
if [[ "$CURRENT_OS" == "Linux" ]]; then
    if [[ "$CURRENT_ARCH" == "x86_64" ]]; then
        build_target "x86_64-unknown-linux-gnu" "linux-x64"
    elif [[ "$CURRENT_ARCH" == "aarch64" ]]; then
        build_target "aarch64-unknown-linux-gnu" "linux-arm64"
    fi
elif [[ "$CURRENT_OS" == "Darwin" ]]; then
    if [[ "$CURRENT_ARCH" == "x86_64" ]]; then
        build_target "x86_64-apple-darwin" "macos-x64"
    elif [[ "$CURRENT_ARCH" == "arm64" ]]; then
        build_target "aarch64-apple-darwin" "macos-arm64"
    fi
fi

echo ""
echo "========================================"
echo "  Build Complete!"
echo "========================================"
echo ""
echo "Output files in $DIST_DIR/:"
ls -lh "$DIST_DIR"/*.tar.gz 2>/dev/null || echo "  (no files)"
echo ""
