import { homedir } from 'os';
import { join } from 'path';
import { symlink, unlink, readlink, mkdir, stat } from 'fs/promises';

const LANGM_DIR = join(homedir(), '.langm');
const CURRENT_LINK = join(LANGM_DIR, 'current');

export class SymlinkManager {
  /**
   * 获取 current 软链接路径
   */
  static getCurrentLinkPath(): string {
    return CURRENT_LINK;
  }

  /**
   * 切换当前运行时（创建/替换软链接）
   */
  async switchTo(targetPath: string): Promise<void> {
    // 确保 .langm 目录存在
    await mkdir(LANGM_DIR, { recursive: true });

    // 尝试删除现有软链接
    try {
      await unlink(CURRENT_LINK);
    } catch (error: any) {
      // 忽略不存在的错误
      if (error.code !== 'ENOENT') {
        throw error;
      }
    }

    // 创建新的软链接
    try {
      // Windows 上创建目录软链接需要 'junction' 类型（不需要管理员权限）
      await symlink(targetPath, CURRENT_LINK, 'junction');
    } catch (error: any) {
      if (error.code === 'EPERM') {
        throw new Error(
          '创建软链接失败：权限不足。\n' +
          '请尝试以下方法之一：\n' +
          '1. 开启 Windows 开发者模式\n' +
          '2. 以管理员身份运行终端'
        );
      }
      throw error;
    }
  }

  /**
   * 获取当前激活的运行时路径
   */
  async getCurrent(): Promise<string | null> {
    try {
      const target = await readlink(CURRENT_LINK);
      return target;
    } catch (error: any) {
      if (error.code === 'ENOENT') {
        return null;
      }
      throw error;
    }
  }

  /**
   * 检查软链接是否存在
   */
  async exists(): Promise<boolean> {
    try {
      await stat(CURRENT_LINK);
      return true;
    } catch {
      return false;
    }
  }
}
