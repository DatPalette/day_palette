import type { common } from '@kit.AbilityKit';
import type { SmartMatchStrategyFile } from './SmartMatchStrategyTypes';

const SMART_MATCH_STRATEGY_PATH: string = 'smartmatch/strategy.v1.json';

let cachedStrategy: SmartMatchStrategyFile | null = null;

function bytesToUtf8(bytes: Uint8Array): string {
  let encoded: string = '';
  for (let i = 0; i < bytes.length; i++) {
    const value: string = bytes[i].toString(16).padStart(2, '0');
    encoded += `%${value}`;
  }
  return decodeURIComponent(encoded);
}

async function readJsonRawFile<T>(context: common.UIAbilityContext, path: string): Promise<T | null> {
  try {
    const raw: Uint8Array = await context.resourceManager.getRawFileContent(path);
    if (raw.length === 0) {
      return null;
    }
    const text: string = bytesToUtf8(raw);
    return JSON.parse(text) as T;
  } catch {
    return null;
  }
}

export async function preloadSmartMatchStrategy(context: common.UIAbilityContext): Promise<void> {
  const strategy: SmartMatchStrategyFile | null = await readJsonRawFile<SmartMatchStrategyFile>(context, SMART_MATCH_STRATEGY_PATH);
  cachedStrategy = strategy;
}

export function getSmartMatchStrategy(): SmartMatchStrategyFile | null {
  return cachedStrategy;
}