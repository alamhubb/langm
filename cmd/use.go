package cmd

import (
	"fmt"
	"os"

	"langm/internal/config"
	"langm/internal/symlink"

	"github.com/AlecAivazis/survey/v2"
	"github.com/spf13/cobra"
)

var useCmd = &cobra.Command{
	Use:   "use [node|java]",
	Short: "切换运行时",
	Long: `选择并切换到指定的运行时。

示例:
  langm use        选择任意运行时
  langm use node   选择 node 运行时
  langm use java   选择 java 运行时`,
	Args: cobra.MaximumNArgs(1),
	Run:  runUse,
}

func init() {
	rootCmd.AddCommand(useCmd)
}

func runUse(cmd *cobra.Command, args []string) {
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
		if filterCap != "" {
			fmt.Printf("没有找到具有 %s 能力的运行时\n", filterCap)
		} else {
			fmt.Println("没有注册任何运行时")
		}
		fmt.Println("使用 langm add <路径> 添加运行时")
		return
	}


	// 构建选择列表
	options := make([]string, len(runtimes))
	for i, rt := range runtimes {
		options[i] = fmt.Sprintf("%s (%s)", rt.Name, rt.Path)
	}

	// 显示交互式选择菜单
	var selectedIndex int
	prompt := &survey.Select{
		Message: "请选择要使用的运行时:",
		Options: options,
	}

	if err := survey.AskOne(prompt, &selectedIndex); err != nil {
		fmt.Println("已取消")
		return
	}

	selectedRuntime := runtimes[selectedIndex]

	// 切换软链接
	if err := symlink.SwitchTo(selectedRuntime.Path); err != nil {
		fmt.Fprintf(os.Stderr, "错误: %v\n", err)
		os.Exit(1)
	}

	// 更新配置
	if err := cfg.SetCurrent(selectedRuntime.Name); err != nil {
		fmt.Fprintf(os.Stderr, "错误: 更新配置失败 - %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("✓ 已切换到: %s\n", selectedRuntime.Name)
	fmt.Printf("  路径: %s\n", selectedRuntime.Path)
	fmt.Printf("  能力: %v\n", selectedRuntime.Capabilities)
	fmt.Println()
	fmt.Println("提示: 请确保 ~/.langm/current/bin 已添加到系统 PATH")
}
