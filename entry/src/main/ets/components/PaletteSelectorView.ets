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

  private actionPreviewColors(): string[] {
    return this.vm.getHeroColorStrings();
  }

  private yesterdayEnabled(): boolean {
    return this.vm.canApplyYesterdayOutfit();
  }

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

      Scroll() {
        Row({ space: 16 }) {
          ForEach(this.paletteList(), (pal: Palette) => {
            Column() {
              Row() {
                Row()
                  .layoutWeight(3)
                  .height(pal.id === this.vm.activePaletteId ? 10 : 8)
                  .backgroundColor(pal.colors[0])
                  .opacity(pal.id === this.vm.activePaletteId ? 1 : 0.9)
                Row()
                  .layoutWeight(2)
                  .height(pal.id === this.vm.activePaletteId ? 10 : 8)
                  .backgroundColor(pal.colors[1])
                  .opacity(pal.id === this.vm.activePaletteId ? 1 : 0.9)
                Row()
                  .layoutWeight(1)
                  .height(pal.id === this.vm.activePaletteId ? 10 : 8)
                  .backgroundColor(pal.colors[2])
                  .opacity(pal.id === this.vm.activePaletteId ? 1 : 0.9)
              }
              .width('100%')
              .borderRadius(2)
              .clip(true)
              .shadow({
                radius: pal.id === this.vm.activePaletteId ? 8 : 0,
                color: pal.id === this.vm.activePaletteId ? 'rgba(0, 0, 0, 0.04)' : 'rgba(0, 0, 0, 0)',
                offsetX: 0,
                offsetY: pal.id === this.vm.activePaletteId ? 3 : 0
              })
 
              Column({ space: 4 }) {
                Text(pal.name)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(DesignTokens.TEXT_MAIN)

                Text(pal.desc)
                  .fontSize(11)
                  .fontColor(DesignTokens.TEXT_MUTED)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
            }
            .width(140)
            .height(96)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(16)
            .backgroundColor(pal.id === this.vm.activePaletteId ? DesignTokens.SURFACE_SELECTED : DesignTokens.SURFACE_CARD)
            .borderRadius(2)
            .border({
              width: 1,
              color: pal.id === this.vm.activePaletteId ? DesignTokens.BORDER_SELECTED : DesignTokens.BORDER_COLOR
            })
            .shadow({
              radius: pal.id === this.vm.activePaletteId ? 16 : 6,
              color: pal.id === this.vm.activePaletteId ? DesignTokens.SHADOW_SELECTED : 'rgba(0, 0, 0, 0.015)',
              offsetX: 0,
              offsetY: pal.id === this.vm.activePaletteId ? 8 : 3
            })
            .scale({ x: pal.id === this.vm.activePaletteId ? 1.01 : 1, y: pal.id === this.vm.activePaletteId ? 1.01 : 1 })
            .onClick(() => {
              this.vm.selectPalette(pal.id);
            })
          }, (pal: Palette) => pal.id + '_' + this.vm.currentLang)
        }
        .padding({
          left: LayoutConstants.PAGE_HORIZONTAL_VP,
          right: LayoutConstants.PAGE_HORIZONTAL_VP,
          bottom: 20
        })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Column({ space: 10 }) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row({ space: 14 }) {
            Column({ space: 4 }) {
              Text(this.vm.getUiStrings().randomPalette)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(DesignTokens.TEXT_MAIN)

              Text(this.vm.getUiStrings().randomPaletteHint)
                .fontSize(10)
                .fontColor(DesignTokens.TEXT_MUTED)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Row() {
                Row()
                  .layoutWeight(3)
                  .height('100%')
                  .backgroundColor(this.actionPreviewColors()[0])
                  .animation({ duration: this.vm.reduceMotion ? 1 : 600, curve: Curve.EaseInOut })
                Row()
                  .layoutWeight(2)
                  .height('100%')
                  .backgroundColor(this.actionPreviewColors()[1])
                  .animation({ duration: this.vm.reduceMotion ? 1 : 600, curve: Curve.EaseInOut })
                Row()
                  .layoutWeight(1)
                  .height('100%')
                  .backgroundColor(this.actionPreviewColors()[2])
                  .animation({ duration: this.vm.reduceMotion ? 1 : 600, curve: Curve.EaseInOut })
              }
              .width(76)
              .height(10)
              .borderRadius(2)
              .clip(true)

              Divider()
                .strokeWidth(1)
                .color('rgba(0, 0, 0, 0.06)')
                .vertical(false)
                .width(76)
            }
            .alignItems(HorizontalAlign.End)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        }
        .width('100%')
        .backgroundColor(DesignTokens.SURFACE_CARD)
        .borderRadius(2)
        .border({ width: 1, color: DesignTokens.BORDER_COLOR })
        .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.02)', offsetY: 4 })
        .onClick(() => {
          this.onRandom();
        })

        Row({ space: 10 }) {
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Text(this.vm.getUiStrings().yesterdayOutfit)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.yesterdayEnabled() ? DesignTokens.TEXT_MAIN : DesignTokens.TEXT_MUTED)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .height(42)
          .backgroundColor(this.yesterdayEnabled() ? DesignTokens.SURFACE_CARD : 'rgba(0, 0, 0, 0.02)')
          .borderRadius(2)
          .border({
            width: 1,
            color: this.yesterdayEnabled() ? DesignTokens.BORDER_COLOR : 'rgba(0, 0, 0, 0.04)'
          })
          .opacity(this.yesterdayEnabled() ? 1 : 0.56)
          .hitTestBehavior(this.yesterdayEnabled() ? HitTestMode.Default : HitTestMode.None)
          .onClick(() => {
            this.onYesterday();
          })

          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Text(this.vm.getUiStrings().fineTune)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(DesignTokens.TEXT_MAIN)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .height(42)
          .backgroundColor(DesignTokens.SURFACE_CARD)
          .borderRadius(2)
          .border({ width: 1, color: DesignTokens.BORDER_COLOR })
          .onClick(() => {
            this.onFineTune();
          })
        }

      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: LayoutConstants.PAGE_HORIZONTAL_VP, right: LayoutConstants.PAGE_HORIZONTAL_VP, top: 20, bottom: 14 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ bottom: LayoutConstants.PALETTE_LIST_BOTTOM_PADDING_VP })
  }

  private paletteList(): Palette[] {
    return this.vm.getRecommendedPalettesForActiveOccasion();
  }
}
