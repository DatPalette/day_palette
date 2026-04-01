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
            .height(LayoutConstants.SCROLL_BOTTOM_INSET_VP)
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

        BottomActionsView({ vm: this.vm })
          .width('100%')
          .position({ bottom: 0, left: 0 })
          .zIndex(30)

      if (this.isSettingsOpen) {
        SettingsPanelView({
          vm: this.vm,
          isOpen: this.isSettingsOpen,
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
    .backgroundColor(DesignTokens.BG_CANVAS)
  }
}
