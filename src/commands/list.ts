import { ConfigManager } from '../services/config-manager';
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
 * 执行 list 命令
 * - langm list: 按语言分组显示所有运行时
 * - langm list node: 只显示 node 能力的运行时
 * - langm list java: 只显示 java 能力的运行时
 */
export async function listCommand(args: string[]): Promise<void> {
  const configManager = new ConfigManager();
  const filterCapability = args[0] as Capability | undefined;
  
  let runtimes: Runtime[];
  
  if (filterCapability && (filterCapability === 'node' || filterCapability === 'java')) {
    runtimes = await configManager.getRuntimesByCapability(filterCapability);
  } else {
    runtimes = await configManager.getRuntimes();
  }
  
  if (runtimes.length === 0) {
    console.log('没有注册任何运行时');
    console.log('使用 langm add <路径> 添加运行时');
    return;
  }

  const current = await configManager.getCurrent();
  
  // 如果指定了过滤能力，直接列出
  if (filterCapability) {
    console.log(`${filterCapability}:`);
    for (const runtime of runtimes) {
      const marker = runtime.name === current ? ' *' : '';
      console.log(`  ${runtime.name}${marker}`);
      console.log(`    ${runtime.path}`);
    }
    return;
  }
  
  // 按能力分组显示
  const groups = groupByCapability(runtimes);
  
  for (const [cap, capRuntimes] of groups) {
    console.log(`${cap}:`);
    for (const runtime of capRuntimes) {
      const marker = runtime.name === current ? ' *' : '';
      console.log(`  ${runtime.name}${marker}`);
      console.log(`    ${runtime.path}`);
    }
  }
}
