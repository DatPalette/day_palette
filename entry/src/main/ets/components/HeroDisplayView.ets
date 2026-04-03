import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { AppLanguage } from '../model/AppLanguage';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import {
  HERO_ACCENT_CARD_LAYOUT,
  HERO_MAIN_CARD_LAYOUT,
  HERO_PALETTE_BASE_SIZE,
  HERO_SECONDARY_CARD_LAYOUT,
  scaleHeroPaletteLayout,
  scaleHeroPaletteValue
} from '../common/constants/HeroPaletteLayout';

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

  private heroCompositionHeight(): number {
    return HERO_PALETTE_BASE_SIZE;
  }

  private heroMainCard() {
    return scaleHeroPaletteLayout(HERO_MAIN_CARD_LAYOUT, this.heroCompositionHeight());
  }

  private heroSecondaryCard() {
    return scaleHeroPaletteLayout(HERO_SECONDARY_CARD_LAYOUT, this.heroCompositionHeight());
  }

  private heroAccentCard() {
    return scaleHeroPaletteLayout(HERO_ACCENT_CARD_LAYOUT, this.heroCompositionHeight());
  }

  private heroCardRadius(): number {
    return scaleHeroPaletteValue(16, this.heroCompositionHeight());
  }

  private heroShadowRadius(): number {
    return scaleHeroPaletteValue(24, this.heroCompositionHeight());
  }

  private heroShadowOffsetY(): number {
    return scaleHeroPaletteValue(12, this.heroCompositionHeight());
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
          .width(this.heroMainCard().width)
          .height(this.heroMainCard().height)
          .backgroundColor(this.heroColors()[0])
          .borderRadius(this.heroCardRadius())
          .margin({ top: this.heroMainCard().top, left: this.heroMainCard().left })
          .rotate({
            x: 0,
            y: 1,
            z: 0,
            angle: this.heroMainCard().angle,
            centerX: '50%',
            centerY: '50%'
          })
          .shadow({
            radius: this.heroShadowRadius(),
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroShadowOffsetY()
          })
          .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
          .zIndex(1)

        Stack()
          .width(this.heroSecondaryCard().width)
          .height(this.heroSecondaryCard().height)
          .backgroundColor(this.heroColors()[1])
          .borderRadius(this.heroCardRadius())
          .margin({ top: this.heroSecondaryCard().top, left: this.heroSecondaryCard().left })
          .rotate({
            x: 0,
            y: 1,
            z: 0,
            angle: this.heroSecondaryCard().angle,
            centerX: '50%',
            centerY: '50%'
          })
          .shadow({
            radius: this.heroShadowRadius(),
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroShadowOffsetY()
          })
          .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
          .zIndex(2)

        Stack()
          .width(this.heroAccentCard().width)
          .height(this.heroAccentCard().height)
          .backgroundColor(this.heroColors()[2])
          .borderRadius(this.heroCardRadius())
          .margin({ top: this.heroAccentCard().top, left: this.heroAccentCard().left })
          .shadow({
            radius: this.heroShadowRadius(),
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroShadowOffsetY()
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
      .height(this.heroCompositionHeight())

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
