import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import type { Palette } from '../model/Palette';
import { LayoutConstants } from '../common/constants/LayoutConstants';

@Component
export struct InspirationEntryView {
  @ObjectLink vm: DayPaletteViewModel;
  @State private panelMounted: boolean = false;
  @State private panelVisible: boolean = false;
  onApplied: () => void = () => {
  };
  private readonly collapsedPanelHeightVp: number = 0;
  private readonly expandedPanelHeightVp: number = 196;

  aboutToAppear(): void {
    if (this.vm.inspirationExpanded) {
      this.panelMounted = true;
      this.panelVisible = true;
    }
  }

  private panelAnimDuration(): number {
    return this.vm.reduceMotion ? 1 : 320;
  }

  private inspirationPalettes(): Palette[] {
    return this.vm.getInspirationPalettes();
  }

  private openPanel(): void {
    if (this.panelMounted && this.panelVisible) {
      return;
    }
    this.vm.inspirationExpanded = true;
    this.panelMounted = true;
    this.panelVisible = false;
    setTimeout((): void => {
      this.panelVisible = true;
    }, this.vm.reduceMotion ? 0 : 16);
  }

  private closePanel(): void {
    if (!this.panelMounted) {
      return;
    }
    this.vm.inspirationExpanded = false;
    this.panelVisible = false;
    setTimeout((): void => {
      if (!this.vm.inspirationExpanded) {
        this.panelMounted = false;
      }
    }, this.panelAnimDuration());
  }

  private togglePanel(): void {
    if (this.panelMounted) {
      this.closePanel();
      return;
    }
    this.openPanel();
  }

  private applyInspirationPalette(paletteId: string): void {
    if (this.vm.applyInspirationPalette(paletteId)) {
      this.panelVisible = false;
      setTimeout((): void => {
        this.panelMounted = false;
      }, this.panelAnimDuration());
      this.onApplied();
    }
  }

  build() {
    Column({ space: 0 }) {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(this.vm.getUiStrings().inspirationEntryEyebrow)
              .fontSize(10)
              .fontColor(DesignTokens.TEXT_MUTED)
              .letterSpacing(1.4)
              .textCase(TextCase.UpperCase)

            Text(this.vm.getUiStrings().inspirationEntryTitle)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(DesignTokens.TEXT_MAIN)

            Text(this.vm.getUiStrings().inspirationEntryHint)
              .fontSize(11)
              .fontColor(DesignTokens.TEXT_MUTED)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text(this.panelMounted ? this.vm.getUiStrings().inspirationCollapse : '›')
            .fontSize(this.panelMounted ? 12 : 20)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MUTED)
            .animation({ duration: this.panelAnimDuration(), curve: Curve.EaseInOut })
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
      .onClick(() => {
        this.togglePanel();
      })

      if (this.panelMounted) {
        Column() {
          Column({ space: 12 }) {
            Row() {
              Column({ space: 4 }) {
                Text(this.vm.getUiStrings().inspirationSectionTitle)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(DesignTokens.TEXT_MAIN)

                Text(this.vm.getUiStrings().inspirationSectionHint)
                  .fontSize(10)
                  .fontColor(DesignTokens.TEXT_MUTED)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.inspirationPalettes(), (pal: Palette) => {
                  Column({ space: 10 }) {
                    Row() {
                      Row()
                        .layoutWeight(3)
                        .height(8)
                        .backgroundColor(pal.colors[0])
                      Row()
                        .layoutWeight(2)
                        .height(8)
                        .backgroundColor(pal.colors[1])
                      Row()
                        .layoutWeight(1)
                        .height(8)
                        .backgroundColor(pal.colors[2])
                    }
                    .width('100%')
                    .borderRadius(2)
                    .clip(true)

                    Column({ space: 4 }) {
                      Text(pal.name)
                        .fontSize(13)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(DesignTokens.TEXT_MAIN)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(pal.desc)
                        .fontSize(10)
                        .fontColor(DesignTokens.TEXT_MUTED)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width(124)
                  .padding(14)
                  .backgroundColor(pal.id === this.vm.activePaletteId ? '#fcfcfb' : DesignTokens.SURFACE_CARD)
                  .borderRadius(2)
                  .border({
                    width: 1,
                    color: pal.id === this.vm.activePaletteId ? 'rgba(26, 26, 26, 0.18)' : DesignTokens.BORDER_COLOR
                  })
                  .shadow({
                    radius: pal.id === this.vm.activePaletteId ? 12 : 6,
                    color: pal.id === this.vm.activePaletteId ? 'rgba(0, 0, 0, 0.04)' : 'rgba(0, 0, 0, 0.015)',
                    offsetX: 0,
                    offsetY: pal.id === this.vm.activePaletteId ? 6 : 3
                  })
                  .animation({ duration: this.vm.reduceMotion ? 1 : 420, curve: Curve.EaseInOut })
                  .onClick(() => {
                    this.applyInspirationPalette(pal.id);
                  })
                }, (pal: Palette) => `insp_${pal.id}_${this.vm.currentLang}`)
              }
              .padding({ bottom: 8 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 14, bottom: 10 })
          .backgroundColor('rgba(255, 255, 255, 0.58)')
          .borderRadius(2)
          .border({ width: 1, color: 'rgba(0, 0, 0, 0.05)' })
          .translate({ x: 0, y: this.panelVisible ? 0 : -10 })
          .scale({ x: this.panelVisible ? 1 : 0.988, y: this.panelVisible ? 1 : 0.988 })
          .opacity(this.panelVisible ? 1 : 0)
          .animation({ duration: this.panelAnimDuration(), curve: Curve.EaseInOut })
        }
        .width('100%')
        .height(this.panelVisible ? this.expandedPanelHeightVp : this.collapsedPanelHeightVp)
        .clip(true)
        .margin({ top: this.panelVisible ? 10 : 0 })
        .animation({ duration: this.panelAnimDuration(), curve: Curve.EaseInOut })
      }
    }
    .width('100%')
    .padding({ left: LayoutConstants.PAGE_HORIZONTAL_VP, right: LayoutConstants.PAGE_HORIZONTAL_VP })
    .margin({ top: 16, bottom: 8 })
  }
}