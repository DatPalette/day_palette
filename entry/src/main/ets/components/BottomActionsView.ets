import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';

@Component
export struct BottomActionsView {
  @ObjectLink vm: DayPaletteViewModel;

  build() {
    Row({ space: 12 }) {
      Button({ type: ButtonType.Normal }) {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.save'))
            .fontSize(16)
            .fontColor([DesignTokens.TEXT_ON_INVERSE])
          Text(this.vm.getUiStrings().save)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_ON_INVERSE)
            .letterSpacing(0.65)
            .textCase(TextCase.UpperCase)
        }
      }
      .layoutWeight(1)
      .height(52)
      .backgroundColor(DesignTokens.TEXT_MAIN)
      .borderRadius(2)

      Button({ type: ButtonType.Normal }) {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.share'))
            .fontSize(16)
            .fontColor([DesignTokens.TEXT_MAIN])
          Text(this.vm.getUiStrings().share)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
            .letterSpacing(0.65)
            .textCase(TextCase.UpperCase)
        }
      }
      .layoutWeight(1)
      .height(52)
      .backgroundColor(Color.Transparent)
      .borderRadius(2)
      .border({ width: 1, color: DesignTokens.BORDER_COLOR })
    }
    .width('100%')
    .padding({ top: 16, left: 24, right: 24, bottom: 32 })
    .backgroundColor('rgba(249, 248, 246, 0.75)')
    .backdropBlur(20)
    .borderWidth({ top: 1 })
    .borderColor('rgba(0, 0, 0, 0.03)')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
