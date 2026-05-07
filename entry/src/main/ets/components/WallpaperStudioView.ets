import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import { hexToRgb888 } from '../export/HexColor';
import type { WallpaperSnapshot } from '../export/WallpaperActions';
import { wallpaperSnapshotFromVm } from '../export/WallpaperActions';
import {
  WALLPAPER_STYLE_BLOCKS_ID,
  WALLPAPER_STYLE_COLLAGE_ID,
  WALLPAPER_STYLE_GRADIENT_ID,
  WALLPAPER_STYLE_IDS,
  WALLPAPER_STYLE_MIST_ID,
  WALLPAPER_VARIANT_IDS
} from '../export/WallpaperImageExporter';

type WallpaperPreviewMode = 'clean' | 'lockscreen';

interface PreviewStripe {
  id: string;
  color: string;
}

@Component
export struct WallpaperStudioView {
  @ObjectLink vm: DayPaletteViewModel;
  @Prop deviceWidthPx: number = 1080;
  @Prop deviceHeightPx: number = 2340;
  @Prop bottomGestureInsetVp: number = 0;
  onRequestClose: () => void = () => {
  };
  onTapSave: (snap: WallpaperSnapshot) => void = (_snap: WallpaperSnapshot) => {
  };
  @State private selectedStyleId: string = WALLPAPER_STYLE_BLOCKS_ID;
  @State private selectedVariantIndex: number = 0;
  @State private previewMode: WallpaperPreviewMode = 'clean';

  private colors(): string[] {
    return this.vm.getHeroColorStrings();
  }

  private previewColor(index: number): string {
    const palette: string[] = this.colors();
    return palette[index] ?? palette[palette.length - 1] ?? '#000000';
  }

  private wallpaperAspectRatio(): number {
    const safeWidth: number = this.deviceWidthPx > 0 ? this.deviceWidthPx : 1080;
    const safeHeight: number = this.deviceHeightPx > 0 ? this.deviceHeightPx : 2340;
    return safeHeight / safeWidth;
  }

  private previewWidthVp(): number {
    return 152;
  }

  private previewHeightVp(): number {
    const desiredHeight: number = Math.round(this.previewWidthVp() * this.wallpaperAspectRatio());
    return Math.min(312, Math.max(228, desiredHeight));
  }

  private currentVariantId(): string {
    return WALLPAPER_VARIANT_IDS[this.selectedVariantIndex] ?? WALLPAPER_VARIANT_IDS[0];
  }

  private nextVariant(): void {
    this.selectedVariantIndex = (this.selectedVariantIndex + 1) % WALLPAPER_VARIANT_IDS.length;
  }

  private styleTitle(styleId: string): string {
    if (styleId === WALLPAPER_STYLE_COLLAGE_ID) {
      return this.vm.getUiStrings().wallpaperStyleCollage;
    }
    if (styleId === WALLPAPER_STYLE_GRADIENT_ID) {
      return this.vm.getUiStrings().wallpaperStyleGradient;
    }
    if (styleId === WALLPAPER_STYLE_MIST_ID) {
      return this.vm.getUiStrings().wallpaperStyleMist;
    }
    return this.vm.getUiStrings().wallpaperStyleBlocks;
  }

  private styleMood(styleId: string): string {
    if (styleId === WALLPAPER_STYLE_COLLAGE_ID) {
      return this.vm.getUiStrings().wallpaperStyleCollageMood;
    }
    if (styleId === WALLPAPER_STYLE_GRADIENT_ID) {
      return this.vm.getUiStrings().wallpaperStyleGradientMood;
    }
    if (styleId === WALLPAPER_STYLE_MIST_ID) {
      return this.vm.getUiStrings().wallpaperStyleMistMood;
    }
    return this.vm.getUiStrings().wallpaperStyleBlocksMood;
  }

  private toHexChannel(value: number): string {
    return Math.max(0, Math.min(255, Math.round(value))).toString(16).padStart(2, '0');
  }

  private rgbToHex(r: number, g: number, b: number): string {
    return `#${this.toHexChannel(r)}${this.toHexChannel(g)}${this.toHexChannel(b)}`.toUpperCase();
  }

