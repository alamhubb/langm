use std::fs;
use std::path::{Path, PathBuf};

pub fn get_langm_dir() -> PathBuf {
    dirs::home_dir().unwrap_or_else(|| PathBuf::from(".")).join(".langm")
}

pub fn get_current_link_path() -> PathBuf {
    get_langm_dir().join("current")
}

pub fn switch_to(target_path: &Path) -> Result<(), String> {
    let langm_dir = get_langm_dir();
    fs::create_dir_all(&langm_dir).map_err(|e| format!("创建目录失败: {}", e))?;

    let current_link = get_current_link_path();
    if current_link.exists() || current_link.is_symlink() {
        let _ = fs::remove_file(&current_link);
        let _ = fs::remove_dir_all(&current_link);
    }

    #[cfg(windows)]
    {
        std::os::windows::fs::symlink_dir(target_path, &current_link).map_err(|e| {
            if e.raw_os_error() == Some(1314) {
                "创建软链接失败：权限不足。\n请尝试以下方法之一：\n1. 开启 Windows 开发者模式\n2. 以管理员身份运行终端".to_string()
            } else {
                format!("创建软链接失败: {}", e)
            }
        })?;
    }

    #[cfg(not(windows))]
    {
        std::os::unix::fs::symlink(target_path, &current_link).map_err(|e| format!("创建软链接失败: {}", e))?;
    }

    Ok(())
}

pub fn get_current() -> Result<Option<PathBuf>, String> {
    let current_link = get_current_link_path();
    if !current_link.exists() && !current_link.is_symlink() {
        return Ok(None);
    }
    fs::read_link(&current_link).map(Some).map_err(|e| format!("读取软链接失败: {}", e))
}
