import { AppLanguage } from '../AppLanguage';
import type { Collection } from '../Collection';
import type { LocaleBundle } from '../LocaleTypes';
import type { Occasion } from '../Occasion';
import type { Palette, PaletteColorProfile } from '../Palette';
import type {
  BaseColorCatalogFile,
  BaseColorCatalogItem,
  CatalogPaletteItem,
  CollectionCatalogFile,
  CollectionCatalogItem,
  LocaleContentCatalogFile,
  LocaleCatalogPaletteTextItem,
  PaletteCatalogFile,
  UiCatalogFile
} from './ColorCatalogTypes';

function normalizeTags(tags?: string[]): string[] {
  return tags ?? [];
}

function mapPaletteColorProfile(item: BaseColorCatalogItem): PaletteColorProfile {
  return {
    id: item.id,
    hex: item.hex,
    tone: item.tone,
    lightnessLevel: item.lightnessLevel,
    saturationLevel: item.saturationLevel,
    colorFamily: item.colorFamily,
    isNeutralCore: item.isNeutralCore,
    styleTags: normalizeTags(item.styleTags),
    occasionTags: normalizeTags(item.occasionTags),
    seasonTags: normalizeTags(item.seasonTags)
  };
}

function mapPaletteFromCatalog(
  paletteId: string,
  colorById: Map<string, BaseColorCatalogItem>,
  paletteById: Map<string, CatalogPaletteItem>,
  paletteTextById: Map<string, LocaleCatalogPaletteTextItem>
): Palette | null {
  const colorItem = paletteById.get(paletteId);
  const textItem = paletteTextById.get(paletteId);
  if (colorItem === undefined || textItem === undefined) {
    return null;
  }
  const primaryColor = colorById.get(colorItem.primaryColorId);
  const secondaryColor = colorById.get(colorItem.secondaryColorId);
  const accentColor = colorById.get(colorItem.accentColorId);
  if (primaryColor === undefined || secondaryColor === undefined || accentColor === undefined) {
    return null;
  }
  return {
    id: colorItem.id,
    name: textItem.name,
    desc: textItem.desc,
    colors: [primaryColor.hex, secondaryColor.hex, accentColor.hex],
    occasionId: colorItem.occasionId,
    safetyLevel: colorItem.safetyLevel,
    moodTags: normalizeTags(colorItem.moodTags),
    styleTags: normalizeTags(colorItem.styleTags),
    seasonTags: normalizeTags(colorItem.seasonTags),
    sourceType: colorItem.sourceType,
    sourceCollectionIds: normalizeTags(colorItem.sourceCollectionIds),
    fitPhotoScenario: colorItem.fitPhotoScenario,
    primaryProfile: mapPaletteColorProfile(primaryColor),
    secondaryProfile: mapPaletteColorProfile(secondaryColor),
    accentProfile: mapPaletteColorProfile(accentColor)
  };
}

function mapCollectionName(item: CollectionCatalogItem, lang: AppLanguage): string {
  if (lang === AppLanguage.EN && item.nameEn !== undefined && item.nameEn.length > 0) {
    return item.nameEn;
  }
  return item.nameZh;
}

function mapCollectionDesc(item: CollectionCatalogItem, lang: AppLanguage): string {
  if (lang === AppLanguage.EN) {
    return '';
  }
  return item.descriptionZh ?? '';
}

export function mapCatalogToLocaleBundle(
  baseColorCatalog: BaseColorCatalogFile,
  paletteCatalog: PaletteCatalogFile,
  uiCatalog: UiCatalogFile,
  localeCatalog: LocaleContentCatalogFile,
  collectionCatalog: CollectionCatalogFile,
  lang: AppLanguage
): LocaleBundle | null {
  if (baseColorCatalog.items.length === 0 || paletteCatalog.items.length === 0 || localeCatalog.occasions.length === 0) {
    return null;
  }

  const colorById: Map<string, BaseColorCatalogItem> = new Map<string, BaseColorCatalogItem>();
  for (let i = 0; i < baseColorCatalog.items.length; i++) {
    const item: BaseColorCatalogItem = baseColorCatalog.items[i];
    colorById.set(item.id, item);
  }

  const paletteById: Map<string, CatalogPaletteItem> = new Map<string, CatalogPaletteItem>();
  for (let i = 0; i < paletteCatalog.items.length; i++) {
    const item: CatalogPaletteItem = paletteCatalog.items[i];
    paletteById.set(item.id, item);
  }

  const paletteTextById: Map<string, LocaleCatalogPaletteTextItem> = new Map<string, LocaleCatalogPaletteTextItem>();
  for (let i = 0; i < localeCatalog.palettes.length; i++) {
    const item: LocaleCatalogPaletteTextItem = localeCatalog.palettes[i];
    paletteTextById.set(item.id, item);
  }

  const occasions: Occasion[] = [];
  for (let i = 0; i < localeCatalog.occasions.length; i++) {
    const occ = localeCatalog.occasions[i];
    const palettes: Palette[] = [];
    for (let j = 0; j < occ.paletteIds.length; j++) {
      const paletteId: string = occ.paletteIds[j];
      const paletteItem = paletteById.get(paletteId);
      if (paletteItem === undefined) {
        continue;
      }
      if (paletteItem.occasionId !== occ.id) {
        continue;
      }
      const palette: Palette | null = mapPaletteFromCatalog(paletteId, colorById, paletteById, paletteTextById);
      if (palette === null) {
        continue;
      }
      palettes.push(palette);
    }
    if (palettes.length === 0) {
      continue;
    }
    occasions.push({
      id: occ.id,
      label: occ.label,
      title: occ.title,
      palettes: palettes
    });
  }

  const collections: Collection[] = [];
  for (let i = 0; i < collectionCatalog.items.length; i++) {
    const item: CollectionCatalogItem = collectionCatalog.items[i];
    const palettes: Palette[] = [];
    for (let j = 0; j < item.paletteIds.length; j++) {
      const palette: Palette | null = mapPaletteFromCatalog(item.paletteIds[j], colorById, paletteById, paletteTextById);
      if (palette === null) {
        continue;
      }
      palettes.push(palette);
    }
    if (palettes.length === 0) {
      continue;
    }
    collections.push({
      id: item.id,
      name: mapCollectionName(item, lang),
      desc: mapCollectionDesc(item, lang),
      themeType: item.themeType,
      coverPaletteId: item.coverPaletteId,
      occasionTags: item.occasionTags ?? [],
      styleTags: item.styleTags ?? [],
      palettes: palettes
    });
  }

  if (occasions.length === 0) {
    return null;
  }

  return {
    ui: uiCatalog.ui,
    collections: collections,
    occasions: occasions
  };
}