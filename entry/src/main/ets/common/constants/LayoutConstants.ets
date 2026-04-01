/** Phase 2 占位：顶栏/底栏占位高度（vp），与 HTML 节奏对齐；后续可接安全区。 */
export class LayoutConstants {
  /** 顶栏 padding-top 42 + 文案区 + padding-bottom 12，另含状态栏估算 */
  static readonly SCROLL_TOP_INSET_VP: number = 118;
  /** 底栏 padding + 52 按钮高 */
  static readonly SCROLL_BOTTOM_INSET_VP: number = 108;
  static readonly PAGE_HORIZONTAL_VP: number = 24;
  static readonly HERO_TOP_PADDING_VP: number = 10;
  static readonly OCCASION_TOP_MARGIN_VP: number = 70;
  static readonly OCCASION_BOTTOM_MARGIN_VP: number = 30;
  static readonly PALETTE_LIST_BOTTOM_PADDING_VP: number = 80;
  /** 顶栏收缩态：主 Scroll 纵向偏移超过此值（vp）时显示 Mini-Palette */
  static readonly TOP_BAR_SCROLL_THRESHOLD_VP: number = 60;
}
