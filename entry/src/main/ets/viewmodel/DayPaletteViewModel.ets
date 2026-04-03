import type { common } from '@kit.AbilityKit';
import { DesignTokens } from '../common/constants/DesignTokens';
import { hexToRgb888 } from '../export/HexColor';
import { AppLanguage } from '../model/AppLanguage';
import { readLanguageOverride, writeLanguageOverride } from '../model/LanguagePreferenceStore';
import { getLocaleBundle } from '../model/LocaleData';
import type { LocaleBundle, UiStrings } from '../model/LocaleTypes';
import type { Occasion } from '../model/Occasion';
import type { Palette } from '../model/Palette';
import { getSystemAppLanguage } from '../model/SystemLanguageResolver';
import { DEFAULT_MINI_PREVIEW_STYLE, MiniPreviewStyle, parseMiniPreviewStyle } from '../model/MiniPreviewStyle';
import type { TodayOutfitState } from '../model/TodayOutfitState';
import { DEFAULT_TEMPLATE_ID } from '../model/TodayOutfitState';
import {
  readMiniPreviewStyleRaw,
  readNoiseOverlayEnabled,
  readReduceMotionEnabled,
  readTodayOutfitState,
  readYesterdayOutfitCalendarDay,
  readYesterdayOutfitState,
  rollCalendarDayAndMaybeSnapshotYesterday,
  todayLocalYmd,
  yesterdayLocalYmd,
  writeMiniPreviewStyleRaw,
  writeNoiseOverlayEnabled,
  writeReduceMotionEnabled,
  writeTodayOutfitState
} from '../persistence/TodayStateStore';

@Observed
export class DayPaletteViewModel {
  /**
   * 手动选择的语言；null 表示跟随系统。
   * 首帧前由 Index.aboutToAppear 从 Preferences 同步。
   */
  manualLanguage: AppLanguage | null = null;
  /** 实际用于文案与数据的语言（系统或手动解析结果）。 */
  currentLang: AppLanguage = AppLanguage.EN;
  /** 与 HTML `activeOccasion` 一致。 */
  activeOccasionId: string = 'workday';
  /** 与 HTML `activePaletteId` 一致。 */
  activePaletteId: string = 'w1';
  /** 短签（≤20 字），出图/卡片用；首版可无 UI 入口仅持久化。 */
  shortNote: string = '';
  /** 当前出图模板 id。 */
  templateId: string = DEFAULT_TEMPLATE_ID;
  /** 精调三色覆盖；null 表示沿用当前套组定义色。 */
  customHex: string[] | null = null;
  /** 减少动效（无障碍）。 */
  reduceMotion: boolean = false;
  /** Hero 轻噪点叠层。 */
  noiseOverlay: boolean = false;
  /** 顶栏微缩预览样式。 */
  miniPreviewStyle: MiniPreviewStyle = DEFAULT_MINI_PREVIEW_STYLE;

  private persistContext: common.UIAbilityContext | null = null;

  setPersistContext(ctx: common.UIAbilityContext): void {
    this.persistContext = ctx;
  }

  getLocaleBundle(): LocaleBundle {
    return getLocaleBundle(this.currentLang);
  }

  getUiStrings(): UiStrings {
    return this.getLocaleBundle().ui;
  }

  getOccasions(): Occasion[] {
    return this.getLocaleBundle().occasions;
  }

  getActiveOccasion(): Occasion | undefined {
    return this.getOccasions().find((o: Occasion) => o.id === this.activeOccasionId);
  }

  getActivePalette(): Palette | undefined {
    const occ = this.getActiveOccasion();
    if (!occ) {
      return undefined;
    }
    return occ.palettes.find((p: Palette) => p.id === this.activePaletteId);
  }

  /**
   * Hero 大标题与顶栏收缩态文案：与当前选中套组 `Palette.name` 一致；
   * 若无套组名则回退场合 `title`（与数据迁移/异常态兼容）。
   * 支持 HTML 式 `<br>` / `<br/>` 折行。
   */
  getHeroDisplayTitleRaw(): string {
    const pal: Palette | undefined = this.getActivePalette();
    if (pal !== undefined && pal.name.trim().length > 0) {
      return pal.name;
    }
    const occ: Occasion | undefined = this.getActiveOccasion();
    return occ !== undefined ? occ.title : '';
  }

  /** Hero 多行标题（按 `<br>` 拆分）。 */
  getHeroTitleLines(): string[] {
    const raw: string = this.getHeroDisplayTitleRaw();
    const parts: string[] = raw.split(/<br\s*\/?>/i);
    const lines: string[] = [];
    for (let i = 0; i < parts.length; i++) {
      const t: string = parts[i].trim();
      if (t.length > 0) {
        lines.push(t);
      }
    }
    if (lines.length === 0 && raw.trim().length > 0) {
      lines.push(raw.trim());
    }
    return lines.length > 0 ? lines : [''];
  }

