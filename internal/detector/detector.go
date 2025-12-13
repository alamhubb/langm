package detector

import (
	"os"
	"path/filepath"
)

// Capability 能力类型
type Capability string

const (
	CapNode Capability = "node"
	CapJava Capability = "java"
)

// Detect 检测目录的能力
func Detect(dirPath string) ([]string, error) {
	var capabilities []string

	// 检测 node 能力
	nodePath := filepath.Join(dirPath, "bin", "node.exe")
	if _, err := os.Stat(nodePath); err == nil {
		capabilities = append(capabilities, string(CapNode))
	}

	// 检测 java 能力
	javaPath := filepath.Join(dirPath, "bin", "java.exe")
	if _, err := os.Stat(javaPath); err == nil {
		capabilities = append(capabilities, string(CapJava))
	}

	return capabilities, nil
}

// DirectoryExists 检查目录是否存在
func DirectoryExists(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return info.IsDir()
}
