import type { common } from '@kit.AbilityKit';
import { AppLanguage } from '../AppLanguage';
import type { LocaleBundle } from '../LocaleTypes';
import { mapCatalogToLocaleBundle } from './ColorCatalogMapper';
import { loadBaseColorCatalog, loadCollectionCatalog, loadLocaleCatalog, loadPaletteCatalog, loadUiCatalog } from './ColorCatalogLoader';

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
    loadCollectionCatalog(context),
    loadUiCatalog(context, lang),
    loadLocaleCatalog(context, lang)
  ]);
  const baseColorCatalog = results[0];
  const paletteFile = results[1];
  const collectionFile = results[2];
  const uiFile = results[3];
  const localeFile = results[4];
  if (baseColorCatalog === null || paletteFile === null || collectionFile === null || uiFile === null || localeFile === null) {
    return null;
  }

  const bundle: LocaleBundle | null = mapCatalogToLocaleBundle(baseColorCatalog, paletteFile, uiFile, localeFile, collectionFile, lang);
  if (bundle !== null) {
    localeBundleCache.set(cacheKey, bundle);
  }
  return bundle;
}