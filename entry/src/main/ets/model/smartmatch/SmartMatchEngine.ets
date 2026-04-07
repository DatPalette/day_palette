import { AppLanguage } from '../AppLanguage';
import type { Collection } from '../Collection';
import type { Palette, PaletteColorProfile } from '../Palette';
import type {
  SmartMatchCandidate,
  SmartMatchInput,
  SmartMatchReason,
  SmartMatchRecommendation
} from './SmartMatchTypes';

interface ScoredCandidate {
  candidate: SmartMatchCandidate;
  score: number;
  reasons: SmartMatchReason[];
}

const DEFAULT_SAFETY_PREFERENCE: string = 'balanced';

function getOccasionTabooFamilies(occasionId: string): string[] {
  if (occasionId === 'workday') {
    return ['orange', 'red', 'purple'];
  }
  if (occasionId === 'outdoor') {
    return ['purple', 'red'];
  }
  if (occasionId === 'dinner') {
    return ['green'];
  }
  return [];
}

function getOccasionMood(lang: AppLanguage, occasionId: string): string {
  if (lang === AppLanguage.ZH) {
    if (occasionId === 'workday') {
      return '稳妥利落';
    }
    if (occasionId === 'weekend') {
      return '轻松有气色';
    }
    if (occasionId === 'outdoor') {
      return '轻盈自然';
    }
    if (occasionId === 'dinner') {
      return '克制有层次';
    }
    return '稳妥耐看';
  }
  if (occasionId === 'workday') {
    return 'polished and steady';
  }
  if (occasionId === 'weekend') {
    return 'light and easy';
  }
  if (occasionId === 'outdoor') {
    return 'airy and natural';
  }
  if (occasionId === 'dinner') {
    return 'layered and restrained';
  }
  return 'safe and wearable';
}

function normalizePaletteTags(tags?: string[]): string[] {
  return tags ?? [];
}

function uniqueStrings(values: string[]): string[] {
  const result: string[] = [];
  for (let i = 0; i < values.length; i++) {
    const value: string = values[i];
    if (!result.includes(value)) {
      result.push(value);
    }
  }
  return result;
}

function isStatementColor(profile: PaletteColorProfile): boolean {
  return profile.saturationLevel === 'high' || (!profile.isNeutralCore && profile.saturationLevel === 'mid' && profile.lightnessLevel !== 'light');
}

function isOccasionTaboo(profile: PaletteColorProfile, occasionId: string): boolean {
  const tabooFamilies: string[] = getOccasionTabooFamilies(occasionId);
  return profile.saturationLevel === 'high' && tabooFamilies.includes(profile.colorFamily);
}

function isRejectedByHardRules(input: SmartMatchInput, candidate: SmartMatchCandidate): boolean {
  const primary: PaletteColorProfile = input.primary;
  const secondary: PaletteColorProfile = candidate.secondary;
  const accent: PaletteColorProfile = candidate.accent;

  if (primary.saturationLevel === 'high' && secondary.saturationLevel === 'high' && accent.saturationLevel === 'high') {
    return true;
  }
  if (primary.lightnessLevel === 'deep' && secondary.lightnessLevel === 'deep') {
    return true;
  }
  if (isStatementColor(primary) && isStatementColor(secondary)) {
    return true;
  }
  if (accent.saturationLevel === 'high' && accent.lightnessLevel === 'light' && primary.saturationLevel !== 'high') {
    return true;
  }
  if (isOccasionTaboo(secondary, input.occasionId) || isOccasionTaboo(accent, input.occasionId)) {
    return true;
  }
  if (candidate.sourcePaletteId === 'forbidden') {
    return true;
  }
  if (candidate.safetyLevel === 'experimental' && input.safetyPreference !== 'expressive') {
    return true;
  }
  return false;
}

function buildSceneReason(input: SmartMatchInput): SmartMatchReason {
  if (input.lang === AppLanguage.ZH) {
    return {
      code: 'scene_match',
      text: `这套更适合${input.occasionLabel}，整体偏${getOccasionMood(input.lang, input.occasionId)}。`
    };
  }
  return {
    code: 'scene_match',
    text: `This set fits ${input.occasionLabel} with a ${getOccasionMood(input.lang, input.occasionId)} feel.`
  };
}