  private lerpHex(startHex: string, endHex: string, t: number): string {
    const start: number[] = hexToRgb888(startHex) ?? [232, 216, 211];
    const end: number[] = hexToRgb888(endHex) ?? [197, 185, 182];
    return this.rgbToHex(
      start[0] + (end[0] - start[0]) * t,
      start[1] + (end[1] - start[1]) * t,
      start[2] + (end[2] - start[2]) * t
    );
  }

  private gradientStripes(): PreviewStripe[] {
    const palette: string[] = this.colors();
    const stripes: PreviewStripe[] = [];
    for (let i: number = 0; i < 18; i++) {
      const ratio: number = i / 17;
      const color: string = ratio <= 0.5
        ? this.lerpHex(palette[0], palette[1], ratio / 0.5)
        : this.lerpHex(palette[1], palette[2], (ratio - 0.5) / 0.5);
      stripes.push({ id: `stripe_${i}`, color: color });
    }
    return stripes;
  }

  private contentTopInsetVp(): number {
    return 42 + LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP + 20;
  }

  private contentBottomInsetVp(): number {
    return 16 + this.bottomGestureInsetVp;
  }

  private selectedPreviewToken(): string {
    return `${this.selectedStyleId}|${this.currentVariantId()}|${this.previewMode}`;
  }

  private handleSave(): void {
    const snapshot: WallpaperSnapshot = wallpaperSnapshotFromVm(
      this.vm,
      this.selectedStyleId,
      this.currentVariantId(),
      this.deviceWidthPx,
      this.deviceHeightPx
    );
    this.onTapSave(snapshot);
  }

  @Builder
  private lockscreenOverlay() {
    Column({ space: 2 }) {
      Text('09:41')
        .fontSize(28)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(255, 255, 255, 0.92)')

      Text(this.vm.getTopBarDateLabel())
        .fontSize(11)
        .fontColor('rgba(255, 255, 255, 0.76)')
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private blocksPreview(widthVp: number, heightVp: number, variantId: string) {
    if (variantId === 'variant_b') {
      Column({ space: 0 }) {
        Row()
          .layoutWeight(3)
          .width('100%')
          .backgroundColor(this.previewColor(0))
        Row()
          .layoutWeight(2)
          .width('100%')
          .backgroundColor(this.previewColor(1))
        Row()
          .layoutWeight(1)
          .width('100%')
          .backgroundColor(this.previewColor(2))
      }
      .width(widthVp)
      .height(heightVp)
      .borderRadius(18)
      .clip(true)
    } else if (variantId === 'variant_c') {
      Stack() {
        Column()
          .width(widthVp)
          .height(heightVp)
          .backgroundColor(this.previewColor(0))

        Row() {
          Column()
            .layoutWeight(5)
            .height('100%')
            .backgroundColor(this.previewColor(1))
          Column()
            .layoutWeight(3)
            .height('100%')
            .backgroundColor(this.previewColor(2))
        }
        .width(widthVp)
        .height(heightVp * 0.28)
        .position({ top: heightVp * 0.72, left: 0 })
      }
      .width(widthVp)
      .height(heightVp)
      .borderRadius(18)
      .clip(true)
    } else {
      Row({ space: 0 }) {
        Column()
          .layoutWeight(3)
          .height('100%')
          .backgroundColor(this.previewColor(0))
        Column()
          .layoutWeight(2)
          .height('100%')
          .backgroundColor(this.previewColor(1))
        Column()
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(this.previewColor(2))
      }
      .width(widthVp)
      .height(heightVp)
      .borderRadius(18)
      .clip(true)
    }
  }

  @Builder
  private collagePreview(widthVp: number, heightVp: number) {
    Stack() {
      Column()
        .width(widthVp)
        .height(heightVp)
        .backgroundColor(this.previewColor(0))
        .borderRadius(18)

      Column()
        .width(widthVp * 0.56)
        .height(heightVp * 0.24)
        .backgroundColor(this.previewColor(1))
        .borderRadius(16)
        .position({ top: heightVp * 0.18, left: widthVp * 0.28 })
        .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.05)', offsetY: 6 })

      Column()
        .width(widthVp * 0.38)
        .height(heightVp * 0.14)
        .backgroundColor(this.previewColor(2))
        .borderRadius(14)
        .position({ top: heightVp * 0.6, left: widthVp * 0.16 })
        .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.05)', offsetY: 6 })
    }
    .width(widthVp)
    .height(heightVp)
  }

