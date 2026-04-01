import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { AppLanguage } from '../model/AppLanguage';

@Component
export struct TopBarView {
  @ObjectLink vm: DayPaletteViewModel;
  @Prop barCompact: boolean = false;
  onOpenSettings: () => void = () => {
  };
  onScrollToTop: () => void = () => {
  };

  private miniColors(): string[] {
    const p = this.vm.getActivePalette();
    if (p !== undefined && p.colors.length >= 3) {
      return p.colors;
    }
    return [DesignTokens.DEFAULT_MAIN, DesignTokens.DEFAULT_SEC, DesignTokens.DEFAULT_ACC];
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Column({ space: 4 }) {
          Text(this.vm.getUiStrings().loc)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MUTED)
            .letterSpacing(1.1)
            .textCase(TextCase.UpperCase)
          Text(this.vm.getUiStrings().date)
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
            .letterSpacing(0.48)
            .fontFamily(this.vm.currentLang === AppLanguage.ZH ? 'HarmonyOS Serif' : 'serif')
        }
        .alignItems(HorizontalAlign.Start)
        .opacity(this.barCompact ? 0 : 1)
        .translate({ y: this.barCompact ? -10 : 0 })
        .animation({ duration: 400, curve: Curve.EaseInOut })

        Row() {
          Row()
            .layoutWeight(3)
            .height('100%')
            .backgroundColor(this.miniColors()[0])
            .animation({ duration: 600, curve: Curve.EaseInOut })
          Row()
            .layoutWeight(2)
            .height('100%')
            .backgroundColor(this.miniColors()[1])
            .animation({ duration: 600, curve: Curve.EaseInOut })
          Row()
            .layoutWeight(1)
            .height('100%')
            .backgroundColor(this.miniColors()[2])
            .animation({ duration: 600, curve: Curve.EaseInOut })
        }
        .width(140)
        .height(36)
        .borderRadius(18)
        .clip(true)
        .shadow({
          radius: 16,
          color: 'rgba(0, 0, 0, 0.08)',
          offsetX: 0,
          offsetY: 6
        })
        .opacity(this.barCompact ? 1 : 0)
        .translate({ y: this.barCompact ? 0 : 10 })
        .animation({ duration: 400, curve: Curve.EaseInOut })
        .hitTestBehavior(this.barCompact ? HitTestMode.Default : HitTestMode.None)
        .onClick(() => {
          this.onScrollToTop();
        })
      }
      .layoutWeight(1)

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.gearshape'))
          .fontSize(20)
          .fontColor([DesignTokens.TEXT_MAIN])
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Transparent)
      .border({ width: 1, color: DesignTokens.BORDER_COLOR })
      .onClick(() => {
        this.onOpenSettings();
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Bottom)
    .padding({
      top: 42,
      left: 24,
      right: 24,
      bottom: 12
    })
    .backgroundColor('rgba(249, 248, 246, 0.75)')
    .backdropBlur(20)
    .borderWidth({ bottom: 1 })
    .borderColor('rgba(0, 0, 0, 0.03)')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
