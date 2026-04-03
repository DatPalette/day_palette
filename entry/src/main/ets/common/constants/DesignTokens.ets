/**
 * 自 HTML `:root` 抽取的语义色与画布色，供后续与 design-system / color.json 对齐。
 */
export class DesignTokens {
  static readonly BG_PAGE: string = '#f9f8f6';
  static readonly BG_CANVAS: string = '#e5e3df';
  static readonly SURFACE_FROSTED: string = 'rgba(249, 248, 246, 0.75)';
  static readonly SURFACE_SUBTLE: string = 'rgba(0, 0, 0, 0.03)';
  static readonly SURFACE_TINTED: string = 'rgba(0, 0, 0, 0.04)';
  static readonly TEXT_MAIN: string = '#1a1a1a';
  static readonly TEXT_MUTED: string = '#8c8c8c';
  static readonly TEXT_ON_INVERSE: string = '#ffffff';
  static readonly BORDER_COLOR: string = 'rgba(0, 0, 0, 0.08)';
  static readonly BORDER_SUBTLE: string = 'rgba(0, 0, 0, 0.03)';
  static readonly SHADOW_SOFT: string = 'rgba(0, 0, 0, 0.06)';
  static readonly SURFACE_CARD: string = '#ffffff';
  /** 原型默认三色（未选中具体 palette 时的占位，与 --c-main/sec/acc 初值一致） */
  static readonly DEFAULT_MAIN: string = '#E8D8D3';
  static readonly DEFAULT_SEC: string = '#C5B9B6';
  static readonly DEFAULT_ACC: string = '#5D637A';
}
