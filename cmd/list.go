package cmd

import (
	"fmt"
	"os"

	"langm/internal/config"

	"github.com/spf13/cobra"
)

var listCmd = &cobra.Command{
	Use:   "list [node|java]",
	Short: "列出已注册的运行时",
	Long: `列出所有已注册的运行时，按语言分组显示。

示例:
  langm list        列出所有运行时
  langm list node   只列出 node 运行时
  langm list java   只列出 java 运行时`,
	Aliases: []string{"ls"},
	Args:    cobra.MaximumNArgs(1),
	Run:     runList,
}

func init() {
	rootCmd.AddCommand(listCmd)
}

// groupByCapability 按能力分组运行时
func groupByCapability(runtimes []config.Runtime) map[string][]config.Runtime {
	groups := make(map[string][]config.Runtime)
	for _, rt := range runtimes {
		for _, cap := range rt.Capabilities {
			groups[cap] = append(groups[cap], rt)
		}
	}
	return groups
}

func runList(cmd *cobra.Command, args []string) {
	cfg, err := config.Load()
	if err != nil {
		fmt.Fprintf(os.Stderr, "错误: %v\n", err)
		os.Exit(1)
	}

	var runtimes []config.Runtime
	var filterCap string

	if len(args) > 0 {
		filterCap = args[0]
		if filterCap != "node" && filterCap != "java" {
			fmt.Fprintf(os.Stderr, "错误: 未知的能力类型 '%s'，支持 node 或 java\n", filterCap)
			os.Exit(1)
		}
		runtimes = cfg.GetRuntimesByCapability(filterCap)
	} else {
		runtimes = cfg.GetRuntimes()
	}

	if len(runtimes) == 0 {
		fmt.Println("没有注册任何运行时")
		fmt.Println("使用 langm add <路径> 添加运行时")
		return
	}

	current := cfg.Current

	// 如果指定了过滤能力，直接列出
	if filterCap != "" {
		fmt.Printf("%s:\n", filterCap)
		for _, rt := range runtimes {
			marker := ""
			if rt.Name == current {
				marker = " *"
			}
			fmt.Printf("  %s%s\n", rt.Name, marker)
			fmt.Printf("    %s\n", rt.Path)
		}
		return
	}

	// 按能力分组显示
	groups := groupByCapability(runtimes)
	for cap, capRuntimes := range groups {
		fmt.Printf("%s:\n", cap)
		for _, rt := range capRuntimes {
			marker := ""
			if rt.Name == current {
				marker = " *"
			}
			fmt.Printf("  %s%s\n", rt.Name, marker)
			fmt.Printf("    %s\n", rt.Path)
		}
	}
}
