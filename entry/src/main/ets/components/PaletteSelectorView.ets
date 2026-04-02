import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import type { Palette } from '../model/Palette';
import { LayoutConstants } from '../common/constants/LayoutConstants';

@Component
export struct PaletteSelectorView {
  @ObjectLink vm: DayPaletteViewModel;
  onRandom: () => void = () => {
  };
  onYesterday: () => void = () => {
  };
  onFineTune: () => void = () => {
  };

  build() {
    Column() {
      Text(this.vm.getUiStrings().curatedTitle)
        .fontSize(10)
        .fontColor(DesignTokens.TEXT_MUTED)
        .letterSpacing(2.25)
        .textCase(TextCase.UpperCase)
        .margin({ bottom: 16 })
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: LayoutConstants.PAGE_HORIZONTAL_VP })

      Row({ space: 20 }) {
        Text(this.vm.getUiStrings().randomPalette)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .decoration({ type: TextDecorationType.Underline })
          .onClick(() => {
            this.onRandom();
          })
        Text(this.vm.getUiStrings().yesterdayOutfit)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .decoration({ type: TextDecorationType.Underline })
          .onClick(() => {
            this.onYesterday();
          })
        Text(this.vm.getUiStrings().fineTune)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .decoration({ type: TextDecorationType.Underline })
          .onClick(() => {
            this.onFineTune();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: LayoutConstants.PAGE_HORIZONTAL_VP, bottom: 12 })

      Scroll() {
        Row({ space: 16 }) {
          ForEach(this.paletteList(), (pal: Palette) => {
            Column() {
              Row() {
                Row()
                  .layoutWeight(3)
                  .height(4)
                  .backgroundColor(pal.colors[0])
                Row()
                  .layoutWeight(2)
                  .height(4)
                  .backgroundColor(pal.colors[1])
                Row()
                  .layoutWeight(1)
                  .height(4)
                  .backgroundColor(pal.colors[2])
              }
              .width('100%')
              .borderRadius(2)
              .clip(true)
              .margin({ bottom: 12 })

              Text(pal.name)
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor(DesignTokens.TEXT_MAIN)
                .margin({ bottom: 4 })
              Text(pal.desc)
                .fontSize(11)
                .fontColor(DesignTokens.TEXT_MUTED)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(140)
            .height(104)
            .alignItems(HorizontalAlign.Start)
            .padding(16)
            .backgroundColor(DesignTokens.SURFACE_CARD)
            .borderRadius(2)
            .border({
              width: 1,
              color: pal.id === this.vm.activePaletteId ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR
            })
            .shadow({
              radius: pal.id === this.vm.activePaletteId ? 20 : 0,
              color: pal.id === this.vm.activePaletteId ? 'rgba(0, 0, 0, 0.03)' : 'rgba(0, 0, 0, 0)',
              offsetX: 0,
              offsetY: pal.id === this.vm.activePaletteId ? 10 : 0
            })
            .onClick(() => {
              this.vm.selectPalette(pal.id);
            })
          }, (pal: Palette) => pal.id + '_' + this.vm.currentLang)
        }
        .padding({ right: LayoutConstants.PAGE_HORIZONTAL_VP, bottom: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ bottom: LayoutConstants.PALETTE_LIST_BOTTOM_PADDING_VP })
  }

  private paletteList(): Palette[] {
    const occ = this.vm.getActiveOccasion();
    return occ !== undefined ? occ.palettes : [];
  }
}