function buildLayerReason(lang: AppLanguage): SmartMatchReason {
  if (lang === AppLanguage.ZH) {
    return {
      code: 'layer_balance',
      text: '辅色负责稳定层次，点缀色只做少量提气。'
    };
  }
  return {
    code: 'layer_balance',
    text: 'The secondary holds the structure while the accent stays restrained.'
  };
}

function buildSafeReason(lang: AppLanguage): SmartMatchReason {
  if (lang === AppLanguage.ZH) {
    return {
      code: 'safe_result',
      text: '这套更稳妥，不容易出错。'
    };
  }
  return {
    code: 'safe_result',
    text: 'This option stays safer and easier to wear.'
  };
}

function buildStyleReason(lang: AppLanguage, styleHint: string): SmartMatchReason {
  if (lang === AppLanguage.ZH) {
    return {
      code: 'style_hint',
      text: `整体更靠近${styleHint}这一路线。`
    };
  }
  return {
    code: 'style_hint',
    text: `The overall direction leans closer to ${styleHint}.`
  };
}

function joinExplanation(lang: AppLanguage, reasons: SmartMatchReason[]): string {
  const texts: string[] = [];
  for (let i = 0; i < reasons.length; i++) {
    texts.push(reasons[i].text);
  }
  if (lang === AppLanguage.ZH) {
    return texts.join(' ');
  }
  return texts.join(' ');
}

function scoreCandidate(input: SmartMatchInput, candidate: SmartMatchCandidate): ScoredCandidate | null {
  if (isRejectedByHardRules(input, candidate)) {
    return null;
  }

  let score: number = 0;
  const reasons: SmartMatchReason[] = [];

  score += 2;
  reasons.push(buildSceneReason(input));

  if (candidate.secondary.isNeutralCore) {
    score += 3;
    reasons.push(buildLayerReason(input.lang));
  }
  if (candidate.collectionOccasionTags.includes(input.occasionId) || candidate.secondary.occasionTags.includes(input.occasionId)) {
    score += 2;
  }
  if (candidate.accent.saturationLevel === 'low' || candidate.accent.saturationLevel === 'mid') {
    score += 1;
  }
  if (candidate.sourceType === 'curated') {
    score += 1;
  }
  if (candidate.safetyLevel === 'safe') {
    score += 2;
    reasons.push(buildSafeReason(input.lang));
  } else if (candidate.safetyLevel === 'expressive') {
    score -= input.safetyPreference === 'expressive' ? 0 : 1;
  } else if (candidate.safetyLevel === 'experimental') {
    score -= 2;
  }
  if (input.styleHint !== undefined && input.styleHint.length > 0) {
    const mergedStyleTags: string[] = uniqueStrings(candidate.styleTags.concat(candidate.collectionStyleTags));
    if (mergedStyleTags.includes(input.styleHint)) {
      score += 1;
      reasons.push(buildStyleReason(input.lang, input.styleHint));
    }
  }
  if (candidate.primary.tone === input.primary.tone) {
    score += 1;
  }
  if (candidate.primary.lightnessLevel === input.primary.lightnessLevel) {
    score += 1;
  }

  return {
    candidate: candidate,
    score: score,
    reasons: reasons.slice(0, 3)
  };
}

