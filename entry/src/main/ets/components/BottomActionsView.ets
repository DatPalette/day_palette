import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import { paletteExportSnapshotFromVm } from '../export/PaletteShareActions';
import type { PaletteExportSnapshot } from '../export/PaletteShareActions';

@Component
export struct BottomActionsView {
  @ObjectLink vm: DayPaletteViewModel;
  /** 系统底部手势条/指示条安全区（vp），由首页根据窗口避让区计算 */
  @Prop bottomGestureInsetVp: number = 0;
  /** 快照必须在 @ObjectLink 上生成，与 Hero/精选列表同源，避免 @State 父组件读到滞后副本 */
  onTapSave: (snap: PaletteExportSnapshot) => void = (_s: PaletteExportSnapshot) => {
  };
  onTapShare: (snap: PaletteExportSnapshot) => void = (_s: PaletteExportSnapshot) => {
  };

  build() {
    Column() {
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
        .onClick(() => {
          const snap: PaletteExportSnapshot = paletteExportSnapshotFromVm(this.vm);
          this.onTapSave(snap);
        })

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
        .onClick(() => {
          const snap: PaletteExportSnapshot = paletteExportSnapshotFromVm(this.vm);
          this.onTapShare(snap);
        })
      }
      .width('100%')
      .padding({
        top: 16,
        left: LayoutConstants.PAGE_HORIZONTAL_VP,
        right: LayoutConstants.PAGE_HORIZONTAL_VP,
        bottom: 32 + this.bottomGestureInsetVp
      })
    }
    .width('100%')
    .backgroundColor(DesignTokens.SURFACE_FROSTED)
    .backdropBlur(20)
    .borderWidth({ top: 1 })
    .borderColor(DesignTokens.BORDER_SUBTLE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
