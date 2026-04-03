import { MiniPreviewStyle } from '../model/MiniPreviewStyle';

@Component
export struct MiniPalettePreviewView {
  @Prop colors: string[] = ['#E8D8D3', '#C5B9B6', '#5D637A'];
  @Prop style: MiniPreviewStyle = MiniPreviewStyle.Capsule;
  @Prop previewWidth: number = 140;
  @Prop previewHeight: number = 36;
  @Prop reduceMotion: boolean = false;

  private static readonly HERO_BASE_SIZE: number = 320;

  private animDuration(): number {
    return this.reduceMotion ? 1 : 600;
  }

  private previewColors(): string[] {
    return this.colors.length >= 3 ? this.colors : ['#E8D8D3', '#C5B9B6', '#5D637A'];
  }

  private radius(): number {
    return this.style === MiniPreviewStyle.Capsule ? this.previewHeight / 2 : 6;
  }

  private heroScale(): number {
    return this.previewHeight / MiniPalettePreviewView.HERO_BASE_SIZE;
  }

  private heroScaled(value: number): number {
    return Math.max(1, Math.round(value * this.heroScale()));
  }

  private heroFrameWidth(): number {
    return this.heroScaled(MiniPalettePreviewView.HERO_BASE_SIZE);
  }

  private heroRadius(): number {
    return Math.max(2, this.heroScaled(16));
  }

  private heroShadowRadius(): number {
    return Math.max(4, this.heroScaled(24));
  }

  private heroShadowOffsetY(): number {
    return Math.max(2, this.heroScaled(12));
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
          .width(this.heroScaled(240))
          .height(this.heroScaled(260))
          .backgroundColor(this.previewColors()[0])
          .borderRadius(this.heroRadius())
          .rotate({ x: 0, y: 1, z: 0, angle: 5, centerX: '50%', centerY: '50%' })
          .shadow({
            radius: this.heroShadowRadius(),
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroShadowOffsetY()
          })
          .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
          .zIndex(1)

        Stack()
          .width(this.heroScaled(176))
          .height(this.heroScaled(180))
          .backgroundColor(this.previewColors()[1])
          .borderRadius(this.heroRadius())
          .margin({
            top: this.heroScaled(120),
            left: this.heroScaled(144)
          })
          .rotate({ x: 0, y: 1, z: 0, angle: -5, centerX: '50%', centerY: '50%' })
          .shadow({
            radius: this.heroShadowRadius(),
            color: 'rgba(0, 0, 0, 0.1)',
            offsetX: 0,
            offsetY: this.heroShadowOffsetY()
          })
          .animation({ duration: this.animDuration(), curve: Curve.EaseInOut })
          .zIndex(2)

        Stack()
          .width(this.heroScaled(112))
          .height(this.heroScaled(100))
          .backgroundColor(this.previewColors()[2])
          .borderRadius(this.heroRadius())
          .margin({
            top: this.heroScaled(220),
            left: this.heroScaled(48)
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