import type { Occasion } from './Occasion';

/** 与 HTML `i18n[lang]` 中除 data 外的静态文案一致。 */
export interface UiStrings {
  loc: string;
  date: string;
  storyTitle: string;
  curatedTitle: string;
  save: string;
  share: string;
  main: string;
  sec: string;
  acc: string;
  settingsTitle: string;
  langLabel: string;
  langFollowSystem: string;
  themeLabel: string;
  themeValue: string;
  aboutLabel: string;
}

/** 某一语言下的 UI 文案 + 场合树（含本地化后的 palette 名称与描述）。 */
export interface LocaleBundle {
  ui: UiStrings;
  occasions: Occasion[];
}