  /** 顶栏胶囊旁单行标题（折行改为空格）。 */
  getHeroTitleCompact(): string {
    return this.getHeroDisplayTitleRaw().replace(/<br\s*\/?>/gi, ' ').trim();
  }

  /**
   * 切换场合时自动选中该场合下第一个配色盘（与 HTML `selectOccasion` 一致）。
   */
  selectOccasion(occasionId: string): void {
    if (this.activeOccasionId === occasionId) {
      return;
    }
    const occ = this.getOccasions().find((o: Occasion) => o.id === occasionId);
    if (!occ || occ.palettes.length === 0) {
      return;
    }
    this.activeOccasionId = occasionId;
    this.activePaletteId = occ.palettes[0].id;
    this.customHex = null;
    this.flushTodayOutfitToStorage();
  }

  selectPalette(paletteId: string): void {
    if (this.activePaletteId === paletteId) {
      return;
    }
    const occ = this.getActiveOccasion();
    if (!occ) {
      return;
    }
    const exists = occ.palettes.some((p: Palette) => p.id === paletteId);
    if (!exists) {
      return;
    }
    this.activePaletteId = paletteId;
    this.customHex = null;
    this.flushTodayOutfitToStorage();
  }

  setShortNote(note: string): void {
    const trimmed = note.trim();
    this.shortNote = trimmed.length > 20 ? trimmed.substring(0, 20) : trimmed;
    this.flushTodayOutfitToStorage();
  }

  setTemplateId(id: string): void {
    if (this.templateId === id) {
      return;
    }
    this.templateId = id;
    this.flushTodayOutfitToStorage();
  }

  /** 语言加载之后调用：恢复今日配色与短签。 */
  loadTodayOutfitFromStorage(): void {
    if (this.persistContext === null) {
      return;
    }
    rollCalendarDayAndMaybeSnapshotYesterday(this.persistContext, todayLocalYmd());
    const saved: TodayOutfitState | null = readTodayOutfitState(this.persistContext);
    if (saved === null) {
      return;
    }
    this.applyTodayOutfitState(saved);
  }

  loadAccessibilityFromStorage(context: common.UIAbilityContext): void {
    this.reduceMotion = readReduceMotionEnabled(context);
    this.noiseOverlay = readNoiseOverlayEnabled(context);
    this.miniPreviewStyle = parseMiniPreviewStyle(readMiniPreviewStyleRaw(context));
  }

  setReduceMotion(context: common.UIAbilityContext, enabled: boolean): void {
    this.reduceMotion = enabled;
    writeReduceMotionEnabled(context, enabled);
  }

  setNoiseOverlay(context: common.UIAbilityContext, enabled: boolean): void {
    this.noiseOverlay = enabled;
    writeNoiseOverlayEnabled(context, enabled);
  }

  setMiniPreviewStyle(context: common.UIAbilityContext, style: MiniPreviewStyle): void {
    if (this.miniPreviewStyle === style) {
      return;
    }
    this.miniPreviewStyle = style;
    writeMiniPreviewStyleRaw(context, style);
  }

  /** 当前场合下从预置套组中随机选一套（不生成裸 RGB）。 */
  randomPaletteInActiveOccasion(): void {
    const occ: Occasion | undefined = this.getActiveOccasion();
    if (occ === undefined || occ.palettes.length === 0) {
      return;
    }
    const idx: number = Math.floor(Math.random() * occ.palettes.length);
    this.activePaletteId = occ.palettes[idx].id;
    this.customHex = null;
    this.flushTodayOutfitToStorage();
  }

  /** 恢复跨日时快照的「昨日」套组；若无快照返回 false。 */
  applyYesterdayOutfitFromStorage(): boolean {
    if (!this.canApplyYesterdayOutfit()) {
      return false;
    }
    if (this.persistContext === null) {
      return false;
    }
    const y: TodayOutfitState | null = readYesterdayOutfitState(this.persistContext);
    if (y === null) {
      return false;
    }
    this.applyTodayOutfitState(y);
    this.flushTodayOutfitToStorage();
    return true;
  }

  canApplyYesterdayOutfit(): boolean {
    if (this.persistContext === null) {
      return false;
    }
    const yesterdayDay: string = readYesterdayOutfitCalendarDay(this.persistContext);
    if (yesterdayDay !== yesterdayLocalYmd()) {
      return false;
    }
    return readYesterdayOutfitState(this.persistContext) !== null;
  }

  getHeroColorStrings(): string[] {
    if (this.customHex !== null && this.customHex.length >= 3) {
      return this.customHex;
    }
    const pal: Palette | undefined = this.getActivePalette();
    if (pal !== undefined && pal.colors.length >= 3) {
      return pal.colors;
    }
    return [DesignTokens.DEFAULT_MAIN, DesignTokens.DEFAULT_SEC, DesignTokens.DEFAULT_ACC];
  }

