import { AppLanguage } from '../model/AppLanguage';
import { getLocaleBundle } from '../model/LocaleData';
import type { LocaleBundle, UiStrings } from '../model/LocaleTypes';
import type { Occasion } from '../model/Occasion';
import type { Palette } from '../model/Palette';

@Observed
export class DayPaletteViewModel {
  /** 与 HTML 默认 `currentLang` 一致。 */
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

  /** 设置语言；跨语言 id 一致，若当前 palette 不在新 bundle 中则回退到该场合首项。 */
  setLanguage(lang: AppLanguage): void {
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
