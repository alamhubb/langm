use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[derive(Serialize, Deserialize, Clone)]
pub struct Runtime {
    pub name: String,
    pub path: String,
    pub capabilities: Vec<String>,
}

#[derive(Serialize, Deserialize, Default)]
pub struct Config {
    pub current: Option<String>,
    pub runtimes: Vec<Runtime>,
}

impl Config {
    pub fn get_config_dir() -> PathBuf {
        dirs::home_dir().unwrap_or_else(|| PathBuf::from(".")).join(".langm")
    }

    pub fn get_config_path() -> PathBuf {
        Self::get_config_dir().join("config.json")
    }

    pub fn load() -> Result<Self, String> {
        let config_path = Self::get_config_path();
        if !config_path.exists() {
            let config = Config::default();
            config.save()?;
            return Ok(config);
        }
        let content = fs::read_to_string(&config_path).map_err(|e| format!("读取配置文件失败: {}", e))?;
        serde_json::from_str(&content).map_err(|_| "配置文件损坏或无效".to_string())
    }

    pub fn save(&self) -> Result<(), String> {
        let config_dir = Self::get_config_dir();
        fs::create_dir_all(&config_dir).map_err(|e| format!("创建配置目录失败: {}", e))?;
        let content = serde_json::to_string_pretty(self).map_err(|e| format!("序列化配置失败: {}", e))?;
        fs::write(Self::get_config_path(), content).map_err(|e| format!("写入配置文件失败: {}", e))
    }

    pub fn add_runtime(&mut self, rt: Runtime) -> Result<(), String> {
        if self.runtimes.iter().any(|r| r.name == rt.name) {
            return Err(format!("运行时 \"{}\" 已存在", rt.name));
        }
        self.runtimes.push(rt);
        self.save()
    }

    pub fn get_runtimes(&self) -> &[Runtime] { &self.runtimes }

    pub fn get_runtimes_by_capability(&self, cap: &str) -> Vec<&Runtime> {
        self.runtimes.iter().filter(|rt| rt.capabilities.contains(&cap.to_string())).collect()
    }

    pub fn set_current(&mut self, name: Option<String>) -> Result<(), String> {
        self.current = name;
        self.save()
    }
}
