#!/usr/bin/env bun

import { addCommand } from './commands/add';
import { listCommand } from './commands/list';
import { useCommand } from './commands/use';

const VERSION = '0.1.0';

function showHelp(): void {
  console.log(`
LangM v${VERSION} - 多语言运行时管理器

用法:
  langm <命令> [参数]

命令:
  add <路径> [-node|-java]  注册运行时目录
  list [node|java]          列出已注册的运行时
  use [node|java]           切换运行时

示例:
  langm add D:\\soft\\node-v20           自动检测并注册
  langm add D:\\soft\\graalvm-25 -java   手动指定为 java
  langm add -node D:\\soft\\node-v20     手动指定为 node
  langm list                             列出所有运行时
  langm list node                        列出 node 运行时
  langm use                              选择运行时
  langm use java                         选择 java 运行时
`);
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const command = args[0];
  const commandArgs = args.slice(1);

  switch (command) {
    case 'add':
      await addCommand(commandArgs);
      break;
    case 'list':
    case 'ls':
      await listCommand(commandArgs);
      break;
    case 'use':
      await useCommand(commandArgs);
      break;
    case '--help':
    case '-h':
    case 'help':
      showHelp();
      break;
    case '--version':
    case '-v':
      console.log(`LangM v${VERSION}`);
      break;
    default:
      if (command) {
        console.error(`未知命令: ${command}`);
      }
      showHelp();
      process.exit(command ? 1 : 0);
  }
}

main().catch(error => {
  console.error('错误:', error.message);
  process.exit(1);
});
