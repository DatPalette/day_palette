import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';

@Component
export struct WallpaperEntryView {
  @ObjectLink vm: DayPaletteViewModel;
  onOpen: () => void = () => {
  };

  private colors(): string[] {
    return this.vm.getHeroColorStrings();
  }

  build() {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      Row({ space: 14 }) {
        Column({ space: 4 }) {
          Text(this.vm.getUiStrings().wallpaperEntryEyebrow)
            .fontSize(10)
            .fontColor(DesignTokens.TEXT_MUTED)
            .letterSpacing(1.4)
            .textCase(TextCase.UpperCase)

          Text(this.vm.getUiStrings().wallpaperEntryTitle)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)

          Text(this.vm.getUiStrings().wallpaperEntryHint)
            .fontSize(11)
            .fontColor(DesignTokens.TEXT_MUTED)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 0 }) {
          Row()
            .layoutWeight(3)
            .width('100%')
            .backgroundColor(this.colors()[0])
          Row()
            .layoutWeight(2)
            .width('100%')
            .backgroundColor(this.colors()[1])
          Row()
            .layoutWeight(1)
            .width('100%')
            .backgroundColor(this.colors()[2])
        }
        .width(44)
        .height(80)
        .borderRadius(12)
        .clip(true)
        .border({ width: 1, color: 'rgba(0, 0, 0, 0.05)' })
        .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.04)', offsetY: 5 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    }
    .width('100%')
    .backgroundColor(DesignTokens.SURFACE_CARD)
    .borderRadius(2)
    .border({ width: 1, color: DesignTokens.BORDER_COLOR })
    .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.02)', offsetY: 4 })
    .padding({ left: LayoutConstants.PAGE_HORIZONTAL_VP, right: LayoutConstants.PAGE_HORIZONTAL_VP })
    .margin({ top: 10, bottom: 6 })
    .onClick(() => {
      this.onOpen();
    })
  }
}