import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { APP_FOREGROUND_EVENT, LOCALE_CONFIG_CHANGED_EVENT } from '../common/constants/AppEventHub';
import { DesignTokens } from '../common/constants/DesignTokens';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onConfigurationUpdate(_config: Configuration): void {
    this.context.eventHub.emit(LOCALE_CONFIG_CHANGED_EVENT);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      void windowStage.getMainWindow().then((win: window.Window) => {
        try {
          win.setWindowLayoutFullScreen(true);
        } catch (e) {
          hilog.warn(DOMAIN, 'testTag', 'setWindowLayoutFullScreen: %{public}s', JSON.stringify(e));
        }
        try {
          win.setWindowBackgroundColor(DesignTokens.BG_PAGE);
        } catch (e) {
          hilog.warn(DOMAIN, 'testTag', 'setWindowBackgroundColor: %{public}s', JSON.stringify(e));
        }
        try {
          win.setWindowSystemBarProperties({
            navigationBarColor: '#00000000'
          });
        } catch (e) {
          hilog.warn(DOMAIN, 'testTag', 'setWindowSystemBarProperties: %{public}s', JSON.stringify(e));
        }
      }).catch((e: Error) => {
        hilog.warn(DOMAIN, 'testTag', 'getMainWindow: %{public}s', JSON.stringify(e));
      });
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    this.context.eventHub.emit(APP_FOREGROUND_EVENT);
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}