  @Builder
  private gradientPreview(widthVp: number, heightVp: number, variantId: string) {
    if (variantId === 'variant_b') {
      Row({ space: 0 }) {
        ForEach(this.gradientStripes(), (stripe: PreviewStripe) => {
          Column()
            .width(widthVp / 18)
            .height(heightVp)
            .backgroundColor(stripe.color)
        }, (stripe: PreviewStripe) => stripe.id)
      }
      .width(widthVp)
      .height(heightVp)
      .borderRadius(18)
      .clip(true)
    } else {
      Column({ space: 0 }) {
        ForEach(this.gradientStripes(), (stripe: PreviewStripe) => {
          Row()
            .width(widthVp)
            .height(heightVp / 18)
            .backgroundColor(stripe.color)
            .translate({ x: variantId === 'variant_c' ? 4 : 0, y: 0 })
        }, (stripe: PreviewStripe) => stripe.id)
      }
      .width(widthVp)
      .height(heightVp)
      .borderRadius(18)
      .clip(true)
    }
  }

  @Builder
  private mistPreview(widthVp: number, heightVp: number, variantId: string) {
    Stack() {
      Column()
        .width(widthVp)
        .height(heightVp)
        .backgroundColor(this.previewColor(0))
        .borderRadius(18)

      Column()
        .width(widthVp * 0.78)
        .height(widthVp * 0.78)
        .backgroundColor(this.previewColor(1))
        .borderRadius(widthVp)
        .opacity(0.46)
        .position({ top: variantId === 'variant_b' ? heightVp * 0.12 : heightVp * 0.2, left: widthVp * 0.06 })

      Column()
        .width(widthVp * 0.86)
        .height(widthVp * 0.86)
        .backgroundColor(this.previewColor(2))
        .borderRadius(widthVp)
        .opacity(0.36)
        .position({ top: variantId === 'variant_c' ? heightVp * 0.22 : heightVp * 0.48, left: widthVp * 0.18 })
    }
    .width(widthVp)
    .height(heightVp)
  }

  @Builder
  private stylePreview(widthVp: number, heightVp: number, styleId: string, variantId: string, showLockscreenOverlay: boolean) {
    Stack() {
      if (styleId === WALLPAPER_STYLE_COLLAGE_ID) {
        this.collagePreview(widthVp, heightVp)
      } else if (styleId === WALLPAPER_STYLE_GRADIENT_ID) {
        this.gradientPreview(widthVp, heightVp, variantId)
      } else if (styleId === WALLPAPER_STYLE_MIST_ID) {
        this.mistPreview(widthVp, heightVp, variantId)
      } else {
        this.blocksPreview(widthVp, heightVp, variantId)
      }

      if (showLockscreenOverlay) {
        Column() {
          this.lockscreenOverlay()
        }
        .position({ top: 20, left: 18 })
      }
    }
    .width(widthVp)
    .height(heightVp)
  }

  @Builder
  private heroPreview() {
    this.stylePreview(
      this.previewWidthVp(),
      this.previewHeightVp(),
      this.selectedStyleId,
      this.currentVariantId(),
      this.previewMode === 'lockscreen'
    )
  }

