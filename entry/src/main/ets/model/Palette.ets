export interface PaletteColorProfile {
  id: string;
  hex: string;
  tone: string;
  lightnessLevel: string;
  saturationLevel: string;
  colorFamily: string;
  isNeutralCore: boolean;
  styleTags: string[];
  occasionTags: string[];
  seasonTags: string[];
}

/**
 * 单个配色盘：与 HTML 原型中 palette 对象一致（id / name / desc / colors）。
 */
export interface Palette {
  id: string;
  name: string;
  desc: string;
  /** 顺序：主色、辅色、点缀 — HEX 字符串，长度 3。 */
  colors: string[];
  occasionId?: string;
  safetyLevel?: string;
  moodTags?: string[];
  styleTags?: string[];
  seasonTags?: string[];
  sourceType?: string;
  sourceCollectionIds?: string[];
  fitPhotoScenario?: boolean;
  primaryProfile?: PaletteColorProfile;
  secondaryProfile?: PaletteColorProfile;
  accentProfile?: PaletteColorProfile;
}
