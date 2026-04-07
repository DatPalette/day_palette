import type { common } from '@kit.AbilityKit';
import { DesignTokens } from '../common/constants/DesignTokens';
import { refreshTrackedTodayOutfitForms } from '../formability/TodayOutfitFormSync';
import { hexToRgb888 } from '../export/HexColor';
import { AppLanguage } from '../model/AppLanguage';
import type { Collection } from '../model/Collection';
import { readLanguageOverride, writeLanguageOverride } from '../model/LanguagePreferenceStore';
import { getLocaleBundle, preloadLocaleBundles } from '../model/LocaleData';
import type { LocaleBundle, UiStrings } from '../model/LocaleTypes';
import type { Occasion } from '../model/Occasion';
import type { Palette } from '../model/Palette';
import type { PaletteColorProfile } from '../model/Palette';
import { getSystemAppLanguage } from '../model/SystemLanguageResolver';
import { buildSmartMatchCandidates, recommendSmartMatches } from '../model/smartmatch/SmartMatchEngine';
import { preloadSmartMatchStrategy } from '../model/smartmatch/SmartMatchStrategyLoader';
import type { SmartMatchCandidate, SmartMatchRecommendation } from '../model/smartmatch/SmartMatchTypes';
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
  /** 本地 catalog 资源加载完成后递增，用于触发 UI 刷新。 */
  catalogRefreshTick: number = 0;
  /** 当前系统日历日（YYYY-MM-DD），用于驱动 TopBar 日期展示。 */
  currentCalendarDay: string = todayLocalYmd();

  private persistContext: common.UIAbilityContext | null = null;

  setPersistContext(ctx: common.UIAbilityContext): void {
    this.persistContext = ctx;
  }

  async preloadLocaleCatalog(context: common.UIAbilityContext): Promise<void> {
    await Promise.all([
      preloadLocaleBundles(context),
      preloadSmartMatchStrategy(context)
    ]);
    this.catalogRefreshTick += 1;
    this.applyResolvedLocale(this.currentLang, true);
  }

  getLocaleBundle(): LocaleBundle {
    return getLocaleBundle(this.currentLang);
  }

  getUiStrings(): UiStrings {
    return this.getLocaleBundle().ui;
  }

  getTopBarDateLabel(): string {
    const parts: string[] = this.currentCalendarDay.split('-');
    if (parts.length !== 3) {
      return this.getUiStrings().date;
    }
    const year: number = Number(parts[0]);
    const month: number = Number(parts[1]);
    const day: number = Number(parts[2]);
    if (!Number.isFinite(year) || !Number.isFinite(month) || !Number.isFinite(day)) {
      return this.getUiStrings().date;
    }
    if (this.currentLang === AppLanguage.ZH) {
      return `${year}年${month}月${day}日`;
    }
    const monthLabels: string[] = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthLabel: string = monthLabels[month - 1] ?? month.toString().padStart(2, '0');
    return `${monthLabel} ${day.toString().padStart(2, '0')}, ${year}`;
  }

  getCollections(): Collection[] {
    return this.getLocaleBundle().collections;
  }

  getCollectionsForOccasion(occasionId: string): Collection[] {
    const collections: Collection[] = this.getCollections();
    const result: Collection[] = [];
    for (let i = 0; i < collections.length; i++) {
      const item: Collection = collections[i];
      if (item.occasionTags.includes(occasionId)) {
        result.push(item);
      }
    }
    return result;
  }

  getCollectionsForActiveOccasion(): Collection[] {
    return this.getCollectionsForOccasion(this.activeOccasionId);
  }

  getOccasions(): Occasion[] {
    return this.getLocaleBundle().occasions;
  }

  getActiveOccasion(): Occasion | undefined {
    return this.getOccasions().find((o: Occasion) => o.id === this.activeOccasionId);
  }

  getRecommendedPalettesForOccasion(occasionId: string): Palette[] {
    const occ: Occasion | undefined = this.getOccasions().find((item: Occasion) => item.id === occasionId);
    if (occ === undefined) {
      return [];
    }
    const collections: Collection[] = this.getCollectionsForOccasion(occasionId);
    if (collections.length === 0) {
      return occ.palettes;
    }

    const recommended: Palette[] = [];
    const seenPaletteIds: string[] = [];
    for (let i = 0; i < collections.length; i++) {
      const collection: Collection = collections[i];
      for (let j = 0; j < collection.palettes.length; j++) {
        const palette: Palette = collection.palettes[j];
        if (seenPaletteIds.includes(palette.id)) {
          continue;
        }
        seenPaletteIds.push(palette.id);
        recommended.push(palette);
      }
    }

    for (let i = 0; i < occ.palettes.length; i++) {
      const palette: Palette = occ.palettes[i];
      if (seenPaletteIds.includes(palette.id)) {
        continue;
      }
      seenPaletteIds.push(palette.id);
      recommended.push(palette);
    }

    return recommended;
  }

  getRecommendedPalettesForActiveOccasion(): Palette[] {
    return this.getRecommendedPalettesForOccasion(this.activeOccasionId);
  }

  getActivePalette(): Palette | undefined {
    return this.getRecommendedPalettesForActiveOccasion().find((p: Palette) => p.id === this.activePaletteId);
  }

  getSmartMatchCandidatesForActiveOccasion(): SmartMatchCandidate[] {
    return buildSmartMatchCandidates(this.getRecommendedPalettesForActiveOccasion(), this.getCollectionsForActiveOccasion());
  }

  getSmartMatchRecommendationsForActivePalette(maxResults: number = 3): SmartMatchRecommendation[] {
    const activePalette: Palette | undefined = this.getActivePalette();
    const activeOccasion: Occasion | undefined = this.getActiveOccasion();
    const primary: PaletteColorProfile | undefined = activePalette?.primaryProfile;
    if (activePalette === undefined || activeOccasion === undefined || primary === undefined) {
      return [];
    }
    const candidates: SmartMatchCandidate[] = this.getSmartMatchCandidatesForActiveOccasion();
    let recommendations: SmartMatchRecommendation[] = recommendSmartMatches({
      lang: this.currentLang,
      occasionId: activeOccasion.id,
      occasionLabel: activeOccasion.label,
      primary: primary,
      safetyPreference: 'balanced',
      styleHint: activePalette.styleTags !== undefined && activePalette.styleTags.length > 0 ? activePalette.styleTags[0] : undefined,
      excludedPaletteId: activePalette.id
    }, candidates, maxResults);
    if (recommendations.length === 0) {
      recommendations = recommendSmartMatches({
        lang: this.currentLang,
        occasionId: activeOccasion.id,
        occasionLabel: activeOccasion.label,
        primary: primary,
        safetyPreference: 'balanced',
        styleHint: activePalette.styleTags !== undefined && activePalette.styleTags.length > 0 ? activePalette.styleTags[0] : undefined,
        excludedPaletteId: undefined
      }, candidates, maxResults);
    }
    return recommendations;
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
    const recommended: Palette[] = this.getRecommendedPalettesForOccasion(occasionId);
    if (recommended.length === 0) {
      return;
    }
    this.activeOccasionId = occasionId;
    this.activePaletteId = recommended[0].id;
    this.customHex = null;
    this.flushTodayOutfitToStorage();
  }

  selectPalette(paletteId: string): void {
    if (this.activePaletteId === paletteId) {
      return;
    }
    const recommended: Palette[] = this.getRecommendedPalettesForActiveOccasion();
    if (recommended.length === 0) {
      return;
    }
    const exists = recommended.some((p: Palette) => p.id === paletteId);
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
    this.refreshCalendarDayBoundary();
    const saved: TodayOutfitState | null = readTodayOutfitState(this.persistContext);
    if (saved === null) {
      return;
    }
    this.applyTodayOutfitState(saved);
  }

  refreshCalendarDayBoundary(): void {
    this.currentCalendarDay = todayLocalYmd();
    if (this.persistContext === null) {
      return;
    }
    rollCalendarDayAndMaybeSnapshotYesterday(this.persistContext, this.currentCalendarDay);
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
    const recommended: Palette[] = this.getRecommendedPalettesForActiveOccasion();
    if (recommended.length === 0) {
      return;
    }
    const idx: number = Math.floor(Math.random() * recommended.length);
    this.activePaletteId = recommended[idx].id;
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

  getActivePaletteBaseColors(): string[] {
    const pal: Palette | undefined = this.getActivePalette();
    if (pal !== undefined && pal.colors.length >= 3) {
      return pal.colors;
    }
    return [DesignTokens.DEFAULT_MAIN, DesignTokens.DEFAULT_SEC, DesignTokens.DEFAULT_ACC];
  }

  getFineTuneCandidateHexes(roleIndex: number, maxResults: number = 12): string[] {
    const result: string[] = [];
    const pushUnique = (hex: string): void => {
      const normalized: string = hex.trim().toLowerCase();
      if (normalized.length === 0) {
        return;
      }
      for (let i = 0; i < result.length; i++) {
        if (result[i].toLowerCase() === normalized) {
          return;
        }
      }
      result.push(hex.trim());
    };

    const currentColors: string[] = this.getHeroColorStrings();
    if (roleIndex >= 0 && roleIndex < currentColors.length) {
      pushUnique(currentColors[roleIndex]);
    }

    const baseColors: string[] = this.getActivePaletteBaseColors();
    if (roleIndex >= 0 && roleIndex < baseColors.length) {
      pushUnique(baseColors[roleIndex]);
    }

    const palettes: Palette[] = this.getRecommendedPalettesForActiveOccasion();
    for (let i = 0; i < palettes.length; i++) {
      const colors: string[] = palettes[i].colors;
      if (roleIndex >= 0 && roleIndex < colors.length) {
        pushUnique(colors[roleIndex]);
      }
      if (result.length >= maxResults) {
        break;
      }
    }

    return result.slice(0, maxResults);
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
      void refreshTrackedTodayOutfitForms(this.persistContext);
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
      const fallbackPalettes: Palette[] = this.getRecommendedPalettesForActiveOccasion();
      if (fallbackPalettes.length > 0) {
        this.activePaletteId = fallbackPalettes[0].id;
      }
      return;
    }
    const recommended: Palette[] = this.getRecommendedPalettesForOccasion(occ.id);
    const pal: Palette | undefined = recommended.find((p: Palette) => p.id === this.activePaletteId);
    if (pal === undefined && recommended.length > 0) {
      this.activePaletteId = recommended[0].id;
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
    this.currentCalendarDay = todayLocalYmd();
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

  private applyResolvedLocale(lang: AppLanguage, force: boolean = false): void {
    if (this.currentLang === lang && !force) {
      return;
    }
    if (this.currentLang !== lang) {
      this.currentLang = lang;
    }
    const occ = this.getActiveOccasion();
    if (occ === undefined) {
      this.activeOccasionId = 'workday';
      const fallbackPalettes: Palette[] = this.getRecommendedPalettesForActiveOccasion();
      if (fallbackPalettes.length > 0) {
        this.activePaletteId = fallbackPalettes[0].id;
      }
      return;
    }
    const recommended: Palette[] = this.getRecommendedPalettesForOccasion(occ.id);
    const pal = recommended.find((p: Palette) => p.id === this.activePaletteId);
    if (pal === undefined && recommended.length > 0) {
      this.activePaletteId = recommended[0].id;
    }
  }
}
