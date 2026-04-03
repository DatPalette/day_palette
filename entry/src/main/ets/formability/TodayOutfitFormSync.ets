import { FormExtensionAbility, formBindingData, formProvider } from '@kit.FormKit';
import { preferences } from '@kit.ArkData';
import { common, type Want } from '@kit.AbilityKit';
import { getLocaleBundle } from '../model/LocaleData';
import { getSystemAppLanguage } from '../model/SystemLanguageResolver';
import { createDefaultTodayOutfitState } from '../model/TodayOutfitState';
import type { TodayOutfitState } from '../model/TodayOutfitState';
import { readTodayOutfitState } from '../persistence/TodayStateStore';

const FORM_SYNC_PREF_NAME: string = 'day_palette_form_sync';
const KEY_FORM_IDS_JSON: string = 'today_outfit_form_ids_json';
const FORM_IDENTITY_KEY: string = 'ohos.extra.param.key.form_identity';

interface WantWithParameters {
  parameters?: Record<string, Object>;
}

function getFormSyncPref(context: common.Context): preferences.Preferences | null {
  try {
    return preferences.getPreferencesSync(context, { name: FORM_SYNC_PREF_NAME });
  } catch {
    return null;
  }
}

function readTrackedFormIds(context: common.Context): string[] {
  try {
    const pref: preferences.Preferences | null = getFormSyncPref(context);
    if (pref === null) {
      return [];
    }
    const raw: string = pref.getSync(KEY_FORM_IDS_JSON, '[]') as string;
    const parsed: Object = JSON.parse(raw) as Object;
    if (!Array.isArray(parsed)) {
      return [];
    }
    const ids: string[] = [];
    for (let i: number = 0; i < parsed.length; i++) {
      const value: Object = parsed[i];
      if (typeof value === 'string' && value.length > 0 && ids.indexOf(value) < 0) {
        ids.push(value);
      }
    }
    return ids;
  } catch {
    return [];
  }
}

function writeTrackedFormIds(context: common.Context, ids: string[]): void {
  try {
    const pref: preferences.Preferences | null = getFormSyncPref(context);
    if (pref === null) {
      return;
    }
    pref.putSync(KEY_FORM_IDS_JSON, JSON.stringify(ids));
    pref.flush();
  } catch {
  }
}

export function extractFormIdFromWant(want: Want): string {
  const withParams: WantWithParameters = want as WantWithParameters;
  const value: Object | undefined = withParams.parameters?.[FORM_IDENTITY_KEY];
  return typeof value === 'string' ? value : '';
}

export function trackTodayOutfitFormId(context: common.Context, formId: string): void {
  if (formId.length === 0) {
    return;
  }
  const ids: string[] = readTrackedFormIds(context);
  if (ids.indexOf(formId) >= 0) {
    return;
  }
  ids.push(formId);
  writeTrackedFormIds(context, ids);
}

export function untrackTodayOutfitFormId(context: common.Context, formId: string): void {
  if (formId.length === 0) {
    return;
  }
  const ids: string[] = readTrackedFormIds(context);
  const nextIds: string[] = ids.filter((id: string) => id !== formId);
  if (nextIds.length === ids.length) {
    return;
  }
  writeTrackedFormIds(context, nextIds);
}

export function buildTodayOutfitFormBinding(context: common.Context): formBindingData.FormBindingData {
  const raw: TodayOutfitState | null = readTodayOutfitState(context);
  const state: TodayOutfitState = raw !== null ? raw : createDefaultTodayOutfitState();
  const bundle = getLocaleBundle(getSystemAppLanguage());
  const oid: string = state.occasionId !== null && state.occasionId.length > 0 ? state.occasionId : 'workday';
  const occ = bundle.occasions.find((o) => o.id === oid);
  const occasionLabel: string = occ !== undefined ? occ.label : '—';
  return formBindingData.createFormBindingData({
    primaryColor: state.primaryColor,
    secondaryColor: state.secondaryColor,
    accentColor: state.accentColor,
    occasionLabel: occasionLabel,
    shortNote: state.shortNote
  });
}

export async function refreshTrackedTodayOutfitForms(context: common.Context): Promise<void> {
  const ids: string[] = readTrackedFormIds(context);
  if (ids.length === 0) {
    return;
  }
  const binding: formBindingData.FormBindingData = buildTodayOutfitFormBinding(context);
  for (let i: number = 0; i < ids.length; i++) {
    const formId: string = ids[i];
    try {
      await formProvider.updateForm(formId, binding);
    } catch {
    }
  }
}