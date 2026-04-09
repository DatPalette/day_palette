import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { AppLanguage } from '../model/AppLanguage';
import type { Occasion } from '../model/Occasion';
import { LayoutConstants } from '../common/constants/LayoutConstants';

@Component
export struct OccasionSelectorView {
  @ObjectLink vm: DayPaletteViewModel;
  topMarginVp: number = LayoutConstants.OCCASION_TOP_MARGIN_VP;
  bottomMarginVp: number = LayoutConstants.OCCASION_BOTTOM_MARGIN_VP;

  build() {
    Column() {
      Text(this.vm.getUiStrings().storyTitle)
        .fontSize(10)
        .fontColor(DesignTokens.TEXT_MUTED)
        .letterSpacing(2.25)
        .textCase(TextCase.UpperCase)
        .margin({ bottom: 16 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Scroll() {
        Row({ space: 24 }) {
          ForEach(this.vm.getOccasions(), (occ: Occasion) => {
            Column({ space: 4 }) {
              Text(occ.label)
                .fontSize(20)
                .fontColor(occ.id === this.vm.activeOccasionId ? DesignTokens.TEXT_MAIN : DesignTokens.TEXT_MUTED)
                .fontFamily(this.vm.currentLang === AppLanguage.ZH ? 'HarmonyOS Serif' : 'serif')
                .onClick(() => {
                  this.vm.selectOccasion(occ.id);
                })
              if (occ.id === this.vm.activeOccasionId) {
                Row()
                  .width(4)
                  .height(4)
                  .borderRadius(2)
                  .backgroundColor(DesignTokens.TEXT_MAIN)
              } else {
                Row()
                  .width(4)
                  .height(4)
                  .opacity(0)
              }
            }
            .alignItems(HorizontalAlign.Center)
          }, (occ: Occasion) => occ.id + '_' + this.vm.currentLang)
        }
        .padding({ bottom: 10 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: LayoutConstants.PAGE_HORIZONTAL_VP, right: LayoutConstants.PAGE_HORIZONTAL_VP })
    .margin({ top: this.topMarginVp, bottom: this.bottomMarginVp })
  }
}
