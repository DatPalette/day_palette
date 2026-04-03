import { MiniPreviewStyle } from '../model/MiniPreviewStyle';
import {
  type HeroPaletteCardLayout,
  HERO_ACCENT_CARD_LAYOUT,
  HERO_MAIN_CARD_LAYOUT,
  HERO_PALETTE_BASE_SIZE,
  HERO_SECONDARY_CARD_LAYOUT,
  scaleHeroPaletteLayout,
  scaleHeroPaletteValue
} from '../common/constants/HeroPaletteLayout';

@Component
export struct MiniPalettePreviewView {
  @Prop colors: string[] = ['#E8D8D3', '#C5B9B6', '#5D637A'];
  @Prop style: MiniPreviewStyle = MiniPreviewStyle.Capsule;
  @Prop previewWidth: number = 140;
  @Prop previewHeight: number = 36;
  @Prop reduceMotion: boolean = false;

  private animDuration(): number {
    return this.reduceMotion ? 1 : 600;
  }

  private previewColors(): string[] {
    return this.colors.length >= 3 ? this.colors : ['#E8D8D3', '#C5B9B6', '#5D637A'];
  }

  private radius(): number {
    return this.style === MiniPreviewStyle.Capsule ? this.previewHeight / 2 : 6;
  }

  private heroFrameWidth(): number {
    return scaleHeroPaletteValue(HERO_PALETTE_BASE_SIZE, this.previewHeight);
  }

  private heroRadius(): number {
    return Math.max(2, scaleHeroPaletteValue(16, this.previewHeight));
  }

  private heroShadowRadius(): number {
    return Math.max(4, scaleHeroPaletteValue(24, this.previewHeight));
  }

  private heroShadowOffsetY(): number {
    return Math.max(2, scaleHeroPaletteValue(12, this.previewHeight));
  }

  private mainCardLayout(): HeroPaletteCardLayout {
    return scaleHeroPaletteLayout(HERO_MAIN_CARD_LAYOUT, this.previewHeight);
  }

  private secondaryCardLayout(): HeroPaletteCardLayout {
    return scaleHeroPaletteLayout(HERO_SECONDARY_CARD_LAYOUT, this.previewHeight);
  }

  private accentCardLayout(): HeroPaletteCardLayout {
    return scaleHeroPaletteLayout(HERO_ACCENT_CARD_LAYOUT, this.previewHeight);
  }

  @Builder
  private CapsulePreview() {
    Row() {
      Row()
        .layoutWeight(3)
        .height('100%')
        .backgroundColor(this.previewColors()[0])
        .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
      Row()
        .layoutWeight(2)
        .height('100%')
        .backgroundColor(this.previewColors()[1])
        .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
      Row()
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(this.previewColors()[2])
        .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
    }
    .width(this.previewWidth)
    .height(this.previewHeight)
    .borderRadius(this.radius())
    .clip(true)
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 6
    })
  }

  @Builder
  private HeroPreview() {
    Row() {
      Stack({ alignContent: Alignment.TopStart }) {
        Stack()
          .width(this.mainCardLayout().width)
          .height(this.mainCardLayout().height)
          .backgroundColor(this.previewColors()[0])
          .borderRadius(this.heroRadius())
          .rotate({ x: 0, y: 1, z: 0, angle: this.mainCardLayout().angle, centerX: '50%', centerY: '50%' })
          .shadow({
            radius: this.heroShadowRadius(),
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroShadowOffsetY()
          })
          .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
          .zIndex(1)

        Stack()
          .width(this.secondaryCardLayout().width)
          .height(this.secondaryCardLayout().height)
          .backgroundColor(this.previewColors()[1])
          .borderRadius(this.heroRadius())
          .margin({
            top: this.secondaryCardLayout().top,
            left: this.secondaryCardLayout().left
          })
          .rotate({ x: 0, y: 1, z: 0, angle: this.secondaryCardLayout().angle, centerX: '50%', centerY: '50%' })
          .shadow({
            radius: this.heroShadowRadius(),
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroShadowOffsetY()
          })
          .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
          .zIndex(2)

        Stack()
          .width(this.accentCardLayout().width)
          .height(this.accentCardLayout().height)
          .backgroundColor(this.previewColors()[2])
          .borderRadius(this.heroRadius())
          .margin({
            top: this.accentCardLayout().top,
            left: this.accentCardLayout().left
          })
          .shadow({
            radius: this.heroShadowRadius(),
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroShadowOffsetY()
          })
          .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
          .zIndex(3)
      }
      .width(this.heroFrameWidth())
      .height(this.previewHeight)
    }
    .width(this.previewWidth)
    .height(this.previewHeight)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    if (this.style === MiniPreviewStyle.Hero) {
      this.HeroPreview();
    } else {
      this.CapsulePreview();
    }
  }
}