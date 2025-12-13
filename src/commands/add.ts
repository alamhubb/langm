import { basename, resolve } from 'path';
import { ConfigManager } from '../services/config-manager';
import { RuntimeDetector } from '../services/runtime-detector';
import type { Capability } from '../types';

interface AddOptions {
  path: string;
  capability?: Capability;
}

/**
 * 解析 add 命令参数
 * 支持格式:
 * - langm add <路径>
 * - langm add <路径> -node
 * - langm add -node <路径>
 * - langm add <路径> -java
 * - langm add -java <路径>
 */
export function parseAddArgs(args: string[]): AddOptions | null {
  if (args.length === 0) {
    return null;
  }

  let path: string | null = null;
  let capability: Capability | undefined;

  for (const arg of args) {
    if (arg === '-node') {
      capability = 'node';
    } else if (arg === '-java') {
      capability = 'java';
    } else if (!path) {
      path = arg;
    }
  }

  if (!path) {
    return null;
  }

  return { path: resolve(path), capability };
}

/**
 * 执行 add 命令
 */
export async function addCommand(args: string[]): Promise<void> {
  const options = parseAddArgs(args);
  
  if (!options) {
    console.error('用法: langm add <路径> [-node|-java]');
    console.error('示例:');
    console.error('  langm add D:\\soft\\node-v20');
    console.error('  langm add D:\\soft\\graalvm-25 -java');
    console.error('  langm add -node D:\\soft\\node-v20');
    process.exit(1);
  }


  const detector = new RuntimeDetector();
  const configManager = new ConfigManager();

  // 检查目录是否存在
  if (!await detector.directoryExists(options.path)) {
    console.error(`错误: 目录不存在 - ${options.path}`);
    process.exit(1);
  }

  // 确定能力
  let capabilities: Capability[];
  
  if (options.capability) {
    // 用户手动指定了能力
    capabilities = [options.capability];
  } else {
    // 自动检测能力
    capabilities = await detector.detect(options.path);
    
    if (capabilities.length === 0) {
      console.error('错误: 无法自动识别运行时类型');
      console.error('该目录下未找到 bin/node.exe 或 bin/java.exe');
      console.error('请使用 -node 或 -java 手动指定类型:');
      console.error(`  langm add ${options.path} -node`);
      console.error(`  langm add ${options.path} -java`);
      process.exit(1);
    }
  }

  // 生成运行时名称（基于目录名）
  const name = basename(options.path);

  // 添加到配置
  try {
    await configManager.addRuntime({
      name,
      path: options.path,
      capabilities
    });
    
    console.log(`✓ 已注册运行时: ${name}`);
    console.log(`  路径: ${options.path}`);
    console.log(`  能力: ${capabilities.join(', ')}`);
  } catch (error: any) {
    console.error(`错误: ${error.message}`);
    process.exit(1);
  }
}
