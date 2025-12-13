use std::path::Path;

/// 获取可执行文件名（跨平台）
fn exe_name(name: &str) -> String {
    if cfg!(windows) {
        format!("{}.exe", name)
    } else {
        name.to_string()
    }
}

pub fn detect(dir_path: &Path) -> Vec<String> {
    let mut capabilities = Vec::new();
    
    // 检测 node
    if dir_path.join("bin").join(exe_name("node")).exists() {
        capabilities.push("node".to_string());
    }
    
    // 检测 java
    if dir_path.join("bin").join(exe_name("java")).exists() {
        capabilities.push("java".to_string());
    }
    
    capabilities
}

pub fn directory_exists(path: &Path) -> bool {
    path.is_dir()
}
