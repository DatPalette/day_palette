import type { common } from '@kit.AbilityKit';
import { AppLanguage } from '../AppLanguage';
import type { BaseColorCatalogFile, CollectionCatalogFile, LocaleContentCatalogFile, PaletteCatalogFile, UiCatalogFile } from './ColorCatalogTypes';

const BASE_COLORS_PATH: string = 'palette-data/base-colors.v1.json';
const PALETTES_PATH: string = 'palette-data/palettes.v1.json';
const COLLECTIONS_PATH: string = 'palette-data/collections.v1.json';
const ZH_LOCALE_PATH: string = 'palette-data/locale/zh-CN.v1.json';
const EN_LOCALE_PATH: string = 'palette-data/locale/en-US.v1.json';
const ZH_UI_PATH: string = 'i18n/ui/zh-CN.v1.json';
const EN_UI_PATH: string = 'i18n/ui/en-US.v1.json';

function bytesToUtf8(bytes: Uint8Array): string {
  let encoded: string = '';
  for (let i = 0; i < bytes.length; i++) {
    const value: string = bytes[i].toString(16).padStart(2, '0');
    encoded += `%${value}`;
  }
  return decodeURIComponent(encoded);
}

async function readJsonRawFile<T>(context: common.UIAbilityContext, path: string): Promise<T | null> {
  try {
    const raw: Uint8Array = await context.resourceManager.getRawFileContent(path);
    if (raw.length === 0) {
      return null;
    }
    const text: string = bytesToUtf8(raw);
    return JSON.parse(text) as T;
  } catch {
    return null;
  }
}

export function loadPaletteCatalog(context: common.UIAbilityContext): Promise<PaletteCatalogFile | null> {
  return readJsonRawFile<PaletteCatalogFile>(context, PALETTES_PATH);
}

export function loadBaseColorCatalog(context: common.UIAbilityContext): Promise<BaseColorCatalogFile | null> {
  return readJsonRawFile<BaseColorCatalogFile>(context, BASE_COLORS_PATH);
}

export function loadCollectionCatalog(context: common.UIAbilityContext): Promise<CollectionCatalogFile | null> {
  return readJsonRawFile<CollectionCatalogFile>(context, COLLECTIONS_PATH);
}

export function loadLocaleCatalog(
  context: common.UIAbilityContext,
  lang: AppLanguage
): Promise<LocaleContentCatalogFile | null> {
  const path: string = lang === AppLanguage.ZH ? ZH_LOCALE_PATH : EN_LOCALE_PATH;
  return readJsonRawFile<LocaleContentCatalogFile>(context, path);
}

export function loadUiCatalog(
  context: common.UIAbilityContext,
  lang: AppLanguage
): Promise<UiCatalogFile | null> {
  const path: string = lang === AppLanguage.ZH ? ZH_UI_PATH : EN_UI_PATH;
  return readJsonRawFile<UiCatalogFile>(context, path);
}