  @Builder
  private styleMiniPreview(styleId: string) {
    this.stylePreview(64, 102, styleId, WALLPAPER_VARIANT_IDS[0], false)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Blank()
          .height(this.contentTopInsetVp())

        Column({ space: 14 }) {
          Column() {
            ForEach([this.selectedPreviewToken()], (token: string) => {
              this.heroPreview()
            }, (token: string) => token)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Row({ space: 10 }) {
            Button(this.vm.getUiStrings().wallpaperPreviewClean)
              .layoutWeight(1)
              .height(38)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.previewMode === 'clean' ? DesignTokens.TEXT_ON_INVERSE : DesignTokens.TEXT_MAIN)
              .backgroundColor(this.previewMode === 'clean' ? DesignTokens.TEXT_MAIN : Color.White)
              .borderRadius(999)
              .border({ width: 1, color: this.previewMode === 'clean' ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR })
              .onClick(() => {
                this.previewMode = 'clean';
              })

            Button(this.vm.getUiStrings().wallpaperPreviewLockscreen)
              .layoutWeight(1)
              .height(38)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.previewMode === 'lockscreen' ? DesignTokens.TEXT_ON_INVERSE : DesignTokens.TEXT_MAIN)
              .backgroundColor(this.previewMode === 'lockscreen' ? DesignTokens.TEXT_MAIN : Color.White)
              .borderRadius(999)
              .border({ width: 1, color: this.previewMode === 'lockscreen' ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR })
              .onClick(() => {
                this.previewMode = 'lockscreen';
              })
          }
          .width('100%')

          Column({ space: 4 }) {
            Text(this.styleTitle(this.selectedStyleId))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(DesignTokens.TEXT_MAIN)
              .width('100%')

            Text(this.styleMood(this.selectedStyleId))
              .fontSize(11)
              .fontColor(DesignTokens.TEXT_MUTED)
              .lineHeight(18)
              .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Row() {
              Blank()
                .layoutWeight(1)
              Button(this.vm.getUiStrings().wallpaperVariantSwitch)
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor(DesignTokens.TEXT_MAIN)
                .height(34)
                .backgroundColor(Color.White)
                .borderRadius(999)
                .border({ width: 1, color: DesignTokens.BORDER_COLOR })
                .onClick(() => {
                  this.nextVariant();
                })
            }
            .width('100%')

            Scroll() {
              Row({ space: 12 }) {
                ForEach(WALLPAPER_STYLE_IDS, (styleId: string) => {
                  Column({ space: 10 }) {
                    Column() {
                      this.styleMiniPreview(styleId)
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Center)

                    Text(this.styleTitle(styleId))
                      .fontSize(11)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(DesignTokens.TEXT_MAIN)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                  }
                  .width(96)
                  .padding(10)
                  .backgroundColor(this.selectedStyleId === styleId ? '#fcfcfb' : Color.White)
                  .borderRadius(12)
                  .border({
                    width: 1,
                    color: this.selectedStyleId === styleId ? DesignTokens.BORDER_SELECTED : DesignTokens.BORDER_COLOR
                  })
                  .shadow({
                    radius: this.selectedStyleId === styleId ? 10 : 4,
                    color: this.selectedStyleId === styleId ? 'rgba(0, 0, 0, 0.04)' : 'rgba(0, 0, 0, 0.015)',
                    offsetY: this.selectedStyleId === styleId ? 6 : 2
                  })
                  .onClick(() => {
                    this.selectedStyleId = styleId;
                    this.selectedVariantIndex = 0;
                  })
                }, (styleId: string) => styleId)
              }
              .padding({ bottom: 4 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({
          left: LayoutConstants.PAGE_HORIZONTAL_VP,
          right: LayoutConstants.PAGE_HORIZONTAL_VP,
          top: 8,
          bottom: this.contentBottomInsetVp()
        })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)

      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('‹')
            .fontSize(28)
            .fontColor(DesignTokens.TEXT_MAIN)
            .fontWeight(FontWeight.Lighter)
        }
        .width(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
        .height(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.onRequestClose();
        })

        Text(this.vm.getUiStrings().wallpaperStudioTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button(this.vm.getUiStrings().wallpaperSave)
          .height(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
          .padding({ left: 12, right: 12 })
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_ON_INVERSE)
          .backgroundColor(DesignTokens.TEXT_MAIN)
          .borderRadius(999)
          .border({ width: 1, color: DesignTokens.TEXT_MAIN })
          .onClick(() => {
            this.handleSave();
          })
      }
      .width('100%')
      .padding({ top: 42, left: 8, right: LayoutConstants.PAGE_HORIZONTAL_VP, bottom: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor(DesignTokens.SURFACE_FROSTED)
      .backdropBlur(20)
      .borderWidth({ bottom: 1 })
      .borderColor(DesignTokens.BORDER_SUBTLE)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .position({ top: 0, left: 0 })
      .zIndex(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DesignTokens.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}