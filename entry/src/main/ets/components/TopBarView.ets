import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import { AppLanguage } from '../model/AppLanguage';
import {
  TOP_BAR_MINI_PREVIEW_HEIGHT,
  TOP_BAR_MINI_PREVIEW_SLOT_HEIGHT,
  TOP_BAR_MINI_PREVIEW_SLOT_WIDTH,
  TOP_BAR_MINI_PREVIEW_WIDTH
} from '../common/constants/MiniPreviewLayout';
import { MiniPalettePreviewView } from './MiniPalettePreviewView';

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

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        // 左侧：展开态日期 / 收缩态标题（同位叠放切换）
        Stack({ alignContent: Alignment.Start }) {
          Text(this.vm.getUiStrings().date)
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
            .letterSpacing(0.48)
            .maxLines(1)
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

        // 右侧：设置
        Row() {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.gearshape'))
              .fontSize(20)
              .fontColor([DesignTokens.TEXT_MAIN])
          }
          .width(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
          .height(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: DesignTokens.BORDER_COLOR })
          .onClick(() => {
            this.onOpenSettings();
          })
        }
        .width(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(44)
      .alignItems(VerticalAlign.Center)

      // 中央：始终保留微缩预览插槽，但不占用左右文案宽度
      Row() {
        Stack() {
          MiniPalettePreviewView({
            colors: this.miniColors(),
            style: this.vm.miniPreviewStyle,
            previewWidth: TOP_BAR_MINI_PREVIEW_WIDTH,
            previewHeight: TOP_BAR_MINI_PREVIEW_HEIGHT,
            reduceMotion: this.vm.reduceMotion
          })
        }
        .opacity(this.barCompact ? 1 : 0)
        .translate({ y: this.barCompact ? 0 : 8 })
        .animation({ duration: this.barDur(400), curve: Curve.EaseInOut })
      }
      .width(TOP_BAR_MINI_PREVIEW_SLOT_WIDTH)
      .height(TOP_BAR_MINI_PREVIEW_SLOT_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .hitTestBehavior(this.barCompact ? HitTestMode.Default : HitTestMode.None)
      .onClick(() => {
        if (this.barCompact) {
          this.onScrollToTop();
        }
      })
    }
    .width('100%')
    .padding({
      top: 42,
      left: LayoutConstants.PAGE_HORIZONTAL_VP,
      right: LayoutConstants.PAGE_HORIZONTAL_VP,
      bottom: 16
    })
    .backgroundColor(DesignTokens.SURFACE_FROSTED)
    .backdropBlur(20)
    .borderWidth({ bottom: 1 })
    .borderColor(DesignTokens.BORDER_SUBTLE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