  setFineTuneHex(mainHex: string, secHex: string, accHex: string): boolean {
    if (hexToRgb888(mainHex) === null || hexToRgb888(secHex) === null || hexToRgb888(accHex) === null) {
      return false;
    }
    this.customHex = [mainHex.trim(), secHex.trim(), accHex.trim()];
    this.flushTodayOutfitToStorage();
    return true;
  }

  clearFineTune(): void {
    if (this.customHex === null) {
      return;
    }
    this.customHex = null;
    this.flushTodayOutfitToStorage();
  }

  buildTodayOutfitState(): TodayOutfitState | null {
    const pal: Palette | undefined = this.getActivePalette();
    if (pal === undefined || pal.colors.length < 3) {
      return null;
    }
    const cols: string[] = this.getHeroColorStrings();
    const now: number = Date.now();
    return {
      schemaVersion: 1,
      primaryColor: cols[0],
      secondaryColor: cols[1],
      accentColor: cols[2],
      occasionId: this.activeOccasionId,
      activePaletteId: this.activePaletteId,
      shortNote: this.shortNote,
      templateId: this.templateId,
      layoutVariantId: null,
      featureFlags: null,
      ext: {},
      updatedAt: now
    };
  }

  flushTodayOutfitToStorage(): void {
    if (this.persistContext === null) {
      return;
    }
    const state: TodayOutfitState | null = this.buildTodayOutfitState();
    if (state !== null) {
      writeTodayOutfitState(this.persistContext, state);
    }
  }

  private applyTodayOutfitState(state: TodayOutfitState): void {
    const oid: string = state.occasionId !== null && state.occasionId.length > 0 ? state.occasionId : 'workday';
    this.activeOccasionId = oid;
    this.activePaletteId = state.activePaletteId;
    this.shortNote = state.shortNote;
    this.templateId = state.templateId.length > 0 ? state.templateId : DEFAULT_TEMPLATE_ID;

    const occ: Occasion | undefined = this.getOccasions().find((o: Occasion) => o.id === this.activeOccasionId);
    if (occ === undefined) {
      this.activeOccasionId = 'workday';
      const o2: Occasion | undefined = this.getActiveOccasion();
      if (o2 !== undefined && o2.palettes.length > 0) {
        this.activePaletteId = o2.palettes[0].id;
      }
      return;
    }
    const pal: Palette | undefined = occ.palettes.find((p: Palette) => p.id === this.activePaletteId);
    if (pal === undefined && occ.palettes.length > 0) {
      this.activePaletteId = occ.palettes[0].id;
    }
    const resolved: Palette | undefined = this.getActivePalette();
    if (resolved !== undefined && resolved.colors.length >= 3) {
      const same: boolean =
        state.primaryColor.toLowerCase() === resolved.colors[0].toLowerCase() &&
        state.secondaryColor.toLowerCase() === resolved.colors[1].toLowerCase() &&
        state.accentColor.toLowerCase() === resolved.colors[2].toLowerCase();
      if (same) {
        this.customHex = null;
      } else {
        this.customHex = [state.primaryColor, state.secondaryColor, state.accentColor];
      }
    } else {
      this.customHex = null;
    }
  }

  /** 从本地恢复手动覆盖并应用当前有效语言（应在首屏 build 前调用）。 */
  loadLanguageFromStorage(context: common.UIAbilityContext): void {
    this.manualLanguage = readLanguageOverride(context);
    const effective: AppLanguage = this.manualLanguage ?? getSystemAppLanguage();
    this.applyResolvedLocale(effective);
  }

  /** 系统区域/语言变化且当前为「跟随系统」时调用。 */
  refreshLocaleIfFollowingSystem(_context: common.UIAbilityContext): void {
    if (this.manualLanguage !== null) {
      return;
    }
    const effective: AppLanguage = getSystemAppLanguage();
    this.applyResolvedLocale(effective);
  }

  setFollowSystem(context: common.UIAbilityContext): void {
    this.manualLanguage = null;
    writeLanguageOverride(context, null);
    this.applyResolvedLocale(getSystemAppLanguage());
  }

  setManualLanguage(context: common.UIAbilityContext, lang: AppLanguage): void {
    this.manualLanguage = lang;
    writeLanguageOverride(context, lang);
    this.applyResolvedLocale(lang);
  }

  isFollowingSystem(): boolean {
    return this.manualLanguage === null;
  }

  private applyResolvedLocale(lang: AppLanguage): void {
    if (this.currentLang === lang) {
      return;
    }
    this.currentLang = lang;
    const occ = this.getActiveOccasion();
    if (occ === undefined) {
      this.activeOccasionId = 'workday';
      const o = this.getActiveOccasion();
      if (o !== undefined && o.palettes.length > 0) {
        this.activePaletteId = o.palettes[0].id;
      }
      return;
    }
    const pal = occ.palettes.find((p: Palette) => p.id === this.activePaletteId);
    if (pal === undefined && occ.palettes.length > 0) {
      this.activePaletteId = occ.palettes[0].id;
    }
  }
}
