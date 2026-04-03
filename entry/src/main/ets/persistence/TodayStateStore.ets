import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import type { TodayOutfitState } from '../model/TodayOutfitState';
import { parseTodayOutfitStateJson, stringifyTodayOutfitState } from '../model/TodayOutfitState';

const SETTINGS_FLUSH_DEBOUNCE_MS: number = 180;

/** 本地日历日 YYYY-MM-DD（用于跨日「昨日」快照）。 */
function localYmdWithOffset(offsetDays: number): string {
  const d: Date = new Date();
  d.setDate(d.getDate() + offsetDays);
  const y: number = d.getFullYear();
  const m: string = (d.getMonth() + 1).toString().padStart(2, '0');
  const day: string = d.getDate().toString().padStart(2, '0');
  return `${y}-${m}-${day}`;
}

export function todayLocalYmd(): string {
  return localYmdWithOffset(0);
}

export function yesterdayLocalYmd(): string {
  return localYmdWithOffset(-1);
}

const PREF_NAME: string = 'day_palette_today';
const KEY_OUTFIT_JSON: string = 'today_outfit_state_json';
const KEY_OUTFIT_CALENDAR_DAY: string = 'today_outfit_calendar_day';
const KEY_LAST_CALENDAR_DAY: string = 'last_open_calendar_day';
const KEY_YESTERDAY_OUTFIT_JSON: string = 'yesterday_outfit_state_json';
const KEY_YESTERDAY_OUTFIT_CALENDAR_DAY: string = 'yesterday_outfit_calendar_day';
const KEY_REDUCE_MOTION: string = 'reduce_motion_enabled';
const KEY_NOISE_OVERLAY: string = 'noise_overlay_enabled';
const KEY_MINI_PREVIEW_STYLE: string = 'mini_preview_style';

let prefCache: preferences.Preferences | null = null;
let prefCacheReady: boolean = false;
let settingsFlushTimerId: number | null = null;

function getPref(context: common.Context): preferences.Preferences | null {
  if (prefCacheReady) {
    return prefCache;
  }
  try {
    prefCache = preferences.getPreferencesSync(context, { name: PREF_NAME });
    prefCacheReady = true;
    return prefCache;
  } catch {
    prefCache = null;
    prefCacheReady = true;
    return null;
  }
}

function flushPrefNow(pref: preferences.Preferences): void {
  pref.flush();
}

function scheduleSettingsPrefFlush(pref: preferences.Preferences): void {
  if (settingsFlushTimerId !== null) {
    clearTimeout(settingsFlushTimerId);
  }
  settingsFlushTimerId = setTimeout((): void => {
    settingsFlushTimerId = null;
    try {
      flushPrefNow(pref);
    } catch {
    }
  }, SETTINGS_FLUSH_DEBOUNCE_MS);
}

export function readTodayOutfitState(context: common.Context): TodayOutfitState | null {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return null;
    }
    const raw: string = pref.getSync(KEY_OUTFIT_JSON, '') as string;
    if (raw.length === 0) {
      return null;
    }
    return parseTodayOutfitStateJson(raw);
  } catch {
    return null;
  }
}

export function writeTodayOutfitState(context: common.Context, state: TodayOutfitState): void {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return;
    }
    pref.putSync(KEY_OUTFIT_JSON, stringifyTodayOutfitState(state));
    pref.putSync(KEY_OUTFIT_CALENDAR_DAY, todayLocalYmd());
    flushPrefNow(pref);
  } catch {
  }
}

export function readTodayOutfitCalendarDay(context: common.Context): string {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return '';
    }
    return pref.getSync(KEY_OUTFIT_CALENDAR_DAY, '') as string;
  } catch {
    return '';
  }
}

export function readLastCalendarOpenDay(context: common.Context): string {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return '';
    }
    return pref.getSync(KEY_LAST_CALENDAR_DAY, '') as string;
  } catch {
    return '';
  }
}

export function writeLastCalendarOpenDay(context: common.Context, day: string): void {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return;
    }
    pref.putSync(KEY_LAST_CALENDAR_DAY, day);
    flushPrefNow(pref);
  } catch {
  }
}

export function writeYesterdayOutfitState(context: common.Context, state: TodayOutfitState, day: string): void {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return;
    }
    pref.putSync(KEY_YESTERDAY_OUTFIT_JSON, stringifyTodayOutfitState(state));
    pref.putSync(KEY_YESTERDAY_OUTFIT_CALENDAR_DAY, day);
    flushPrefNow(pref);
  } catch {
  }
}

export function readYesterdayOutfitState(context: common.Context): TodayOutfitState | null {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return null;
    }
    const raw: string = pref.getSync(KEY_YESTERDAY_OUTFIT_JSON, '') as string;
    if (raw.length === 0) {
      return null;
    }
    return parseTodayOutfitStateJson(raw);
  } catch {
    return null;
  }
}

export function readYesterdayOutfitCalendarDay(context: common.Context): string {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return '';
    }
    return pref.getSync(KEY_YESTERDAY_OUTFIT_CALENDAR_DAY, '') as string;
  } catch {
    return '';
  }
}

/** 跨自然日首次打开时：将当前存档快照写入「昨日」槽，便于沿用昨日套组。 */
export function rollCalendarDayAndMaybeSnapshotYesterday(context: common.Context, todayLocal: string): void {
  const last: string = readLastCalendarOpenDay(context);
  if (last === todayLocal) {
    return;
  }
  const current: TodayOutfitState | null = readTodayOutfitState(context);
  const draftDay: string = readTodayOutfitCalendarDay(context);
  if (current !== null && draftDay === yesterdayLocalYmd()) {
    writeYesterdayOutfitState(context, current, draftDay);
  }
  writeLastCalendarOpenDay(context, todayLocal);
}

export function readReduceMotionEnabled(context: common.Context): boolean {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return false;
    }
    return pref.getSync(KEY_REDUCE_MOTION, false) as boolean;
  } catch {
    return false;
  }
}

export function writeReduceMotionEnabled(context: common.Context, enabled: boolean): void {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return;
    }
    pref.putSync(KEY_REDUCE_MOTION, enabled);
    scheduleSettingsPrefFlush(pref);
  } catch {
  }
}

export function readNoiseOverlayEnabled(context: common.Context): boolean {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return false;
    }
    return pref.getSync(KEY_NOISE_OVERLAY, false) as boolean;
  } catch {
    return false;
  }
}

export function writeNoiseOverlayEnabled(context: common.Context, enabled: boolean): void {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return;
    }
    pref.putSync(KEY_NOISE_OVERLAY, enabled);
    scheduleSettingsPrefFlush(pref);
  } catch {
  }
}

export function readMiniPreviewStyleRaw(context: common.Context): string {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return '';
    }
    return pref.getSync(KEY_MINI_PREVIEW_STYLE, '') as string;
  } catch {
    return '';
  }
}

export function writeMiniPreviewStyleRaw(context: common.Context, style: string): void {
  try {
    const pref: preferences.Preferences | null = getPref(context);
    if (pref === null) {
      return;
    }
    pref.putSync(KEY_MINI_PREVIEW_STYLE, style);
    scheduleSettingsPrefFlush(pref);
  } catch {
  }
}
