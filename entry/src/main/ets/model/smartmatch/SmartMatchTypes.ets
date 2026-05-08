import { AppLanguage } from '../AppLanguage';
import type { PaletteColorProfile } from '../Palette';

export interface SmartMatchInput {
  lang: AppLanguage;
  occasionId: string;
  occasionLabel: string;
  primary: PaletteColorProfile;
  safetyPreference: string;
  styleHint?: string;
  excludedPaletteId?: string;
}

export interface SmartMatchCandidate {
  sourcePaletteId: string;
  sourcePaletteName: string;
  occasionId: string;
  safetyLevel: string;
  sourceType: string;
  moodTags: string[];
  styleTags: string[];
  seasonTags: string[];
  fitPhotoScenario: boolean;
  sourceCollectionIds: string[];
  collectionOccasionTags: string[];
  collectionStyleTags: string[];
  primary: PaletteColorProfile;
  secondary: PaletteColorProfile;
  accent: PaletteColorProfile;
}

export interface SmartMatchReason {
  code: string;
  text: string;
}

export interface SmartMatchRecommendation {
  sourcePaletteId: string;
  sourcePaletteName: string;
  secondary: PaletteColorProfile;
  accent: PaletteColorProfile;
  score: number;
  explanation: string;
  reasons: SmartMatchReason[];
}