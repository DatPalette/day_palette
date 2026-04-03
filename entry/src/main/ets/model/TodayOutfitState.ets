import { DesignTokens } from '../common/constants/DesignTokens';

/**
 * 与 docs/architecture/data-model.md TodayOutfitState 对齐；
 * activePaletteId 用于恢复 UI 选中项（JSON 资源侧 id）。
 */
export interface TodayOutfitState {
  schemaVersion: number;
  primaryColor: string;
  secondaryColor: string;
  accentColor: string;
  occasionId: string | null;
  activePaletteId: string;
  shortNote: string;
  templateId: string;
  layoutVariantId: string | null;
  featureFlags: number | null;
  ext: Record<string, string>;
  updatedAt: number;
}

const SCHEMA_VERSION: number = 1;
export const DEFAULT_TEMPLATE_ID: string = 'tpl_editorial_v1';

export function createDefaultTodayOutfitState(): TodayOutfitState {
  const now: number = Date.now();
  return {
    schemaVersion: SCHEMA_VERSION,
    primaryColor: DesignTokens.DEFAULT_MAIN,
    secondaryColor: DesignTokens.DEFAULT_SEC,
    accentColor: DesignTokens.DEFAULT_ACC,
    occasionId: 'workday',
    activePaletteId: 'w1',
    shortNote: '',
    templateId: DEFAULT_TEMPLATE_ID,
    layoutVariantId: null,
    featureFlags: null,
    ext: {},
    updatedAt: now
  };
}

interface TodayOutfitStateRaw {
  schemaVersion?: number;
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  occasionId?: string | null;
  activePaletteId?: string;
  shortNote?: string;
  templateId?: string;
  layoutVariantId?: string | null;
  featureFlags?: number | null;
  updatedAt?: number;
}

export function parseTodayOutfitStateJson(raw: string): TodayOutfitState | null {
  try {
    const r = JSON.parse(raw) as TodayOutfitStateRaw;
    if (r.schemaVersion !== undefined && r.schemaVersion !== 1) {
      return null;
    }
    if (r.primaryColor === undefined || r.secondaryColor === undefined || r.accentColor === undefined) {
      return null;
    }
    if (r.activePaletteId === undefined) {
      return null;
    }
    const shortNote = r.shortNote ?? '';
    const sn = shortNote.length > 20 ? shortNote.substring(0, 20) : shortNote;
    return {
      schemaVersion: SCHEMA_VERSION,
      primaryColor: r.primaryColor,
      secondaryColor: r.secondaryColor,
      accentColor: r.accentColor,
      occasionId: typeof r.occasionId === 'string' ? r.occasionId : null,
      activePaletteId: r.activePaletteId,
      shortNote: sn,
      templateId: r.templateId ?? DEFAULT_TEMPLATE_ID,
      layoutVariantId: r.layoutVariantId ?? null,
      featureFlags: r.featureFlags ?? null,
      ext: {},
      updatedAt: r.updatedAt ?? Date.now()
    };
  } catch {
    return null;
  }
}

export function stringifyTodayOutfitState(state: TodayOutfitState): string {
  return JSON.stringify(state);
}
