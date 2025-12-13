package config

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
)

// Runtime 运行时配置
type Runtime struct {
	Name         string   `json:"name"`
	Path         string   `json:"path"`
	Capabilities []string `json:"capabilities"`
}

// Config 配置文件结构
type Config struct {
	Current  string    `json:"current"`
	Runtimes []Runtime `json:"runtimes"`
}

// GetConfigDir 获取配置目录路径
func GetConfigDir() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".langm")
}

// GetConfigPath 获取配置文件路径
func GetConfigPath() string {
	return filepath.Join(GetConfigDir(), "config.json")
}

// Load 加载配置文件
func Load() (*Config, error) {
	configPath := GetConfigPath()
	
	data, err := os.ReadFile(configPath)
	if err != nil {
		if os.IsNotExist(err) {
			// 配置文件不存在，创建默认配置
			cfg := &Config{
				Current:  "",
				Runtimes: []Runtime{},
			}
			if err := cfg.Save(); err != nil {
				return nil, err
			}
			return cfg, nil
		}
		return nil, err
	}

	var cfg Config
	if err := json.Unmarshal(data, &cfg); err != nil {
		return nil, errors.New("配置文件损坏或无效")
	}

	return &cfg, nil
}


// Save 保存配置文件
func (c *Config) Save() error {
	configDir := GetConfigDir()
	if err := os.MkdirAll(configDir, 0755); err != nil {
		return err
	}

	data, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(GetConfigPath(), data, 0644)
}

// AddRuntime 添加运行时
func (c *Config) AddRuntime(rt Runtime) error {
	// 检查是否已存在同名运行时
	for _, r := range c.Runtimes {
		if r.Name == rt.Name {
			return errors.New("运行时 \"" + rt.Name + "\" 已存在")
		}
	}

	c.Runtimes = append(c.Runtimes, rt)
	return c.Save()
}

// GetRuntimes 获取所有运行时
func (c *Config) GetRuntimes() []Runtime {
	return c.Runtimes
}

// GetRuntimesByCapability 按能力过滤运行时
func (c *Config) GetRuntimesByCapability(cap string) []Runtime {
	var result []Runtime
	for _, rt := range c.Runtimes {
		for _, c := range rt.Capabilities {
			if c == cap {
				result = append(result, rt)
				break
			}
		}
	}
	return result
}

// GetRuntimeByName 根据名称获取运行时
func (c *Config) GetRuntimeByName(name string) *Runtime {
	for _, rt := range c.Runtimes {
		if rt.Name == name {
			return &rt
		}
	}
	return nil
}

// SetCurrent 设置当前激活的运行时
func (c *Config) SetCurrent(name string) error {
	c.Current = name
	return c.Save()
}
