import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { AppLanguage } from '../model/AppLanguage';
import { LayoutConstants } from '../common/constants/LayoutConstants';

@Component
export struct HeroDisplayView {
  @ObjectLink vm: DayPaletteViewModel;

  private heroDur(): number {
    return this.vm.reduceMotion ? 1 : 600;
  }

  private heroColors(): string[] {
    return this.vm.getHeroColorStrings();
  }

  private heroTitleLines(): string[] {
    return this.vm.getHeroTitleLines();
  }

  build() {
    Column() {
      Column({ space: 0 }) {
        ForEach(this.heroTitleLines(), (line: string, index: number) => {
          Text(line)
            .fontSize(42)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
            .lineHeight(46.2)
            .fontFamily(this.vm.currentLang === AppLanguage.ZH ? 'HarmonyOS Serif' : 'serif')
            .fontStyle(this.vm.currentLang === AppLanguage.ZH ? FontStyle.Normal : FontStyle.Italic)
            .animation({ duration: this.vm.reduceMotion ? 1 : 300, curve: Curve.EaseInOut })
        }, (line: string, index: number) => `hero-title-${index}-${this.vm.activePaletteId}-${this.vm.currentLang}`)
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
          .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
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
          .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
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
          .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
          .zIndex(3)

        if (this.vm.noiseOverlay) {
          Column()
            .width('100%')
            .height(320)
            .backgroundColor('rgba(30,30,30,0.06)')
            .blendMode(BlendMode.MULTIPLY)
            .zIndex(10)
        }
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
      .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
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
