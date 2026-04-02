import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { LOCALE_CONFIG_CHANGED_EVENT } from '../common/constants/AppEventHub';
import { getBottomGestureBarHeightPx } from '../common/window/NavigationIndicatorInset';
import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { TopBarView } from '../components/TopBarView';
import { HeroDisplayView } from '../components/HeroDisplayView';
import { OccasionSelectorView } from '../components/OccasionSelectorView';
import { PaletteSelectorView } from '../components/PaletteSelectorView';
import { BottomActionsView } from '../components/BottomActionsView';
import { SettingsPanelView } from '../components/SettingsPanelView';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';

@Entry
@Component
struct Index {
  @State vm: DayPaletteViewModel = new DayPaletteViewModel();
  private scroller: Scroller = new Scroller();
  @State mainScrollY: number = 0;
  @State isSettingsOpen: boolean = false;
  /** 底部导航指示条 / 手势区高度（vp），用于底栏内边距与主列表底部留白 */
  @State bottomGestureInsetVp: number = 0;
  private localeEventHandler: (() => void) | undefined = undefined;
  private bottomWindowRef: window.Window | undefined = undefined;
  private avoidAreaChangeHandler = (data: window.AvoidAreaOptions): void => {
    if (data.type === window.AvoidAreaType.TYPE_SYSTEM ||
      data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR ||
      data.type === window.AvoidAreaType.TYPE_SYSTEM_GESTURE) {
      if (this.bottomWindowRef !== undefined) {
        this.applyBottomGestureInsetFromWindow(this.bottomWindowRef);
      }
    }
  };

  aboutToAppear(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.vm.loadLanguageFromStorage(ctx);
    this.localeEventHandler = (): void => {
      const host = this.getUIContext().getHostContext() as common.UIAbilityContext;
      this.vm.refreshLocaleIfFollowingSystem(host);
    };
    ctx.eventHub.on(LOCALE_CONFIG_CHANGED_EVENT, this.localeEventHandler);
    this.attachBottomGestureInsetListener(ctx);
  }

  aboutToDisappear(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (this.localeEventHandler !== undefined) {
      ctx.eventHub.off(LOCALE_CONFIG_CHANGED_EVENT, this.localeEventHandler);
      this.localeEventHandler = undefined;
    }
    this.detachBottomGestureInsetListener();
  }

  private applyBottomGestureInsetFromWindow(win: window.Window): void {
    const px: number = getBottomGestureBarHeightPx(win);
    let vp: number = px2vp(px);
    if (px <= 0 || vp <= 0) {
      vp = LayoutConstants.BOTTOM_INDICATOR_FALLBACK_VP;
    }
    this.bottomGestureInsetVp = vp;
  }

  private attachBottomGestureInsetListener(ctx: common.UIAbilityContext): void {
    const bind = (win: window.Window): void => {
      if (this.bottomWindowRef === undefined) {
        this.bottomWindowRef = win;
        win.on('avoidAreaChange', this.avoidAreaChangeHandler);
      }
      this.applyBottomGestureInsetFromWindow(win);
    };
    void window.getLastWindow(ctx).then(bind).catch(() => {
    });
    setTimeout((): void => {
      void window.getLastWindow(ctx).then(bind).catch(() => {
      });
    }, 100);
  }

  private detachBottomGestureInsetListener(): void {
    if (this.bottomWindowRef !== undefined) {
      try {
        this.bottomWindowRef.off('avoidAreaChange', this.avoidAreaChangeHandler);
      } catch {
      }
      this.bottomWindowRef = undefined;
    }
  }

  private scrollMainToTop(): void {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation: { duration: 400, curve: Curve.EaseInOut }
    });
  }

  private openSettings(): void {
    this.getUIContext()?.animateTo({ duration: 400, curve: Curve.EaseInOut }, () => {
      this.isSettingsOpen = true;
    });
  }

  private closeSettings(): void {
    this.getUIContext()?.animateTo({ duration: 400, curve: Curve.EaseInOut }, () => {
      this.isSettingsOpen = false;
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll(this.scroller) {
        Column() {
          Blank()
            .height(LayoutConstants.SCROLL_TOP_INSET_VP)
          HeroDisplayView({ vm: this.vm })
          OccasionSelectorView({ vm: this.vm })
          PaletteSelectorView({ vm: this.vm })
          Blank()
            .height(LayoutConstants.SCROLL_BOTTOM_INSET_VP + this.bottomGestureInsetVp)
        }
        .width('100%')
        .backgroundColor(DesignTokens.BG_PAGE)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
      .onDidScroll((xOffset: number, yOffset: number) => {
        const y: number = this.scroller.currentOffset().yOffset;
        this.mainScrollY = y > 0 ? y : 0;
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

        TopBarView({
          vm: this.vm,
          barCompact: this.mainScrollY > LayoutConstants.TOP_BAR_SCROLL_THRESHOLD_VP,
          onOpenSettings: () => {
            this.openSettings();
          },
          onScrollToTop: () => {
            this.scrollMainToTop();
          }
        })
          .width('100%')
          .position({ top: 0, left: 0 })
          .zIndex(30)

        BottomActionsView({
          vm: this.vm,
          bottomGestureInsetVp: this.bottomGestureInsetVp
        })
          .width('100%')
          .position({ bottom: 0, left: 0 })
          .zIndex(30)

      if (this.isSettingsOpen) {
        SettingsPanelView({
          vm: this.vm,
          isOpen: this.isSettingsOpen,
          bottomGestureInsetVp: this.bottomGestureInsetVp,
          onRequestClose: () => {
            this.closeSettings();
          }
        })
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .zIndex(100)
          .transition(TransitionEffect.translate({ x: '100%' }).animation({ duration: 400, curve: Curve.EaseInOut }))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DesignTokens.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
