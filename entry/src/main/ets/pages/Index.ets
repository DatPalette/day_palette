import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { LengthMetrics } from '@kit.ArkUI';
import { APP_FOREGROUND_EVENT, LOCALE_CONFIG_CHANGED_EVENT } from '../common/constants/AppEventHub';
import { getBottomGestureBarHeightPx } from '../common/window/NavigationIndicatorInset';
import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { TopBarView } from '../components/TopBarView';
import { HeroDisplayView } from '../components/HeroDisplayView';
import { InspirationEntryView } from '../components/InspirationEntryView';
import { OccasionSelectorView } from '../components/OccasionSelectorView';
import { PaletteSelectorView } from '../components/PaletteSelectorView';
import { WallpaperEntryView } from '../components/WallpaperEntryView';
import { BottomActionsView } from '../components/BottomActionsView';
import { SettingsPanelView } from '../components/SettingsPanelView';
import { FineTuneSheet } from '../components/FineTuneSheet';
import { WallpaperStudioView } from '../components/WallpaperStudioView';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import {
  saveTodayPaletteToGallery,
  shareTodayPaletteImage
} from '../export/PaletteShareActions';
import { saveWallpaperToGallery } from '../export/WallpaperActions';
import type {
  PaletteExportSnapshot,
  SavePaletteImageFailure,
  SavePaletteImageResult,
  SharePaletteFailure,
  SharePaletteResult
} from '../export/PaletteShareActions';
import type {
  SaveWallpaperImageFailure,
  SaveWallpaperImageResult,
  WallpaperSnapshot
} from '../export/WallpaperActions';

interface WindowRectLike {
  width?: number;
  height?: number;
}

interface WindowPropertiesLike {
  windowRect?: WindowRectLike;
}

interface WindowWithPropertiesLike {
  getWindowProperties?: () => WindowPropertiesLike;
}

