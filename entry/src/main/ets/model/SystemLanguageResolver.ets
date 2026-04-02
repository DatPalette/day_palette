import { i18n } from '@kit.LocalizationKit';
import { AppLanguage } from './AppLanguage';

/** 将系统语言映射为应用支持的语言（其余一律英文）。 */
export function getSystemAppLanguage(): AppLanguage {
  try {
    const tag: string = i18n.System.getSystemLanguage();
    if (tag && tag.toLowerCase().startsWith('zh')) {
      return AppLanguage.ZH;
    }
  } catch {
  }
  return AppLanguage.EN;
}
