import type { common } from '@kit.AbilityKit';
import { AppLanguage } from '../model/AppLanguage';
import { readLanguageOverride, writeLanguageOverride } from '../model/LanguagePreferenceStore';
import { getLocaleBundle } from '../model/LocaleData';
import type { LocaleBundle, UiStrings } from '../model/LocaleTypes';
import type { Occasion } from '../model/Occasion';
import type { Palette } from '../model/Palette';
import { getSystemAppLanguage } from '../model/SystemLanguageResolver';

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
  }

  /** 从本地恢复手动覆盖并应用当前有效语言（应在首屏 build 前调用）。 */
  loadLanguageFromStorage(context: common.UIAbilityContext): void {
    this.manualLanguage = readLanguageOverride(context);
    const effective: AppLanguage = this.manualLanguage ?? getSystemAppLanguage();
    this.applyResolvedLocale(effective);
  }

  /** 系统区域/语言变化且当前为「跟随系统」时调用。 */
  refreshLocaleIfFollowingSystem(context: common.UIAbilityContext): void {
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
