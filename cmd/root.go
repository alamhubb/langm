package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var Version = "0.1.0"

var rootCmd = &cobra.Command{
	Use:   "langm",
	Short: "LangM - 多语言运行时管理器",
	Long: `LangM 是一个基于能力的多语言运行时管理器。
核心特点是智能切换——一个 GraalVM 可以同时作为 Java 和 Node 使用。

用最快的速度，在 Node.js、JDK 和 GraalVM 之间自由切换。`,
	Version: Version,
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.SetVersionTemplate("LangM v{{.Version}}\n")
}
