import type { LocaleBundle } from '../LocaleTypes';
import type { Occasion } from '../Occasion';
import type { Palette } from '../Palette';
import type {
  BaseColorCatalogFile,
  BaseColorCatalogItem,
  CatalogPaletteItem,
  LocaleContentCatalogFile,
  LocaleCatalogPaletteTextItem,
  PaletteCatalogFile,
  UiCatalogFile
} from './ColorCatalogTypes';

export function mapCatalogToLocaleBundle(
  baseColorCatalog: BaseColorCatalogFile,
  paletteCatalog: PaletteCatalogFile,
  uiCatalog: UiCatalogFile,
  localeCatalog: LocaleContentCatalogFile
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
      const colorItem = paletteById.get(paletteId);
      const textItem = paletteTextById.get(paletteId);
      if (colorItem === undefined || textItem === undefined) {
        continue;
      }
      if (colorItem.occasionId !== occ.id) {
        continue;
      }
      const primaryColor = colorById.get(colorItem.primaryColorId);
      const secondaryColor = colorById.get(colorItem.secondaryColorId);
      const accentColor = colorById.get(colorItem.accentColorId);
      if (primaryColor === undefined || secondaryColor === undefined || accentColor === undefined) {
        continue;
      }
      palettes.push({
        id: colorItem.id,
        name: textItem.name,
        desc: textItem.desc,
        colors: [primaryColor.hex, secondaryColor.hex, accentColor.hex]
      });
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

  if (occasions.length === 0) {
    return null;
  }

  return {
    ui: uiCatalog.ui,
    occasions: occasions
  };
}