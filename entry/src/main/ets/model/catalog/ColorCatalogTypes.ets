import type { UiStrings } from '../LocaleTypes';

export interface UiCatalogFile {
  version: number;
  updatedAt: string;
  ui: UiStrings;
}

export interface BaseColorCatalogItem {
  id: string;
  hex: string;
  nameZh: string;
  nameEn?: string;
  tone: string;
  lightnessLevel: string;
  saturationLevel: string;
  colorFamily: string;
  styleTags?: string[];
  occasionTags?: string[];
  seasonTags?: string[];
  isNeutralCore: boolean;
  status: string;
  notes?: string;
}

export interface BaseColorCatalogFile {
  version: number;
  updatedAt: string;
  items: BaseColorCatalogItem[];
}

export interface CatalogPaletteItem {
  id: string;
  slug: string;
  primaryColorId: string;
  secondaryColorId: string;
  accentColorId: string;
  occasionId: string;
  moodTags?: string[];
  styleTags?: string[];
  seasonTags?: string[];
  genderLean?: string;
  safetyLevel: string;
  fitPhotoScenario: boolean;
  heroTitleZh?: string;
  heroSubtitleZh?: string;
  sourceType: string;
  sourceCollectionIds?: string[];
  isPro: boolean;
  status: string;
  reviewer?: string;
  reviewNotes?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface PaletteCatalogFile {
  version: number;
  updatedAt: string;
  items: CatalogPaletteItem[];
}

export interface CollectionCatalogItem {
  id: string;
  nameZh: string;
  nameEn?: string;
  themeType: string;
  descriptionZh?: string;
  paletteIds: string[];
  coverPaletteId: string;
  occasionTags?: string[];
  styleTags?: string[];
  isPro: boolean;
  releaseMode: string;
  status: string;
}

export interface CollectionCatalogFile {
  version: number;
  updatedAt: string;
  items: CollectionCatalogItem[];
}

export interface LocaleCatalogOccasionItem {
  id: string;
  label: string;
  title: string;
  paletteIds: string[];
}

export interface LocaleCatalogPaletteTextItem {
  id: string;
  name: string;
  desc: string;
}

export interface LocaleContentCatalogFile {
  version: number;
  updatedAt: string;
  occasions: LocaleCatalogOccasionItem[];
  palettes: LocaleCatalogPaletteTextItem[];
}