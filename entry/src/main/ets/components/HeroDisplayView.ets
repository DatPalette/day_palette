import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { AppLanguage } from '../model/AppLanguage';
import { LayoutConstants } from '../common/constants/LayoutConstants';

@Component
export struct HeroDisplayView {
  @ObjectLink vm: DayPaletteViewModel;

  private heroColors(): string[] {
    const p = this.vm.getActivePalette();
    if (p !== undefined && p.colors.length >= 3) {
      return p.colors;
    }
    return [DesignTokens.DEFAULT_MAIN, DesignTokens.DEFAULT_SEC, DesignTokens.DEFAULT_ACC];
  }

  private moodLines(): string[] {
    const occ = this.vm.getActiveOccasion();
    const raw = occ !== undefined ? occ.title : '';
    return raw.split('<br>');
  }

  build() {
    Column() {
      Column({ space: 0 }) {
        ForEach(this.moodLines(), (line: string, index: number) => {
          Text(line)
            .fontSize(42)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
            .lineHeight(46.2)
            .fontFamily(this.vm.currentLang === AppLanguage.ZH ? 'HarmonyOS Serif' : 'serif')
            .fontStyle(this.vm.currentLang === AppLanguage.ZH ? FontStyle.Normal : FontStyle.Italic)
            .animation({ duration: 300, curve: Curve.EaseInOut })
        }, (line: string, index: number) => `mood-${index}-${this.vm.currentLang}`)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 30 })

      Stack({ alignContent: Alignment.TopStart }) {
        Stack()
          .width('75%')
          .height(260)
          .backgroundColor(this.heroColors()[0])
          .borderRadius(2)
          .margin({ top: 0, left: 0 })
          .rotate({
            x: 0,
            y: 1,
            z: 0,
            angle: 5,
            centerX: '50%',
            centerY: '50%'
          })
          .shadow({
            radius: 40,
            color: 'rgba(0, 0, 0, 0.08)',
            offsetX: 0,
            offsetY: 20
          })
          .animation({ duration: 600, curve: Curve.EaseInOut })
          .zIndex(1)

        Stack()
          .width('55%')
          .height(180)
          .backgroundColor(this.heroColors()[1])
          .borderRadius(2)
          .margin({ top: 120, left: '45%' })
          .rotate({
            x: 0,
            y: 1,
            z: 0,
            angle: -5,
            centerX: '50%',
            centerY: '50%'
          })
          .shadow({
            radius: 40,
            color: 'rgba(0, 0, 0, 0.08)',
            offsetX: 0,
            offsetY: 20
          })
          .animation({ duration: 600, curve: Curve.EaseInOut })
          .zIndex(2)

        Stack()
          .width('35%')
          .height(100)
          .backgroundColor(this.heroColors()[2])
          .borderRadius(2)
          .margin({ top: 220, left: '15%' })
          .shadow({
            radius: 40,
            color: 'rgba(0, 0, 0, 0.08)',
            offsetX: 0,
            offsetY: 20
          })
          .animation({ duration: 600, curve: Curve.EaseInOut })
          .zIndex(3)
      }
      .width('100%')
      .height(320)

      Row() {
        Column({ space: 4 }) {
          Text(this.vm.getUiStrings().main)
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MUTED)
            .letterSpacing(1.5)
            .textCase(this.vm.currentLang === AppLanguage.ZH ? TextCase.Normal : TextCase.UpperCase)
          Text(this.heroColors()[0].toUpperCase())
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          Text(this.vm.getUiStrings().sec)
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MUTED)
            .letterSpacing(1.5)
            .textCase(this.vm.currentLang === AppLanguage.ZH ? TextCase.Normal : TextCase.UpperCase)
          Text(this.heroColors()[1].toUpperCase())
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          Text(this.vm.getUiStrings().acc)
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MUTED)
            .letterSpacing(1.5)
            .textCase(this.vm.currentLang === AppLanguage.ZH ? TextCase.Normal : TextCase.UpperCase)
          Text(this.heroColors()[2].toUpperCase())
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 })
      .animation({ duration: 600, curve: Curve.EaseInOut })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: LayoutConstants.HERO_TOP_PADDING_VP,
      left: LayoutConstants.PAGE_HORIZONTAL_VP,
      right: LayoutConstants.PAGE_HORIZONTAL_VP
    })
  }
}
