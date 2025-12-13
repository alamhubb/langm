import { join } from 'path';
import type { Capability } from '../types';

export class RuntimeDetector {
  /**
   * 检测目录的能力
   * - 检查 bin/node.exe 存在 → 添加 node 能力
   * - 检查 bin/java.exe 存在 → 添加 java 能力
   */
  async detect(dirPath: string): Promise<Capability[]> {
    const capabilities: Capability[] = [];
    
    // 检测 node 能力
    const nodePath = join(dirPath, 'bin', 'node.exe');
    const nodeFile = Bun.file(nodePath);
    if (await nodeFile.exists()) {
      capabilities.push('node');
    }
    
    // 检测 java 能力
    const javaPath = join(dirPath, 'bin', 'java.exe');
    const javaFile = Bun.file(javaPath);
    if (await javaFile.exists()) {
      capabilities.push('java');
    }
    
    return capabilities;
  }

  /**
   * 检查目录是否存在
   */
  async directoryExists(dirPath: string): Promise<boolean> {
    try {
      const { stat } = await import('fs/promises');
      const stats = await stat(dirPath);
      return stats.isDirectory();
    } catch {
      return false;
    }
  }
}
