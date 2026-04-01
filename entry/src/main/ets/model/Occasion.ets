import type { Palette } from './Palette';

/**
 * 场合及其下的配色盘列表；id 与原型中 data 的键（workday / weekend / …）一致。
 */
export interface Occasion {
  id: string;
  label: string;
  /** 情绪标题；保留 HTML 中的 `<br>`，由 UI 层解析为换行。 */
  title: string;
  palettes: Palette[];
}
