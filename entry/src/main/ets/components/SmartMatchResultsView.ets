import { DesignTokens } from '../common/constants/DesignTokens';
import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import type { SmartMatchRecommendation } from '../model/smartmatch/SmartMatchTypes';

@Component
export struct SmartMatchResultsView {
  @ObjectLink vm: DayPaletteViewModel;
  @Prop showHeader: boolean = true;

  private recommendationList(): SmartMatchRecommendation[] {
    return this.vm.getSmartMatchRecommendationsForActivePalette();
  }

  private getActivePrimaryHex(): string {
    const activePalette = this.vm.getActivePalette();
    if (activePalette !== undefined && activePalette.primaryProfile !== undefined) {
      return activePalette.primaryProfile.hex;
    }
    return this.vm.getHeroColorStrings()[0];
  }

  private isAppliedRecommendation(item: SmartMatchRecommendation): boolean {
    const colors: string[] = this.vm.getHeroColorStrings();
    return colors[0].toLowerCase() === this.getActivePrimaryHex().toLowerCase() &&
      colors[1].toLowerCase() === item.secondary.hex.toLowerCase() &&
      colors[2].toLowerCase() === item.accent.hex.toLowerCase();
  }

  build() {
    Column({ space: 12 }) {
      if (this.showHeader) {
        Column({ space: 4 }) {
          Text(this.vm.getUiStrings().smartMatchTitle)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
            .width('100%')
            .textAlign(TextAlign.Start)

          Text(this.vm.getUiStrings().smartMatchHint)
            .fontSize(11)
            .fontColor(DesignTokens.TEXT_MUTED)
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      if (this.recommendationList().length === 0) {
        Column({ space: 8 }) {
          Text(this.vm.getUiStrings().smartMatchEmpty)
            .fontSize(12)
            .fontColor(DesignTokens.TEXT_MUTED)
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(DesignTokens.SURFACE_CARD)
        .borderRadius(2)
        .border({ width: 1, color: DesignTokens.BORDER_COLOR })
      } else {
        ForEach(this.recommendationList(), (item: SmartMatchRecommendation, index: number) => {
          Column({ space: 10 }) {
            Row({ space: 8 }) {
              Text(`${this.vm.getUiStrings().smartMatchSource} ${item.sourcePaletteName}`)
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor(DesignTokens.TEXT_MAIN)
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(`#${index + 1}`)
                .fontSize(10)
                .fontColor(DesignTokens.TEXT_MUTED)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            Row() {
              Row()
                .layoutWeight(3)
                .height(10)
                .backgroundColor(this.getActivePrimaryHex())
              Row()
                .layoutWeight(2)
                .height(10)
                .backgroundColor(item.secondary.hex)
              Row()
                .layoutWeight(1)
                .height(10)
                .backgroundColor(item.accent.hex)
            }
            .width('100%')
            .borderRadius(2)
            .clip(true)

            Text(item.explanation)
              .fontSize(11)
              .fontColor(DesignTokens.TEXT_MUTED)
              .lineHeight(18)
              .width('100%')
              .textAlign(TextAlign.Start)

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Text(this.isAppliedRecommendation(item) ? this.vm.getUiStrings().smartMatchApplied : this.vm.getUiStrings().smartMatchApply)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isAppliedRecommendation(item) ? DesignTokens.TEXT_ON_INVERSE : DesignTokens.TEXT_MAIN)
            }
            .width('100%')
            .height(38)
            .backgroundColor(this.isAppliedRecommendation(item) ? DesignTokens.TEXT_MAIN : DesignTokens.SURFACE_CARD)
            .borderRadius(2)
            .border({ width: this.isAppliedRecommendation(item) ? 0 : 1, color: DesignTokens.BORDER_COLOR })
            .onClick(() => {
              const primaryHex: string = this.getActivePrimaryHex();
              this.vm.setFineTuneHex(primaryHex, item.secondary.hex, item.accent.hex);
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(DesignTokens.SURFACE_CARD)
          .borderRadius(2)
          .border({ width: 1, color: this.isAppliedRecommendation(item) ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR })
          .shadow({
            radius: this.isAppliedRecommendation(item) ? 12 : 6,
            color: this.isAppliedRecommendation(item) ? 'rgba(0, 0, 0, 0.04)' : 'rgba(0, 0, 0, 0.02)',
            offsetX: 0,
            offsetY: this.isAppliedRecommendation(item) ? 6 : 3
          })
        }, (item: SmartMatchRecommendation) => item.sourcePaletteId + '_' + item.secondary.id + '_' + item.accent.id + '_' + this.vm.currentLang)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}