@Entry
@Component
struct Index {
  @State vm: DayPaletteViewModel = new DayPaletteViewModel();
  private scroller: Scroller = new Scroller();
  @State paletteRevealRequestToken: number = 0;
  @State mainScrollY: number = 0;
  @State isSettingsOpen: boolean = false;
  @State fineTuneOpen: boolean = false;
  @State wallpaperStudioOpen: boolean = false;
  /** 底部导航指示条 / 手势区高度（vp），用于底栏内边距与主列表底部留白 */
  @State bottomGestureInsetVp: number = 0;
  @State wallpaperViewportWidthPx: number = 1080;
  @State wallpaperViewportHeightPx: number = 2340;
  private localeEventHandler: (() => void) | undefined = undefined;
  private appForegroundHandler: (() => void) | undefined = undefined;
  private midnightRefreshTimerId: number | null = null;
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
    void this.vm.preloadLocaleCatalog(ctx);
    this.localeEventHandler = (): void => {
      const host = this.getUIContext().getHostContext() as common.UIAbilityContext;
      this.vm.refreshLocaleIfFollowingSystem(host);
    };
    this.appForegroundHandler = (): void => {
      this.vm.refreshCalendarDayBoundary();
      this.scheduleMidnightRefresh();
    };
    ctx.eventHub.on(LOCALE_CONFIG_CHANGED_EVENT, this.localeEventHandler);
    ctx.eventHub.on(APP_FOREGROUND_EVENT, this.appForegroundHandler);
    this.attachBottomGestureInsetListener(ctx);
    this.scheduleMidnightRefresh();
  }

  aboutToDisappear(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (this.localeEventHandler !== undefined) {
      ctx.eventHub.off(LOCALE_CONFIG_CHANGED_EVENT, this.localeEventHandler);
      this.localeEventHandler = undefined;
    }
    if (this.appForegroundHandler !== undefined) {
      ctx.eventHub.off(APP_FOREGROUND_EVENT, this.appForegroundHandler);
      this.appForegroundHandler = undefined;
    }
    this.detachBottomGestureInsetListener();
    this.clearMidnightRefreshTimer();
  }

  private clearMidnightRefreshTimer(): void {
    if (this.midnightRefreshTimerId !== null) {
      clearTimeout(this.midnightRefreshTimerId);
      this.midnightRefreshTimerId = null;
    }
  }

  private scheduleMidnightRefresh(): void {
    this.clearMidnightRefreshTimer();
    const now: Date = new Date();
    const nextMidnight: Date = new Date(now.getTime());
    nextMidnight.setHours(24, 0, 0, 0);
    const delayMs: number = Math.max(1000, nextMidnight.getTime() - now.getTime() + 50);
    this.midnightRefreshTimerId = setTimeout((): void => {
      this.midnightRefreshTimerId = null;
      this.vm.refreshCalendarDayBoundary();
      this.scheduleMidnightRefresh();
    }, delayMs);
  }

  private applyBottomGestureInsetFromWindow(win: window.Window): void {
    const px: number = getBottomGestureBarHeightPx(win);
    let vp: number = this.getUIContext().px2vp(px);
    if (px <= 0 || vp <= 0) {
      vp = LayoutConstants.BOTTOM_INDICATOR_FALLBACK_VP;
    }
    this.bottomGestureInsetVp = vp;
    this.updateWallpaperViewportFromWindow(win);
  }

  private updateWallpaperViewportFromWindow(win: window.Window): void {
    try {
      const props: WindowPropertiesLike | undefined =
        (win as WindowWithPropertiesLike).getWindowProperties?.();
      const rect: WindowRectLike | undefined = props?.windowRect;
      const widthPx: number = typeof rect?.width === 'number' ? Math.floor(rect.width) : 0;
      const heightPx: number = typeof rect?.height === 'number' ? Math.floor(rect.height) : 0;
      if (widthPx > 0 && heightPx > 0) {
        this.wallpaperViewportWidthPx = Math.min(widthPx, heightPx);
        this.wallpaperViewportHeightPx = Math.max(widthPx, heightPx);
      }
    } catch {
    }
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

  private openWallpaperStudio(): void {
    this.getUIContext()?.animateTo({ duration: this.uiAnimMs(220), curve: Curve.EaseInOut }, () => {
      this.wallpaperStudioOpen = true;
    });
  }

  private closeWallpaperStudio(): void {
    this.getUIContext()?.animateTo({ duration: this.uiAnimMs(220), curve: Curve.EaseInOut }, () => {
      this.wallpaperStudioOpen = false;
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

  private handleSaveWallpaper(snap: WallpaperSnapshot): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    void saveWallpaperToGallery(ctx, snap).then((r: SaveWallpaperImageResult) => {
      if (r.ok) {
        this.showToastMsg(this.vm.getUiStrings().wallpaperSaveSuccess, false);
        return;
      }
      const fail: SaveWallpaperImageFailure = r as SaveWallpaperImageFailure;
      if (fail.hint === 'save_dialog_cancelled') {
        this.showToastMsg(this.vm.getUiStrings().saveCancelled, false);
        return;
      }
      this.showToastMsg(this.vm.getUiStrings().wallpaperSaveFail, true);
    });
  }

  private fineTuneSyncToken(): string {
    return this.vm.getHeroColorStrings().join('|');
  }

  @Builder
  private fineTuneSheetBuilder() {
    FineTuneSheet({
      vm: this.vm,
      syncToken: this.fineTuneSyncToken(),
      bottomGestureInsetVp: this.bottomGestureInsetVp,
      onRequestClose: () => {
        this.fineTuneOpen = false;
      }
    })
      .width('100%')
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll(this.scroller) {
        Column() {
          Blank()
            .height(LayoutConstants.SCROLL_TOP_INSET_VP)
          HeroDisplayView({ vm: this.vm })
          InspirationEntryView({
            vm: this.vm,
            onApplied: () => {
              this.paletteRevealRequestToken += 1;
            }
          })
          OccasionSelectorView({
            vm: this.vm,
            topMarginVp: 20,
            bottomMarginVp: 26
          })
          PaletteSelectorView({
            vm: this.vm,
            revealRequestToken: this.paletteRevealRequestToken,
            bottomPaddingVp: 0,
            onRandom: () => {
              this.vm.randomPaletteInActiveOccasion();
              this.paletteRevealRequestToken += 1;
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
          WallpaperEntryView({
            vm: this.vm,
            onOpen: () => {
              this.openWallpaperStudio();
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

      if (this.wallpaperStudioOpen) {
        WallpaperStudioView({
          vm: this.vm,
          deviceWidthPx: this.wallpaperViewportWidthPx,
          deviceHeightPx: this.wallpaperViewportHeightPx,
          bottomGestureInsetVp: this.bottomGestureInsetVp,
          onRequestClose: () => {
            this.closeWallpaperStudio();
          },
          onTapSave: (snap: WallpaperSnapshot) => {
            this.handleSaveWallpaper(snap);
          }
        })
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .zIndex(90)
          .transition(TransitionEffect.translate({ x: '100%' }).animation({
            duration: this.uiAnimMs(220),
            curve: Curve.EaseInOut
          }))
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor(DesignTokens.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .bindSheet($$this.fineTuneOpen, this.fineTuneSheetBuilder(), {
      height: SheetSize.FIT_CONTENT,
      preferType: SheetType.BOTTOM,
      dragBar: true,
      showClose: false,
      backgroundColor: DesignTokens.SURFACE_CARD,
      maskColor: 'rgba(0, 0, 0, 0.30)',
      keyboardAvoidMode: SheetKeyboardAvoidMode.TRANSLATE_AND_SCROLL,
      radius: LengthMetrics.vp(28),
      onDisappear: () => {
        this.fineTuneOpen = false;
      }
    })
  }
}
