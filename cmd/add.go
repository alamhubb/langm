package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"langm/internal/config"
	"langm/internal/detector"

	"github.com/spf13/cobra"
)

var (
	addNodeFlag bool
	addJavaFlag bool
)

var addCmd = &cobra.Command{
	Use:   "add <路径>",
	Short: "注册运行时目录",
	Long: `将本地运行时目录注册到 LangM。

示例:
  langm add D:\soft\node-v20           自动检测并注册
  langm add D:\soft\graalvm-25 -java   手动指定为 java
  langm add -node D:\soft\node-v20     手动指定为 node`,
	Args: cobra.ExactArgs(1),
	Run:  runAdd,
}

func init() {
	addCmd.Flags().BoolVarP(&addNodeFlag, "node", "n", false, "指定为 node 能力")
	addCmd.Flags().BoolVarP(&addJavaFlag, "java", "j", false, "指定为 java 能力")
	rootCmd.AddCommand(addCmd)
}

func runAdd(cmd *cobra.Command, args []string) {
	dirPath, err := filepath.Abs(args[0])
	if err != nil {
		fmt.Fprintf(os.Stderr, "错误: 无效的路径 - %s\n", args[0])
		os.Exit(1)
	}

	// 检查目录是否存在
	if !detector.DirectoryExists(dirPath) {
		fmt.Fprintf(os.Stderr, "错误: 目录不存在 - %s\n", dirPath)
		os.Exit(1)
	}


	// 确定能力
	var capabilities []string

	if addNodeFlag || addJavaFlag {
		// 用户手动指定了能力
		if addNodeFlag {
			capabilities = append(capabilities, "node")
		}
		if addJavaFlag {
			capabilities = append(capabilities, "java")
		}
	} else {
		// 自动检测能力
		capabilities, err = detector.Detect(dirPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "错误: 检测能力失败 - %v\n", err)
			os.Exit(1)
		}

		if len(capabilities) == 0 {
			fmt.Fprintln(os.Stderr, "错误: 无法自动识别运行时类型")
			fmt.Fprintln(os.Stderr, "该目录下未找到 bin/node.exe 或 bin/java.exe")
			fmt.Fprintln(os.Stderr, "请使用 -node 或 -java 手动指定类型:")
			fmt.Fprintf(os.Stderr, "  langm add %s -node\n", dirPath)
			fmt.Fprintf(os.Stderr, "  langm add %s -java\n", dirPath)
			os.Exit(1)
		}
	}

	// 生成运行时名称（基于目录名）
	name := filepath.Base(dirPath)

	// 加载配置并添加
	cfg, err := config.Load()
	if err != nil {
		fmt.Fprintf(os.Stderr, "错误: %v\n", err)
		os.Exit(1)
	}

	rt := config.Runtime{
		Name:         name,
		Path:         dirPath,
		Capabilities: capabilities,
	}

	if err := cfg.AddRuntime(rt); err != nil {
		fmt.Fprintf(os.Stderr, "错误: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("✓ 已注册运行时: %s\n", name)
	fmt.Printf("  路径: %s\n", dirPath)
	fmt.Printf("  能力: %v\n", capabilities)
}
