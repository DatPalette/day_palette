import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { AppLanguage } from '../model/AppLanguage';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import {
  HERO_ACCENT_CARD_LAYOUT,
  HERO_MAIN_CARD_LAYOUT,
  HERO_PALETTE_BASE_SIZE,
  HERO_SECONDARY_CARD_LAYOUT
} from '../common/constants/HeroPaletteLayout';

const HERO_DISPLAY_COMPOSITION_HEIGHT: number = HERO_PALETTE_BASE_SIZE;
const HERO_DISPLAY_MAIN_CARD = HERO_MAIN_CARD_LAYOUT;
const HERO_DISPLAY_SECONDARY_CARD = HERO_SECONDARY_CARD_LAYOUT;
const HERO_DISPLAY_ACCENT_CARD = HERO_ACCENT_CARD_LAYOUT;
const HERO_DISPLAY_CARD_RADIUS: number = 16;
const HERO_DISPLAY_SHADOW_RADIUS: number = 24;
const HERO_DISPLAY_SHADOW_OFFSET_Y: number = 12;

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
          .width(HERO_DISPLAY_MAIN_CARD.width)
          .height(HERO_DISPLAY_MAIN_CARD.height)
          .backgroundColor(this.heroColors()[0])
          .borderRadius(HERO_DISPLAY_CARD_RADIUS)
          .margin({ top: HERO_DISPLAY_MAIN_CARD.top, left: HERO_DISPLAY_MAIN_CARD.left })
          .rotate({
            x: 0,
            y: 1,
            z: 0,
            angle: HERO_DISPLAY_MAIN_CARD.angle,
            centerX: '50%',
            centerY: '50%'
          })
          .shadow({
            radius: HERO_DISPLAY_SHADOW_RADIUS,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: HERO_DISPLAY_SHADOW_OFFSET_Y
          })
          .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
          .zIndex(1)

        Stack()
          .width(HERO_DISPLAY_SECONDARY_CARD.width)
          .height(HERO_DISPLAY_SECONDARY_CARD.height)
          .backgroundColor(this.heroColors()[1])
          .borderRadius(HERO_DISPLAY_CARD_RADIUS)
          .margin({ top: HERO_DISPLAY_SECONDARY_CARD.top, left: HERO_DISPLAY_SECONDARY_CARD.left })
          .rotate({
            x: 0,
            y: 1,
            z: 0,
            angle: HERO_DISPLAY_SECONDARY_CARD.angle,
            centerX: '50%',
            centerY: '50%'
          })
          .shadow({
            radius: HERO_DISPLAY_SHADOW_RADIUS,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: HERO_DISPLAY_SHADOW_OFFSET_Y
          })
          .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
          .zIndex(2)

        Stack()
          .width(HERO_DISPLAY_ACCENT_CARD.width)
          .height(HERO_DISPLAY_ACCENT_CARD.height)
          .backgroundColor(this.heroColors()[2])
          .borderRadius(HERO_DISPLAY_CARD_RADIUS)
          .margin({ top: HERO_DISPLAY_ACCENT_CARD.top, left: HERO_DISPLAY_ACCENT_CARD.left })
          .shadow({
            radius: HERO_DISPLAY_SHADOW_RADIUS,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: HERO_DISPLAY_SHADOW_OFFSET_Y
          })
          .animation({ duration: this.heroDur(), curve: Curve.EaseInOut })
          .zIndex(3)

        if (this.vm.noiseOverlay) {
          Column()
            .width('100%')
            .height(HERO_DISPLAY_COMPOSITION_HEIGHT)
            .backgroundColor('rgba(30,30,30,0.06)')
            .blendMode(BlendMode.MULTIPLY)
            .zIndex(10)
        }
      }
      .width('100%')
      .height(HERO_DISPLAY_COMPOSITION_HEIGHT)

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
