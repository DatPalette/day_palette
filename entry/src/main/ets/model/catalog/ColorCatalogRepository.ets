import type { common } from '@kit.AbilityKit';
import { AppLanguage } from '../AppLanguage';
import type { LocaleBundle } from '../LocaleTypes';
import { mapCatalogToLocaleBundle } from './ColorCatalogMapper';
import { loadBaseColorCatalog, loadLocaleCatalog, loadPaletteCatalog, loadUiCatalog } from './ColorCatalogLoader';

const localeBundleCache: Map<string, LocaleBundle> = new Map<string, LocaleBundle>();

export async function loadLocaleBundleFromCatalog(
  context: common.UIAbilityContext,
  lang: AppLanguage
): Promise<LocaleBundle | null> {
  const cacheKey: string = lang;
  const cached: LocaleBundle | undefined = localeBundleCache.get(cacheKey);
  if (cached !== undefined) {
    return cached;
  }

  const results = await Promise.all([
    loadBaseColorCatalog(context),
    loadPaletteCatalog(context),
    loadUiCatalog(context, lang),
    loadLocaleCatalog(context, lang)
  ]);
  const baseColorCatalog = results[0];
  const paletteFile = results[1];
  const uiFile = results[2];
  const localeFile = results[3];
  if (baseColorCatalog === null || paletteFile === null || uiFile === null || localeFile === null) {
    return null;
  }

  const bundle: LocaleBundle | null = mapCatalogToLocaleBundle(baseColorCatalog, paletteFile, uiFile, localeFile);
  if (bundle !== null) {
    localeBundleCache.set(cacheKey, bundle);
  }
  return bundle;
}