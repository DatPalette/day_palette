import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { AppLanguage } from './AppLanguage';

const PREF_NAME: string = 'day_palette_settings';
const KEY_LANG_OVERRIDE: string = 'language_override';

function getPrefSafe(context: common.UIAbilityContext): preferences.Preferences | null {
  try {
    return preferences.getPreferencesSync(context, { name: PREF_NAME });
  } catch {
    return null;
  }
}

/** 有值表示用户手动指定；无键或空表示跟随系统。 */
export function readLanguageOverride(context: common.UIAbilityContext): AppLanguage | null {
  try {
    const pref: preferences.Preferences | null = getPrefSafe(context);
    if (pref === null) {
      return null;
    }
    const raw: string = pref.getSync(KEY_LANG_OVERRIDE, '') as string;
    if (raw === 'zh') {
      return AppLanguage.ZH;
    }
    if (raw === 'en') {
      return AppLanguage.EN;
    }
    return null;
  } catch {
    return null;
  }
}

export function writeLanguageOverride(context: common.UIAbilityContext, override: AppLanguage | null): void {
  try {
    const pref: preferences.Preferences | null = getPrefSafe(context);
    if (pref === null) {
      return;
    }
    if (override === null) {
      pref.deleteSync(KEY_LANG_OVERRIDE);
    } else {
      pref.putSync(KEY_LANG_OVERRIDE, override === AppLanguage.ZH ? 'zh' : 'en');
    }
    pref.flush();
  } catch {
  }
}
