import type { Collection } from './Collection';
import type { Occasion } from './Occasion';

/** 与 HTML `i18n[lang]` 中除 data 外的静态文案一致。 */
export interface UiStrings {
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
  aboutLabel: string;
  saveSuccess: string;
  /** 用户拒绝或未授予相册写入 */
  saveFailAlbumPermission: string;
  /** 申请权限过程异常 */
  saveFailPermissionRequest: string;
  /** 离屏图 / PixelMap 失败 */
  saveFailBuildImage: string;
  /** PNG 编码失败 */
  saveFailEncodeImage: string;
  /** createAsset / 打开媒体库 URI 等 */
  saveFailGalleryApi: string;
  /** 写入相册文件失败 */
  saveFailGalleryWrite: string;
  /** 未分类；可带错误码占位 */
  saveFailUnknown: string;
  /** 用户在系统「保存到相册」弹窗中取消 */
  saveCancelled: string;
  shareFailBuildImage: string;
  shareFailOther: string;
  /** 主文案：从当前场合套组中随机换一套（非算法生成新色）。 */
  randomPalette: string;
  /** 副文案：说明行为边界，字号更小，与主文案同列展示。 */
  randomPaletteHint: string;
  smartMatch: string;
  smartMatchTitle: string;
  smartMatchHint: string;
  smartMatchApply: string;
  smartMatchApplied: string;
  smartMatchEmpty: string;
  smartMatchSource: string;
  yesterdayOutfit: string;
  fineTune: string;
  fineTuneTitle: string;
  fineTuneApply: string;
  fineTuneReset: string;
  fineTuneInvalid: string;
  fineTuneSuggested: string;
  fineTuneManual: string;
  fineTuneUndo: string;
  yesterdayEmpty: string;
  exportTemplateLabel: string;
  templateEditorial: string;
  templateColumns: string;
  templateThirds: string;
  templateBento: string;
  templateStack: string;
  miniPreviewStyleLabel: string;
  miniPreviewStyleCapsule: string;
  miniPreviewStyleHero: string;
  reduceMotionLabel: string;
  noiseLabel: string;
  themeFollowSystem: string;
  themeLight: string;
  themeDark: string;
}

/** 某一语言下的 UI 文案 + 场合树（含本地化后的 palette 名称与描述）。 */
export interface LocaleBundle {
  ui: UiStrings;
  collections: Collection[];
  occasions: Occasion[];
}
