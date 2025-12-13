import { homedir } from 'os';
import { join } from 'path';
import type { Config, Runtime, Capability } from '../types';
import { DEFAULT_CONFIG } from '../types';

const LANGM_DIR = join(homedir(), '.langm');
const CONFIG_PATH = join(LANGM_DIR, 'config.json');

export class ConfigManager {
  private config: Config | null = null;

  // 获取配置目录路径
  static getConfigDir(): string {
    return LANGM_DIR;
  }

  // 获取配置文件路径
  static getConfigPath(): string {
    return CONFIG_PATH;
  }

  // 加载配置
  async load(): Promise<Config> {
    try {
      const file = Bun.file(CONFIG_PATH);
      if (await file.exists()) {
        const text = await file.text();
        this.config = JSON.parse(text) as Config;
        return this.config;
      }
    } catch (error) {
      throw new Error(`配置文件损坏或无效: ${CONFIG_PATH}`);
    }

    // 配置文件不存在，创建默认配置
    this.config = { ...DEFAULT_CONFIG };
    await this.save(this.config);
    return this.config;
  }

  // 保存配置
  async save(config: Config): Promise<void> {
    // 确保目录存在
    const { mkdir } = await import('fs/promises');
    await mkdir(LANGM_DIR, { recursive: true });
    
    await Bun.write(CONFIG_PATH, JSON.stringify(config, null, 2));
    this.config = config;
  }


  // 添加运行时
  async addRuntime(runtime: Runtime): Promise<void> {
    if (!this.config) {
      await this.load();
    }
    
    // 检查是否已存在同名运行时
    const exists = this.config!.runtimes.some(r => r.name === runtime.name);
    if (exists) {
      throw new Error(`运行时 "${runtime.name}" 已存在`);
    }
    
    this.config!.runtimes.push(runtime);
    await this.save(this.config!);
  }

  // 获取所有运行时
  async getRuntimes(): Promise<Runtime[]> {
    if (!this.config) {
      await this.load();
    }
    return this.config!.runtimes;
  }

  // 按能力过滤运行时
  async getRuntimesByCapability(cap: Capability): Promise<Runtime[]> {
    const runtimes = await this.getRuntimes();
    return runtimes.filter(r => r.capabilities.includes(cap));
  }

  // 获取当前激活的运行时名称
  async getCurrent(): Promise<string | null> {
    if (!this.config) {
      await this.load();
    }
    return this.config!.current;
  }

  // 设置当前激活的运行时
  async setCurrent(name: string | null): Promise<void> {
    if (!this.config) {
      await this.load();
    }
    this.config!.current = name;
    await this.save(this.config!);
  }

  // 根据名称获取运行时
  async getRuntimeByName(name: string): Promise<Runtime | undefined> {
    const runtimes = await this.getRuntimes();
    return runtimes.find(r => r.name === name);
  }
}
