package symlink

import (
	"errors"
	"os"
	"path/filepath"
)

// GetLangmDir 获取 .langm 目录路径
func GetLangmDir() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".langm")
}

// GetCurrentLinkPath 获取 current 软链接路径
func GetCurrentLinkPath() string {
	return filepath.Join(GetLangmDir(), "current")
}

// SwitchTo 切换当前运行时（创建/替换软链接）
func SwitchTo(targetPath string) error {
	langmDir := GetLangmDir()
	if err := os.MkdirAll(langmDir, 0755); err != nil {
		return err
	}

	currentLink := GetCurrentLinkPath()

	// 尝试删除现有软链接
	if err := os.Remove(currentLink); err != nil && !os.IsNotExist(err) {
		// 如果是目录（junction），尝试删除目录
		os.RemoveAll(currentLink)
	}

	// 创建新的软链接（Windows 上使用 junction 不需要管理员权限）
	// Go 的 os.Symlink 在 Windows 上会自动处理
	if err := os.Symlink(targetPath, currentLink); err != nil {
		// 检查是否是权限错误
		if os.IsPermission(err) {
			return errors.New("创建软链接失败：权限不足。\n请尝试以下方法之一：\n1. 开启 Windows 开发者模式\n2. 以管理员身份运行终端")
		}
		return err
	}

	return nil
}

// GetCurrent 获取当前激活的运行时路径
func GetCurrent() (string, error) {
	currentLink := GetCurrentLinkPath()
	
	target, err := os.Readlink(currentLink)
	if err != nil {
		if os.IsNotExist(err) {
			return "", nil
		}
		return "", err
	}
	
	return target, nil
}

// Exists 检查软链接是否存在
func Exists() bool {
	_, err := os.Lstat(GetCurrentLinkPath())
	return err == nil
}
