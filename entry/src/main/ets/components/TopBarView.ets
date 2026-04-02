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

  private barDur(ms: number): number {
    return this.vm.reduceMotion ? 1 : ms;
  }

  private miniColors(): string[] {
    return this.vm.getHeroColorStrings();
  }

  /** 顶栏收缩态单行标题（与 Hero 同源：当前套组名） */
  private compactHeroTitle(): string {
    return this.vm.getHeroTitleCompact();
  }

  /** 微缩三色胶囊（略扁，高度小于旧版 36） */
  @Builder
  private MiniPaletteCapsule() {
    Row() {
      Row()
        .layoutWeight(3)
        .height('100%')
        .backgroundColor(this.miniColors()[0])
        .animation({ duration: this.barDur(600), curve: Curve.EaseInOut })
      Row()
        .layoutWeight(2)
        .height('100%')
        .backgroundColor(this.miniColors()[1])
        .animation({ duration: this.barDur(600), curve: Curve.EaseInOut })
      Row()
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(this.miniColors()[2])
        .animation({ duration: this.barDur(600), curve: Curve.EaseInOut })
    }
    .width(118)
    .height(28)
    .borderRadius(14)
    .clip(true)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.07)',
      offsetX: 0,
      offsetY: 4
    })
  }

  build() {
    Row() {
      // 左侧：展开态日期 / 收缩态标题（同位叠放切换）
      Stack({ alignContent: Alignment.Start }) {
        Text(this.vm.getUiStrings().date)
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .letterSpacing(0.48)
          .fontFamily(this.vm.currentLang === AppLanguage.ZH ? 'HarmonyOS Serif' : 'serif')
          .alignSelf(ItemAlign.Start)
          .opacity(this.barCompact ? 0 : 1)
          .translate({ y: this.barCompact ? -8 : 0 })
          .animation({ duration: this.barDur(400), curve: Curve.EaseInOut })

        Text(this.compactHeroTitle())
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .letterSpacing(0.3)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '100%' })
          .fontFamily(this.vm.currentLang === AppLanguage.ZH ? 'HarmonyOS Serif' : 'serif')
          .fontStyle(this.vm.currentLang === AppLanguage.ZH ? FontStyle.Normal : FontStyle.Italic)
          .alignSelf(ItemAlign.Start)
          .opacity(this.barCompact ? 1 : 0)
          .translate({ y: this.barCompact ? 0 : 8 })
          .animation({ duration: this.barDur(400), curve: Curve.EaseInOut })
      }
      .layoutWeight(1)
      .alignContent(Alignment.Start)

      // 中央：仅收缩态显示微缩预览，点击回顶
      Row() {
        if (this.barCompact) {
          this.MiniPaletteCapsule()
        }
      }
      .justifyContent(FlexAlign.Center)
      .hitTestBehavior(this.barCompact ? HitTestMode.Default : HitTestMode.None)
      .onClick(() => {
        if (this.barCompact) {
          this.onScrollToTop();
        }
      })

      // 右侧：设置（与左侧等宽占位，保证中央几何居中）
      Row() {
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
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
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
