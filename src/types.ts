// 能力类型
export type Capability = 'node' | 'java';

// 运行时配置
export interface Runtime {
  name: string;
  path: string;
  capabilities: Capability[];
}

// 配置文件结构
export interface Config {
  current: string | null;
  runtimes: Runtime[];
}

// 默认空配置
export const DEFAULT_CONFIG: Config = {
  current: null,
  runtimes: []
};
