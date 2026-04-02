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
import { FineTuneSheet } from '../components/FineTuneSheet';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import {
  saveTodayPaletteToGallery,
  shareTodayPaletteImage
} from '../export/PaletteShareActions';
import type {
  PaletteExportSnapshot,
  SavePaletteImageFailure,
  SavePaletteImageResult,
  SharePaletteFailure,
  SharePaletteResult
} from '../export/PaletteShareActions';

@Entry
@Component
struct Index {
  @State vm: DayPaletteViewModel = new DayPaletteViewModel();
  private scroller: Scroller = new Scroller();
  @State mainScrollY: number = 0;
  @State isSettingsOpen: boolean = false;
  @State fineTuneOpen: boolean = false;
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
    this.vm.setPersistContext(ctx);
    this.vm.loadLanguageFromStorage(ctx);
    this.vm.loadAccessibilityFromStorage(ctx);
    this.vm.loadTodayOutfitFromStorage();
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
    let vp: number = this.getUIContext().px2vp(px);
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

  private uiAnimMs(normal: number): number {
    return this.vm.reduceMotion ? 0 : normal;
  }

  private scrollMainToTop(): void {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation: { duration: this.uiAnimMs(400), curve: Curve.EaseInOut }
    });
  }

  private openSettings(): void {
    this.getUIContext()?.animateTo({ duration: this.uiAnimMs(400), curve: Curve.EaseInOut }, () => {
      this.isSettingsOpen = true;
    });
  }

  private closeSettings(): void {
    this.getUIContext()?.animateTo({ duration: this.uiAnimMs(400), curve: Curve.EaseInOut }, () => {
      this.isSettingsOpen = false;
    });
  }

  private showToastMsg(message: string, longDuration: boolean = false): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: longDuration ? 8000 : 3000
      });
    } catch (_e) {
    }
  }

  private messageForSaveFailure(r: SavePaletteImageFailure): string {
    const u = this.vm.getUiStrings();
    let msg: string;
    switch (r.hint) {
      case 'album_permission_denied':
        msg = u.saveFailAlbumPermission;
        break;
      case 'permission_request_failed':
        msg = u.saveFailPermissionRequest;
        break;
      case 'export_pixel_map':
        msg = u.saveFailBuildImage;
        break;
      case 'export_pack_png':
        msg = u.saveFailEncodeImage;
        break;
      case 'gallery_create_open':
        msg = u.saveFailGalleryApi;
        break;
      case 'gallery_write':
        msg = u.saveFailGalleryWrite;
        break;
      case 'save_dialog_cancelled':
        msg = u.saveCancelled;
        break;
      default:
        msg = u.saveFailUnknown;
        break;
    }
    if (r.code !== undefined && r.code >= 0) {
      msg = `${msg} [${r.code}]`;
    }
    return msg;
  }

  private handleSaveImage(snap: PaletteExportSnapshot): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    void saveTodayPaletteToGallery(ctx, snap).then((r: SavePaletteImageResult) => {
      if (r.ok) {
        this.showToastMsg(this.vm.getUiStrings().saveSuccess, false);
      } else {
        const rf: SavePaletteImageFailure = r as SavePaletteImageFailure;
        if (rf.hint === 'save_dialog_cancelled') {
          this.showToastMsg(this.vm.getUiStrings().saveCancelled, false);
        } else {
          this.showToastMsg(this.messageForSaveFailure(rf), true);
        }
      }
    });
  }

  private handleShareImage(snap: PaletteExportSnapshot): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    void shareTodayPaletteImage(ctx, snap).then((r: SharePaletteResult) => {
      if (!r.ok) {
        const fail: SharePaletteFailure = r as SharePaletteFailure;
        const u = this.vm.getUiStrings();
        const msg: string = fail.hint === 'build_image' ? u.shareFailBuildImage : u.shareFailOther;
        this.showToastMsg(msg, true);
      }
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
          PaletteSelectorView({
            vm: this.vm,
            onRandom: () => {
              this.vm.randomPaletteInActiveOccasion();
            },
            onYesterday: () => {
              const ok: boolean = this.vm.applyYesterdayOutfitFromStorage();
              if (!ok) {
                this.showToastMsg(this.vm.getUiStrings().yesterdayEmpty);
              }
            },
            onFineTune: () => {
              this.fineTuneOpen = true;
            }
          })
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
          bottomGestureInsetVp: this.bottomGestureInsetVp,
          onTapSave: (snap: PaletteExportSnapshot) => {
            this.handleSaveImage(snap);
          },
          onTapShare: (snap: PaletteExportSnapshot) => {
            this.handleShareImage(snap);
          }
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
          .transition(TransitionEffect.translate({ x: '100%' }).animation({
            duration: this.uiAnimMs(400),
            curve: Curve.EaseInOut
          }))
      }

      if (this.fineTuneOpen) {
        FineTuneSheet({
          vm: this.vm,
          bottomGestureInsetVp: this.bottomGestureInsetVp,
          onRequestClose: () => {
            this.fineTuneOpen = false;
          }
        })
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .zIndex(120)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DesignTokens.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
