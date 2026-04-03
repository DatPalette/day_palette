export enum MiniPreviewStyle {
  Capsule = 'capsule',
  Hero = 'hero'
}

export const DEFAULT_MINI_PREVIEW_STYLE: MiniPreviewStyle = MiniPreviewStyle.Capsule;

export function parseMiniPreviewStyle(raw: string): MiniPreviewStyle {
  if (raw === MiniPreviewStyle.Hero) {
    return MiniPreviewStyle.Hero;
  }
  return DEFAULT_MINI_PREVIEW_STYLE;
}