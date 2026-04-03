import { MiniPreviewStyle } from '../model/MiniPreviewStyle';
import { DesignTokens } from '../common/constants/DesignTokens';
import {
  type HeroPaletteCardLayout,
  HERO_ACCENT_CARD_LAYOUT,
  HERO_MAIN_CARD_LAYOUT,
  HERO_PALETTE_BASE_SIZE,
  HERO_SECONDARY_CARD_LAYOUT,
  scaleHeroPaletteLayout,
  scaleHeroPaletteValue
} from '../common/constants/HeroPaletteLayout';

const FALLBACK_PREVIEW_COLORS: string[] = [
  DesignTokens.DEFAULT_MAIN,
  DesignTokens.DEFAULT_SEC,
  DesignTokens.DEFAULT_ACC
];

interface HeroPreviewMetrics {
  frameWidth: number;
  radius: number;
  shadowRadius: number;
  shadowOffsetY: number;
  mainCard: HeroPaletteCardLayout;
  secondaryCard: HeroPaletteCardLayout;
  accentCard: HeroPaletteCardLayout;
}

@Component
export struct MiniPalettePreviewView {
  @Prop colors: string[] = FALLBACK_PREVIEW_COLORS;
  @Prop style: MiniPreviewStyle = MiniPreviewStyle.Capsule;
  @Prop previewWidth: number = 140;
  @Watch('onPreviewHeightChanged') @Prop previewHeight: number = 36;
  @Prop reduceMotion: boolean = false;
  @State private heroMetrics: HeroPreviewMetrics = this.buildHeroPreviewMetrics(36);

  private animDuration(): number {
    return this.reduceMotion ? 1 : 600;
  }

  private previewColors(): string[] {
    return this.colors.length >= 3 ? this.colors : FALLBACK_PREVIEW_COLORS;
  }

  private radius(): number {
    return this.style === MiniPreviewStyle.Capsule ? Math.min(14, this.previewHeight / 2) : 6;
  }

  private buildHeroPreviewMetrics(targetHeight: number): HeroPreviewMetrics {
    return {
      frameWidth: scaleHeroPaletteValue(HERO_PALETTE_BASE_SIZE, targetHeight),
      radius: Math.max(2, scaleHeroPaletteValue(16, targetHeight)),
      shadowRadius: Math.max(4, scaleHeroPaletteValue(24, targetHeight)),
      shadowOffsetY: Math.max(2, scaleHeroPaletteValue(12, targetHeight)),
      mainCard: scaleHeroPaletteLayout(HERO_MAIN_CARD_LAYOUT, targetHeight),
      secondaryCard: scaleHeroPaletteLayout(HERO_SECONDARY_CARD_LAYOUT, targetHeight),
      accentCard: scaleHeroPaletteLayout(HERO_ACCENT_CARD_LAYOUT, targetHeight)
    };
  }

  private onPreviewHeightChanged(): void {
    this.heroMetrics = this.buildHeroPreviewMetrics(this.previewHeight);
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
      radius: 10,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: 3
    })
  }

  @Builder
  private HeroPreview() {
    Row() {
      Stack({ alignContent: Alignment.TopStart }) {
        Stack()
          .width(this.heroMetrics.mainCard.width)
          .height(this.heroMetrics.mainCard.height)
          .backgroundColor(this.previewColors()[0])
          .borderRadius(this.heroMetrics.radius)
          .rotate({ x: 0, y: 1, z: 0, angle: this.heroMetrics.mainCard.angle, centerX: '50%', centerY: '50%' })
          .shadow({
            radius: this.heroMetrics.shadowRadius,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroMetrics.shadowOffsetY
          })
          .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
          .zIndex(1)

        Stack()
          .width(this.heroMetrics.secondaryCard.width)
          .height(this.heroMetrics.secondaryCard.height)
          .backgroundColor(this.previewColors()[1])
          .borderRadius(this.heroMetrics.radius)
          .margin({
            top: this.heroMetrics.secondaryCard.top,
            left: this.heroMetrics.secondaryCard.left
          })
          .rotate({ x: 0, y: 1, z: 0, angle: this.heroMetrics.secondaryCard.angle, centerX: '50%', centerY: '50%' })
          .shadow({
            radius: this.heroMetrics.shadowRadius,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroMetrics.shadowOffsetY
          })
          .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
          .zIndex(2)

        Stack()
          .width(this.heroMetrics.accentCard.width)
          .height(this.heroMetrics.accentCard.height)
          .backgroundColor(this.previewColors()[2])
          .borderRadius(this.heroMetrics.radius)
          .margin({
            top: this.heroMetrics.accentCard.top,
            left: this.heroMetrics.accentCard.left
          })
          .shadow({
            radius: this.heroMetrics.shadowRadius,
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroMetrics.shadowOffsetY
          })
          .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
          .zIndex(3)
      }
      .width(this.heroMetrics.frameWidth)
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

  aboutToAppear(): void {
    this.onPreviewHeightChanged();
  }
}