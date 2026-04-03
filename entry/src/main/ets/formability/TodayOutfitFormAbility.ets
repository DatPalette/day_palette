import { FormExtensionAbility, formProvider } from '@kit.FormKit';
import { type Want } from '@kit.AbilityKit';
import {
  buildTodayOutfitFormBinding,
  extractFormIdFromWant,
  trackTodayOutfitFormId,
  untrackTodayOutfitFormId
} from './TodayOutfitFormSync';

export default class TodayOutfitFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): ESObject {
    trackTodayOutfitFormId(this.context, extractFormIdFromWant(want));
    return buildTodayOutfitFormBinding(this.context) as ESObject;
  }

  onUpdateForm(formId: string): void {
    try {
      trackTodayOutfitFormId(this.context, formId);
      void formProvider.updateForm(formId, buildTodayOutfitFormBinding(this.context));
    } catch (_e) {
    }
  }

  onRemoveForm(formId: string): void {
    untrackTodayOutfitFormId(this.context, formId);
  }
}