export function buildSmartMatchCandidates(palettes: Palette[], collections: Collection[]): SmartMatchCandidate[] {
  const collectionOccasionTagsById: Map<string, string[]> = new Map<string, string[]>();
  const collectionStyleTagsById: Map<string, string[]> = new Map<string, string[]>();
  for (let i = 0; i < collections.length; i++) {
    const collection: Collection = collections[i];
    collectionOccasionTagsById.set(collection.id, collection.occasionTags);
    collectionStyleTagsById.set(collection.id, collection.styleTags);
  }

  const result: SmartMatchCandidate[] = [];
  for (let i = 0; i < palettes.length; i++) {
    const palette: Palette = palettes[i];
    if (palette.primaryProfile === undefined || palette.secondaryProfile === undefined || palette.accentProfile === undefined) {
      continue;
    }
    const sourceCollectionIds: string[] = normalizePaletteTags(palette.sourceCollectionIds);
    const occasionTags: string[] = [];
    const styleTagsFromCollections: string[] = [];
    for (let j = 0; j < sourceCollectionIds.length; j++) {
      const collectionId: string = sourceCollectionIds[j];
      const occasionTagsForCollection: string[] = collectionOccasionTagsById.get(collectionId) ?? [];
      const styleTagsForCollection: string[] = collectionStyleTagsById.get(collectionId) ?? [];
      for (let k = 0; k < occasionTagsForCollection.length; k++) {
        occasionTags.push(occasionTagsForCollection[k]);
      }
      for (let k = 0; k < styleTagsForCollection.length; k++) {
        styleTagsFromCollections.push(styleTagsForCollection[k]);
      }
    }

    result.push({
      sourcePaletteId: palette.id,
      sourcePaletteName: palette.name,
      occasionId: palette.occasionId ?? '',
      safetyLevel: palette.safetyLevel ?? 'safe',
      sourceType: palette.sourceType ?? 'curated',
      moodTags: normalizePaletteTags(palette.moodTags),
      styleTags: normalizePaletteTags(palette.styleTags),
      seasonTags: normalizePaletteTags(palette.seasonTags),
      fitPhotoScenario: palette.fitPhotoScenario ?? false,
      sourceCollectionIds: sourceCollectionIds,
      collectionOccasionTags: uniqueStrings(occasionTags),
      collectionStyleTags: uniqueStrings(styleTagsFromCollections),
      primary: palette.primaryProfile,
      secondary: palette.secondaryProfile,
      accent: palette.accentProfile
    });
  }
  return result;
}

export function recommendSmartMatches(
  input: SmartMatchInput,
  candidates: SmartMatchCandidate[],
  maxResults: number = 3
): SmartMatchRecommendation[] {
  const effectiveSafetyPreference: string = input.safetyPreference.length > 0 ? input.safetyPreference : DEFAULT_SAFETY_PREFERENCE;
  const normalizedInput: SmartMatchInput = {
    lang: input.lang,
    occasionId: input.occasionId,
    occasionLabel: input.occasionLabel,
    primary: input.primary,
    safetyPreference: effectiveSafetyPreference,
    styleHint: input.styleHint,
    excludedPaletteId: input.excludedPaletteId
  };

  const scored: ScoredCandidate[] = [];
  for (let i = 0; i < candidates.length; i++) {
    const candidate: SmartMatchCandidate = candidates[i];
    if (normalizedInput.excludedPaletteId !== undefined && candidate.sourcePaletteId === normalizedInput.excludedPaletteId) {
      continue;
    }
    const scoredCandidate: ScoredCandidate | null = scoreCandidate(normalizedInput, candidate);
    if (scoredCandidate === null) {
      continue;
    }
    scored.push(scoredCandidate);
  }

  scored.sort((left: ScoredCandidate, right: ScoredCandidate): number => {
    if (right.score !== left.score) {
      return right.score - left.score;
    }
    return left.candidate.sourcePaletteId.localeCompare(right.candidate.sourcePaletteId);
  });

  const uniqueRecommendations: SmartMatchRecommendation[] = [];
  const seenCombos: string[] = [];
  for (let i = 0; i < scored.length; i++) {
    const item: ScoredCandidate = scored[i];
    const comboKey: string = `${item.candidate.secondary.id}_${item.candidate.accent.id}`;
    if (seenCombos.includes(comboKey)) {
      continue;
    }
    seenCombos.push(comboKey);
    uniqueRecommendations.push({
      sourcePaletteId: item.candidate.sourcePaletteId,
      sourcePaletteName: item.candidate.sourcePaletteName,
      secondary: item.candidate.secondary,
      accent: item.candidate.accent,
      score: item.score,
      explanation: joinExplanation(normalizedInput.lang, item.reasons),
      reasons: item.reasons
    });
    if (uniqueRecommendations.length >= maxResults) {
      break;
    }
  }

  return uniqueRecommendations;
}