#!/bin/bash
# LangM 一键安装脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/user/langm/main/scripts/install.sh | bash
#
# 为什么使用 bash 而不是 sh？
# - bash 在 Linux 和 macOS 上行为一致
# - sh 在不同系统可能是不同实现 (dash/ash/bash)
# - bash 提供更好的错误处理和字符串操作
# - 与 nvm、bun、rustup 等主流工具保持一致

set -e

REPO="user/langm"
VERSION="${LANGM_VERSION:-latest}"
INSTALL_DIR="${LANGM_INSTALL_DIR:-/usr/local/bin}"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       error "不支持的操作系统: $(uname -s)" ;;
    esac
}

# 检测架构
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)  echo "x64" ;;
        aarch64|arm64) echo "arm64" ;;
        *)             error "不支持的架构: $(uname -m)" ;;
    esac
}

# 获取最新版本
get_latest_version() {
    curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | \
        grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/'
}

# 主安装流程
main() {
    echo ""
    echo "  _                       __  __ "
    echo " | |    __ _ _ __   __ _|  \/  |"
    echo " | |   / _\` | '_ \ / _\` | |\/| |"
    echo " | |__| (_| | | | | (_| | |  | |"
    echo " |_____\__,_|_| |_|\__, |_|  |_|"
    echo "                   |___/        "
    echo ""
    echo " 多语言运行时管理器"
    echo ""

    OS=$(detect_os)
    ARCH=$(detect_arch)
    
    info "检测到系统: $OS-$ARCH"

    # 获取版本
    if [ "$VERSION" = "latest" ]; then
        info "获取最新版本..."
        VERSION=$(get_latest_version)
        if [ -z "$VERSION" ]; then
            error "无法获取最新版本"
        fi
    fi
    info "安装版本: v$VERSION"

    # 构建下载 URL
    FILENAME="langm-${VERSION}-${OS}-${ARCH}.tar.gz"
    URL="https://github.com/${REPO}/releases/download/v${VERSION}/${FILENAME}"

    # 创建临时目录
    TMP_DIR=$(mktemp -d)
    trap "rm -rf $TMP_DIR" EXIT

    # 下载
    info "下载 $FILENAME ..."
    if ! curl -fsSL "$URL" -o "$TMP_DIR/langm.tar.gz"; then
        error "下载失败: $URL"
    fi

    # 解压
    info "解压..."
    tar -xzf "$TMP_DIR/langm.tar.gz" -C "$TMP_DIR"

    # 安装
    info "安装到 $INSTALL_DIR ..."
    if [ -w "$INSTALL_DIR" ]; then
        mv "$TMP_DIR/langm" "$INSTALL_DIR/langm"
        chmod +x "$INSTALL_DIR/langm"
    else
        warn "需要 sudo 权限安装到 $INSTALL_DIR"
        sudo mv "$TMP_DIR/langm" "$INSTALL_DIR/langm"
        sudo chmod +x "$INSTALL_DIR/langm"
    fi

    # 验证安装
    if command -v langm &> /dev/null; then
        info "安装成功!"
        echo ""
        langm --version
    else
        warn "langm 已安装，但不在 PATH 中"
        warn "请将 $INSTALL_DIR 添加到 PATH"
    fi

    # 提示配置 PATH
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo " 下一步: 配置运行时路径"
    echo ""
    echo " 在 ~/.bashrc 或 ~/.zshrc 中添加:"
    echo ""
    echo "   export PATH=\"\$HOME/.langm/current/bin:\$PATH\""
    echo ""
    echo " 然后运行: source ~/.bashrc"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo " 快速开始:"
    echo "   langm add /path/to/graalvm"
    echo "   langm list"
    echo "   langm use"
    echo ""
}

main "$@"
