import { FormExtensionAbility, formBindingData, formProvider } from '@kit.FormKit';
import { common, type Want } from '@kit.AbilityKit';
import { getLocaleBundle } from '../model/LocaleData';
import { getSystemAppLanguage } from '../model/SystemLanguageResolver';
import { createDefaultTodayOutfitState } from '../model/TodayOutfitState';
import type { TodayOutfitState } from '../model/TodayOutfitState';
import { readTodayOutfitState } from '../persistence/TodayStateStore';

function buildBinding(context: common.Context): ESObject {
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
  }) as ESObject;
}

export default class TodayOutfitFormAbility extends FormExtensionAbility {
  onAddForm(_want: Want): ESObject {
    return buildBinding(this.context);
  }

  onUpdateForm(formId: string): void {
    try {
      formProvider.updateForm(formId, buildBinding(this.context));
    } catch (_e) {
    }
  }
}
