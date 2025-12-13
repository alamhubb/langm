import prompts from 'prompts';
import { ConfigManager } from '../services/config-manager';
import { SymlinkManager } from '../services/symlink-manager';
import type { Capability, Runtime } from '../types';

/**
 * 按能力分组运行时
 */
function groupByCapability(runtimes: Runtime[]): Map<Capability, Runtime[]> {
  const groups = new Map<Capability, Runtime[]>();
  
  for (const runtime of runtimes) {
    for (const cap of runtime.capabilities) {
      if (!groups.has(cap)) {
        groups.set(cap, []);
      }
      groups.get(cap)!.push(runtime);
    }
  }
  
  return groups;
}

/**
 * 执行 use 命令
 * - langm use: 显示所有运行时供选择
 * - langm use node: 显示 node 能力的运行时供选择
 * - langm use java: 显示 java 能力的运行时供选择
 */
export async function useCommand(args: string[]): Promise<void> {
  const configManager = new ConfigManager();
  const symlinkManager = new SymlinkManager();
  const filterCapability = args[0] as Capability | undefined;
  
  let runtimes: Runtime[];
  
  if (filterCapability && (filterCapability === 'node' || filterCapability === 'java')) {
    runtimes = await configManager.getRuntimesByCapability(filterCapability);
  } else {
    runtimes = await configManager.getRuntimes();
  }
  
  if (runtimes.length === 0) {
    if (filterCapability) {
      console.log(`没有找到具有 ${filterCapability} 能力的运行时`);
    } else {
      console.log('没有注册任何运行时');
    }
    console.log('使用 langm add <路径> 添加运行时');
    return;
  }


  // 构建选择列表
  let choices: { title: string; value: string; description: string }[];
  
  if (filterCapability) {
    // 按指定能力过滤，直接列出
    choices = runtimes.map(r => ({
      title: r.name,
      value: r.name,
      description: r.path
    }));
  } else {
    // 按能力分组
    const groups = groupByCapability(runtimes);
    choices = [];
    
    for (const [cap, capRuntimes] of groups) {
      // 添加分组标题（不可选）
      choices.push({
        title: `── ${cap} ──`,
        value: '',
        description: ''
      });
      
      for (const runtime of capRuntimes) {
        choices.push({
          title: `  ${runtime.name}`,
          value: runtime.name,
          description: runtime.path
        });
      }
    }
  }

  // 显示交互式选择菜单
  const response = await prompts({
    type: 'select',
    name: 'selected',
    message: '请选择要使用的运行时:',
    choices: choices.filter(c => c.value !== ''), // 过滤掉分组标题
    initial: 0
  });

  if (!response.selected) {
    console.log('已取消');
    return;
  }

  // 获取选中的运行时
  const selectedRuntime = runtimes.find(r => r.name === response.selected);
  if (!selectedRuntime) {
    console.error('错误: 未找到选中的运行时');
    process.exit(1);
  }

  // 切换软链接
  try {
    await symlinkManager.switchTo(selectedRuntime.path);
    await configManager.setCurrent(selectedRuntime.name);
    
    console.log(`✓ 已切换到: ${selectedRuntime.name}`);
    console.log(`  路径: ${selectedRuntime.path}`);
    console.log(`  能力: ${selectedRuntime.capabilities.join(', ')}`);
    console.log('');
    console.log('提示: 请确保 ~/.langm/current/bin 已添加到系统 PATH');
  } catch (error: any) {
    console.error(`错误: ${error.message}`);
    process.exit(1);
  }
}
