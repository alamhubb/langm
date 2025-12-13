mod config;
mod detector;
mod symlink;

use clap::{Parser, Subcommand};
use dialoguer::{theme::ColorfulTheme, Select};
use std::collections::HashMap;
use std::path::PathBuf;
use config::{Config, Runtime};

#[derive(Parser)]
#[command(name = "langm", version = "0.1.0", about = "LangM - 多语言运行时管理器")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// 注册运行时目录
    Add {
        path: PathBuf,
        #[arg(long, short = 'n')]
        node: bool,
        #[arg(long, short = 'j')]
        java: bool,
    },
    /// 列出已注册的运行时
    #[command(alias = "ls")]
    List { capability: Option<String> },
    /// 切换运行时
    Use { capability: Option<String> },
}

fn main() {
    let cli = Cli::parse();
    let result = match cli.command {
        Commands::Add { path, node, java } => cmd_add(path, node, java),
        Commands::List { capability } => cmd_list(capability),
        Commands::Use { capability } => cmd_use(capability),
    };
    if let Err(e) = result {
        eprintln!("错误: {}", e);
        std::process::exit(1);
    }
}


fn cmd_add(path: PathBuf, node: bool, java: bool) -> Result<(), String> {
    let abs_path = path.canonicalize().map_err(|_| format!("目录不存在: {}", path.display()))?;
    if !detector::directory_exists(&abs_path) {
        return Err(format!("目录不存在: {}", abs_path.display()));
    }

    let capabilities = if node || java {
        let mut caps = Vec::new();
        if node { caps.push("node".to_string()); }
        if java { caps.push("java".to_string()); }
        caps
    } else {
        let caps = detector::detect(&abs_path);
        if caps.is_empty() {
            let exe_hint = if cfg!(windows) { "bin/node.exe 或 bin/java.exe" } else { "bin/node 或 bin/java" };
            return Err(format!("无法自动识别运行时类型\n该目录下未找到 {}\n请使用 --node 或 --java 手动指定类型:\n  langm add {} --node", exe_hint, abs_path.display()));
        }
        caps
    };

    let name = abs_path.file_name().and_then(|n| n.to_str()).unwrap_or("unknown").to_string();
    let mut cfg = Config::load()?;
    cfg.add_runtime(Runtime { name: name.clone(), path: abs_path.to_string_lossy().to_string(), capabilities: capabilities.clone() })?;

    println!("✓ 已注册运行时: {}", name);
    println!("  路径: {}", abs_path.display());
    println!("  能力: {:?}", capabilities);
    Ok(())
}

fn cmd_list(capability: Option<String>) -> Result<(), String> {
    let cfg = Config::load()?;
    let runtimes: Vec<&Runtime> = match &capability {
        Some(cap) if cap == "node" || cap == "java" => cfg.get_runtimes_by_capability(cap),
        Some(cap) => return Err(format!("未知的能力类型 '{}'，支持 node 或 java", cap)),
        None => cfg.get_runtimes().iter().collect(),
    };

    if runtimes.is_empty() {
        println!("没有注册任何运行时");
        println!("使用 langm add <路径> 添加运行时");
        return Ok(());
    }

    let current = cfg.current.as_deref();
    if let Some(cap) = capability {
        println!("{}:", cap);
        for rt in runtimes {
            let marker = if Some(rt.name.as_str()) == current { " *" } else { "" };
            println!("  {}{}", rt.name, marker);
            println!("    {}", rt.path);
        }
    } else {
        let mut groups: HashMap<&str, Vec<&Runtime>> = HashMap::new();
        for rt in &runtimes {
            for cap in &rt.capabilities {
                groups.entry(cap.as_str()).or_default().push(rt);
            }
        }
        for (cap, cap_runtimes) in groups {
            println!("{}:", cap);
            for rt in cap_runtimes {
                let marker = if Some(rt.name.as_str()) == current { " *" } else { "" };
                println!("  {}{}", rt.name, marker);
                println!("    {}", rt.path);
            }
        }
    }
    Ok(())
}


fn cmd_use(capability: Option<String>) -> Result<(), String> {
    let mut cfg = Config::load()?;
    let runtimes: Vec<Runtime> = match &capability {
        Some(cap) if cap == "node" || cap == "java" => cfg.get_runtimes_by_capability(cap).into_iter().cloned().collect(),
        Some(cap) => return Err(format!("未知的能力类型 '{}'，支持 node 或 java", cap)),
        None => cfg.get_runtimes().to_vec(),
    };

    if runtimes.is_empty() {
        if let Some(cap) = capability {
            println!("没有找到具有 {} 能力的运行时", cap);
        } else {
            println!("没有注册任何运行时");
        }
        println!("使用 langm add <路径> 添加运行时");
        return Ok(());
    }

    let options: Vec<String> = runtimes.iter().map(|rt| format!("{} ({})", rt.name, rt.path)).collect();
    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("请选择要使用的运行时")
        .items(&options)
        .default(0)
        .interact_opt()
        .map_err(|e| format!("选择失败: {}", e))?;

    let selected_index = match selection {
        Some(i) => i,
        None => { println!("已取消"); return Ok(()); }
    };

    let selected = &runtimes[selected_index];
    symlink::switch_to(std::path::Path::new(&selected.path))?;
    cfg.set_current(Some(selected.name.clone()))?;

    println!("✓ 已切换到: {}", selected.name);
    println!("  路径: {}", selected.path);
    println!("  能力: {:?}", selected.capabilities);
    println!();
    if cfg!(windows) {
        println!("提示: 请确保 %USERPROFILE%\\.langm\\current\\bin 已添加到系统 PATH");
    } else {
        println!("提示: 请确保 ~/.langm/current/bin 已添加到 PATH");
        println!("      例如在 ~/.bashrc 或 ~/.zshrc 中添加:");
        println!("      export PATH=\"$HOME/.langm/current/bin:$PATH\"");
    }
    Ok(())
}
